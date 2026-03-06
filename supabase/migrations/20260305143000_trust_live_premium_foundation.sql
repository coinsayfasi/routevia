-- Full Stack Pro Premium foundation (non-breaking, POI-native)

create table if not exists public.user_reputation (
  user_id uuid primary key references auth.users(id) on delete cascade,
  trust_level text not null default 'new_user' check (trust_level in ('new_user','verified_traveler','local_contributor')),
  score int not null default 40 check (score between 0 and 100),
  spam_flags int not null default 0,
  reviewed_count int not null default 0,
  signal_count int not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists public.poi_trust_metrics (
  poi_id uuid primary key references public.pois(id) on delete cascade,
  trust_score numeric(5,2) not null default 0,
  weighted_rating numeric(4,2) not null default 0,
  review_count int not null default 0,
  signal_quality numeric(4,3) not null default 0,
  media_quality numeric(4,3) not null default 0.45,
  freshness_score numeric(4,3) not null default 0,
  spam_risk numeric(4,3) not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists public.poi_live_status (
  poi_id uuid primary key references public.pois(id) on delete cascade,
  crowded_score int not null default 0 check (crowded_score between 0 and 100),
  family_score int not null default 0 check (family_score between 0 and 100),
  sunset_score int not null default 0 check (sunset_score between 0 and 100),
  quiet_score int not null default 0 check (quiet_score between 0 and 100),
  tags text[] not null default '{}',
  confidence int not null default 0 check (confidence between 0 and 100),
  last_event_at timestamptz,
  updated_at timestamptz not null default now()
);

create table if not exists public.premium_features (
  feature_key text primary key,
  enabled boolean not null default false,
  premium_only boolean not null default true,
  rollout_percent int not null default 100 check (rollout_percent between 0 and 100),
  description text,
  updated_at timestamptz not null default now()
);

insert into public.premium_features(feature_key, enabled, premium_only, rollout_percent, description)
values
  ('advanced_optimize', true, true, 100, 'Bugunu optimize et (v2)'),
  ('trend_map', true, true, 100, 'Trend harita katmani'),
  ('offline_city_packs', true, true, 100, 'Sehir paketleri offline'),
  ('live_status', true, false, 100, 'Canli durum etiketleri'),
  ('trust_score', true, false, 100, 'Routevia Trust Score')
on conflict (feature_key) do update
set enabled = excluded.enabled,
    premium_only = excluded.premium_only,
    rollout_percent = excluded.rollout_percent,
    description = excluded.description,
    updated_at = now();

alter table public.user_reputation enable row level security;
alter table public.poi_trust_metrics enable row level security;
alter table public.poi_live_status enable row level security;
alter table public.premium_features enable row level security;

drop policy if exists user_reputation_select_own_or_admin on public.user_reputation;
create policy user_reputation_select_own_or_admin
on public.user_reputation
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists user_reputation_admin_write on public.user_reputation;
create policy user_reputation_admin_write
on public.user_reputation
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists poi_trust_metrics_public_read on public.poi_trust_metrics;
create policy poi_trust_metrics_public_read
on public.poi_trust_metrics
for select
to anon, authenticated
using (true);

drop policy if exists poi_trust_metrics_admin_write on public.poi_trust_metrics;
create policy poi_trust_metrics_admin_write
on public.poi_trust_metrics
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists poi_live_status_public_read on public.poi_live_status;
create policy poi_live_status_public_read
on public.poi_live_status
for select
to anon, authenticated
using (true);

drop policy if exists poi_live_status_admin_write on public.poi_live_status;
create policy poi_live_status_admin_write
on public.poi_live_status
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists premium_features_public_read on public.premium_features;
create policy premium_features_public_read
on public.premium_features
for select
to anon, authenticated
using (true);

drop policy if exists premium_features_admin_write on public.premium_features;
create policy premium_features_admin_write
on public.premium_features
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

create or replace function public.recalc_user_reputation(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_reviews int := 0;
  v_signals int := 0;
  v_spam int := 0;
  v_score int := 40;
  v_level text := 'new_user';
begin
  if p_user_id is null then
    return;
  end if;

  select count(*)::int into v_reviews
  from public.poi_reviews
  where user_id = p_user_id;

  select count(*)::int into v_signals
  from public.poi_signals
  where user_id = p_user_id;

  select count(*)::int into v_spam
  from (
    select date_trunc('minute', created_at) as m, count(*) as c
    from public.poi_signals
    where user_id = p_user_id
      and created_at >= now() - interval '24 hours'
    group by 1
    having count(*) >= 10
  ) burst;

  v_score := 40
    + least(25, v_reviews * 2)
    + least(20, v_signals)
    - least(30, v_spam * 5);

  v_score := greatest(0, least(100, v_score));

  if v_score >= 80 and v_reviews >= 20 then
    v_level := 'local_contributor';
  elsif v_score >= 60 and v_reviews >= 6 then
    v_level := 'verified_traveler';
  else
    v_level := 'new_user';
  end if;

  insert into public.user_reputation(user_id, trust_level, score, spam_flags, reviewed_count, signal_count, updated_at)
  values (p_user_id, v_level, v_score, v_spam, v_reviews, v_signals, now())
  on conflict (user_id) do update
  set trust_level = excluded.trust_level,
      score = excluded.score,
      spam_flags = excluded.spam_flags,
      reviewed_count = excluded.reviewed_count,
      signal_count = excluded.signal_count,
      updated_at = now();
end;
$$;

grant execute on function public.recalc_user_reputation(uuid) to authenticated;

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
  where r.poi_id = p_poi_id;

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
    select max(created_at) as ts from public.poi_reviews where poi_id = p_poi_id
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

grant execute on function public.recalc_poi_trust_score(uuid) to authenticated;

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

grant execute on function public.refresh_poi_live_status(uuid, int) to authenticated;

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

create or replace function public._poi_review_or_signal_refresh_trigger()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_poi uuid;
  v_user uuid;
begin
  v_poi := coalesce(new.poi_id, old.poi_id);
  v_user := coalesce(new.user_id, old.user_id);

  perform public.recalc_user_reputation(v_user);
  perform public.recalc_poi_trust_score(v_poi);
  perform public.refresh_poi_live_status(v_poi, 6);
  return null;
end;
$$;

drop trigger if exists trg_poi_reviews_refresh_metrics on public.poi_reviews;
create trigger trg_poi_reviews_refresh_metrics
after insert or update or delete on public.poi_reviews
for each row execute function public._poi_review_or_signal_refresh_trigger();

drop trigger if exists trg_poi_signals_refresh_metrics on public.poi_signals;
create trigger trg_poi_signals_refresh_metrics
after insert or update or delete on public.poi_signals
for each row execute function public._poi_review_or_signal_refresh_trigger();

-- Backfill for existing rows
insert into public.user_reputation(user_id, trust_level, score, spam_flags, reviewed_count, signal_count, updated_at)
select distinct user_id, 'new_user', 40, 0, 0, 0, now()
from (
  select user_id from public.poi_reviews
  union
  select user_id from public.poi_signals
) u
where user_id is not null
on conflict (user_id) do nothing;

insert into public.poi_trust_metrics(poi_id, updated_at)
select distinct id, now()
from public.pois
where provenance_verified = true
on conflict (poi_id) do nothing;

insert into public.poi_live_status(poi_id, updated_at)
select distinct id, now()
from public.pois
where provenance_verified = true
on conflict (poi_id) do nothing;

with seeds as (
  select distinct poi_id from public.poi_reviews
  union
  select distinct poi_id from public.poi_signals
)
select public.recalc_poi_trust_score(s.poi_id)
from seeds s
where s.poi_id is not null;

with users as (
  select distinct user_id from public.poi_reviews
  union
  select distinct user_id from public.poi_signals
)
select public.recalc_user_reputation(u.user_id)
from users u
where u.user_id is not null;

with seeds as (
  select distinct poi_id from public.poi_reviews
  union
  select distinct poi_id from public.poi_signals
)
select public.refresh_poi_live_status(s.poi_id, 6)
from seeds s
where s.poi_id is not null;
