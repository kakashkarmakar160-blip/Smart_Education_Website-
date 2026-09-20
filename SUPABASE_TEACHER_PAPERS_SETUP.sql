-- Smart Education: cross-device Teacher Paper storage
-- Run this entire file once in Supabase SQL Editor.

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

-- A logged-in/anonymous teacher may publish a paper only for their own auth user.
drop policy if exists "teacher_papers_insert_own" on public.teacher_papers;
create policy "teacher_papers_insert_own"
on public.teacher_papers for insert to authenticated
with check (teacher_user_id = auth.uid());

-- Students/anonymous users need to find a paper by its shared code.
drop policy if exists "teacher_papers_select_authenticated" on public.teacher_papers;
create policy "teacher_papers_select_authenticated"
on public.teacher_papers for select to authenticated
using (true);

grant select, insert on public.teacher_papers to authenticated;

create index if not exists teacher_papers_access_code_idx on public.teacher_papers(access_code);
