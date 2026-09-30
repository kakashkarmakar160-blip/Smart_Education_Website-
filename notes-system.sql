-- Smart Education Notes System
-- Run this once in Supabase SQL Editor.
BEGIN;

CREATE TABLE IF NOT EXISTS public.notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  note_code text NOT NULL UNIQUE,
  teacher_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  teacher_name text,
  title text NOT NULL,
  class_name text,
  semester text,
  subject text,
  chapter text,
  content_html text NOT NULL DEFAULT '',
  background_logo_url text,
  published boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notes_teacher ON public.notes(teacher_user_id, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_notes_code ON public.notes(note_code);

ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS notes_select ON public.notes;
CREATE POLICY notes_select ON public.notes
FOR SELECT TO authenticated
USING (published = true OR teacher_user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS notes_insert ON public.notes;
CREATE POLICY notes_insert ON public.notes
FOR INSERT TO authenticated
WITH CHECK (teacher_user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS notes_update ON public.notes;
CREATE POLICY notes_update ON public.notes
FOR UPDATE TO authenticated
USING (teacher_user_id = (SELECT auth.uid()))
WITH CHECK (teacher_user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS notes_delete ON public.notes;
CREATE POLICY notes_delete ON public.notes
FOR DELETE TO authenticated
USING (teacher_user_id = (SELECT auth.uid()));

GRANT SELECT, INSERT, UPDATE, DELETE ON public.notes TO authenticated;

-- Public image bucket. The app still enforces a 350 KB maximum per upload.
INSERT INTO storage.buckets (id, name, public)
VALUES ('notes-media', 'notes-media', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS notes_media_select ON storage.objects;
CREATE POLICY notes_media_select ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'notes-media');

DROP POLICY IF EXISTS notes_media_insert ON storage.objects;
CREATE POLICY notes_media_insert ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'notes-media' AND (storage.foldername(name))[1] = (SELECT auth.uid())::text);

DROP POLICY IF EXISTS notes_media_update ON storage.objects;
CREATE POLICY notes_media_update ON storage.objects
FOR UPDATE TO authenticated
USING (bucket_id = 'notes-media' AND (storage.foldername(name))[1] = (SELECT auth.uid())::text)
WITH CHECK (bucket_id = 'notes-media' AND (storage.foldername(name))[1] = (SELECT auth.uid())::text);

DROP POLICY IF EXISTS notes_media_delete ON storage.objects;
CREATE POLICY notes_media_delete ON storage.objects
FOR DELETE TO authenticated
USING (bucket_id = 'notes-media' AND (storage.foldername(name))[1] = (SELECT auth.uid())::text);

COMMIT;
