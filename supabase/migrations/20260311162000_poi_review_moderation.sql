alter table public.poi_reviews
  add column if not exists status text not null default 'pending';

alter table public.poi_reviews
  drop constraint if exists poi_reviews_status_check;

alter table public.poi_reviews
  add constraint poi_reviews_status_check
  check (status in ('pending', 'approved', 'hidden'));

update public.poi_reviews
set status = 'approved'
where status is null
   or btrim(status) = '';

create index if not exists poi_reviews_status_idx
  on public.poi_reviews(status, created_at desc);

drop policy if exists poi_reviews_select_public on public.poi_reviews;
drop policy if exists poi_reviews_select_visible on public.poi_reviews;
create policy poi_reviews_select_visible
on public.poi_reviews
for select
using (
  status = 'approved'
  or auth.uid() = user_id
  or public.is_admin(auth.uid())
);

drop policy if exists poi_reviews_insert_own on public.poi_reviews;
create policy poi_reviews_insert_own
on public.poi_reviews
for insert
to authenticated
with check (
  auth.uid() = user_id
  and status = 'pending'
);

drop policy if exists poi_reviews_update_own on public.poi_reviews;
drop policy if exists poi_reviews_admin_update on public.poi_reviews;
create policy poi_reviews_update_own
on public.poi_reviews
for update
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()))
with check (auth.uid() = user_id or public.is_admin(auth.uid()));

create or replace function public.guard_poi_review_status()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if public.is_admin(auth.uid()) then
    return new;
  end if;
  new.status := 'pending';
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_poi_reviews_guard_status on public.poi_reviews;
create trigger trg_poi_reviews_guard_status
before update on public.poi_reviews
for each row execute function public.guard_poi_review_status();

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
where r.status = 'approved'
group by r.poi_id;

grant select on public.poi_stats to anon, authenticated;

