-- Smart Education: Groups, group chat, separate DP and Create with Link
-- Run all in Supabase SQL Editor. Existing site tables are not dropped.
alter table public.profiles add column if not exists student_dp_url text;
alter table public.profiles add column if not exists teacher_dp_url text;

create table if not exists public.edu_groups (
 id uuid primary key default gen_random_uuid(),
 teacher_user_id uuid not null references auth.users(id) on delete cascade,
 group_name text not null,
 class_name text, subject text, description text, group_code text not null unique,
 logo_data_url text, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.edu_group_members (
 id uuid primary key default gen_random_uuid(), group_id uuid not null references public.edu_groups(id) on delete cascade,
 student_user_id uuid not null references auth.users(id) on delete cascade, joined_at timestamptz not null default now(),
 unique(group_id,student_user_id)
);
create table if not exists public.edu_group_messages (
 id uuid primary key default gen_random_uuid(), group_id uuid not null references public.edu_groups(id) on delete cascade,
 sender_user_id uuid not null references auth.users(id) on delete cascade, sender_name text, message text not null check (char_length(message) between 1 and 2000),
 created_at timestamptz not null default now()
);
create index if not exists edu_groups_teacher_idx on public.edu_groups(teacher_user_id);
create index if not exists edu_group_members_student_idx on public.edu_group_members(student_user_id);
create index if not exists edu_group_messages_group_created_idx on public.edu_group_messages(group_id,created_at);

-- Teacher-created external links. A student uses the published code to open the exact URL.
create table if not exists public.edu_shared_links (
 id uuid primary key default gen_random_uuid(), teacher_user_id uuid not null references auth.users(id) on delete cascade,
 title text not null default 'Shared Link', target_url text not null check (target_url ~* '^https?://'),
 link_code text not null unique, created_at timestamptz not null default now(), published boolean not null default true
);
create index if not exists edu_shared_links_teacher_idx on public.edu_shared_links(teacher_user_id);

alter table public.edu_groups enable row level security;
alter table public.edu_group_members enable row level security;
alter table public.edu_group_messages enable row level security;
alter table public.edu_shared_links enable row level security;

-- Authenticated users may look up a group code to join; only owner can edit group fields.
drop policy if exists "edu groups select authenticated" on public.edu_groups;
create policy "edu groups select authenticated" on public.edu_groups for select to authenticated using (true);
drop policy if exists "edu groups teacher insert" on public.edu_groups;
create policy "edu groups teacher insert" on public.edu_groups for insert to authenticated with check (teacher_user_id=auth.uid());
drop policy if exists "edu groups teacher update" on public.edu_groups;
create policy "edu groups teacher update" on public.edu_groups for update to authenticated using (teacher_user_id=auth.uid()) with check (teacher_user_id=auth.uid());
drop policy if exists "edu groups teacher delete" on public.edu_groups;
create policy "edu groups teacher delete" on public.edu_groups for delete to authenticated using (teacher_user_id=auth.uid());

-- Membership: students may join themselves / leave themselves; group owner may add/remove members.
drop policy if exists "edu group members select self or group owner" on public.edu_group_members;
create policy "edu group members select self or group owner" on public.edu_group_members for select to authenticated using (
 student_user_id=auth.uid() or exists(select 1 from public.edu_groups g where g.id=group_id and g.teacher_user_id=auth.uid()) or exists(select 1 from public.edu_group_members mine where mine.group_id=edu_group_members.group_id and mine.student_user_id=auth.uid())
);
drop policy if exists "edu group members join self" on public.edu_group_members;
drop policy if exists "edu group members insert self or owner" on public.edu_group_members;
create policy "edu group members insert self or owner" on public.edu_group_members for insert to authenticated with check (
 student_user_id=auth.uid() or exists(select 1 from public.edu_groups g where g.id=group_id and g.teacher_user_id=auth.uid())
);
drop policy if exists "edu group members leave self or owner" on public.edu_group_members;
create policy "edu group members leave self or owner" on public.edu_group_members for delete to authenticated using (
 student_user_id=auth.uid() or exists(select 1 from public.edu_groups g where g.id=group_id and g.teacher_user_id=auth.uid())
);

-- Only group members and the teacher owner can read/send messages.
drop policy if exists "edu messages select group participants" on public.edu_group_messages;
create policy "edu messages select group participants" on public.edu_group_messages for select to authenticated using (
 exists(select 1 from public.edu_groups g where g.id=group_id and g.teacher_user_id=auth.uid()) or
 exists(select 1 from public.edu_group_members m where m.group_id=edu_group_messages.group_id and m.student_user_id=auth.uid())
);
drop policy if exists "edu messages insert group participants" on public.edu_group_messages;
create policy "edu messages insert group participants" on public.edu_group_messages for insert to authenticated with check (
 sender_user_id=auth.uid() and (exists(select 1 from public.edu_groups g where g.id=group_id and g.teacher_user_id=auth.uid()) or
 exists(select 1 from public.edu_group_members m where m.group_id=edu_group_messages.group_id and m.student_user_id=auth.uid()))
);

-- Link code can be published only by its teacher. Signed-in students can resolve codes/URLs.
drop policy if exists "edu shared links select authenticated" on public.edu_shared_links;
create policy "edu shared links select authenticated" on public.edu_shared_links for select to authenticated using (published=true or teacher_user_id=auth.uid());
drop policy if exists "edu shared links teacher insert" on public.edu_shared_links;
create policy "edu shared links teacher insert" on public.edu_shared_links for insert to authenticated with check (teacher_user_id=auth.uid());
drop policy if exists "edu shared links teacher update" on public.edu_shared_links;
create policy "edu shared links teacher update" on public.edu_shared_links for update to authenticated using (teacher_user_id=auth.uid()) with check (teacher_user_id=auth.uid());
drop policy if exists "edu shared links teacher delete" on public.edu_shared_links;
create policy "edu shared links teacher delete" on public.edu_shared_links for delete to authenticated using (teacher_user_id=auth.uid());


-- Safely expose only the fields needed for names and profile photos in teacher results and group chat.
-- This avoids granting broad SELECT access to every profiles column.
create or replace function public.get_public_profile_cards(p_user_ids uuid[])
returns table (id uuid, name text, student_dp_url text, teacher_dp_url text, avatar_url text)
language sql
stable
security definer
set search_path = public
as $$
  select p.id, p.name, p.student_dp_url, p.teacher_dp_url, p.avatar_url
  from public.profiles p
  where p.id = any(coalesce(p_user_ids, array[]::uuid[]))
    and auth.uid() is not null;
$$;
revoke all on function public.get_public_profile_cards(uuid[]) from public, anon;
grant execute on function public.get_public_profile_cards(uuid[]) to authenticated;
