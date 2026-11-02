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
