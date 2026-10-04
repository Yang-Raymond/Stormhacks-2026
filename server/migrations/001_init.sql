CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE users (
  id            bigserial PRIMARY KEY,
  email         citext NOT NULL UNIQUE,
  password_hash text   NOT NULL,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE problems (
  id                 bigserial PRIMARY KEY,
  title              text NOT NULL,
  description        text NOT NULL,
  difficulty         text NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
  entry_point        text NOT NULL,
  buggy_code         text NOT NULL,
  fixed_code         text NOT NULL,
  tests              jsonb NOT NULL,
  visible_test_count int  NOT NULL,
  created_by         bigint REFERENCES users(id) ON DELETE SET NULL,
  created_at         timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE submissions (
  id           bigserial PRIMARY KEY,
  user_id      bigint NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  problem_id   bigint NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
  code         text NOT NULL,
  passed       boolean NOT NULL,
  passed_count int NOT NULL,
  total_count  int NOT NULL,
  created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX submissions_user_problem_idx ON submissions (user_id, problem_id);

-- connect-pg-simple session store
CREATE TABLE session (
  sid    varchar PRIMARY KEY,
  sess   json NOT NULL,
  expire timestamp(6) NOT NULL
);
CREATE INDEX session_expire_idx ON session (expire);
