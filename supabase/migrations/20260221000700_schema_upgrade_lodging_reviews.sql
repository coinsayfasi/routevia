do $$
begin
  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    where t.typname = 'place_category' and e.enumlabel = 'lodging'
  ) then
    alter type public.place_category add value 'lodging';
  end if;
end $$;

alter table public.places
  add column if not exists price_level int,
  add column if not exists is_free boolean not null default false,
  add column if not exists google_place_id text;

alter table public.places
  drop constraint if exists places_price_level_check;
alter table public.places
  add constraint places_price_level_check check (price_level is null or price_level between 0 and 4);

update public.places
set is_free = true
where is_free = false and (
  tags && array['free','budget']::text[]
  or category in ('nature','viewpoint','market')
);

create unique index if not exists places_google_place_id_uidx
on public.places (google_place_id)
where google_place_id is not null;

alter table public.place_reviews
  add column if not exists flags text[] not null default '{}';

update public.place_reviews
set flags = case
  when coalesce(array_length(flags, 1), 0) > 0 then flags
  when coalesce(array_length(quick_flags, 1), 0) > 0 then quick_flags
  else '{}'::text[]
end;

alter table public.place_reviews
  drop constraint if exists place_reviews_flags_allowed_check;
alter table public.place_reviews
  add constraint place_reviews_flags_allowed_check check (
    flags <@ array[
      'crowded',
      'family',
      'quiet',
      'photo_spot',
      'budget',
      'sunset_worthy'
    ]::text[]
  );

create index if not exists place_reviews_place_created_idx
on public.place_reviews(place_id, created_at desc);

-- Recreate stats view using canonical flags column
create or replace view public.place_stats
with (security_invoker = on)
as
select
  r.place_id,
  round(avg(r.rating)::numeric, 2) as avg_rating,
  count(*)::int as review_count,
  round(avg(case when r.flags && array['crowded']::text[] then 1 else 0 end)::numeric, 3) as crowded_score,
  round(avg(case when r.flags && array['family']::text[] then 1 else 0 end)::numeric, 3) as family_score,
  round(avg(case when r.flags && array['photo_spot','sunset_worthy']::text[] then 1 else 0 end)::numeric, 3) as photo_score
from public.place_reviews r
group by r.place_id;

grant select on public.place_stats to anon, authenticated;

-- RLS hardening for community reviews
alter table public.place_reviews enable row level security;

drop policy if exists "place_reviews_owner_insert" on public.place_reviews;
drop policy if exists "place_reviews_owner_update" on public.place_reviews;
drop policy if exists "place_reviews_owner_delete" on public.place_reviews;
drop policy if exists "place_reviews_owner_select" on public.place_reviews;
drop policy if exists "place_reviews_public_select" on public.place_reviews;
drop policy if exists "place_reviews_auth_insert" on public.place_reviews;
drop policy if exists "place_reviews_owner_or_admin_update" on public.place_reviews;
drop policy if exists "place_reviews_owner_or_admin_delete" on public.place_reviews;

create policy "place_reviews_public_select"
on public.place_reviews
for select
to anon, authenticated
using (true);

create policy "place_reviews_auth_insert"
on public.place_reviews
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "place_reviews_owner_or_admin_update"
on public.place_reviews
for update
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()))
with check (auth.uid() = user_id or public.is_admin(auth.uid()));

create policy "place_reviews_owner_or_admin_delete"
on public.place_reviews
for delete
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

-- keep RPC aligned with current flags model
create or replace function public.get_place_stats(p_place_id uuid)
returns jsonb
language sql
stable
security invoker
as $$
  with stat as (
    select
      place_id,
      avg_rating,
      review_count,
      crowded_score,
      family_score,
      photo_score
    from public.place_stats
    where place_id = p_place_id
  ),
  recent as (
    select jsonb_agg(
      jsonb_build_object(
        'rating', r.rating,
        'flags', r.flags,
        'comment_short', r.comment_short,
        'created_at', r.created_at
      )
      order by r.created_at desc
    ) as items
    from (
      select rating, flags, comment_short, created_at
      from public.place_reviews
      where place_id = p_place_id
      order by created_at desc
      limit 8
    ) r
  )
  select jsonb_build_object(
    'place_id', p_place_id,
    'avg_rating', coalesce((select avg_rating from stat), 0),
    'review_count', coalesce((select review_count from stat), 0),
    'crowded_score', coalesce((select crowded_score from stat), 0),
    'family_score', coalesce((select family_score from stat), 0),
    'photo_score', coalesce((select photo_score from stat), 0),
    'recent_reviews', coalesce((select items from recent), '[]'::jsonb)
  );
$$;

grant execute on function public.get_place_stats(uuid) to anon, authenticated;
