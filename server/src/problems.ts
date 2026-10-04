import { Router, type Request } from "express";
import { rateLimit } from "express-rate-limit";
import { z } from "zod";
import { requireAuth } from "./auth.js";
import { type ChallengeKind, periodEndsAt } from "./challenges.js";
import { pool } from "./db.js";
import { HttpError } from "./errors.js";
import { difficulties } from "./gemini.js";
import { generateVerifiedProblem, generationLimiter, insertProblem } from "./generation.js";
import type { Language, Signature } from "./languages.js";
import { allPassed, evalAtStep, runTests, traceCode, type RunResult, type TestCase } from "./runner.js";

const idParam = z.object({ id: z.coerce.number().int().positive() });
const codeBody = z.object({ code: z.string().max(20_000) });
const expression = z.string().trim().min(1).max(200);
const debugBody = codeBody.extend({
  args: z.array(z.unknown()).max(20),
  conditions: z.array(z.object({ line: z.number().int().positive(), expr: expression })).max(50).default([]),
});
const evalBody = debugBody.extend({
  step: z.number().int().min(0),
  frame: z.number().int().min(0),
  expressions: z.array(expression).min(1).max(20),
});
const debugLimiter = rateLimit({ windowMs: 60_000, limit: 240, keyGenerator: (req) => req.session.userId! });

type ProblemRow = {
  id: string;
  title: string;
  description: string;
  difficulty: string;
  entry_point: string;
  buggy_code: string;
  tests: TestCase[];
  visible_test_count: number;
  language: Language;
  signature: Signature | null;
  solved: boolean;
  challenge_owner: string | null;
  challenge_kind: ChallengeKind | null;
  challenge_period: string | null;
};

type LoadedProblem = ProblemRow & { challenge: { kind: ChallengeKind; endsAt: string } | null };

/**
 * Loads a problem as seen by the current user. Challenge problems are personal: only their owner can see them,
 * and once the period ends without a passing submission they're gone (410 until the cleanup deletes them).
 */
async function loadProblem(req: Request): Promise<LoadedProblem> {
  const { id } = idParam.parse({ id: req.params.id });
  const userId = req.session.userId ?? null;
  const { rows } = await pool.query<ProblemRow>(
    `SELECT p.id, p.title, p.description, p.difficulty, p.entry_point, p.buggy_code, p.tests, p.visible_test_count,
            p.language, p.signature,
            EXISTS (SELECT 1 FROM submissions s WHERE s.problem_id = p.id AND s.user_id = $2 AND s.passed) AS solved,
            c.user_id AS challenge_owner, c.kind AS challenge_kind,
            to_char(c.period_start, 'YYYY-MM-DD') AS challenge_period
     FROM problems p LEFT JOIN challenges c ON c.problem_id = p.id
     WHERE p.id = $1`,
    [id, userId],
  );
  const row = rows[0];
  if (!row || (row.challenge_owner && row.challenge_owner !== userId)) throw new HttpError(404, "Problem not found");
  if (!row.challenge_kind || !row.challenge_period) return { ...row, challenge: null };
  const endsAt = periodEndsAt(row.challenge_kind, row.challenge_period);
  if (endsAt.getTime() <= Date.now() && !row.solved) {
    throw new HttpError(410, `This ${row.challenge_kind} challenge has expired. Start a new one from the problems page.`);
  }
  return { ...row, challenge: { kind: row.challenge_kind, endsAt: endsAt.toISOString() } };
}

function requirePython(p: LoadedProblem) {
  if (p.language !== "python") throw new HttpError(400, "The debugger currently supports Python only");
}

/**
 * Grades against every test. Visible tests are always shown in full; of the hidden tests only the
 * first failing one is revealed (LeetCode-style) so there's something to debug without leaking the whole set.
 */
function publicResults(run: RunResult, problem: ProblemRow) {
  const total = problem.tests.length;
  // A compile error or timeout yields no per-test results, so every test counts as failed.
  const results = problem.tests.map((t, i) => ({ ...t, ...(run.results[i] ?? { passed: false }) }));
  const failedHidden = results
    .map((r, i) => ({ ...r, testNumber: i + 1 }))
    .slice(problem.visible_test_count)
    .filter((r) => !r.passed);
  return {
    status: run.status,
    error: run.error,
    passed: allPassed(run, total),
    passedCount: results.filter((r) => r.passed).length,
    totalCount: total,
    visibleResults: results.slice(0, problem.visible_test_count),
    hiddenFailure: run.status === "ok" ? failedHidden[0] : undefined,
    hiddenFailureCount: failedHidden.length,
  };
}

function saveDraft(userId: string, problemId: string, code: string) {
  return pool.query(
    `INSERT INTO drafts (user_id, problem_id, code) VALUES ($1, $2, $3)
     ON CONFLICT (user_id, problem_id) DO UPDATE SET code = EXCLUDED.code, updated_at = now()`,
    [userId, problemId, code],
  );
}

