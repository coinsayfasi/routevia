create table if not exists public.community_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  related_route_id uuid references public.trips_clean(id) on delete set null,
  title text not null default '',
  summary text not null default '',
  city text not null default '',
  country text not null default '',
  post_type text not null default 'story' check (post_type in ('story', 'guide')),
  cover_storage_path text,
  content_body text not null default '',
  tags text[] not null default '{}'::text[],
  status text not null default 'draft' check (status in ('draft', 'pending', 'approved', 'rejected')),
  admin_note text,
  submitted_at timestamptz,
  published_at timestamptz,
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id) on delete set null,
  estimated_read_minutes int not null default 1 check (estimated_read_minutes between 1 and 60),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.community_posts
  add column if not exists user_id uuid references auth.users(id) on delete cascade,
  add column if not exists related_route_id uuid references public.trips_clean(id) on delete set null,
  add column if not exists title text not null default '',
  add column if not exists summary text not null default '',
  add column if not exists city text not null default '',
  add column if not exists country text not null default '',
  add column if not exists post_type text not null default 'story',
  add column if not exists cover_storage_path text,
  add column if not exists content_body text not null default '',
  add column if not exists tags text[] not null default '{}'::text[],
  add column if not exists status text not null default 'draft',
  add column if not exists admin_note text,
  add column if not exists submitted_at timestamptz,
  add column if not exists published_at timestamptz,
  add column if not exists reviewed_at timestamptz,
  add column if not exists reviewed_by uuid references auth.users(id) on delete set null,
  add column if not exists estimated_read_minutes int not null default 1,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

alter table public.community_posts
  drop constraint if exists community_posts_post_type_check;

alter table public.community_posts
  add constraint community_posts_post_type_check
  check (post_type in ('story', 'guide'));

alter table public.community_posts
  drop constraint if exists community_posts_status_check;

alter table public.community_posts
  add constraint community_posts_status_check
  check (status in ('draft', 'pending', 'approved', 'rejected'));

create table if not exists public.community_post_gallery (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.community_posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  storage_path text not null unique,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.community_post_gallery
  add column if not exists post_id uuid references public.community_posts(id) on delete cascade,
  add column if not exists user_id uuid references auth.users(id) on delete cascade,
  add column if not exists storage_path text,
  add column if not exists sort_order int not null default 0,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

alter table public.community_post_gallery
  alter column storage_path set not null;

create index if not exists community_posts_user_status_updated_idx
  on public.community_posts(user_id, status, updated_at desc);

create index if not exists community_posts_public_feed_idx
  on public.community_posts(status, published_at desc nulls last, created_at desc);

create index if not exists community_posts_route_idx
  on public.community_posts(related_route_id);

create index if not exists community_post_gallery_post_sort_idx
  on public.community_post_gallery(post_id, sort_order, created_at);

create or replace function public.community_posts_touch_metadata()
returns trigger
language plpgsql
as $$
declare
  v_body text;
  v_word_count int := 0;
begin
  new.updated_at := now();
  v_body := trim(regexp_replace(coalesce(new.content_body, ''), '\s+', ' ', 'g'));
  if v_body <> '' then
    v_word_count := array_length(regexp_split_to_array(v_body, ' '), 1);
  end if;
  new.estimated_read_minutes := greatest(1, least(60, ceil(greatest(v_word_count, 1)::numeric / 180.0)::int));

  if new.status = 'approved' and new.published_at is null then
    new.published_at := now();
  elsif new.status <> 'approved' then
    new.published_at := null;
  end if;

  if new.status = 'pending' and new.submitted_at is null then
    new.submitted_at := now();
  end if;

  return new;
end;
$$;

create or replace function public.community_gallery_touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_community_posts_touch_metadata on public.community_posts;
create trigger trg_community_posts_touch_metadata
before insert or update on public.community_posts
for each row execute function public.community_posts_touch_metadata();

drop trigger if exists trg_community_post_gallery_touch_updated_at on public.community_post_gallery;
create trigger trg_community_post_gallery_touch_updated_at
before update on public.community_post_gallery
for each row execute function public.community_gallery_touch_updated_at();

alter table public.community_posts enable row level security;
alter table public.community_post_gallery enable row level security;

drop policy if exists community_posts_select_visible on public.community_posts;
create policy community_posts_select_visible
on public.community_posts
for select
to authenticated
using (
  status = 'approved'
  or auth.uid() = user_id
  or public.is_admin(auth.uid())
);

drop policy if exists community_posts_insert_own on public.community_posts;
create policy community_posts_insert_own
on public.community_posts
for insert
to authenticated
with check (
  auth.uid() = user_id
  and status in ('draft', 'pending')
);

drop policy if exists community_posts_update_owner_or_admin on public.community_posts;
create policy community_posts_update_owner_or_admin
on public.community_posts
for update
to authenticated
using (
  (
    auth.uid() = user_id
    and status in ('draft', 'rejected', 'pending')
  )
  or public.is_admin(auth.uid())
)
with check (
  (
    auth.uid() = user_id
    and user_id = auth.uid()
    and status in ('draft', 'pending', 'rejected')
  )
  or public.is_admin(auth.uid())
);

drop policy if exists community_posts_delete_owner_or_admin on public.community_posts;
create policy community_posts_delete_owner_or_admin
on public.community_posts
for delete
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists community_post_gallery_select_visible on public.community_post_gallery;
create policy community_post_gallery_select_visible
on public.community_post_gallery
for select
to authenticated
using (
  exists (
    select 1
    from public.community_posts cp
    where cp.id = post_id
      and (
        cp.status = 'approved'
        or cp.user_id = auth.uid()
        or public.is_admin(auth.uid())
      )
  )
);

drop policy if exists community_post_gallery_insert_own on public.community_post_gallery;
create policy community_post_gallery_insert_own
on public.community_post_gallery
for insert
to authenticated
with check (
  auth.uid() = user_id
  and exists (
    select 1
    from public.community_posts cp
    where cp.id = post_id
      and cp.user_id = auth.uid()
  )
);

drop policy if exists community_post_gallery_update_owner_or_admin on public.community_post_gallery;
create policy community_post_gallery_update_owner_or_admin
on public.community_post_gallery
for update
to authenticated
using (
  auth.uid() = user_id
  or public.is_admin(auth.uid())
)
with check (
  auth.uid() = user_id
  or public.is_admin(auth.uid())
);

drop policy if exists community_post_gallery_delete_owner_or_admin on public.community_post_gallery;
create policy community_post_gallery_delete_owner_or_admin
on public.community_post_gallery
for delete
to authenticated
using (
  auth.uid() = user_id
  or public.is_admin(auth.uid())
);

insert into storage.buckets (id, name, public)
values ('community-posts', 'community-posts', false)
on conflict (id) do update
set public = excluded.public;

drop policy if exists "Authenticated read community-posts" on storage.objects;
create policy "Authenticated read community-posts"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'community-posts'
  and (
    public.is_admin(auth.uid())
    or (storage.foldername(name))[1] = auth.uid()::text
    or exists (
      select 1
      from public.community_posts cp
      where cp.id::text = (storage.foldername(name))[2]
        and cp.status = 'approved'
    )
  )
);

drop policy if exists "Authenticated upload own community-posts" on storage.objects;
create policy "Authenticated upload own community-posts"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'community-posts'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Authenticated delete own community-posts" on storage.objects;
create policy "Authenticated delete own community-posts"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'community-posts'
  and (
    public.is_admin(auth.uid())
    or (storage.foldername(name))[1] = auth.uid()::text
  )
);
