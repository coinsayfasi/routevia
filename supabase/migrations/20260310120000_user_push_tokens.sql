create table if not exists public.user_push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  token text not null unique,
  platform text not null check (platform in ('android', 'ios')),
  enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  unique (user_id, token)
);

create index if not exists user_push_tokens_user_idx
  on public.user_push_tokens(user_id, enabled, updated_at desc);

drop trigger if exists trg_user_push_tokens_touch_updated_at on public.user_push_tokens;
create trigger trg_user_push_tokens_touch_updated_at
before update on public.user_push_tokens
for each row execute function public.community_touch_updated_at();

alter table public.user_push_tokens enable row level security;

drop policy if exists user_push_tokens_select_own on public.user_push_tokens;
create policy user_push_tokens_select_own
on public.user_push_tokens
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists user_push_tokens_insert_own on public.user_push_tokens;
create policy user_push_tokens_insert_own
on public.user_push_tokens
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists user_push_tokens_update_own on public.user_push_tokens;
create policy user_push_tokens_update_own
on public.user_push_tokens
for update
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()))
with check (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists user_push_tokens_delete_own on public.user_push_tokens;
create policy user_push_tokens_delete_own
on public.user_push_tokens
for delete
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));
