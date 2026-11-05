-- Smart Education Class Marketplace: run once in Supabase SQL Editor
create table if not exists public.teacher_classes (
 id uuid primary key default gen_random_uuid(), teacher_id uuid not null references auth.users(id) on delete cascade,
 class_name text not null, school_class text not null, subject text not null, semester text,
 price numeric(10,2) not null default 0 check(price>=0), description text, logo_data text,
 published boolean not null default true, created_at timestamptz not null default now()
);
create table if not exists public.class_resources (
 id uuid primary key default gen_random_uuid(), class_id uuid not null references public.teacher_classes(id) on delete cascade,
 resource_type text not null, title text not null, url text not null check(url ~* '^https://'), cover_data text,
 created_at timestamptz not null default now()
);
create table if not exists public.class_admission_requests (
 id uuid primary key default gen_random_uuid(), class_id uuid not null references public.teacher_classes(id) on delete cascade,
 student_id uuid not null references auth.users(id) on delete cascade, student_name text not null,
 phone text not null, email text not null, address text not null,
 status text not null default 'pending' check(status in ('pending','accepted','rejected')),
 created_at timestamptz not null default now(), unique(class_id,student_id)
);
create table if not exists public.class_enrollments (
 id uuid primary key default gen_random_uuid(), class_id uuid not null references public.teacher_classes(id) on delete cascade,
 student_id uuid not null references auth.users(id) on delete cascade, student_name text, status text not null default 'active' check(status in ('active','removed','blocked')),
 created_at timestamptz not null default now(), unique(class_id,student_id)
);
create index if not exists teacher_classes_search_idx on public.teacher_classes(school_class,semester,subject,published);
create index if not exists class_resources_class_idx on public.class_resources(class_id);
create index if not exists class_requests_class_idx on public.class_admission_requests(class_id,status);
create index if not exists class_enrollments_student_idx on public.class_enrollments(student_id,status);
alter table public.teacher_classes enable row level security;
alter table public.class_resources enable row level security;
alter table public.class_admission_requests enable row level security;
alter table public.class_enrollments enable row level security;
drop policy if exists "market classes browse" on public.teacher_classes;
create policy "market classes browse" on public.teacher_classes for select to authenticated using (published=true or teacher_id=auth.uid());
drop policy if exists "market classes owner insert" on public.teacher_classes;
create policy "market classes owner insert" on public.teacher_classes for insert to authenticated with check(teacher_id=auth.uid());
drop policy if exists "market classes owner update" on public.teacher_classes;
create policy "market classes owner update" on public.teacher_classes for update to authenticated using(teacher_id=auth.uid()) with check(teacher_id=auth.uid());
drop policy if exists "market classes owner delete" on public.teacher_classes;
create policy "market classes owner delete" on public.teacher_classes for delete to authenticated using(teacher_id=auth.uid());
drop policy if exists "resources enrolled or owner read" on public.class_resources;
create policy "resources enrolled or owner read" on public.class_resources for select to authenticated using (exists(select 1 from public.teacher_classes c where c.id=class_id and c.teacher_id=auth.uid()) or exists(select 1 from public.class_enrollments e where e.class_id=class_id and e.student_id=auth.uid() and e.status='active'));
drop policy if exists "resources owner insert" on public.class_resources;
create policy "resources owner insert" on public.class_resources for insert to authenticated with check(exists(select 1 from public.teacher_classes c where c.id=class_id and c.teacher_id=auth.uid()));
drop policy if exists "resources owner delete" on public.class_resources;
create policy "resources owner delete" on public.class_resources for delete to authenticated using(exists(select 1 from public.teacher_classes c where c.id=class_id and c.teacher_id=auth.uid()));
drop policy if exists "requests student insert" on public.class_admission_requests;
create policy "requests student insert" on public.class_admission_requests for insert to authenticated with check(student_id=auth.uid() and status='pending' and exists(select 1 from public.teacher_classes c where c.id=class_id and c.published=true));
drop policy if exists "requests student or teacher read" on public.class_admission_requests;
create policy "requests student or teacher read" on public.class_admission_requests for select to authenticated using(student_id=auth.uid() or exists(select 1 from public.teacher_classes c where c.id=class_id and c.teacher_id=auth.uid()));
drop policy if exists "requests teacher update" on public.class_admission_requests;
create policy "requests teacher update" on public.class_admission_requests for update to authenticated using(exists(select 1 from public.teacher_classes c where c.id=class_id and c.teacher_id=auth.uid())) with check(exists(select 1 from public.teacher_classes c where c.id=class_id and c.teacher_id=auth.uid()));
drop policy if exists "enrollments student or teacher read" on public.class_enrollments;
create policy "enrollments student or teacher read" on public.class_enrollments for select to authenticated using(student_id=auth.uid() or exists(select 1 from public.teacher_classes c where c.id=class_id and c.teacher_id=auth.uid()));
drop policy if exists "enrollments teacher insert" on public.class_enrollments;
create policy "enrollments teacher insert" on public.class_enrollments for insert to authenticated with check(exists(select 1 from public.teacher_classes c where c.id=class_id and c.teacher_id=auth.uid()));
drop policy if exists "enrollments teacher update" on public.class_enrollments;
create policy "enrollments teacher update" on public.class_enrollments for update to authenticated using(exists(select 1 from public.teacher_classes c where c.id=class_id and c.teacher_id=auth.uid())) with check(exists(select 1 from public.teacher_classes c where c.id=class_id and c.teacher_id=auth.uid()));


