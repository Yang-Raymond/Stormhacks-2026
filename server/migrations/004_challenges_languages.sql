-- Problems can be written in languages other than Python. Statically typed languages need a signature
-- ({ params: [{ name, type }], returns }) so the runner can convert JSON test values to native ones.
ALTER TABLE problems
  ADD COLUMN language text NOT NULL DEFAULT 'python'
    CHECK (language IN ('python', 'javascript', 'typescript', 'java', 'c', 'cpp', 'csharp')),
  ADD COLUMN signature jsonb,
  -- Challenge problems are personal and never listed as practice, even if their challenge row is gone.
  ADD COLUMN is_challenge boolean NOT NULL DEFAULT false;

ALTER TABLE submissions ADD COLUMN language text NOT NULL DEFAULT 'python';

-- Personal daily/weekly challenges. A period starts at 00:00 UTC (daily) or Monday 00:00 UTC (weekly).
-- Unsolved challenges are deleted once their period ends; solved ones stay as history.
CREATE TABLE challenges (
  id           bigserial PRIMARY KEY,
  user_id      bigint NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  kind         text   NOT NULL CHECK (kind IN ('daily', 'weekly')),
  period_start date   NOT NULL,
  problem_id   bigint NOT NULL UNIQUE REFERENCES problems(id) ON DELETE CASCADE,
  created_at   timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, kind, period_start)
);
