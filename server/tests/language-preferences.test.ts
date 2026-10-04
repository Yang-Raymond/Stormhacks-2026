import assert from "node:assert/strict";
import test from "node:test";
import { languages, preferredLanguagesSchema } from "../src/languages.js";
import { LANGUAGES, preferredLanguage } from "../../front_end/lib/languages.ts";

test("each dropdown option saves and resolves to the same runnable language", () => {
  assert.deepEqual(LANGUAGES.map((language) => language.id), [...languages]);
  for (const language of LANGUAGES) {
    const saved = preferredLanguagesSchema.parse([language.id]);
    assert.equal(preferredLanguage(saved), language.id);
    assert.equal(preferredLanguage([language.label]), language.id);
  }
});

test("profile and onboarding reject empty, multiple, and unsupported selections", () => {
  for (const value of [[], ["python", "java"], ["python", "python"], ["Go"], ["Other"], "python", null]) {
    assert.equal(preferredLanguagesSchema.safeParse(value).success, false);
  }
});

test("legacy preferences resolve to the first supported language", () => {
  assert.equal(preferredLanguage(["TypeScript", "Python"]), "typescript");
  assert.equal(preferredLanguage(["JavaScript"]), "javascript");
  assert.equal(preferredLanguage(["Python"]), "python");
  assert.equal(preferredLanguage(["Go", "JavaScript"]), "javascript");
  assert.equal(preferredLanguage(["Other"]), "python");
  assert.equal(preferredLanguage(), "python");
});
