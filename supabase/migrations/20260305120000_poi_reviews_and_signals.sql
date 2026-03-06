-- POI-native engagement layer for clean/compliant runtime.

create table if not exists public.poi_reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  poi_id uuid not null references public.pois(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  flags text[] not null default '{}'::text[],
  comment_short text not null default '' check (char_length(comment_short) <= 240),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, poi_id),
  check (
    flags <@ array[
      'crowded',
      'family',
      'quiet',
      'photo_spot',
      'budget',
      'sunset_worthy'
    ]::text[]
  )
);

create index if not exists poi_reviews_poi_idx on public.poi_reviews(poi_id, created_at desc);
create index if not exists poi_reviews_user_idx on public.poi_reviews(user_id, created_at desc);

create table if not exists public.poi_signals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  poi_id uuid not null references public.pois(id) on delete cascade,
  type text not null check (type in ('checkin','favorite','rating')),
  rating numeric,
  created_at timestamptz not null default now()
);

create index if not exists poi_signals_poi_type_idx on public.poi_signals(poi_id, type, created_at desc);
create index if not exists poi_signals_user_created_idx on public.poi_signals(user_id, created_at desc);
create unique index if not exists poi_signals_user_poi_once_uidx
  on public.poi_signals(user_id, poi_id, type)
  where type in ('checkin','favorite');

alter table public.poi_reviews enable row level security;
alter table public.poi_signals enable row level security;

drop policy if exists poi_reviews_select_public on public.poi_reviews;
create policy poi_reviews_select_public
on public.poi_reviews
for select
using (true);

drop policy if exists poi_reviews_insert_own on public.poi_reviews;
create policy poi_reviews_insert_own
on public.poi_reviews
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists poi_reviews_update_own on public.poi_reviews;
create policy poi_reviews_update_own
on public.poi_reviews
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists poi_reviews_delete_own_or_admin on public.poi_reviews;
create policy poi_reviews_delete_own_or_admin
on public.poi_reviews
for delete
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists poi_signals_select_public on public.poi_signals;
create policy poi_signals_select_public
on public.poi_signals
for select
using (true);

drop policy if exists poi_signals_insert_own on public.poi_signals;
create policy poi_signals_insert_own
on public.poi_signals
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists poi_signals_delete_own_or_admin on public.poi_signals;
create policy poi_signals_delete_own_or_admin
on public.poi_signals
for delete
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

create or replace view public.poi_stats
with (security_invoker = on)
as
select
  r.poi_id as place_id,
  round(avg(r.rating)::numeric, 2) as avg_rating,
  count(*)::int as review_count,
  count(*) filter (where r.flags @> array['crowded']::text[])::int as crowded_count,
  count(*) filter (where r.flags @> array['family']::text[])::int as family_count,
  count(*) filter (where r.flags @> array['photo_spot']::text[])::int as photo_spot_count,
  count(*) filter (where r.flags @> array['sunset_worthy']::text[])::int as sunset_worthy_count
from public.poi_reviews r
group by r.poi_id;

grant select on public.poi_stats to anon, authenticated;

create or replace function public.get_poi_stats(p_poi_id uuid)
returns jsonb
language sql
stable
security invoker
as $$
  with stat as (
    select
      avg_rating,
      review_count,
      crowded_count,
      family_count,
      photo_spot_count,
      sunset_worthy_count
    from public.poi_stats
    where place_id = p_poi_id
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
      from public.poi_reviews
      where poi_id = p_poi_id
      order by created_at desc
      limit 8
    ) r
  )
  select jsonb_build_object(
    'place_id', p_poi_id,
    'avg_rating', coalesce((select avg_rating from stat), 0),
    'review_count', coalesce((select review_count from stat), 0),
    'crowded_count', coalesce((select crowded_count from stat), 0),
    'family_count', coalesce((select family_count from stat), 0),
    'photo_spot_count', coalesce((select photo_spot_count from stat), 0),
    'sunset_worthy_count', coalesce((select sunset_worthy_count from stat), 0),
    'recent_reviews', coalesce((select items from recent), '[]'::jsonb)
  );
$$;

grant execute on function public.get_poi_stats(uuid) to anon, authenticated;
