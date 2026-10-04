import { createHash } from "node:crypto";
import { config } from "./config.js";
import { pool } from "./db.js";
import { snowflakeEnabled, snowflakeQuery } from "./snowflake.js";

/**
 * Ships activity events from the Tiger Data hypertable to the Snowflake warehouse every few minutes.
 * User ids are replaced by a salted one-way hash; a watermark in `sync_state` makes the sync resumable.
 */
const INTERVAL_MS = 5 * 60_000;
const BATCH = 500;
const MAX_BATCHES_PER_RUN = 20;
// Skip the last few seconds so rows from transactions still in flight (with lower ids) aren't jumped over.
const SETTLE = "30 seconds";
const STATE_KEY = "snowflake_events";

type EventRow = {
  id: string;
  at: Date;
  user_id: string;
  problem_id: string | null;
  problem_title: string | null;
  is_challenge: boolean | null;
  kind: string;
  language: string | null;
  difficulty: string | null;
  passed: boolean | null;
  passed_count: number | null;
  total_count: number | null;
};

const anonymize = (userId: string) =>
  createHash("sha256").update(`${config.ANALYTICS_SALT}:${userId}`).digest("hex").slice(0, 32);

async function syncBatch(): Promise<number> {
  const { rows: state } = await pool.query<{ last_id: string }>(
    `INSERT INTO sync_state (name) VALUES ($1) ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name RETURNING last_id`,
    [STATE_KEY],
  );
  const { rows } = await pool.query<EventRow>(
    `SELECT e.id, e.at, e.user_id, e.problem_id, p.title AS problem_title, p.is_challenge, e.kind, e.language,
            e.difficulty, e.passed, e.passed_count, e.total_count
     FROM events e LEFT JOIN problems p ON p.id = e.problem_id
     WHERE e.id > $1 AND e.at < now() - INTERVAL '${SETTLE}'
     ORDER BY e.id
     LIMIT $2`,
    [state[0].last_id, BATCH],
  );
  if (!rows.length) return 0;

  const firstId = rows[0].id;
  const lastId = rows[rows.length - 1].id;
  const col = <K extends keyof EventRow>(k: K) => rows.map((r) => r[k]);
  // Idempotent: if a previous run inserted this range but failed to save the watermark, replace those rows.
  await snowflakeQuery("DELETE FROM EVENTS WHERE EVENT_ID BETWEEN ? AND ?", [Number(firstId), Number(lastId)]);
  await snowflakeQuery(
    `INSERT INTO EVENTS (EVENT_ID, AT, USER_HASH, PROBLEM_ID, PROBLEM_TITLE, IS_CHALLENGE, KIND, LANGUAGE, DIFFICULTY,
                         PASSED, PASSED_COUNT, TOTAL_COUNT)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      col("id").map(Number),
      rows.map((r) => r.at.toISOString()),
      rows.map((r) => anonymize(r.user_id)),
      col("problem_id").map((v) => (v === null ? null : Number(v))),
      col("problem_title"),
      col("is_challenge"),
      col("kind"),
      col("language"),
      col("difficulty"),
      col("passed"),
      col("passed_count"),
      col("total_count"),
    ],
  );
  await pool.query("UPDATE sync_state SET last_id = $2, updated_at = now() WHERE name = $1", [STATE_KEY, lastId]);
  return rows.length;
}

let running = false;

export async function syncNow() {
  if (running) return;
  running = true;
  try {
    let shipped = 0;
    for (let i = 0; i < MAX_BATCHES_PER_RUN; i++) {
      const n = await syncBatch();
      shipped += n;
      if (n < BATCH) break;
    }
    if (shipped) console.log(`analytics sync: shipped ${shipped} events to Snowflake`);
  } catch (err) {
    console.warn("analytics sync failed; will retry", err instanceof Error ? err.message : err);
  } finally {
    running = false;
  }
}

export function startAnalyticsSync() {
  if (!snowflakeEnabled || !config.ANALYTICS_SALT) {
    console.log("analytics sync disabled (set SNOWFLAKE_ACCOUNT, SNOWFLAKE_TOKEN and ANALYTICS_SALT to enable)");
    return;
  }
  setTimeout(() => void syncNow(), 15_000);
  setInterval(() => void syncNow(), INTERVAL_MS).unref();
}