async function gradeProblem(req: Request) {
  const p = await loadProblem(req);
  const { code } = codeBody.parse(req.body);
  // Whatever was run or submitted is the user's latest work, even if an autosave never landed.
  const [run] = await Promise.all([
    runTests(code, p.entry_point, p.tests, p.language, p.signature),
    saveDraft(req.session.userId!, p.id, code),
  ]);
  return { p, code, result: publicResults(run, p) };
}

export const problemsRouter = Router();

problemsRouter.get("/", async (req, res) => {
  const { rows } = await pool.query(
    `SELECT p.id, p.title, p.difficulty, p.language, p.created_at,
            EXISTS (SELECT 1 FROM submissions s
                    WHERE s.problem_id = p.id AND s.user_id = $1 AND s.passed) AS solved
     FROM problems p
     WHERE NOT p.is_challenge -- challenges are personal
     ORDER BY p.created_at DESC`,
    [req.session.userId ?? null],
  );
  res.json({ problems: rows });
});

// Practice problems stay Python; challenges choose their language (see challenges.ts).
problemsRouter.post("/generate", requireAuth, generationLimiter, async (req, res) => {
  const { difficulty } = z.object({ difficulty: z.enum(difficulties) }).parse(req.body);
  const problem = await generateVerifiedProblem(difficulty, "python");
  res.status(201).json({ id: await insertProblem(pool, problem, difficulty, req.session.userId!) });
});

problemsRouter.get("/:id", async (req, res) => {
  const p = await loadProblem(req);
  const { rows } = await pool.query<{ saved_code: string }>(
    "SELECT code AS saved_code FROM drafts WHERE problem_id = $1 AND user_id = $2",
    [p.id, req.session.userId ?? null],
  );
  // The same problem in other languages is a separate row sharing the title. Challenges are personal, so they have none.
  const { rows: variants } = p.challenge
    ? { rows: [{ id: p.id, language: p.language }] }
    : await pool.query<{ id: string; language: Language }>(
        `SELECT DISTINCT ON (p.language) p.id, p.language FROM problems p
         WHERE p.title = $1 AND NOT EXISTS (SELECT 1 FROM challenges c WHERE c.problem_id = p.id)
         ORDER BY p.language, p.id = $2 DESC, p.id`,
        [p.title, p.id],
      );
  res.json({
    problem: {
      solved: p.solved,
      savedCode: rows[0]?.saved_code ?? null,
      language: p.language,
      signature: p.signature,
      challenge: p.challenge,
      id: p.id,
      title: p.title,
      description: p.description,
      difficulty: p.difficulty,
      entryPoint: p.entry_point,
      buggyCode: p.buggy_code,
      examples: p.tests.slice(0, p.visible_test_count),
      totalTests: p.tests.length,
      variants,
    },
  });
});

problemsRouter.put("/:id/draft", requireAuth, async (req, res) => {
  const p = await loadProblem(req);
  const { code } = codeBody.parse(req.body);
  await saveDraft(req.session.userId!, p.id, code);
  res.status(204).end();
});

/** Resetting discards the draft, so the problem opens with the original buggy code again. */
problemsRouter.delete("/:id/draft", requireAuth, async (req, res) => {
  const { id } = idParam.parse(req.params);
  await pool.query("DELETE FROM drafts WHERE user_id = $1 AND problem_id = $2", [req.session.userId, id]);
  res.status(204).end();
});

// Run and Submit grade identically against every test; only Submit records the attempt.
problemsRouter.post("/:id/run", requireAuth, async (req, res) => {
  const { result } = await gradeProblem(req);
  res.json(result);
});

problemsRouter.post("/:id/submit", requireAuth, async (req, res) => {
  const { p, code, result } = await gradeProblem(req);
  await pool.query(
    `INSERT INTO submissions (user_id, problem_id, code, passed, passed_count, total_count, language)
     VALUES ($1, $2, $3, $4, $5, $6, $7)`,
    [req.session.userId, p.id, code, result.passed, result.passedCount, result.totalCount, p.language],
  );
  res.json(result);
});

// Debug args come from the client (an example, the revealed hidden failure, or custom input),
// so these endpoints never expose hidden test data.
problemsRouter.post("/:id/debug", requireAuth, debugLimiter, async (req, res) => {
  const p = await loadProblem(req);
  requirePython(p);
  const { code, args, conditions } = debugBody.parse(req.body);
  res.json(await traceCode(code, p.entry_point, args, conditions));
});

problemsRouter.post("/:id/debug/eval", requireAuth, debugLimiter, async (req, res) => {
  const p = await loadProblem(req);
  requirePython(p);
  const { code, args, conditions, ...at } = evalBody.parse(req.body);
  res.json(await evalAtStep(code, p.entry_point, args, { ...at, conditions }));
});
