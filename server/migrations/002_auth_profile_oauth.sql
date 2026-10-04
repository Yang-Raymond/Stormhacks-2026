ALTER TABLE users
  ALTER COLUMN password_hash DROP NOT NULL,
  ADD COLUMN full_name         text,
  ADD COLUMN debug_language    text,
  ADD COLUMN terms_accepted_at timestamptz;

CREATE TABLE oauth_accounts (
  provider         text   NOT NULL CHECK (provider IN ('github', 'google')),
  provider_user_id text   NOT NULL,
  user_id          bigint NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at       timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (provider, provider_user_id)
);

CREATE INDEX oauth_accounts_user_idx ON oauth_accounts (user_id);
