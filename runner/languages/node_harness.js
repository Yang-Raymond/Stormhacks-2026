"use strict";
// Driver for JavaScript and TypeScript solutions; see languages/__init__.py for the protocol.
// usage: node node_harness.js <solution file> <entry point> <javascript|typescript>
const fs = require("fs");
const vm = require("vm");

const [, , file, entry, language] = process.argv;
const input = fs.readFileSync(0, "utf8");
const split = input.indexOf("\n");
const nonce = input.slice(0, split);
const tests = JSON.parse(input.slice(split + 1));

function report(payload) {
  process.stdout.write("\n" + nonce + JSON.stringify(payload) + nonce + "\n");
}

function firstLines(error, n = 6) {
  return String((error && error.stack) || error).split("\n").slice(0, n).join("\n");
}

function load() {
  let source = fs.readFileSync(file, "utf8");
  if (language === "typescript") {
    const ts = require("/opt/typescript/lib/typescript.js");
    const out = ts.transpileModule(source, {
      fileName: file,
      reportDiagnostics: true,
      compilerOptions: { target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.CommonJS },
    });
    const errors = (out.diagnostics || []).filter((d) => d.category === ts.DiagnosticCategory.Error);
    if (errors.length) {
      throw new Error(
        errors
          .map((d) => {
            const where = d.file && d.start !== undefined ? d.file.getLineAndCharacterOfPosition(d.start) : null;
            const message = ts.flattenDiagnosticMessageText(d.messageText, "\n");
            return where ? `${file}:${where.line + 1}:${where.character + 1} - ${message}` : message;
          })
          .join("\n"),
      );
    }
    source = out.outputText;
  }

  // Run in a fresh context, and build arguments inside it, so `instanceof Array` etc. behave normally.
  const module = { exports: {} };
  const context = vm.createContext({ module, exports: module.exports, console });
  vm.runInContext(
    `${source}\n;globalThis.__entry = typeof ${entry} === "function" ? ${entry} : module.exports[${JSON.stringify(entry)}];`,
    context,
    { filename: file },
  );
  if (typeof context.__entry !== "function") throw new Error(`Function ${entry} is not defined`);
  return context;
}

const toJson = (_key, value) =>
  ArrayBuffer.isView(value)
    ? Array.from(value)
    : value instanceof Set
      ? [...value]
      : value instanceof Map
        ? Object.fromEntries(value)
        : typeof value === "bigint"
          ? Number(value)
          : value;

let context;
try {
  context = load();
} catch (error) {
  report({ error: firstLines(error) });
  process.exit(0);
}

const results = tests.map((args) => {
  try {
    context.__args = JSON.stringify(args);
    const value = vm.runInContext("__entry(...JSON.parse(__args))", context);
    const text = JSON.stringify(value, toJson);
    return { value: text === undefined ? null : JSON.parse(text) };
  } catch (error) {
    return { error: `${(error && error.name) || "Error"}: ${(error && error.message) || error}`.slice(0, 500) };
  }
});
report(results);
