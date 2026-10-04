"use strict";
// Driver for JavaScript and TypeScript solutions; see languages/__init__.py for the protocol.
// usage: node node_harness.js <solution file> <entry point> <javascript|typescript>
const fs = require("fs");
const vm = require("vm");
const { firstLines, load } = require("./node_common.js");

const [, , file, entry, language] = process.argv;
const input = fs.readFileSync(0, "utf8");
const split = input.indexOf("\n");
const nonce = input.slice(0, split);
const tests = JSON.parse(input.slice(split + 1));

function report(payload) {
  process.stdout.write("\n" + nonce + JSON.stringify(payload) + nonce + "\n");
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
  ({ context } = load(file, entry, language, console));
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
