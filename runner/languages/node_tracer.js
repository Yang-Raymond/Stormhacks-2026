"use strict";
// Tracer for JavaScript and TypeScript solutions, driving V8 through an in-process inspector session.
// Produces the same report as tracer.py (trace and eval modes); see languages/__init__.py for the trace protocol.
// usage: node node_tracer.js <solution file> <entry point> <javascript|typescript>
const fs = require("fs");
const inspector = require("inspector");
const util = require("util");
const vm = require("vm");
const { firstLines, load } = require("./node_common.js");

const [, , file, entry, language] = process.argv;
const DRIVER = "ladybug-driver.js";
const MAX_STEPS = 2000;
const MAX_REPR = 200;
const MAX_VARS = 50;
const MAX_FRAMES = 20;
const MAX_STDOUT = 20_000;
const MAX_REPORT_CHARS = 3_000_000;

const input = fs.readFileSync(0, "utf8");
const split = input.indexOf("\n");
const nonce = input.slice(0, split);
const spec = JSON.parse(input.slice(split + 1));
const evalSpec = spec.eval ?? null;
const conditions = new Map((spec.conditions ?? []).map((c) => [c.line, c.expr]));

let stdout = "";
const write = (...args) => {
  if (stdout.length < MAX_STDOUT) stdout = (stdout + util.format(...args) + "\n").slice(0, MAX_STDOUT);
};
const userConsole = { log: write, info: write, warn: write, error: write, debug: write };

function finish(payload) {
  if (!("stdout" in payload)) payload.stdout = stdout;
  fs.writeSync(1, "\n" + nonce + JSON.stringify(payload) + nonce + "\n");
  // Exit straight away: the solution may still be mid-loop (step limit) and must not resume.
  process.exit(0);
}

const clip = (text) => (text.length <= MAX_REPR ? text : text.slice(0, MAX_REPR) + "...");

/** Runs inside the solution's context (via callFunctionOn), so it must not reference anything from this file. */
function format(value) {
  const seen = new Set();
  const limit = 220;
  function go(v) {
    if (typeof v === "string") return JSON.stringify(v);
    if (typeof v === "bigint") return v + "n";
    if (typeof v === "function") return `[Function ${v.name || "(anonymous)"}]`;
    if (v === null || typeof v !== "object") return String(v);
    if (seen.has(v)) return "[Circular]";
    seen.add(v);
    const tag = Object.prototype.toString.call(v).slice(8, -1);
    const items = (list) => {
      let out = "";
      for (const item of list) {
        if (out.length > limit) return out + ", ...";
        out += (out ? ", " : "") + item();
      }
      return out;
    };
    if (Array.isArray(v) || ArrayBuffer.isView(v)) return `[${items(Array.from(v, (x) => () => go(x)))}]`;
    if (tag === "Map") return `Map(${v.size}) {${items(Array.from(v, ([k, x]) => () => `${go(k)} => ${go(x)}`))}}`;
    if (tag === "Set") return `Set(${v.size}) {${items(Array.from(v, (x) => () => go(x)))}}`;
    if (tag === "Error") return `${v.name}: ${v.message}`;
    const name = v.constructor && v.constructor.name !== "Object" ? v.constructor.name + " " : "";
    return `${name}{${items(Object.keys(v).map((k) => () => `${k}: ${go(v[k])}`))}}`;
  }
  return go(value);
}
const FORMAT_FN = `function () { return (${format})(this); }`;

const session = new inspector.Session();
session.connect();
// Call frames don't carry the url of vm scripts, so remember which script id is which file.
const scriptUrls = new Map();
session.on("Debugger.scriptParsed", ({ params }) => scriptUrls.set(params.scriptId, params.url));
const urlOf = (frame) => scriptUrls.get(frame.location.scriptId);

// In-process sessions answer synchronously, which keeps the paused handler a plain loop body.
function post(method, params = {}) {
  let result;
  let error;
  session.post(method, params, (err, res) => {
    error = err;
    result = res;
  });
  if (error) throw error;
  return result;
}

function show(remote) {
  if (remote.objectId && remote.type !== "function") {
    try {
      return clip(post("Runtime.callFunctionOn", { objectId: remote.objectId, functionDeclaration: FORMAT_FN, returnByValue: true }).result.value);
    } catch {
      return clip(remote.description ?? remote.type);
    }
  }
  if (remote.type === "string") return clip(JSON.stringify(remote.value));
  if (remote.type === "undefined") return "undefined";
  return clip(remote.unserializableValue ?? remote.description ?? String(remote.value));
}