-- Allow class owners to edit their own resource links (Manage Class)
DROP POLICY IF EXISTS "resources owner update" ON public.class_resources;
CREATE POLICY "resources owner update"
ON public.class_resources FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM public.teacher_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid()))
WITH CHECK (EXISTS (SELECT 1 FROM public.teacher_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid()));

NOTIFY pgrst, 'reload schema';

-- Compatibility migration for existing Marketplace tables and older deployments
ALTER TABLE public.teacher_classes ADD COLUMN IF NOT EXISTS teacher_name text;
ALTER TABLE public.class_resources ADD COLUMN IF NOT EXISTS teacher_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.class_resources ADD COLUMN IF NOT EXISTS url text;
ALTER TABLE public.class_resources ADD COLUMN IF NOT EXISTS resource_url text;
ALTER TABLE public.class_resources ADD COLUMN IF NOT EXISTS cover_data text;
ALTER TABLE public.class_resources ADD COLUMN IF NOT EXISTS cover_url text;
ALTER TABLE public.class_resources ADD COLUMN IF NOT EXISTS image_url text;
UPDATE public.class_resources SET resource_url = url WHERE resource_url IS NULL AND url IS NOT NULL;
UPDATE public.class_resources SET url = resource_url WHERE url IS NULL AND resource_url IS NOT NULL;
ALTER TABLE public.class_admission_requests ADD COLUMN IF NOT EXISTS teacher_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.class_enrollments ADD COLUMN IF NOT EXISTS teacher_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.class_enrollments ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'active';
ALTER TABLE public.class_enrollments ADD COLUMN IF NOT EXISTS student_name text;
-- Backfill owner IDs so legacy records continue to work
UPDATE public.class_resources r SET teacher_id=c.teacher_id FROM public.teacher_classes c WHERE c.id=r.class_id AND r.teacher_id IS NULL;
UPDATE public.class_admission_requests r SET teacher_id=c.teacher_id FROM public.teacher_classes c WHERE c.id=r.class_id AND r.teacher_id IS NULL;
UPDATE public.class_enrollments e SET teacher_id=c.teacher_id FROM public.teacher_classes c WHERE c.id=e.class_id AND e.teacher_id IS NULL;
UPDATE public.teacher_classes SET teacher_name=COALESCE(teacher_name,'Teacher') WHERE teacher_name IS NULL;
CREATE INDEX IF NOT EXISTS class_resources_teacher_idx ON public.class_resources(teacher_id);
NOTIFY pgrst, 'reload schema';

-- Ensure inserted resource/admission/enrollment owner IDs match the actual class owner
DROP POLICY IF EXISTS "resources owner insert" ON public.class_resources;
CREATE POLICY "resources owner insert" ON public.class_resources FOR INSERT TO authenticated
WITH CHECK (teacher_id = auth.uid() AND EXISTS (SELECT 1 FROM public.teacher_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid()));
DROP POLICY IF EXISTS "requests student insert" ON public.class_admission_requests;
CREATE POLICY "requests student insert" ON public.class_admission_requests FOR INSERT TO authenticated
WITH CHECK (student_id = auth.uid() AND status = 'pending' AND EXISTS (SELECT 1 FROM public.teacher_classes c WHERE c.id = class_id AND c.teacher_id = teacher_id AND c.published = true));
DROP POLICY IF EXISTS "enrollments teacher insert" ON public.class_enrollments;
CREATE POLICY "enrollments teacher insert" ON public.class_enrollments FOR INSERT TO authenticated
WITH CHECK (teacher_id = auth.uid() AND EXISTS (SELECT 1 FROM public.teacher_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid()));
NOTIFY pgrst, 'reload schema';
