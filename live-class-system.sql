-- SMART EDUCATION — LIVE CLASS SYSTEM
-- Run once in Supabase SQL Editor after the existing Notes SQL.
BEGIN;

CREATE TABLE IF NOT EXISTS public.live_classes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  live_code text NOT NULL UNIQUE,
  room_name text NOT NULL UNIQUE,
  teacher_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  teacher_name text,
  title text NOT NULL,
  class_name text,
  semester text,
  subject text,
  chapter text,
  starts_at timestamptz,
  duration_minutes integer NOT NULL DEFAULT 60 CHECK (duration_minutes BETWEEN 1 AND 480),
  status text NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled','live','ended','cancelled')),
  created_at timestamptz NOT NULL DEFAULT now(),
  ended_at timestamptz
);

CREATE TABLE IF NOT EXISTS public.live_class_participants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id uuid NOT NULL REFERENCES public.live_classes(id) ON DELETE CASCADE,
  student_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  student_name text,
  joined_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at timestamptz NOT NULL DEFAULT now(),
  blocked boolean NOT NULL DEFAULT false,
  UNIQUE(class_id, student_user_id)
);

CREATE TABLE IF NOT EXISTS public.live_class_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id uuid NOT NULL REFERENCES public.live_classes(id) ON DELETE CASCADE,
  student_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  student_name text,
  message text NOT NULL CHECK (char_length(message) BETWEEN 1 AND 1000),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.live_class_grades (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id uuid NOT NULL REFERENCES public.live_classes(id) ON DELETE CASCADE,
  student_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  teacher_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  stars integer NOT NULL CHECK (stars BETWEEN 0 AND 5),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(class_id, student_user_id)
);

CREATE INDEX IF NOT EXISTS idx_live_classes_code ON public.live_classes(live_code);
CREATE INDEX IF NOT EXISTS idx_live_classes_teacher ON public.live_classes(teacher_user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_live_participants_class ON public.live_class_participants(class_id);
CREATE INDEX IF NOT EXISTS idx_live_comments_class ON public.live_class_comments(class_id, created_at);
CREATE INDEX IF NOT EXISTS idx_live_grades_student ON public.live_class_grades(student_user_id, updated_at DESC);

ALTER TABLE public.live_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_class_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_class_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_class_grades ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS live_classes_select ON public.live_classes;
CREATE POLICY live_classes_select ON public.live_classes FOR SELECT TO authenticated
USING (teacher_user_id = (SELECT auth.uid()) OR status IN ('scheduled','live'));

DROP POLICY IF EXISTS live_classes_insert ON public.live_classes;
CREATE POLICY live_classes_insert ON public.live_classes FOR INSERT TO authenticated
WITH CHECK (teacher_user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS live_classes_update ON public.live_classes;
CREATE POLICY live_classes_update ON public.live_classes FOR UPDATE TO authenticated
USING (teacher_user_id = (SELECT auth.uid()))
WITH CHECK (teacher_user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS live_classes_delete ON public.live_classes;
CREATE POLICY live_classes_delete ON public.live_classes FOR DELETE TO authenticated
USING (teacher_user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS live_participants_select ON public.live_class_participants;
CREATE POLICY live_participants_select ON public.live_class_participants FOR SELECT TO authenticated
USING (
  student_user_id = (SELECT auth.uid()) OR
  EXISTS (SELECT 1 FROM public.live_classes c WHERE c.id = class_id AND c.teacher_user_id = (SELECT auth.uid()))
);

DROP POLICY IF EXISTS live_participants_insert ON public.live_class_participants;
CREATE POLICY live_participants_insert ON public.live_class_participants FOR INSERT TO authenticated
WITH CHECK (
  student_user_id = (SELECT auth.uid()) AND
  EXISTS (SELECT 1 FROM public.live_classes c WHERE c.id = class_id AND c.status IN ('scheduled','live'))
);

DROP POLICY IF EXISTS live_participants_update ON public.live_class_participants;
CREATE POLICY live_participants_update ON public.live_class_participants FOR UPDATE TO authenticated
USING (
  student_user_id = (SELECT auth.uid()) OR
  EXISTS (SELECT 1 FROM public.live_classes c WHERE c.id = class_id AND c.teacher_user_id = (SELECT auth.uid()))
)
WITH CHECK (
  student_user_id = (SELECT auth.uid()) OR
  EXISTS (SELECT 1 FROM public.live_classes c WHERE c.id = class_id AND c.teacher_user_id = (SELECT auth.uid()))
);

DROP POLICY IF EXISTS live_comments_select ON public.live_class_comments;
CREATE POLICY live_comments_select ON public.live_class_comments FOR SELECT TO authenticated
USING (
  student_user_id = (SELECT auth.uid()) OR
  EXISTS (SELECT 1 FROM public.live_classes c WHERE c.id = class_id AND c.teacher_user_id = (SELECT auth.uid()))
);

DROP POLICY IF EXISTS live_comments_insert ON public.live_class_comments;
CREATE POLICY live_comments_insert ON public.live_class_comments FOR INSERT TO authenticated
WITH CHECK (
  student_user_id = (SELECT auth.uid()) AND
  EXISTS (
    SELECT 1 FROM public.live_classes c
    WHERE c.id = class_id AND c.status = 'live'
  ) AND
  NOT EXISTS (
    SELECT 1 FROM public.live_class_participants p
    WHERE p.class_id = live_class_comments.class_id
      AND p.student_user_id = (SELECT auth.uid())
      AND p.blocked = true
  )
);

DROP POLICY IF EXISTS live_comments_delete ON public.live_class_comments;
CREATE POLICY live_comments_delete ON public.live_class_comments FOR DELETE TO authenticated
USING (
  student_user_id = (SELECT auth.uid()) OR
  EXISTS (SELECT 1 FROM public.live_classes c WHERE c.id = class_id AND c.teacher_user_id = (SELECT auth.uid()))
);

DROP POLICY IF EXISTS live_grades_select ON public.live_class_grades;
CREATE POLICY live_grades_select ON public.live_class_grades FOR SELECT TO authenticated
USING (
  student_user_id = (SELECT auth.uid()) OR teacher_user_id = (SELECT auth.uid())
);

DROP POLICY IF EXISTS live_grades_insert ON public.live_class_grades;
CREATE POLICY live_grades_insert ON public.live_class_grades FOR INSERT TO authenticated
WITH CHECK (
  teacher_user_id = (SELECT auth.uid()) AND
  EXISTS (SELECT 1 FROM public.live_classes c WHERE c.id = class_id AND c.teacher_user_id = (SELECT auth.uid()))
);

DROP POLICY IF EXISTS live_grades_update ON public.live_class_grades;
CREATE POLICY live_grades_update ON public.live_class_grades FOR UPDATE TO authenticated
USING (teacher_user_id = (SELECT auth.uid()))
WITH CHECK (teacher_user_id = (SELECT auth.uid()));

GRANT SELECT, INSERT, UPDATE, DELETE ON public.live_classes TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.live_class_participants TO authenticated;
GRANT SELECT, INSERT, DELETE ON public.live_class_comments TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.live_class_grades TO authenticated;

COMMIT;
