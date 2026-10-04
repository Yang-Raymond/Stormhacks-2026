"use strict";
// Loading shared by the JavaScript/TypeScript test driver and tracer.
const fs = require("fs");
const vm = require("vm");

function firstLines(error, n = 6) {
  return String((error && error.stack) || error).split("\n").slice(0, n).join("\n");
}

const BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/** For each generated line (0-based), the original line its first mapping points at; from a v3 source map. */
function generatedToOriginalLines(sourceMap) {
  const lines = [];
  let original = 0;
  for (const group of JSON.parse(sourceMap).mappings.split(";")) {
    let mapped = null;
    for (const segment of group.split(",").filter(Boolean)) {
      const fields = [];
      let value = 0;
      let shift = 0;
      for (const ch of segment) {
        const digit = BASE64.indexOf(ch);
        value += (digit & 31) << shift;
        if (digit & 32) {
          shift += 5;
        } else {
          fields.push(value & 1 ? -(value >> 1) : value >> 1);
          value = 0;
          shift = 0;
        }
      }
      if (fields.length >= 4) {
        original += fields[2];
        if (mapped === null) mapped = original;
      }
    }
    lines.push(mapped);
  }
  return lines;
}

function transpile(file, source) {
  const ts = require("/opt/typescript/lib/typescript.js");
  const out = ts.transpileModule(source, {
    fileName: file,
    reportDiagnostics: true,
    compilerOptions: { target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.CommonJS, sourceMap: true },
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
  // Drop the trailing sourceMappingURL comment so the code's lines are exactly the mapped ones.
  return { code: out.outputText.replace(/\n\/\/# sourceMappingURL=.*\s*$/, "\n"), lines: generatedToOriginalLines(out.sourceMapText) };
}

/**
 * Evaluates the solution in a fresh context (so `instanceof Array` etc. behave normally) and exposes the entry
 * point as `__entry`. `originalLine` maps a 0-based line of the executed code to the 1-based line the user wrote.
 */
function load(file, entry, language, console) {
  let source = fs.readFileSync(file, "utf8");
  let lines = null;
  if (language === "typescript") ({ code: source, lines } = transpile(file, source));

  const module = { exports: {} };
  const context = vm.createContext({ module, exports: module.exports, console });
  vm.runInContext(source, context, { filename: file });
  vm.runInContext(
    `globalThis.__entry = typeof ${entry} === "function" ? ${entry} : module.exports[${JSON.stringify(entry)}];`,
    context,
  );
  if (typeof context.__entry !== "function") throw new Error(`Function ${entry} is not defined`);
  const originalLine = (line) => (lines ? (lines[line] ?? lines.slice(0, line).findLast((l) => l !== null) ?? 0) : line) + 1;
  return { context, originalLine };
}

module.exports = { firstLines, load };
