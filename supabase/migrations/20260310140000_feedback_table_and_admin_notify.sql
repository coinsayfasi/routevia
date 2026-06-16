-- feedback table (for user feedback / growth center)
create table if not exists public.feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  message text not null check (char_length(message) >= 4 and char_length(message) <= 1200),
  rating smallint check (rating is null or (rating >= 1 and rating <= 5)),
  created_at timestamptz not null default now()
);

create index if not exists feedback_user_created_idx on public.feedback(user_id, created_at desc);
create index if not exists feedback_created_idx on public.feedback(created_at desc);

alter table public.feedback enable row level security;

drop policy if exists feedback_insert_own on public.feedback;
create policy feedback_insert_own
on public.feedback
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists feedback_select_admin on public.feedback;
create policy feedback_select_admin
on public.feedback
for select
to authenticated
using (public.is_admin(auth.uid()));

-- admin_notifications table (for admin sending push to users)
create table if not exists public.admin_notifications (
  id uuid primary key default gen_random_uuid(),
  sent_by uuid references auth.users(id) on delete set null,
  target_user_id uuid references auth.users(id) on delete cascade,
  title text not null,
  body text not null,
  data jsonb default '{}'::jsonb,
  sent_at timestamptz not null default now(),
  success_count int default 0,
  fail_count int default 0
);

alter table public.admin_notifications enable row level security;

drop policy if exists admin_notifications_admin_all on public.admin_notifications;
create policy admin_notifications_admin_all
on public.admin_notifications
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));
