-- Smart Education: Settings, separate DP fields and Groups
-- Run this entire file in Supabase SQL Editor. This does not replace existing tables.
alter table public.profiles add column if not exists student_dp_url text;
alter table public.profiles add column if not exists teacher_dp_url text;

create table if not exists public.edu_groups (
  id uuid primary key default gen_random_uuid(),
  teacher_user_id uuid not null references auth.users(id) on delete cascade,
  group_name text not null,
  class_name text,
  subject text,
  description text,
  group_code text not null unique,
  logo_data_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.edu_group_members (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.edu_groups(id) on delete cascade,
  student_user_id uuid not null references auth.users(id) on delete cascade,
  joined_at timestamptz not null default now(),
  unique(group_id, student_user_id)
);
create index if not exists edu_groups_teacher_idx on public.edu_groups(teacher_user_id);
create index if not exists edu_group_members_student_idx on public.edu_group_members(student_user_id);
alter table public.edu_groups enable row level security;
alter table public.edu_group_members enable row level security;
-- Groups are visible to their creator and members. A student can read a group by code only
-- if policy allows select; membership policies below support joined groups. For joining by code,
-- permit authenticated users to select group directory; never store secrets in group descriptions.
drop policy if exists "edu groups select authenticated" on public.edu_groups;
create policy "edu groups select authenticated" on public.edu_groups for select to authenticated using (true);
drop policy if exists "edu groups teacher insert" on public.edu_groups;
create policy "edu groups teacher insert" on public.edu_groups for insert to authenticated with check (teacher_user_id = auth.uid());
drop policy if exists "edu groups teacher update" on public.edu_groups;
create policy "edu groups teacher update" on public.edu_groups for update to authenticated using (teacher_user_id = auth.uid()) with check (teacher_user_id = auth.uid());
drop policy if exists "edu groups teacher delete" on public.edu_groups;
create policy "edu groups teacher delete" on public.edu_groups for delete to authenticated using (teacher_user_id = auth.uid());
drop policy if exists "edu group members select self or group owner" on public.edu_group_members;
create policy "edu group members select self or group owner" on public.edu_group_members for select to authenticated using (student_user_id = auth.uid() or exists (select 1 from public.edu_groups g where g.id = group_id and g.teacher_user_id = auth.uid()));
drop policy if exists "edu group members join self" on public.edu_group_members;
create policy "edu group members join self" on public.edu_group_members for insert to authenticated with check (student_user_id = auth.uid());
drop policy if exists "edu group members leave self or owner" on public.edu_group_members;
create policy "edu group members leave self or owner" on public.edu_group_members for delete to authenticated using (student_user_id = auth.uid() or exists (select 1 from public.edu_groups g where g.id = group_id and g.teacher_user_id = auth.uid()));
-- Note: group-code lookup is available to authenticated users; keep codes private and share only with intended students.
