create table if not exists public.place_reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  place_id uuid not null references public.places(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  worth_it boolean not null,
  crowded_level int not null check (crowded_level between 1 and 3),
  family_friendly boolean not null,
  quick_flags text[] not null default '{}',
  comment_short text not null default '' check (char_length(comment_short) <= 240),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, place_id),
  check (
    quick_flags <@ array[
      'crowded',
      'family',
      'budget',
      'sunset_worthy',
      'photo'
    ]::text[]
  )
);

create index if not exists place_reviews_place_idx on public.place_reviews(place_id);
create index if not exists place_reviews_user_idx on public.place_reviews(user_id);

create trigger trg_place_reviews_updated_at
before update on public.place_reviews
for each row execute function public.set_updated_at();

alter table public.place_reviews enable row level security;

create policy "place_reviews_owner_insert"
on public.place_reviews
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "place_reviews_owner_update"
on public.place_reviews
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "place_reviews_owner_delete"
on public.place_reviews
for delete
to authenticated
using (auth.uid() = user_id);

create policy "place_reviews_owner_select"
on public.place_reviews
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

create or replace view public.place_stats
with (security_invoker = on)
as
select
  r.place_id,
  round(avg(r.rating)::numeric, 2) as avg_rating,
  count(*)::int as review_count,
  round(avg(case when r.crowded_level = 3 then 1 else 0 end)::numeric, 3) as crowded_score,
  round(avg(case when r.family_friendly then 1 else 0 end)::numeric, 3) as family_score,
  round(
    avg(
      case
        when r.quick_flags && array['photo', 'sunset_worthy']::text[] then 1
        else 0
      end
    )::numeric,
    3
  ) as photo_score
from public.place_reviews r
group by r.place_id;

grant select on public.place_stats to anon, authenticated;

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
        'worth_it', r.worth_it,
        'crowded_level', r.crowded_level,
        'family_friendly', r.family_friendly,
        'quick_flags', r.quick_flags,
        'comment_short', r.comment_short,
        'created_at', r.created_at
      )
      order by r.created_at desc
    ) as items
    from (
      select
        rating,
        worth_it,
        crowded_level,
        family_friendly,
        quick_flags,
        comment_short,
        created_at
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
