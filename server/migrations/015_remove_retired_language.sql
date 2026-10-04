-- Retire the unsupported runtime from existing installations. Problem-owned drafts,
-- submissions, challenges and attempts are removed by their ON DELETE CASCADE keys.
-- The migration runner applies this cleanup and its tracking record atomically.
DELETE FROM events WHERE language = 'csharp'
  OR problem_id IN (SELECT id FROM problems WHERE language = 'csharp');
DELETE FROM submissions WHERE language = 'csharp';
DELETE FROM problems WHERE language = 'csharp';

UPDATE users
SET debug_languages = CASE
  WHEN cardinality(array_remove(array_remove(debug_languages, 'csharp'), 'C#')) = 0
    THEN ARRAY['python']
  ELSE array_remove(array_remove(debug_languages, 'csharp'), 'C#')
END
WHERE debug_languages && ARRAY['csharp', 'C#'];

ALTER TABLE problems DROP CONSTRAINT problems_language_check;
ALTER TABLE problems ADD CONSTRAINT problems_language_check
  CHECK (language IN ('python', 'javascript', 'typescript', 'java', 'c', 'cpp'));
