-- The latest code each user has written for a problem, so work survives leaving the page.
CREATE TABLE drafts (
  user_id    bigint NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  problem_id bigint NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
  code       text   NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, problem_id)
);
