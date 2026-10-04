import { GoogleGenAI } from "@google/genai";
import { z } from "zod";
import { config } from "./config.js";
import { type Language, languageLabels, type Signature, signatureSchema, solutionShape, valueTypes } from "./languages.js";
import type { TestCase } from "./runner.js";

export const difficulties = ["easy", "medium", "hard"] as const;
export type Difficulty = (typeof difficulties)[number];

const ai = new GoogleGenAI({ apiKey: config.GEMINI_API_KEY });

// Gemini's structured output can't express "any JSON value", so test args/expected arrive as JSON strings.
const responseSchema = z.object({
  title: z.string().min(1).max(120),
  description: z.string().min(1).max(4000),
  entry_point: z.string().regex(/^[A-Za-z_][A-Za-z0-9_]*$/),
  fixed_code: z.string().min(1).max(10_000),
  buggy_code: z.string().min(1).max(10_000),
  signature: signatureSchema,
  tests: z
    .array(z.object({ args_json: z.string(), expected_json: z.string() }))
    .min(4)
    .max(20),
});

const bugGuidance: Record<Difficulty, string> = {
  easy: "Introduce exactly ONE obvious bug, such as an off-by-one error, wrong comparison operator, or wrong return value. The function should be short (5-15 lines).",
  medium:
    "Introduce ONE OR TWO logic bugs that only show up on some inputs, such as mishandled edge cases (empty input, duplicates, negatives) or incorrect loop bounds. The function should be 10-30 lines.",
  hard: "Introduce TWO OR THREE subtle bugs that interact, such as incorrect state updates in a loop, mutation of shared data, wrong recursion base case, or incorrect algorithmic invariant. The function should be 20-50 lines and implement a non-trivial algorithm.",
};

const prompt = (difficulty: Difficulty, language: Language) => `You are writing a "debug this code" exercise for a LeetCode-style practice site. The solution language is ${languageLabels[language]}.

1. Pick an algorithmic problem suitable for ${difficulty} difficulty. Vary the topic (arrays, strings, hash maps, two pointers, stacks, intervals, graphs, dynamic programming, ...). Inputs and output must be expressible with these types only: ${valueTypes.join(", ")} (no trees, linked lists, objects or nulls).
2. signature: the function's parameters in order, each with one of those types, and the return type. "int" values must fit in 32 bits; use "double" only for genuinely fractional values.
3. Write a correct solution in ${languageLabels[language]}. Shape: ${solutionShape[language]} Helper functions are allowed. No I/O, no reading input, no printing, no randomness.
4. Produce buggy_code: the SAME solution with bugs injected. ${bugGuidance[difficulty]} Keep the same function name and signature. Do NOT add comments that hint at the bugs.
5. Write 6-12 test cases. Each test has args_json: a JSON array with one value per signature parameter, in order, and expected_json: the JSON value the correct function returns. Values must match the signature types (int[][] is an array of int arrays). At least one test must fail on buggy_code, and the first two tests should be simple illustrative examples.
6. description: a clear LeetCode-style problem statement in Markdown with constraints and examples, written for ${languageLabels[language]} (use its naming for the function). Describe what the function SHOULD do; do not mention the bugs.`;

export type GeneratedProblem = {
  title: string;
  description: string;
  entryPoint: string;
  fixedCode: string;
  buggyCode: string;
  tests: TestCase[];
  language: Language;
  signature: Signature;
};

export async function generateProblem(difficulty: Difficulty, language: Language): Promise<GeneratedProblem> {
  const response = await ai.models.generateContent({
    model: config.GEMINI_MODEL,
    contents: prompt(difficulty, language),
    config: {
      responseMimeType: "application/json",
      responseJsonSchema: z.toJSONSchema(responseSchema, { target: "draft-7" }),
      temperature: 1,
    },
  });

  const data = responseSchema.parse(JSON.parse(response.text ?? ""));
  if (language === "c" && data.signature.returns === "int[][]") throw new Error("C solutions can't return int[][]");
  const tests = data.tests.map((t) => {
    const args: unknown = JSON.parse(t.args_json);
    if (!Array.isArray(args)) throw new Error("test args_json is not an array");
    if (args.length !== data.signature.params.length) throw new Error("test args don't match the signature");
    return { args, expected: JSON.parse(t.expected_json) as unknown };
  });

  return {
    title: data.title,
    description: data.description,
    entryPoint: data.entry_point,
    fixedCode: data.fixed_code,
    buggyCode: data.buggy_code,
    tests,
    language,
    signature: data.signature,
  };
}
