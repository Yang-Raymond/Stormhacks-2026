ALTER TABLE users
  ADD COLUMN role            text,
  ADD COLUMN debug_languages text[] NOT NULL DEFAULT '{}',
  ADD COLUMN avatar_url      text,
  ADD COLUMN onboarded_at    timestamptz;

UPDATE users SET debug_languages = ARRAY[debug_language] WHERE debug_language IS NOT NULL;
ALTER TABLE users DROP COLUMN debug_language;

-- Existing accounts skip onboarding.
UPDATE users SET onboarded_at = now();
