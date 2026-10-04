-- migrate:no-transaction
-- Continuous aggregates can't be created inside a transaction, so this file runs statement by statement
-- (see migrate.ts) and every statement is safe to re-run.

-- Present in the timescaledb image and on Tiger Cloud; created explicitly so this works on any Postgres + Timescale.
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Every run, submit, debug session, hint and challenge start, as a time series. Kept even if the problem is
-- deleted (expired challenges) so analytics stay complete.
CREATE TABLE IF NOT EXISTS events (
  at           timestamptz NOT NULL DEFAULT now(),
  id           bigserial,
  user_id      bigint NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  problem_id   bigint REFERENCES problems(id) ON DELETE SET NULL,
  kind         text NOT NULL CHECK (kind IN ('run', 'submit', 'debug', 'hint', 'challenge_start')),
  language     text,
  difficulty   text,
  passed       boolean,
  passed_count int,
  total_count  int
);

SELECT create_hypertable('events', by_range('at', INTERVAL '7 days'), if_not_exists => true);

CREATE INDEX IF NOT EXISTS events_user_at_idx ON events (user_id, at DESC);
-- The Snowflake sync reads events in id order past a watermark.
CREATE INDEX IF NOT EXISTS events_id_idx ON events (id);

-- Old chunks are converted to compressed columnar storage; activity history is append-only.
ALTER TABLE events SET (
  timescaledb.enable_columnstore = true,
  timescaledb.segmentby = 'user_id',
  timescaledb.orderby = 'at DESC'
);
CALL add_columnstore_policy('events', after => INTERVAL '30 days', if_not_exists => true);

-- Backfill from submissions made before events existed (only on the first run).
INSERT INTO events (at, user_id, problem_id, kind, language, difficulty, passed, passed_count, total_count)
SELECT s.created_at, s.user_id, s.problem_id, 'submit', s.language, p.difficulty, s.passed, s.passed_count, s.total_count
FROM submissions s JOIN problems p ON p.id = s.problem_id
WHERE NOT EXISTS (SELECT 1 FROM events);

-- Per-user daily activity (UTC days, matching challenge periods). Real-time: recent events not yet
-- materialized are still included.
CREATE MATERIALIZED VIEW IF NOT EXISTS daily_activity
WITH (timescaledb.continuous, timescaledb.materialized_only = false) AS
SELECT time_bucket(INTERVAL '1 day', at) AS day,
       user_id,
       count(*) FILTER (WHERE kind = 'run') AS runs,
       count(*) FILTER (WHERE kind = 'submit') AS submits,
       count(*) FILTER (WHERE kind = 'submit' AND passed) AS accepted,
       count(*) FILTER (WHERE kind = 'debug') AS debug_sessions,
       count(*) FILTER (WHERE kind = 'hint') AS hints,
       count(*) AS total
FROM events
GROUP BY day, user_id
WITH NO DATA;

SELECT add_continuous_aggregate_policy('daily_activity',
  start_offset => INTERVAL '30 days',
  end_offset => INTERVAL '1 hour',
  schedule_interval => INTERVAL '5 minutes',
  if_not_exists => true);

-- Materialize only complete days. Refreshing today's partial bucket would move the watermark past today, and
-- real-time aggregation only covers data after the watermark, so today's new events would stay hidden.
CALL refresh_continuous_aggregate('daily_activity', NULL, date_trunc('day', now() AT TIME ZONE 'UTC') AT TIME ZONE 'UTC');

-- Watermarks for background jobs (the Snowflake sync records the last event id it shipped).
CREATE TABLE IF NOT EXISTS sync_state (
  name       text PRIMARY KEY,
  last_id    bigint NOT NULL DEFAULT 0,
  updated_at timestamptz NOT NULL DEFAULT now()
);
