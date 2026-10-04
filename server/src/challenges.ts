import { Router } from "express";
import { z } from "zod";
import { recordEvent } from "./activity.js";
import { requireAuth } from "./auth.js";
import { pool } from "./db.js";
import { HttpError } from "./errors.js";
import type { Difficulty } from "./gemini.js";
import { generateVerifiedProblem, generationLimiter, insertProblem } from "./generation.js";
import { languageSchema } from "./languages.js";

export const challengeKinds = ["daily", "weekly"] as const;
export type ChallengeKind = (typeof challengeKinds)[number];

const DAY_MS = 86_400_000;
const periodDays: Record<ChallengeKind, number> = { daily: 1, weekly: 7 };

/** The UTC date ("YYYY-MM-DD") a period starts on: today for daily, this week's Monday for weekly. */
export function periodKey(kind: ChallengeKind, now = new Date()) {
  const today = Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate());
  const daysSinceMonday = (now.getUTCDay() + 6) % 7;
  const start = kind === "daily" ? today : today - daysSinceMonday * DAY_MS;
  return new Date(start).toISOString().slice(0, 10);
}

export function periodEndsAt(kind: ChallengeKind, key: string) {
  return new Date(Date.parse(`${key}T00:00:00Z`) + periodDays[kind] * DAY_MS);
}

/** Unsolved challenges disappear when their period ends; deleting the problem cascades drafts and submissions. */
async function deleteExpiredUnsolved(userId: string) {
  await pool.query(
    `DELETE FROM problems p USING challenges c
     WHERE c.problem_id = p.id AND c.user_id = $1
       AND c.period_start + CASE c.kind WHEN 'daily' THEN 1 ELSE 7 END <= (now() AT TIME ZONE 'UTC')::date
       AND NOT EXISTS (SELECT 1 FROM submissions s WHERE s.problem_id = p.id AND s.user_id = $1 AND s.passed)`,
    [userId],
  );
}

type ChallengeRow = {
  kind: ChallengeKind;
  period_start: string;
  problem_id: string;
  title: string;
  difficulty: Difficulty;
  language: string;
  solved: boolean;
};

const summarize = (r: ChallengeRow) => ({
  kind: r.kind,
  periodStart: r.period_start,
  problemId: r.problem_id,
  title: r.title,
  difficulty: r.difficulty,
  language: r.language,
  solved: r.solved,
});

// Starts in progress, keyed by user/kind/period: generation takes ~30s, so a double click must not start two.
const starting = new Set<string>();

export const challengesRouter = Router();

challengesRouter.get("/", requireAuth, async (req, res) => {
  const userId = req.session.userId!;
  await deleteExpiredUnsolved(userId);
  const { rows } = await pool.query<ChallengeRow>(
    `SELECT c.kind, to_char(c.period_start, 'YYYY-MM-DD') AS period_start, p.id AS problem_id, p.title,
            p.difficulty, p.language,
            EXISTS (SELECT 1 FROM submissions s WHERE s.problem_id = p.id AND s.user_id = c.user_id AND s.passed) AS solved
     FROM challenges c JOIN problems p ON p.id = c.problem_id
     WHERE c.user_id = $1
     ORDER BY c.period_start DESC, c.kind`,
    [userId],
  );
  const now = new Date();
  const current = (kind: ChallengeKind) => {
    const key = periodKey(kind, now);
    const row = rows.find((r) => r.kind === kind && r.period_start === key);
    return {
      kind,
      periodStart: key,
      endsAt: periodEndsAt(kind, key).toISOString(),
      starting: starting.has(`${userId}:${kind}:${key}`),
      challenge: row ? summarize(row) : null,
    };
  };
  res.json({
    daily: current("daily"),
    weekly: current("weekly"),
    history: rows.filter((r) => r.solved && r.period_start !== periodKey(r.kind, now)).map(summarize),
  });
});

challengesRouter.post("/:kind/start", requireAuth, generationLimiter, async (req, res) => {
  const { kind } = z.object({ kind: z.enum(challengeKinds) }).parse(req.params);
  const { language } = z.object({ language: languageSchema }).parse(req.body);
  const userId = req.session.userId!;
  const key = periodKey(kind);
  const lock = `${userId}:${kind}:${key}`;

  const existing = await pool.query("SELECT 1 FROM challenges WHERE user_id = $1 AND kind = $2 AND period_start = $3", [
    userId,
    kind,
    key,
  ]);
  if (existing.rowCount) throw new HttpError(409, `You've already started this ${kind} challenge`);
  if (starting.has(lock)) throw new HttpError(409, `Your ${kind} challenge is already being generated`);

  starting.add(lock);
  try {
    const difficulty: Difficulty = kind === "weekly" ? "hard" : Math.random() < 0.5 ? "easy" : "medium";
    const problem = await generateVerifiedProblem(difficulty, language);
    // Use the period at completion, so a start just before midnight doesn't produce an already-expired challenge.
    const finalKey = periodKey(kind);
    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      const problemId = await insertProblem(client, problem, difficulty, userId, true);
      const inserted = await client.query(
        `INSERT INTO challenges (user_id, kind, period_start, problem_id) VALUES ($1, $2, $3, $4)
         ON CONFLICT (user_id, kind, period_start) DO NOTHING`,
        [userId, kind, finalKey, problemId],
      );
      if (!inserted.rowCount) {
        await client.query("ROLLBACK");
        throw new HttpError(409, `You've already started this ${kind} challenge`);
      }
      await client.query("COMMIT");
      recordEvent({ userId, kind: "challenge_start", problemId, language, difficulty });
      res.status(201).json({ id: problemId });
    } catch (err) {
      await client.query("ROLLBACK").catch(() => {});
      throw err;
    } finally {
      client.release();
    }
  } finally {
    starting.delete(lock);
  }
});
