import { config } from "./config.js";
import { HttpError } from "./errors.js";
import { languageLabels, type Language } from "./languages.js";
import { snowflakeQuery } from "./snowflake.js";

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

/** Asks Snowflake Cortex for a single nudge (not the answer) about the student's code. */
export async function generateHint(input: HintInput): Promise<string> {
  const rows = await snowflakeQuery<{ hint: string }>("SELECT SNOWFLAKE.CORTEX.COMPLETE(?, ?) AS HINT", [
    config.SNOWFLAKE_CORTEX_MODEL,
    prompt(input),
  ]);
  const hint = rows[0]?.hint?.trim();
  if (!hint) throw new HttpError(502, "Cortex returned an empty hint, please try again");
  // Belt and braces: drop any code block the model emits despite the instructions.
  return clip(hint.replace(/```[\s\S]*?```/g, "").trim(), MAX_HINT_CHARS);
}
