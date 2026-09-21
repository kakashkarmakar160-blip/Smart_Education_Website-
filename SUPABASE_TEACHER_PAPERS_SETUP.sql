-- Smart Education: Teacher Papers + Cross-device Student Results
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
create policy "teacher_papers_insert_own" on public.teacher_papers for insert to authenticated with check (teacher_user_id = (select auth.uid()));
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

alter table public.teacher_exam_results add column if not exists student_name text;
alter table public.teacher_exam_results enable row level security;
drop policy if exists "teacher_exam_results_student_insert" on public.teacher_exam_results;
create policy "teacher_exam_results_student_insert" on public.teacher_exam_results for insert to authenticated with check (student_user_id = (select auth.uid()));
drop policy if exists "teacher_exam_results_select" on public.teacher_exam_results;
create policy "teacher_exam_results_select" on public.teacher_exam_results for select to authenticated using (teacher_user_id = (select auth.uid()) or student_user_id = (select auth.uid()));
drop policy if exists "teacher_exam_results_teacher_update" on public.teacher_exam_results;
create policy "teacher_exam_results_teacher_update" on public.teacher_exam_results for update to authenticated using (teacher_user_id = (select auth.uid())) with check (teacher_user_id = (select auth.uid()));
grant select, insert, update on public.teacher_exam_results to authenticated;
create index if not exists teacher_exam_results_teacher_idx on public.teacher_exam_results(teacher_user_id);
create index if not exists teacher_exam_results_student_idx on public.teacher_exam_results(student_user_id);
create index if not exists teacher_exam_results_paper_idx on public.teacher_exam_results(paper_id);
create index if not exists teacher_exam_results_code_idx on public.teacher_exam_results(access_code);


-- DELETE POLICIES: teacher can delete only their own papers/results
drop policy if exists "teacher_papers_delete_own" on public.teacher_papers;
create policy "teacher_papers_delete_own" on public.teacher_papers
for delete to authenticated
using ((select auth.uid()) = teacher_user_id);

drop policy if exists "teacher_exam_results_teacher_delete" on public.teacher_exam_results;
create policy "teacher_exam_results_teacher_delete" on public.teacher_exam_results
for delete to authenticated
using ((select auth.uid()) = teacher_user_id);

grant delete on public.teacher_papers to authenticated;
grant delete on public.teacher_exam_results to authenticated;


-- ============================================================
-- STUDENT RESULT MIRROR
-- teacher_exam_results is the source of truth for teacher editing.
-- Every insert/update/delete is mirrored to student_results so the
-- student device can always load the same result.
-- ============================================================

alter table public.student_results
  add column if not exists result_id text;

alter table public.student_results
  add column if not exists student_user_id uuid;

alter table public.student_results
  add column if not exists teacher_user_id uuid;

alter table public.student_results
  add column if not exists paper_id uuid;

alter table public.student_results
  add column if not exists access_code text;

alter table public.student_results
  add column if not exists student_name text;

alter table public.student_results
  add column if not exists result jsonb default '{}'::jsonb;

alter table public.student_results
  add column if not exists created_at timestamptz not null default now();

alter table public.student_results
  add column if not exists updated_at timestamptz not null default now();

create unique index if not exists student_results_result_id_unique
on public.student_results(result_id)
where result_id is not null;

create or replace function public.sync_teacher_exam_result_to_student_results()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    delete from public.student_results
    where result_id = old.result_id;
    return old;
  end if;

  insert into public.student_results
    (result_id, student_user_id, teacher_user_id, paper_id,
     access_code, student_name, result, created_at, updated_at)
  values
    (new.result_id, new.student_user_id, new.teacher_user_id, new.paper_id,
     new.access_code, new.student_name, new.result, new.created_at, new.updated_at)
  on conflict (result_id) do update set
    student_user_id = excluded.student_user_id,
    teacher_user_id = excluded.teacher_user_id,
    paper_id = excluded.paper_id,
    access_code = excluded.access_code,
    student_name = excluded.student_name,
    result = excluded.result,
    updated_at = excluded.updated_at;

  return new;
end;
$$;

drop trigger if exists trg_sync_teacher_exam_result_to_student_results
on public.teacher_exam_results;

create trigger trg_sync_teacher_exam_result_to_student_results
after insert or update or delete
on public.teacher_exam_results
for each row
execute function public.sync_teacher_exam_result_to_student_results();

-- Backfill all existing teacher results into student_results.
insert into public.student_results
  (result_id, student_user_id, teacher_user_id, paper_id,
   access_code, student_name, result, created_at, updated_at)
select
  result_id, student_user_id, teacher_user_id, paper_id,
  access_code, student_name, result, created_at, updated_at
from public.teacher_exam_results
where result_id is not null
on conflict (result_id) do update set
  student_user_id = excluded.student_user_id,
  teacher_user_id = excluded.teacher_user_id,
  paper_id = excluded.paper_id,
  access_code = excluded.access_code,
  student_name = excluded.student_name,
  result = excluded.result,
  updated_at = excluded.updated_at;

grant select on public.student_results to authenticated;
