import { Router } from "express";
import { requireAuth, toUser, type UserRow } from "./auth.js";
import { pool } from "./db.js";

export const profileRouter = Router();

type DifficultyRow = {
  difficulty: "easy" | "medium" | "hard";
  total: string;
  solved: string;
};

type MedianRow = {
  median_solve_seconds: number | string | null;
};

type HintStatsRow = {
  total_solves: string;
  unhinted_solves: string;
};

type LanguageRow = {
  language: string;
  solved: string;
};

type SubmissionRow = {
  id: string;
  problem_id: string;
  title: string;
  difficulty: string;
  language: string;
  passed: boolean;
  passed_count: number;
  total_count: number;
  elapsed_seconds: number | null;
  created_at: Date | string;
};

profileRouter.get("/me", requireAuth, async (req, res) => {
  const userId = req.session.userId!;

  const [
    userResult,
    diffResult,
    medianResult,
    hintResult,
    langResult,
    recentResult,
  ] = await Promise.all([
    // 1. User info
    pool.query<UserRow>(
      "SELECT id, email, full_name, role, debug_languages, avatar_url, onboarded_at, created_at FROM users WHERE id = $1",
      [userId],
    ),

    // 2. Solved by difficulty & overall total
    pool.query<DifficultyRow>(
      `WITH user_problems AS (
         SELECT p.title AS bug_key, p.difficulty,
                EXISTS (
                  SELECT 1 FROM problems p2
                  JOIN submissions s ON s.problem_id = p2.id
                  WHERE p2.title = p.title AND NOT p2.is_challenge AND s.user_id = $1 AND s.passed
                ) AS solved
         FROM problems p
         WHERE NOT p.is_challenge
         GROUP BY p.title, p.difficulty
         UNION ALL
         SELECT 'c_' || c.problem_id AS bug_key, p.difficulty,
                EXISTS (
                  SELECT 1 FROM submissions s
                  WHERE s.problem_id = c.problem_id AND s.user_id = $1 AND s.passed
                ) AS solved
         FROM challenges c
         JOIN problems p ON p.id = c.problem_id
         WHERE c.user_id = $1
       )
       SELECT difficulty,
              count(*) AS total,
              count(*) FILTER (WHERE solved) AS solved
       FROM user_problems
       GROUP BY difficulty`,
      [userId],
    ),

    // 3. Median solve time in seconds
    pool.query<MedianRow>(
      `WITH first_solves AS (
         SELECT s.problem_id, min(s.created_at) AS solved_at
         FROM submissions s
         WHERE s.user_id = $1 AND s.passed
         GROUP BY s.problem_id
       ),
       durations AS (
         SELECT extract(epoch FROM fs.solved_at - a.started_at)::double precision AS duration_seconds
         FROM first_solves fs
         JOIN problem_attempts a ON a.problem_id = fs.problem_id AND a.user_id = $1
         WHERE fs.solved_at >= a.started_at
       )
       SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY duration_seconds) AS median_solve_seconds
       FROM durations`,
      [userId],
    ),

    // 4. Solved without hints rate
    pool.query<HintStatsRow>(
      `WITH first_solves AS (
         SELECT s.problem_id, min(s.created_at) AS solved_at
         FROM submissions s
         WHERE s.user_id = $1 AND s.passed
         GROUP BY s.problem_id
       ),
       solves_with_hint_flag AS (
         SELECT fs.problem_id,
                EXISTS (
                  SELECT 1 FROM events e
                  WHERE e.user_id = $1
                    AND e.problem_id = fs.problem_id
                    AND e.kind = 'hint'
                    AND e.at <= fs.solved_at
                ) AS used_hint
         FROM first_solves fs
       )
       SELECT count(*) AS total_solves,
              count(*) FILTER (WHERE NOT used_hint) AS unhinted_solves
       FROM solves_with_hint_flag`,
      [userId],
    ),

    // 5. Solved by language
    pool.query<LanguageRow>(
      `SELECT s.language, count(DISTINCT s.problem_id) AS solved
       FROM submissions s
       WHERE s.user_id = $1 AND s.passed
       GROUP BY s.language
       ORDER BY solved DESC, s.language ASC`,
      [userId],
    ),

    // 6. Recent submissions (last 20)
    pool.query<SubmissionRow>(
      `SELECT s.id,
              s.problem_id,
              p.title,
              p.difficulty,
              s.language,
              s.passed,
              s.passed_count,
              s.total_count,
              s.created_at,
              CASE
                WHEN a.started_at IS NOT NULL AND s.created_at >= a.started_at
                THEN extract(epoch FROM s.created_at - a.started_at)::int
                ELSE NULL
              END AS elapsed_seconds
       FROM submissions s
       JOIN problems p ON p.id = s.problem_id
       LEFT JOIN problem_attempts a ON a.problem_id = s.problem_id AND a.user_id = s.user_id
       WHERE s.user_id = $1
       ORDER BY s.created_at DESC
       LIMIT 20`,
      [userId],
    ),
  ]);

  const userRow = userResult.rows[0];
  if (!userRow) {
    return void res.status(404).json({ error: "User not found" });
  }

  // Difficulty breakdown with order guaranteed: easy, medium, hard
  const diffMap = new Map(diffResult.rows.map((r) => [r.difficulty, r]));
  const orderedDifficulties: ("easy" | "medium" | "hard")[] = ["easy", "medium", "hard"];
  const byDifficulty = orderedDifficulties.map((d) => {
    const row = diffMap.get(d);
    return {
      difficulty: d,
      solved: row ? Number.parseInt(row.solved, 10) : 0,
      total: row ? Number.parseInt(row.total, 10) : 0,
    };
  });

  const totalBugs = byDifficulty.reduce((sum, d) => sum + d.total, 0);
  const totalSolved = byDifficulty.reduce((sum, d) => sum + d.solved, 0);

  const rawMedian = medianResult.rows[0]?.median_solve_seconds;
  const medianSolveSeconds =
    rawMedian !== null && rawMedian !== undefined ? Math.round(Number(rawMedian)) : null;

  const hintStats = hintResult.rows[0];
  const totalSolvesCount = hintStats ? Number.parseInt(hintStats.total_solves, 10) : 0;
  const unhintedSolvesCount = hintStats ? Number.parseInt(hintStats.unhinted_solves, 10) : 0;
  const noHintRate =
    totalSolvesCount > 0 ? unhintedSolvesCount / totalSolvesCount : null;

  const languages = langResult.rows.map((r) => ({
    language: r.language,
    solved: Number.parseInt(r.solved, 10),
  }));

  const recent = recentResult.rows.map((r) => ({
    id: r.id,
    problemId: r.problem_id,
    title: r.title,
    difficulty: r.difficulty,
    language: r.language,
    passed: r.passed,
    passedCount: r.passed_count,
    totalCount: r.total_count,
    elapsedSeconds: r.elapsed_seconds,
    createdAt: new Date(r.created_at).toISOString(),
  }));

  res.json({
    user: toUser(userRow),
    stats: {
      solved: totalSolved,
      total: totalBugs,
      medianSolveSeconds,
      noHintRate,
    },
    byDifficulty,
    languages,
    recent,
  });
});
