import { Router } from "express";
import { requireAuth } from "./auth.js";
import { pool } from "./db.js";

export type EventKind = "run" | "submit" | "debug" | "hint" | "challenge_start";

export type ActivityEvent = {
  userId: string;
  kind: EventKind;
  problemId?: string | null;
  language?: string | null;
  difficulty?: string | null;
  passed?: boolean | null;
  passedCount?: number | null;
  totalCount?: number | null;
};

/** Appends to the `events` hypertable. Fire-and-forget: activity tracking must never fail the user's request. */
export function recordEvent(e: ActivityEvent) {
  pool
    .query(
      `INSERT INTO events (user_id, problem_id, kind, language, difficulty, passed, passed_count, total_count)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [
        e.userId,
        e.problemId ?? null,
        e.kind,
        e.language ?? null,
        e.difficulty ?? null,
        e.passed ?? null,
        e.passedCount ?? null,
        e.totalCount ?? null,
      ],
    )
    .catch((err) => console.warn("activity event not recorded", err));
}

const DAY_MS = 86_400_000;
const HEATMAP_WEEKS = 26;

type DayRow = { day: string; runs: number; submits: number; accepted: number; debug_sessions: number; hints: number; total: number };

const utcDay = (ms: number) => new Date(ms).toISOString().slice(0, 10);

/** Longest and current run of consecutive active days; today not being active yet doesn't break the streak. */
function streaks(activeDays: Set<string>, today: number) {
  let current = 0;
  for (let d = activeDays.has(utcDay(today)) ? today : today - DAY_MS; activeDays.has(utcDay(d)); d -= DAY_MS) current++;
  let longest = 0;
  let run = 0;
  let prev: number | null = null;
  for (const day of [...activeDays].sort()) {
    const t = Date.parse(`${day}T00:00:00Z`);
    run = prev !== null && t - prev === DAY_MS ? run + 1 : 1;
    longest = Math.max(longest, run);
    prev = t;
  }
  return { current, longest };
}

export const activityRouter = Router();

activityRouter.get("/me", requireAuth, async (req, res) => {
  const { rows } = await pool.query<DayRow>(
    `SELECT to_char(day, 'YYYY-MM-DD') AS day, runs::int, submits::int, accepted::int,
            debug_sessions::int, hints::int, total::int
     FROM daily_activity
     WHERE user_id = $1
     ORDER BY day`,
    [req.session.userId],
  );
  const byDay = new Map(rows.map((r) => [r.day, r]));
  const now = new Date();
  const today = Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate());
  const monday = today - ((now.getUTCDay() + 6) % 7) * DAY_MS;
  // Heatmap columns are Monday-start weeks, ending with the current week.
  const firstDay = monday - (HEATMAP_WEEKS - 1) * 7 * DAY_MS;

  const days = [];
  for (let t = firstDay; t <= today; t += DAY_MS) {
    const r = byDay.get(utcDay(t));
    days.push({ date: utcDay(t), total: r?.total ?? 0, accepted: r?.accepted ?? 0 });
  }
  const sum = (from: number, key: keyof Omit<DayRow, "day">) =>
    rows.filter((r) => Date.parse(`${r.day}T00:00:00Z`) >= from).reduce((n, r) => n + r[key], 0);

  res.json({
    streak: streaks(new Set(rows.filter((r) => r.total > 0).map((r) => r.day)), today),
    thisWeek: { runs: sum(monday, "runs"), submits: sum(monday, "submits"), accepted: sum(monday, "accepted") },
    allTime: { activeDays: rows.length, accepted: sum(0, "accepted"), hints: sum(0, "hints") },
    days,
  });
});