function describeException(remote) {
  return String(remote?.description ?? remote?.value ?? "Error").split("\n")[0].slice(0, 2000);
}

function locals(frame) {
  const shown = {};
  // Innermost block scopes first, so a shadowing variable wins, then the function's own locals.
  for (const scope of frame.scopeChain) {
    if (scope.type !== "block" && scope.type !== "local") continue;
    for (const prop of post("Runtime.getProperties", { objectId: scope.object.objectId, ownProperties: true }).result) {
      if (Object.keys(shown).length >= MAX_VARS) return shown;
      if (prop.name in shown || prop.name === "this" || !prop.value || prop.value.type === "function") continue;
      shown[prop.name] = show(prop.value);
    }
  }
  return shown;
}

function evaluate(frame, expression) {
  const { result, exceptionDetails } = post("Debugger.evaluateOnCallFrame", { callFrameId: frame.callFrameId, expression });
  if (exceptionDetails) return { error: describeException(exceptionDetails.exception ?? { value: exceptionDetails.text }) };
  return { value: show(result) };
}

post("Debugger.enable");

let loaded;
try {
  loaded = load(file, entry, language, userConsole);
} catch (error) {
  finish({ steps: [], error: firstLines(error) });
}
const { context, originalLine } = loaded;
const lineOf = (frame) => originalLine(frame.location.lineNumber);

const steps = [];
let budget = MAX_REPORT_CHARS;

function record(params, frames) {
  const top = frames[0];
  const index = steps.length;
  if (evalSpec && index === evalSpec.step) {
    if (evalSpec.frame >= frames.length) finish({ error: "frame no longer exists at this step" });
    const target = frames[evalSpec.frame];
    finish({ values: evalSpec.expressions.map((e) => evaluate(target, e)) });
  }

  const line = lineOf(top);
  const step = { line, event: "line", depth: frames.length, out: stdout.length };
  if (params.reason === "exception") {
    step.event = "exception";
    step.exception = describeException(params.data);
  } else if (top.returnValue) {
    step.event = "return";
    step.value = show(top.returnValue);
  } else if (conditions.has(line)) {
    const outcome = evaluate(top, conditions.get(line));
    // A condition that throws still pauses, as in most debuggers, so the mistake is visible.
    step.cond = "error" in outcome ? true : !["false", "0", "null", "undefined", "NaN", '""', "-0"].includes(outcome.value);
    if ("error" in outcome) step.condError = outcome.error;
  }
  if (!evalSpec) {
    step.frames = frames.slice(0, MAX_FRAMES).map((f) => ({ name: f.functionName || "(anonymous)", line: lineOf(f), locals: locals(f) }));
    budget -= JSON.stringify(step).length;
    if (budget < 0) finish({ steps, truncated: true });
  }
  steps.push(step);
  if (steps.length >= MAX_STEPS && !evalSpec) finish({ steps, truncated: true });
}

session.on("Debugger.paused", ({ params }) => {
  const frames = params.callFrames.filter((f) => urlOf(f) === file);
  const top = params.callFrames[0];
  if (urlOf(top) === file) {
    record(params, frames);
    post("Debugger.stepInto");
  } else if (frames.length) {
    // Inside our console shim or similar: get back to the solution.
    post("Debugger.stepOut");
  } else if (urlOf(top) === DRIVER) {
    post("Debugger.stepInto");
  } else {
    post("Debugger.resume");
  }
});

// Only now, so loading the solution doesn't pause on exceptions it throws and catches.
post("Debugger.setPauseOnExceptions", { state: "all" });

const outcome = {};
try {
  context.__args = JSON.stringify(spec.args);
  const result = vm.runInContext("debugger; __entry(...JSON.parse(__args));", context, { filename: DRIVER });
  outcome.result = clip(format(result));
} catch (error) {
  outcome.error = `${(error && error.name) || "Error"}: ${(error && error.message) || error}`.slice(0, 2000);
}
post("Debugger.disable");

if (evalSpec) finish({ error: "the program finished before reaching this step" });
finish({ steps, truncated: false, ...outcome });
