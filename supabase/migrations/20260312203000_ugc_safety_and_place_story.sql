create table if not exists public.community_post_reports (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.community_posts(id) on delete cascade,
  reporter_user_id uuid not null references auth.users(id) on delete cascade,
  reason text not null,
  details text,
  status text not null default 'pending' check (status in ('pending', 'reviewed', 'dismissed', 'actioned')),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  unique (post_id, reporter_user_id),
  check (char_length(reason) between 3 and 120),
  check (details is null or char_length(details) <= 600)
);

create table if not exists public.user_blocks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  blocked_user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, blocked_user_id),
  check (user_id <> blocked_user_id)
);

create table if not exists public.ugc_policy_acceptances (
  user_id uuid primary key references auth.users(id) on delete cascade,
  accepted_at timestamptz not null default now(),
  version text not null default '2026-03-12',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.place_story_submissions (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.pois(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null default '',
  story_text text not null,
  fact_type text not null default 'story' check (fact_type in ('story', 'local_tip', 'history_note', 'hidden_feature')),
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  admin_note text,
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (char_length(title) <= 140),
  check (char_length(story_text) between 40 and 2000)
);

create index if not exists community_post_reports_status_created_idx
  on public.community_post_reports(status, created_at desc);

create index if not exists community_post_reports_post_idx
  on public.community_post_reports(post_id, created_at desc);

create index if not exists user_blocks_user_idx
  on public.user_blocks(user_id, created_at desc);

create index if not exists place_story_submissions_status_created_idx
  on public.place_story_submissions(status, created_at desc);

create index if not exists place_story_submissions_place_status_idx
  on public.place_story_submissions(place_id, status, created_at desc);

create or replace function public.touch_simple_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_ugc_policy_acceptances_touch on public.ugc_policy_acceptances;
create trigger trg_ugc_policy_acceptances_touch
before update on public.ugc_policy_acceptances
for each row execute function public.touch_simple_updated_at();

drop trigger if exists trg_place_story_submissions_touch on public.place_story_submissions;
create trigger trg_place_story_submissions_touch
before update on public.place_story_submissions
for each row execute function public.touch_simple_updated_at();

alter table public.community_post_reports enable row level security;
alter table public.user_blocks enable row level security;
alter table public.ugc_policy_acceptances enable row level security;
alter table public.place_story_submissions enable row level security;

drop policy if exists community_post_reports_insert_own on public.community_post_reports;
create policy community_post_reports_insert_own
on public.community_post_reports
for insert
to authenticated
with check (auth.uid() = reporter_user_id);

drop policy if exists community_post_reports_select_own_or_admin on public.community_post_reports;
create policy community_post_reports_select_own_or_admin
on public.community_post_reports
for select
to authenticated
using (auth.uid() = reporter_user_id or public.is_admin(auth.uid()));

drop policy if exists community_post_reports_admin_update on public.community_post_reports;
create policy community_post_reports_admin_update
on public.community_post_reports
for update
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists user_blocks_select_own_or_admin on public.user_blocks;
create policy user_blocks_select_own_or_admin
on public.user_blocks
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists user_blocks_insert_own on public.user_blocks;
create policy user_blocks_insert_own
on public.user_blocks
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists user_blocks_delete_own_or_admin on public.user_blocks;
create policy user_blocks_delete_own_or_admin
on public.user_blocks
for delete
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists ugc_policy_acceptances_select_own_or_admin on public.ugc_policy_acceptances;
create policy ugc_policy_acceptances_select_own_or_admin
on public.ugc_policy_acceptances
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists ugc_policy_acceptances_upsert_own_or_admin on public.ugc_policy_acceptances;
create policy ugc_policy_acceptances_upsert_own_or_admin
on public.ugc_policy_acceptances
for all
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()))
with check (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists place_story_submissions_select_visible on public.place_story_submissions;
create policy place_story_submissions_select_visible
on public.place_story_submissions
for select
to authenticated
using (
  status = 'approved'
  or auth.uid() = user_id
  or public.is_admin(auth.uid())
);

drop policy if exists place_story_submissions_insert_own on public.place_story_submissions;
create policy place_story_submissions_insert_own
on public.place_story_submissions
for insert
to authenticated
with check (auth.uid() = user_id and status = 'pending');

drop policy if exists place_story_submissions_update_owner_or_admin on public.place_story_submissions;
create policy place_story_submissions_update_owner_or_admin
on public.place_story_submissions
for update
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()))
with check (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists place_story_submissions_delete_owner_or_admin on public.place_story_submissions;
create policy place_story_submissions_delete_owner_or_admin
on public.place_story_submissions
for delete
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));