create or replace function public.recalc_poi_trust_score(p_poi_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_weighted_rating numeric := 0;
  v_review_count int := 0;
  v_fav int := 0;
  v_checkin int := 0;
  v_signal_quality numeric := 0;
  v_freshness numeric := 0;
  v_spam_risk numeric := 0;
  v_media_quality numeric := 0.45;
  v_trust_score numeric := 0;
begin
  if p_poi_id is null then
    return;
  end if;

  select
    coalesce(sum(r.rating * greatest(0.3, coalesce(ur.score, 40)::numeric / 100.0))
      / nullif(sum(greatest(0.3, coalesce(ur.score, 40)::numeric / 100.0)), 0), 0),
    count(*)::int,
    coalesce(
      avg(
        case
          when coalesce(ur.score, 40) < 35 then 1
          else 0
        end
      ),
      0
    )
  into v_weighted_rating, v_review_count, v_spam_risk
  from public.poi_reviews r
  left join public.user_reputation ur on ur.user_id = r.user_id
  where r.poi_id = p_poi_id
    and r.status = 'approved';

  select
    count(*) filter (where type = 'favorite')::int,
    count(*) filter (where type = 'checkin')::int
  into v_fav, v_checkin
  from public.poi_signals s
  where s.poi_id = p_poi_id
    and s.created_at >= now() - interval '30 days';

  v_signal_quality := least(1, ((v_fav * 1.2 + v_checkin * 0.8) / greatest(8, v_review_count + 4)::numeric));

  select
    case
      when max(ts) is null then 0.2
      when now() - max(ts) <= interval '7 days' then 1.0
      when now() - max(ts) <= interval '30 days' then 0.7
      else 0.4
    end
  into v_freshness
  from (
    select max(created_at) as ts
    from public.poi_reviews
    where poi_id = p_poi_id
      and status = 'approved'
    union all
    select max(created_at) as ts from public.poi_signals where poi_id = p_poi_id
  ) x;

  v_trust_score :=
    (coalesce(v_weighted_rating, 0) / 5.0) * 45
    + coalesce(v_signal_quality, 0) * 20
    + coalesce(v_freshness, 0) * 15
    + v_media_quality * 10
    + (1 - least(1, coalesce(v_spam_risk, 0))) * 10;

  v_trust_score := greatest(0, least(100, v_trust_score));

  insert into public.poi_trust_metrics(
    poi_id,
    trust_score,
    weighted_rating,
    review_count,
    signal_quality,
    media_quality,
    freshness_score,
    spam_risk,
    updated_at
  )
  values (
    p_poi_id,
    round(v_trust_score::numeric, 2),
    round(coalesce(v_weighted_rating, 0)::numeric, 2),
    v_review_count,
    round(coalesce(v_signal_quality, 0)::numeric, 3),
    round(v_media_quality::numeric, 3),
    round(coalesce(v_freshness, 0)::numeric, 3),
    round(coalesce(v_spam_risk, 0)::numeric, 3),
    now()
  )
  on conflict (poi_id) do update
  set trust_score = excluded.trust_score,
      weighted_rating = excluded.weighted_rating,
      review_count = excluded.review_count,
      signal_quality = excluded.signal_quality,
      media_quality = excluded.media_quality,
      freshness_score = excluded.freshness_score,
      spam_risk = excluded.spam_risk,
      updated_at = now();
end;
$$;

create or replace function public.refresh_poi_live_status(p_poi_id uuid, p_hours int default 6)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_crowded int := 0;
  v_family int := 0;
  v_sunset int := 0;
  v_quiet int := 0;
  v_conf int := 0;
  v_last timestamptz := null;
  v_tags text[] := '{}';
  v_total int := 0;
begin
  if p_poi_id is null then
    return;
  end if;

  with recent as (
    select
      count(*)::int as total,
      count(*) filter (where r.flags @> array['crowded']::text[])::int as crowded_cnt,
      count(*) filter (where r.flags @> array['family']::text[])::int as family_cnt,
      count(*) filter (where r.flags @> array['sunset_worthy']::text[])::int as sunset_cnt,
      count(*) filter (where r.flags @> array['quiet']::text[])::int as quiet_cnt,
      max(r.created_at) as last_ts
    from public.poi_reviews r
    where r.poi_id = p_poi_id
      and r.status = 'approved'
      and r.created_at >= now() - make_interval(hours => greatest(1, p_hours))
  ), sig as (
    select
      count(*)::int as total_sig,
      count(*) filter (where type = 'checkin')::int as checkin_cnt,
      max(created_at) as last_sig
    from public.poi_signals s
    where s.poi_id = p_poi_id
      and s.created_at >= now() - make_interval(hours => greatest(1, p_hours))
  )
  select
    coalesce(r.total,0),
    coalesce(r.crowded_cnt,0),
    coalesce(r.family_cnt,0),
    coalesce(r.sunset_cnt,0),
    coalesce(r.quiet_cnt,0),
    greatest(coalesce(r.last_ts, 'epoch'::timestamptz), coalesce(sig.last_sig, 'epoch'::timestamptz)),
    coalesce(sig.total_sig,0)
  into v_total, v_crowded, v_family, v_sunset, v_quiet, v_last, v_conf
  from recent r, sig;

  if v_total > 0 then
    v_crowded := least(100, round((v_crowded::numeric / v_total) * 100)::int);
    v_family := least(100, round((v_family::numeric / v_total) * 100)::int);
    v_sunset := least(100, round((v_sunset::numeric / v_total) * 100)::int);
    v_quiet := least(100, round((v_quiet::numeric / v_total) * 100)::int);
  else
    v_crowded := 0;
    v_family := 0;
    v_sunset := 0;
    v_quiet := 0;
  end if;

  v_conf := least(100, round((least(20, v_total)::numeric / 20) * 70 + (least(20, v_conf)::numeric / 20) * 30)::int);

  if v_crowded >= 45 then v_tags := array_append(v_tags, 'kalabalik'); end if;
  if v_family >= 35 then v_tags := array_append(v_tags, 'aile_uygun'); end if;
  if v_sunset >= 30 then v_tags := array_append(v_tags, 'gun_batimi'); end if;
  if v_quiet >= 30 and v_crowded < 35 then v_tags := array_append(v_tags, 'sessiz'); end if;

  insert into public.poi_live_status(
    poi_id,
    crowded_score,
    family_score,
    sunset_score,
    quiet_score,
    tags,
    confidence,
    last_event_at,
    updated_at
  ) values (
    p_poi_id,
    v_crowded,
    v_family,
    v_sunset,
    v_quiet,
    coalesce(v_tags, '{}'),
    v_conf,
    nullif(v_last, 'epoch'::timestamptz),
    now()
  )
  on conflict (poi_id) do update
  set crowded_score = excluded.crowded_score,
      family_score = excluded.family_score,
      sunset_score = excluded.sunset_score,
      quiet_score = excluded.quiet_score,
      tags = excluded.tags,
      confidence = excluded.confidence,
      last_event_at = excluded.last_event_at,
      updated_at = now();
end;
$$;

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
  trust as (
    select trust_score
    from public.poi_trust_metrics t
    where t.poi_id = p_poi_id
  ),
  recent as (
    select jsonb_agg(
      jsonb_build_object(
        'rating', r.rating,
        'flags', r.flags,
        'comment_short', r.comment_short,
        'created_at', r.created_at,
        'trust_level', coalesce(ur.trust_level, 'new_user'),
        'reviewer_score', coalesce(ur.score, 40)
      )
      order by coalesce(ur.score, 40) desc, r.created_at desc
    ) as items
    from (
      select user_id, rating, flags, comment_short, created_at
      from public.poi_reviews
      where poi_id = p_poi_id
        and status = 'approved'
      order by created_at desc
      limit 20
    ) r
    left join public.user_reputation ur on ur.user_id = r.user_id
  )
  select jsonb_build_object(
    'place_id', p_poi_id,
    'avg_rating', coalesce((select avg_rating from stat), 0),
    'review_count', coalesce((select review_count from stat), 0),
    'crowded_count', coalesce((select crowded_count from stat), 0),
    'family_count', coalesce((select family_count from stat), 0),
    'photo_spot_count', coalesce((select photo_spot_count from stat), 0),
    'sunset_worthy_count', coalesce((select sunset_worthy_count from stat), 0),
    'trust_score', coalesce((select trust_score from trust), 0),
    'recent_reviews', coalesce((select items from recent), '[]'::jsonb)
  );
$$;

with poi_seed as (
  select distinct poi_id
  from public.poi_reviews
  where poi_id is not null
)
select public.recalc_poi_trust_score(poi_id)
from poi_seed;

with poi_seed as (
  select distinct poi_id
  from public.poi_reviews
  where poi_id is not null
)
select public.refresh_poi_live_status(poi_id, 6)
from poi_seed;
