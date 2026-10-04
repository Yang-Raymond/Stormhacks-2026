import { z } from "zod";

export const languages = ["python", "javascript", "typescript", "java", "c", "cpp"] as const;
export type Language = (typeof languages)[number];
export const languageSchema = z.enum(languages);
export const preferredLanguagesSchema = z.array(languageSchema).length(1, "Select exactly one preferred language");

export const languageLabels: Record<Language, string> = {
  python: "Python 3",
  javascript: "JavaScript",
  typescript: "TypeScript",
  java: "Java",
  c: "C",
  cpp: "C++",
};

/** Language-neutral types a problem signature may use; the runner maps them to each language (runner/languages). */
export const valueTypes = ["int", "double", "bool", "string", "int[]", "double[]", "bool[]", "string[]", "int[][]"] as const;
export type ValueType = (typeof valueTypes)[number];
export type Signature = { params: { name: string; type: ValueType }[]; returns: ValueType };

export const signatureSchema = z.object({
  params: z.array(z.object({ name: z.string().regex(/^[A-Za-z_][A-Za-z0-9_]*$/), type: z.enum(valueTypes) })).min(1).max(8),
  returns: z.enum(valueTypes),
});

/** How the solution must be shaped in each language so the runner's test driver can call it. */
export const solutionShape: Record<Language, string> = {
  python: "A single top-level function named entry_point (snake_case), Python 3, standard library only.",
  javascript: "A top-level `function entry_point(...)` declaration (camelCase), plain modern JavaScript, no imports.",
  typescript:
    "A top-level `function entry_point(...)` declaration (camelCase) with type annotations, no imports. Use only syntax that type-stripping handles: no enums or namespaces.",
  java:
    "A class named `Solution` (not public is fine) with a public instance method named entry_point (camelCase). Java 17, java.util imports allowed, no main method, no package declaration.",
  c: [
    "A top-level C11 function named entry_point (camelCase) using LeetCode's C conventions:",
    "string -> char*, bool -> bool (stdbool), T[] -> two params (T* name, int nameSize), string[] -> (char** name, int nameSize),",
    "int[][] -> three params (int** name, int nameSize, int* nameColSize). If the function returns an array, append a final",
    "`int* returnSize` param, set *returnSize, and return a malloc'd array. The return type must not be int[][].",
    "The standard headers (stdio, stdlib, string, stdbool, math, limits, ctype, stdint) are already included; do not write main.",
  ].join(" "),
  cpp:
    "A class named `Solution` with a public method named entry_point (camelCase), LeetCode style: T[] -> vector<T>&, int[][] -> vector<vector<int>>&, string -> string. `#include <bits/stdc++.h>` and `using namespace std;` are already provided; no main.",
};
