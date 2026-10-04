-- Tracks when a user first opened each problem, so solve time = first accepted submission time - started_at.
CREATE TABLE IF NOT EXISTS problem_attempts (
  user_id    bigint NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  problem_id bigint NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
  started_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, problem_id)
);
