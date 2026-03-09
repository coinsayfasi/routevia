create table if not exists public.place_reviews (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.pois(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  comment text not null default '',
  flags text[] not null default '{}'::text[],
  status text not null default 'pending' check (status in ('pending','approved','hidden')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (place_id, user_id),
  check (char_length(comment) <= 1200)
);

alter table public.place_reviews
  add column if not exists comment text not null default '',
  add column if not exists status text not null default 'pending',
  add column if not exists flags text[] not null default '{}'::text[];

alter table public.place_reviews
  drop constraint if exists place_reviews_status_check;

alter table public.place_reviews
  add constraint place_reviews_status_check
  check (status in ('pending','approved','hidden'));

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'place_reviews'
      and column_name = 'comment_short'
  ) then
    execute $sql$
      update public.place_reviews
      set comment = case
        when coalesce(comment, '') = '' then coalesce(comment_short, '')
        else comment
      end
    $sql$;
  end if;
end $$;

create table if not exists public.place_photos (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.pois(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  image_url text not null,
  storage_path text not null unique,
  status text not null default 'pending' check (status in ('pending','approved','rejected','hidden')),
  likes_count int not null default 0 check (likes_count >= 0),
  reports_count int not null default 0 check (reports_count >= 0),
  width_px int,
  height_px int,
  file_size_bytes int,
  moderation_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.place_photos
  add column if not exists storage_path text,
  add column if not exists width_px int,
  add column if not exists height_px int,
  add column if not exists file_size_bytes int,
  add column if not exists moderation_note text,
  add column if not exists updated_at timestamptz not null default now();

update public.place_photos
set storage_path = coalesce(storage_path, image_url)
where storage_path is null;

alter table public.place_photos
  alter column storage_path set not null;

create table if not exists public.place_checkins (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.pois(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.user_trust (
  user_id uuid primary key references auth.users(id) on delete cascade,
  trust_score int not null default 0,
  reviews_count int not null default 0,
  photos_count int not null default 0,
  reports_count int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.photo_reports (
  id uuid primary key default gen_random_uuid(),
  photo_id uuid not null references public.place_photos(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  reason text not null,
  created_at timestamptz not null default now(),
  unique (photo_id, user_id),
  check (char_length(reason) between 3 and 240)
);

create table if not exists public.place_community_state (
  place_id uuid primary key references public.pois(id) on delete cascade,
  cover_photo text,
  routevia_score numeric(12,4) not null default 0,
  avg_rating numeric(4,2) not null default 0,
  review_count int not null default 0,
  checkins_count int not null default 0,
  photo_count int not null default 0,
  updated_at timestamptz not null default now()
);

create index if not exists place_reviews_place_status_idx
  on public.place_reviews(place_id, status, created_at desc);
create index if not exists place_reviews_user_created_idx
  on public.place_reviews(user_id, created_at desc);
create index if not exists place_photos_place_status_idx
  on public.place_photos(place_id, status, created_at desc);
create index if not exists place_photos_user_created_idx
  on public.place_photos(user_id, created_at desc);
create index if not exists place_checkins_place_created_idx
  on public.place_checkins(place_id, created_at desc);
create index if not exists place_checkins_user_created_idx
  on public.place_checkins(user_id, created_at desc);
create index if not exists photo_reports_photo_created_idx
  on public.photo_reports(photo_id, created_at desc);
create unique index if not exists place_checkins_user_place_day_uidx
  on public.place_checkins(
    place_id,
    user_id,
    ((created_at at time zone 'UTC')::date)
  );

create or replace function public.community_touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_place_reviews_touch_updated_at on public.place_reviews;
create trigger trg_place_reviews_touch_updated_at
before update on public.place_reviews
for each row execute function public.community_touch_updated_at();

drop trigger if exists trg_place_photos_touch_updated_at on public.place_photos;
create trigger trg_place_photos_touch_updated_at
before update on public.place_photos
for each row execute function public.community_touch_updated_at();

drop trigger if exists trg_user_trust_touch_updated_at on public.user_trust;
create trigger trg_user_trust_touch_updated_at
before update on public.user_trust
for each row execute function public.community_touch_updated_at();

drop trigger if exists trg_place_community_state_touch_updated_at on public.place_community_state;
create trigger trg_place_community_state_touch_updated_at
before update on public.place_community_state
for each row execute function public.community_touch_updated_at();

create or replace function public.recalc_user_trust(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_reviews_count int := 0;
  v_photos_count int := 0;
  v_reports_count int := 0;
begin
  if p_user_id is null then
    return;
  end if;

  select count(*)::int
  into v_reviews_count
  from public.place_reviews
  where user_id = p_user_id
    and status = 'approved';

  select count(*)::int
  into v_photos_count
  from public.place_photos
  where user_id = p_user_id
    and status = 'approved';

  select count(*)::int
  into v_reports_count
  from public.photo_reports pr
  join public.place_photos pp on pp.id = pr.photo_id
  where pp.user_id = p_user_id;

  insert into public.user_trust (
    user_id,
    trust_score,
    reviews_count,
    photos_count,
    reports_count,
    created_at,
    updated_at
  )
  values (
    p_user_id,
    greatest(0, v_reviews_count * 2 + v_photos_count * 3 - v_reports_count * 5),
    v_reviews_count,
    v_photos_count,
    v_reports_count,
    now(),
    now()
  )
  on conflict (user_id) do update
  set trust_score = excluded.trust_score,
      reviews_count = excluded.reviews_count,
      photos_count = excluded.photos_count,
      reports_count = excluded.reports_count,
      updated_at = now();
end;
$$;

grant execute on function public.recalc_user_trust(uuid) to authenticated;

create or replace function public.recalc_place_photo_reports(p_photo_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_reports int := 0;
begin
  if p_photo_id is null then
    return;
  end if;

  select count(*)::int
  into v_reports
  from public.photo_reports
  where photo_id = p_photo_id;

  update public.place_photos
  set reports_count = v_reports,
      status = case
        when v_reports >= 3 then 'hidden'
        when status = 'hidden' and v_reports < 3 then 'approved'
        else status
      end,
      updated_at = now()
  where id = p_photo_id;
end;
$$;

create or replace function public.recalc_place_community_state(p_place_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_avg_rating numeric(4,2) := 0;
  v_review_count int := 0;
  v_checkins_count int := 0;
  v_photo_count int := 0;
  v_cover_photo text := null;
  v_routevia_score numeric(12,4) := 0;
begin
  if p_place_id is null then
    return;
  end if;

  select
    coalesce(avg(r.rating)::numeric(4,2), 0),
    count(*)::int
  into
    v_avg_rating,
    v_review_count
  from public.place_reviews r
  where r.place_id = p_place_id
    and r.status = 'approved';

  select count(*)::int
  into v_checkins_count
  from public.place_checkins c
  where c.place_id = p_place_id;

  select count(*)::int
  into v_photo_count
  from public.place_photos p
  where p.place_id = p_place_id
    and p.status = 'approved';

  select ranked.image_url
  into v_cover_photo
  from (
    select
      p.image_url,
      (p.likes_count + coalesce(ut.trust_score, 0) - p.reports_count) as photo_score,
      p.created_at
    from public.place_photos p
    left join public.user_trust ut on ut.user_id = p.user_id
    where p.place_id = p_place_id
      and p.status = 'approved'
  ) ranked
  order by ranked.photo_score desc, ranked.created_at asc
  limit 1;

  v_routevia_score :=
    coalesce(v_avg_rating, 0)
    * ln(v_checkins_count + 1)
    * ln(v_photo_count + 1);

  insert into public.place_community_state(
    place_id,
    cover_photo,
    routevia_score,
    avg_rating,
    review_count,
    checkins_count,
    photo_count,
    updated_at
  )
  values (
    p_place_id,
    v_cover_photo,
    coalesce(v_routevia_score, 0),
    coalesce(v_avg_rating, 0),
    v_review_count,
    v_checkins_count,
    v_photo_count,
    now()
  )
  on conflict (place_id) do update
  set cover_photo = excluded.cover_photo,
      routevia_score = excluded.routevia_score,
      avg_rating = excluded.avg_rating,
      review_count = excluded.review_count,
      checkins_count = excluded.checkins_count,
      photo_count = excluded.photo_count,
      updated_at = now();
end;
$$;

grant execute on function public.recalc_place_community_state(uuid) to authenticated;

create or replace function public.handle_place_review_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    perform public.recalc_user_trust(old.user_id);
    perform public.recalc_place_community_state(old.place_id);
  else
    perform public.recalc_user_trust(new.user_id);
    perform public.recalc_place_community_state(new.place_id);
  end if;
  return null;
end;
$$;

drop trigger if exists trg_place_review_change on public.place_reviews;
create trigger trg_place_review_change
after insert or update or delete on public.place_reviews
for each row execute function public.handle_place_review_change();

create or replace function public.handle_place_photo_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    perform public.recalc_user_trust(old.user_id);
    perform public.recalc_place_community_state(old.place_id);
  else
    perform public.recalc_user_trust(new.user_id);
    perform public.recalc_place_community_state(new.place_id);
  end if;
  return null;
end;
$$;

drop trigger if exists trg_place_photo_change on public.place_photos;
create trigger trg_place_photo_change
after insert or update or delete on public.place_photos
for each row execute function public.handle_place_photo_change();

create or replace function public.handle_place_checkin_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    perform public.recalc_place_community_state(old.place_id);
  else
    perform public.recalc_place_community_state(new.place_id);
  end if;
  return null;
end;
$$;

drop trigger if exists trg_place_checkin_change on public.place_checkins;
create trigger trg_place_checkin_change
after insert or delete on public.place_checkins
for each row execute function public.handle_place_checkin_change();

create or replace function public.handle_photo_report_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_photo_id uuid;
  v_place_id uuid;
  v_owner_id uuid;
begin
  v_photo_id := coalesce(new.photo_id, old.photo_id);
  if v_photo_id is null then
    return null;
  end if;

  perform public.recalc_place_photo_reports(v_photo_id);

  select place_id, user_id
  into v_place_id, v_owner_id
  from public.place_photos
  where id = v_photo_id;

  if v_owner_id is not null then
    perform public.recalc_user_trust(v_owner_id);
  end if;

  if v_place_id is not null then
    perform public.recalc_place_community_state(v_place_id);
  end if;

  return null;
end;
$$;

drop trigger if exists trg_photo_report_change on public.photo_reports;
create trigger trg_photo_report_change
after insert or delete on public.photo_reports
for each row execute function public.handle_photo_report_change();

create or replace function public.get_place_reviews(p_place_id uuid, p_limit int default 20, p_user_id uuid default auth.uid())
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  with base_reviews as (
    select
      r.id,
      r.place_id,
      r.user_id,
      r.rating,
      r.comment,
      r.flags,
      r.status,
      r.created_at,
      r.updated_at,
      coalesce(ut.trust_score, 0) as reviewer_score
    from public.place_reviews r
    left join public.user_trust ut on ut.user_id = r.user_id
    where r.place_id = p_place_id
      and (
        r.status = 'approved'
        or (p_user_id is not null and r.user_id = p_user_id)
      )
    order by r.created_at desc
    limit greatest(1, least(coalesce(p_limit, 20), 50))
  ),
  review_items as (
    select coalesce(
      jsonb_agg(
        jsonb_build_object(
          'id', br.id,
          'rating', br.rating,
          'comment', br.comment,
          'comment_short', br.comment,
          'flags', br.flags,
          'status', br.status,
          'created_at', br.created_at,
          'updated_at', br.updated_at,
          'reviewer_score', br.reviewer_score,
          'trust_level',
            case
              when br.reviewer_score >= 60 then 'local_contributor'
              when br.reviewer_score >= 25 then 'verified_traveler'
              else 'new_user'
            end
        )
        order by br.created_at desc
      ),
      '[]'::jsonb
    ) as items
    from base_reviews br
  ),
  counts as (
    select
      coalesce(avg(r.rating), 0)::numeric(4,2) as avg_rating,
      count(*)::int as review_count
    from public.place_reviews r
    where r.place_id = p_place_id
      and r.status = 'approved'
  )
  select jsonb_build_object(
    'place_id', p_place_id,
    'avg_rating', coalesce((select avg_rating from counts), 0),
    'review_count', coalesce((select review_count from counts), 0),
    'reviews', coalesce((select items from review_items), '[]'::jsonb)
  );
$$;

grant execute on function public.get_place_reviews(uuid, int, uuid) to authenticated;

create or replace function public.get_place_photos(p_place_id uuid, p_limit int default 24, p_user_id uuid default auth.uid())
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  with photos as (
    select
      p.id,
      p.place_id,
      p.user_id,
      p.image_url,
      p.storage_path,
      p.status,
      p.likes_count,
      p.reports_count,
      p.created_at,
      p.updated_at,
      coalesce(ut.trust_score, 0) as uploader_trust_score
    from public.place_photos p
    left join public.user_trust ut on ut.user_id = p.user_id
    where p.place_id = p_place_id
      and (
        p.status = 'approved'
        or (p_user_id is not null and p.user_id = p_user_id)
      )
    order by
      case when p.status = 'approved' then 0 else 1 end,
      (p.likes_count + coalesce(ut.trust_score, 0) - p.reports_count) desc,
      p.created_at desc
    limit greatest(1, least(coalesce(p_limit, 24), 50))
  )
  select jsonb_build_object(
    'place_id', p_place_id,
    'cover_photo', (
      select pcs.cover_photo
      from public.place_community_state pcs
      where pcs.place_id = p_place_id
    ),
    'photos', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'id', ph.id,
            'place_id', ph.place_id,
            'user_id', ph.user_id,
            'image_url', ph.image_url,
            'storage_path', ph.storage_path,
            'status', ph.status,
            'likes_count', ph.likes_count,
            'reports_count', ph.reports_count,
            'created_at', ph.created_at,
            'updated_at', ph.updated_at,
            'uploader_trust_score', ph.uploader_trust_score
          )
          order by
            case when ph.status = 'approved' then 0 else 1 end,
            (ph.likes_count + ph.uploader_trust_score - ph.reports_count) desc,
            ph.created_at desc
        )
        from photos ph
      ),
      '[]'::jsonb
    )
  );
$$;

grant execute on function public.get_place_photos(uuid, int, uuid) to authenticated;

alter table public.place_reviews enable row level security;
alter table public.place_photos enable row level security;
alter table public.place_checkins enable row level security;
alter table public.user_trust enable row level security;
alter table public.photo_reports enable row level security;
alter table public.place_community_state enable row level security;

drop policy if exists place_reviews_select_visible on public.place_reviews;
create policy place_reviews_select_visible
on public.place_reviews
for select
using (status = 'approved' or auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists place_reviews_insert_own on public.place_reviews;
create policy place_reviews_insert_own
on public.place_reviews
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists place_reviews_update_own on public.place_reviews;
create policy place_reviews_update_own
on public.place_reviews
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists place_reviews_delete_own on public.place_reviews;
create policy place_reviews_delete_own
on public.place_reviews
for delete
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists place_photos_select_visible on public.place_photos;
create policy place_photos_select_visible
on public.place_photos
for select
using (status = 'approved' or auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists place_photos_insert_own on public.place_photos;
create policy place_photos_insert_own
on public.place_photos
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists place_photos_delete_own on public.place_photos;
create policy place_photos_delete_own
on public.place_photos
for delete
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists place_checkins_select_own on public.place_checkins;
create policy place_checkins_select_own
on public.place_checkins
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists place_checkins_insert_own on public.place_checkins;
create policy place_checkins_insert_own
on public.place_checkins
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists photo_reports_insert_own on public.photo_reports;
create policy photo_reports_insert_own
on public.photo_reports
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists photo_reports_select_own_or_admin on public.photo_reports;
create policy photo_reports_select_own_or_admin
on public.photo_reports
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists user_trust_select_own_or_admin on public.user_trust;
create policy user_trust_select_own_or_admin
on public.user_trust
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists user_trust_admin_write on public.user_trust;
create policy user_trust_admin_write
on public.user_trust
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists place_community_state_read_authenticated on public.place_community_state;
create policy place_community_state_read_authenticated
on public.place_community_state
for select
using (true);

insert into storage.buckets (id, name, public)
values ('place-photos', 'place-photos', true)
on conflict (id) do update
set public = excluded.public;

drop policy if exists "Public read place-photos" on storage.objects;
create policy "Public read place-photos"
on storage.objects
for select
using (bucket_id = 'place-photos');

drop policy if exists "Authenticated upload own place-photos" on storage.objects;
create policy "Authenticated upload own place-photos"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'place-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Authenticated delete own place-photos" on storage.objects;
create policy "Authenticated delete own place-photos"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'place-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

insert into public.place_community_state (
  place_id,
  cover_photo,
  routevia_score,
  avg_rating,
  review_count,
  checkins_count,
  photo_count,
  updated_at
)
select
  p.id,
  null,
  0,
  0,
  0,
  0,
  0,
  now()
from public.pois p
on conflict (place_id) do nothing;
