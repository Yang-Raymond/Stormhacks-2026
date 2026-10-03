import { Router } from "express";
import { rateLimit } from "express-rate-limit";
import { z } from "zod";
import { requireAuth } from "./auth.js";
import { pool } from "./db.js";
import { HttpError } from "./errors.js";
import { difficulties, generateProblem, type GeneratedProblem } from "./gemini.js";
import { allPassed, runTests, type RunResult, type TestCase } from "./runner.js";

const VISIBLE_TESTS = 2;
const GENERATION_ATTEMPTS = 3;

const idParam = z.object({ id: z.coerce.number().int().positive() });
const codeBody = z.object({ code: z.string().max(20_000) });

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

/** Only visible tests and their per-test details ever leave the server; hidden tests stay secret. */
function publicResults(run: RunResult, problem: ProblemRow) {
  const visible = problem.tests.slice(0, problem.visible_test_count);
  return {
    status: run.status,
    error: run.error,
    passedCount: run.results.filter((r) => r.passed).length,
    totalCount: run.results.length,
    visibleResults: run.results.slice(0, visible.length).map((r, i) => ({ ...visible[i], ...r })),
  };
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
  res.json({
    problem: {
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

problemsRouter.post("/:id/run", requireAuth, async (req, res) => {
  const p = await loadProblem(req.params.id);
  const { code } = codeBody.parse(req.body);
  const visible = p.tests.slice(0, p.visible_test_count);
  const run = await runTests(code, p.entry_point, visible);
  res.json(publicResults(run, p));
});

problemsRouter.post("/:id/submit", requireAuth, async (req, res) => {
  const p = await loadProblem(req.params.id);
  const { code } = codeBody.parse(req.body);
  const run = await runTests(code, p.entry_point, p.tests);
  const result = publicResults(run, p);
  const passed = allPassed(run, p.tests.length);
  await pool.query(
    `INSERT INTO submissions (user_id, problem_id, code, passed, passed_count, total_count)
     VALUES ($1, $2, $3, $4, $5, $6)`,
    [req.session.userId, p.id, code, passed, result.passedCount, p.tests.length],
  );
  res.json({ ...result, totalCount: p.tests.length, passed });
});
