import { config } from "./config.js";
import { HttpError } from "./errors.js";
import { generateText } from "./gemini.js";
import { languageLabels, type Language } from "./languages.js";
import { snowflakeEnabled, snowflakeQuery } from "./snowflake.js";

export type FailingCase = { args: unknown[]; expected: unknown; actual?: string; error?: string };

type HintInput = {
  title: string;
  description: string;
  language: Language;
  code: string;
  referenceCode: string;
  failing?: FailingCase;
};

const MAX_HINT_CHARS = 800;
const clip = (s: string, n: number) => (s.length > n ? s.slice(0, n) + "\n…" : s);

function prompt(h: HintInput) {
  const failing = h.failing
    ? [
        "A failing test case:",
        `  input: ${JSON.stringify(h.failing.args)}`,
        `  expected: ${JSON.stringify(h.failing.expected)}`,
        `  got: ${h.failing.error ?? h.failing.actual ?? "(no output)"}`,
      ].join("\n")
    : "The student hasn't run the tests yet.";
  return `You are a patient debugging tutor on a practice site where students fix buggy ${languageLabels[h.language]} code.

Problem: ${h.title}
${clip(h.description, 3000)}

The student's current code:
\`\`\`
${clip(h.code, 6000)}
\`\`\`

${failing}

For your eyes only (NEVER quote or reveal it), a correct reference solution:
\`\`\`
${clip(h.referenceCode, 6000)}
\`\`\`

Write ONE hint of at most 80 words that nudges the student toward the next bug in THEIR code. Point to the part of the
code or the case they should think about, or ask a guiding question. Do not write any code, do not give the corrected
line or expression, and do not state the full fix. Plain text only, no preamble.`;
}

export type HintProvider = "cortex" | "gemini";

// Set once Snowflake says Cortex is off for this account (e.g. trial accounts), so later hints skip straight to
// Gemini instead of paying for a failed round trip. Resets when the server restarts with new credentials.
let cortexUnavailable = false;

async function fromCortex(text: string) {
  const rows = await snowflakeQuery<{ hint: string }>("SELECT SNOWFLAKE.CORTEX.COMPLETE(?, ?) AS HINT", [
    config.SNOWFLAKE_CORTEX_MODEL,
    text,
  ]);
  return rows[0]?.hint ?? "";
}

/**
 * A single nudge (not the answer) about the student's code. Uses Snowflake Cortex when the account allows it and
 * falls back to Gemini otherwise, so hints work on any setup.
 */
export async function generateHint(input: HintInput): Promise<{ hint: string; provider: HintProvider }> {
  const text = prompt(input);
  let hint = "";
  let provider: HintProvider = "gemini";
  if (snowflakeEnabled && !cortexUnavailable) {
    try {
      hint = await fromCortex(text);
      provider = "cortex";
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      if (/not available for trial accounts|not available in your region/i.test(message)) cortexUnavailable = true;
      console.warn("Cortex hint failed, falling back to Gemini:", message);
    }
  }
  if (!hint.trim()) {
    hint = await generateText(text);
    provider = "gemini";
  }
  hint = hint.trim();
  if (!hint) throw new HttpError(502, "The model returned an empty hint, please try again");
  // Belt and braces: drop any code block the model emits despite the instructions.
  return { hint: clip(hint.replace(/```[\s\S]*?```/g, "").trim(), MAX_HINT_CHARS), provider };
}
