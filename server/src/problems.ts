import { Router, type Request } from "express";
import { rateLimit } from "express-rate-limit";
import { z } from "zod";
import { requireAuth } from "./auth.js";
import { pool } from "./db.js";
import { HttpError } from "./errors.js";
import { difficulties, generateProblem, type GeneratedProblem } from "./gemini.js";
import { allPassed, evalAtStep, runTests, traceCode, type RunResult, type TestCase } from "./runner.js";

const VISIBLE_TESTS = 2;
const GENERATION_ATTEMPTS = 3;

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
};

async function loadProblem(rawId: unknown): Promise<ProblemRow> {
  const { id } = idParam.parse({ id: rawId });
  const { rows } = await pool.query<ProblemRow>(
    `SELECT id, title, description, difficulty, entry_point, buggy_code, tests, visible_test_count
     FROM problems WHERE id = $1`,
    [id],
  );
  if (!rows[0]) throw new HttpError(404, "Problem not found");
  return rows[0];
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
  const p = await loadProblem(req.params.id);
  const { code } = codeBody.parse(req.body);
  // Whatever was run or submitted is the user's latest work, even if an autosave never landed.
  const [run] = await Promise.all([runTests(code, p.entry_point, p.tests), saveDraft(req.session.userId!, p.id, code)]);
  return { p, code, result: publicResults(run, p) };
}

/** A generated problem is only usable if the reference solution passes every test and the buggy one doesn't. */
async function isValidExercise(p: GeneratedProblem) {
  const [fixed, buggy] = await Promise.all([
    runTests(p.fixedCode, p.entryPoint, p.tests),
    runTests(p.buggyCode, p.entryPoint, p.tests),
  ]);
  return allPassed(fixed, p.tests.length) && !allPassed(buggy, p.tests.length);
}

export const problemsRouter = Router();

problemsRouter.get("/", async (req, res) => {
  const { rows } = await pool.query(
    `SELECT p.id, p.title, p.difficulty, p.created_at,
            EXISTS (SELECT 1 FROM submissions s
                    WHERE s.problem_id = p.id AND s.user_id = $1 AND s.passed) AS solved
     FROM problems p ORDER BY p.created_at DESC`,
    [req.session.userId ?? null],
  );
  res.json({ problems: rows });
});

problemsRouter.post(
  "/generate",
  requireAuth,
  rateLimit({ windowMs: 60 * 60_000, limit: 20, keyGenerator: (req) => req.session.userId! }),
  async (req, res) => {
    const { difficulty } = z.object({ difficulty: z.enum(difficulties) }).parse(req.body);

    for (let attempt = 1; attempt <= GENERATION_ATTEMPTS; attempt++) {
      let problem: GeneratedProblem;
      try {
        problem = await generateProblem(difficulty);
      } catch (err) {
        console.warn(`generation attempt ${attempt} returned unusable output`, err);
        continue;
      }
      if (!(await isValidExercise(problem))) {
        console.warn(`generation attempt ${attempt} failed verification`);
        continue;
      }
      const { rows } = await pool.query<{ id: string }>(
        `INSERT INTO problems (title, description, difficulty, entry_point, buggy_code, fixed_code, tests,
                               visible_test_count, created_by)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id`,
        [
          problem.title,
          problem.description,
          difficulty,
          problem.entryPoint,
          problem.buggyCode,
          problem.fixedCode,
          JSON.stringify(problem.tests),
          VISIBLE_TESTS,
          req.session.userId,
        ],
      );
      return void res.status(201).json({ id: rows[0].id });
    }
    throw new HttpError(502, "Could not generate a valid problem, please try again");
  },
);

problemsRouter.get("/:id", async (req, res) => {
  const p = await loadProblem(req.params.id);
  const { rows } = await pool.query<{ solved: boolean; saved_code: string | null }>(
    `SELECT EXISTS (SELECT 1 FROM submissions WHERE problem_id = $1 AND user_id = $2 AND passed) AS solved,
            (SELECT code FROM drafts WHERE problem_id = $1 AND user_id = $2) AS saved_code`,
    [p.id, req.session.userId ?? null],
  );
  res.json({
    problem: {
      solved: rows[0].solved,
      savedCode: rows[0].saved_code,
      id: p.id,
      title: p.title,
      description: p.description,
      difficulty: p.difficulty,
      entryPoint: p.entry_point,
      buggyCode: p.buggy_code,
      examples: p.tests.slice(0, p.visible_test_count),
      totalTests: p.tests.length,
    },
  });
});

problemsRouter.put("/:id/draft", requireAuth, async (req, res) => {
  const p = await loadProblem(req.params.id);
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
    `INSERT INTO submissions (user_id, problem_id, code, passed, passed_count, total_count)
     VALUES ($1, $2, $3, $4, $5, $6)`,
    [req.session.userId, p.id, code, result.passed, result.passedCount, result.totalCount],
  );
  res.json(result);
});

// Debug args come from the client (an example, the revealed hidden failure, or custom input),
// so these endpoints never expose hidden test data.
problemsRouter.post("/:id/debug", requireAuth, debugLimiter, async (req, res) => {
  const p = await loadProblem(req.params.id);
  const { code, args, conditions } = debugBody.parse(req.body);
  res.json(await traceCode(code, p.entry_point, args, conditions));
});

problemsRouter.post("/:id/debug/eval", requireAuth, debugLimiter, async (req, res) => {
  const p = await loadProblem(req.params.id);
  const { code, args, conditions, ...at } = evalBody.parse(req.body);
  res.json(await evalAtStep(code, p.entry_point, args, { ...at, conditions }));
});
