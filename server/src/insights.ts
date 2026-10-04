import { Router } from "express";
import { config } from "./config.js";
import { snowflakeEnabled, snowflakeQuery } from "./snowflake.js";

/** Site-wide analytics computed in the Snowflake warehouse (fed by analyticsSync.ts). */
const CACHE_MS = 10 * 60_000;

type Rate = { submits: number; accepted: number };

async function compute() {
  const [totals, byLanguage, byDifficulty, hardest, byHour] = await Promise.all([
    snowflakeQuery<{ events: number; users: number; submits: number; accepted: number; hints: number; debugs: number }>(
      `SELECT COUNT(*) AS EVENTS, COUNT(DISTINCT USER_HASH) AS USERS, COUNT_IF(KIND = 'submit') AS SUBMITS,
              COUNT_IF(KIND = 'submit' AND PASSED) AS ACCEPTED, COUNT_IF(KIND = 'hint') AS HINTS,
              COUNT_IF(KIND = 'debug') AS DEBUGS
       FROM EVENTS`,
    ),
    snowflakeQuery<Rate & { language: string }>(
      `SELECT LANGUAGE, COUNT_IF(KIND = 'submit') AS SUBMITS, COUNT_IF(KIND = 'submit' AND PASSED) AS ACCEPTED
       FROM EVENTS WHERE LANGUAGE IS NOT NULL
       GROUP BY LANGUAGE HAVING SUBMITS > 0 ORDER BY SUBMITS DESC`,
    ),
    snowflakeQuery<Rate & { difficulty: string }>(
      `SELECT DIFFICULTY, COUNT_IF(KIND = 'submit') AS SUBMITS, COUNT_IF(KIND = 'submit' AND PASSED) AS ACCEPTED
       FROM EVENTS WHERE DIFFICULTY IS NOT NULL
       GROUP BY DIFFICULTY HAVING SUBMITS > 0`,
    ),
    snowflakeQuery<Rate & { problem_id: number; title: string; difficulty: string; language: string }>(
      `SELECT PROBLEM_ID, ANY_VALUE(PROBLEM_TITLE) AS TITLE, ANY_VALUE(DIFFICULTY) AS DIFFICULTY,
              ANY_VALUE(LANGUAGE) AS LANGUAGE, COUNT_IF(KIND = 'submit') AS SUBMITS,
              COUNT_IF(KIND = 'submit' AND PASSED) AS ACCEPTED
       FROM EVENTS WHERE PROBLEM_ID IS NOT NULL AND NOT COALESCE(IS_CHALLENGE, FALSE)
       GROUP BY PROBLEM_ID HAVING SUBMITS >= 2
       ORDER BY DIV0(ACCEPTED, SUBMITS) ASC, SUBMITS DESC LIMIT 8`,
    ),
    snowflakeQuery<{ hour: number; events: number }>(
      `SELECT HOUR(CONVERT_TIMEZONE('UTC', AT)) AS HOUR, COUNT(*) AS EVENTS FROM EVENTS GROUP BY 1 ORDER BY 1`,
    ),
  ]);
  return {
    configured: true as const,
    generatedAt: new Date().toISOString(),
    model: config.SNOWFLAKE_CORTEX_MODEL,
    totals: totals[0],
    byLanguage,
    byDifficulty,
    hardest,
    byHour,
  };
}

let cache: { at: number; data: Awaited<ReturnType<typeof compute>> } | null = null;
let inflight: Promise<Awaited<ReturnType<typeof compute>>> | null = null;

export const insightsRouter = Router();

insightsRouter.get("/", async (_req, res) => {
  if (!snowflakeEnabled) return void res.json({ configured: false });
  if (!cache || Date.now() - cache.at > CACHE_MS) {
    inflight ??= compute().finally(() => (inflight = null));
    cache = { at: Date.now(), data: await inflight };
  }
  res.json(cache.data);
});

/** Which optional integrations are configured, so the UI can hide what isn't available. */
export const featuresRouter = Router();

featuresRouter.get("/", (_req, res) => {
  res.json({ hints: snowflakeEnabled, insights: snowflakeEnabled });
});
