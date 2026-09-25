-- Smart Education: Cross-device Practice Question Paper bank
-- Run this once in Supabase SQL Editor.

BEGIN;

CREATE TABLE IF NOT EXISTS public.practice_question_banks (
  bank_key text PRIMARY KEY,
  class_id text NOT NULL,
  semester text NOT NULL,
  subject text NOT NULL,
  questions jsonb NOT NULL DEFAULT '[]'::jsonb,
  updated_by uuid NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.practice_question_banks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS practice_question_banks_select ON public.practice_question_banks;
CREATE POLICY practice_question_banks_select
ON public.practice_question_banks
FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS practice_question_banks_insert ON public.practice_question_banks;
CREATE POLICY practice_question_banks_insert
ON public.practice_question_banks
FOR INSERT
TO authenticated
WITH CHECK (true);

DROP POLICY IF EXISTS practice_question_banks_update ON public.practice_question_banks;
CREATE POLICY practice_question_banks_update
ON public.practice_question_banks
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS practice_question_banks_delete ON public.practice_question_banks;
CREATE POLICY practice_question_banks_delete
ON public.practice_question_banks
FOR DELETE
TO authenticated
USING (true);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.practice_question_banks TO authenticated;

CREATE INDEX IF NOT EXISTS idx_practice_question_banks_lookup
ON public.practice_question_banks(class_id, semester, subject);

COMMIT;
