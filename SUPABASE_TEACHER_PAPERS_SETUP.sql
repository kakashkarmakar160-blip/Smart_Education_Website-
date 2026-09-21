-- Smart Education: Cross-device Teacher Papers + Student Results

create table if not exists public.teacher_papers (
  id uuid primary key default gen_random_uuid(),
  access_code text not null unique,
  name text not null,
  target text,
  teacher_name text,
  teacher_user_id uuid not null references auth.users(id) on delete cascade,
  questions jsonb not null default '[]'::jsonb,
  published_at timestamptz not null default now()
);

alter table public.teacher_papers enable row level security;
drop policy if exists "teacher_papers_insert_own" on public.teacher_papers;
create policy "teacher_papers_insert_own" on public.teacher_papers for insert to authenticated with check (teacher_user_id = auth.uid());
drop policy if exists "teacher_papers_select_authenticated" on public.teacher_papers;
create policy "teacher_papers_select_authenticated" on public.teacher_papers for select to authenticated using (true);
grant select, insert on public.teacher_papers to authenticated;
create index if not exists teacher_papers_access_code_idx on public.teacher_papers(access_code);

create table if not exists public.teacher_exam_results (
  result_id text primary key,
  paper_id uuid references public.teacher_papers(id) on delete cascade,
  access_code text,
  teacher_user_id uuid not null references auth.users(id) on delete cascade,
  student_user_id uuid not null references auth.users(id) on delete cascade,
  student_name text,
  result jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- If the table already existed from an earlier version, add the missing name column.
alter table public.teacher_exam_results add column if not exists student_name text;
alter table public.teacher_exam_results add column if not exists updated_at timestamptz not null default now();
alter table public.teacher_exam_results add column if not exists created_at timestamptz not null default now();
alter table public.teacher_exam_results add column if not exists result jsonb not null default '{}'::jsonb;

alter table public.teacher_exam_results enable row level security;
drop policy if exists "teacher_exam_results_student_insert" on public.teacher_exam_results;
create policy "teacher_exam_results_student_insert" on public.teacher_exam_results for insert to authenticated with check (student_user_id = auth.uid());
drop policy if exists "teacher_exam_results_teacher_select" on public.teacher_exam_results;
create policy "teacher_exam_results_teacher_select" on public.teacher_exam_results for select to authenticated using (teacher_user_id = auth.uid() or student_user_id = auth.uid());
drop policy if exists "teacher_exam_results_teacher_update" on public.teacher_exam_results;
create policy "teacher_exam_results_teacher_update" on public.teacher_exam_results for update to authenticated using (teacher_user_id = auth.uid()) with check (teacher_user_id = auth.uid());

grant select, insert, update on public.teacher_exam_results to authenticated;
create index if not exists teacher_exam_results_teacher_idx on public.teacher_exam_results(teacher_user_id);
create index if not exists teacher_exam_results_student_idx on public.teacher_exam_results(student_user_id);
create index if not exists teacher_exam_results_paper_idx on public.teacher_exam_results(paper_id);
create index if not exists teacher_exam_results_code_idx on public.teacher_exam_results(access_code);
