begin;

create or replace function public.map_place_category_to_clean(p_category text)
returns public.place_category
language plpgsql
immutable
set search_path = public, extensions, pg_temp
as $$
begin
  case lower(coalesce(p_category, ''))
    when 'museum' then return 'museum'::public.place_category;
    when 'historical' then return 'historical'::public.place_category;
    when 'nature' then return 'nature'::public.place_category;
    when 'beach' then return 'beach'::public.place_category;
    when 'viewpoint' then return 'viewpoint'::public.place_category;
    when 'market' then return 'market'::public.place_category;
    when 'cafe' then return 'cafe'::public.place_category;
    when 'food' then return 'food'::public.place_category;
    when 'activity' then return 'activity'::public.place_category;
    when 'waterfall' then return 'nature'::public.place_category;
    when 'canyon' then return 'nature'::public.place_category;
    when 'lake' then return 'nature'::public.place_category;
    when 'national_park' then return 'nature'::public.place_category;
    when 'hiking_trail' then return 'nature'::public.place_category;
    when 'historical_site' then return 'historical'::public.place_category;
    when 'archeological_site' then return 'historical'::public.place_category;
    when 'castle_fortress' then return 'historical'::public.place_category;
    when 'food_restaurant' then return 'food'::public.place_category;
    when 'dessert' then return 'food'::public.place_category;
    when 'street_food' then return 'food'::public.place_category;
    when 'tour' then return 'activity'::public.place_category;
    when 'tour_city' then return 'activity'::public.place_category;
    when 'tour_boat' then return 'activity'::public.place_category;
    when 'activity_family' then return 'activity'::public.place_category;
    when 'activity_adventure' then return 'activity'::public.place_category;
    when 'marina' then return 'activity'::public.place_category;
    when 'nightlife' then return 'activity'::public.place_category;
    else return 'activity'::public.place_category;
  end case;
end;
$$;

create or replace function public.refresh_poi_live_status(p_poi_id uuid, p_hours int default 6)
returns void
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare
  v_crowded int := 0;
  v_family int := 0;
  v_sunset int := 0;
  v_quiet int := 0;
  v_conf int := 0;
  v_last timestamptz := null;
  v_tags text[] := '{}'::text[];
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
    coalesce(r.total, 0),
    coalesce(r.crowded_cnt, 0),
    coalesce(r.family_cnt, 0),
    coalesce(r.sunset_cnt, 0),
    coalesce(r.quiet_cnt, 0),
    greatest(coalesce(r.last_ts, 'epoch'::timestamptz), coalesce(sig.last_sig, 'epoch'::timestamptz)),
    coalesce(sig.total_sig, 0)
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
    coalesce(v_tags, '{}'::text[]),
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

create or replace function public.approve_curated_candidates(
  p_candidate_ids uuid[],
  p_action text default 'approve'
)
returns table(candidate_id uuid, status text, place_id uuid)
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare
  v_action text := lower(coalesce(p_action, 'approve'));
  v_rec record;
  v_slug citext;
  v_place_id uuid;
begin
  if coalesce(current_setting('request.jwt.claim.role', true), '') <> 'service_role'
     and (auth.uid() is null or not public.is_admin(auth.uid())) then
    raise exception 'admin_required';
  end if;

  if v_action not in ('approve', 'reject') then
    raise exception 'invalid_action';
  end if;

  if p_candidate_ids is null or coalesce(array_length(p_candidate_ids, 1), 0) = 0 then
    return;
  end if;

  if v_action = 'reject' then
    update public.curated_candidates c
      set status = 'rejected', updated_at = now()
    where c.id = any(p_candidate_ids);

    return query
    select c.id, c.status, null::uuid
    from public.curated_candidates c
    where c.id = any(p_candidate_ids);
    return;
  end if;

  for v_rec in
    select c.id as candidate_id,
           c.raw_place_id,
           c.province_id,
           c.district_id,
           c.name,
           c.category,
           c.tags,
           c.short_desc,
           c.history_tip,
           c.eat_tip,
           c.pro_tip,
           c.score_boost,
           rp.source,
           rp.source_place_id,
           rp.user_ratings_total,
           rp.price_level,
           rp.lat,
           rp.lng,
           rp.website,
           rp.phone
    from public.curated_candidates c
    join public.raw_places rp on rp.id = c.raw_place_id
    where c.id = any(p_candidate_ids)
      and c.status = 'draft'
  loop
    v_slug := left(regexp_replace(lower(v_rec.name || '-' || v_rec.district_id::text), '[^a-z0-9]+', '-', 'g'), 120)::citext;

    insert into public.places (
      province_id, district_id, name, slug, category, geog, short_summary,
      best_time, duration_min, tags, popularity_score, is_free, price_level,
      website, phone, source_kind, source_url, is_published
    ) values (
      v_rec.province_id,
      v_rec.district_id,
      v_rec.name,
      v_slug,
      v_rec.category::public.place_category,
      st_setsrid(st_makepoint(v_rec.lng, v_rec.lat), 4326)::geography,
      v_rec.short_desc,
      case when v_rec.tags && array['sunset']::text[] then 'sunset'::public.best_time else 'day'::public.best_time end,
      case when v_rec.category in ('food', 'cafe') then 90 else 120 end,
      v_rec.tags,
      greatest(coalesce(v_rec.user_ratings_total, 0), 40),
      false,
      v_rec.price_level,
      v_rec.website,
      v_rec.phone,
      'curated'::public.source_kind,
      null,
      true
    )
    on conflict (province_id, slug) do update set
      province_id = excluded.province_id,
      district_id = excluded.district_id,
      name = excluded.name,
      category = excluded.category,
      geog = excluded.geog,
      short_summary = excluded.short_summary,
      tags = excluded.tags,
      popularity_score = greatest(public.places.popularity_score, excluded.popularity_score),
      price_level = excluded.price_level,
      website = coalesce(excluded.website, public.places.website),
      phone = coalesce(excluded.phone, public.places.phone),
      source_kind = 'curated'::public.source_kind,
      is_published = true,
      updated_at = now()
    returning id into v_place_id;

    insert into public.place_details(place_id, history_bullets, eat_drink_bullets, tips_bullets)
    values (
      v_place_id,
      array[left(v_rec.history_tip, 160)],
      array[left(v_rec.eat_tip, 160)],
      array[left(v_rec.pro_tip, 160)]
    )
    on conflict on constraint place_details_pkey do update
      set history_bullets = excluded.history_bullets,
          eat_drink_bullets = excluded.eat_drink_bullets,
          tips_bullets = excluded.tips_bullets;

    insert into public.place_sources(place_id, source, source_place_id, confidence)
    values (v_place_id, v_rec.source, v_rec.source_place_id, 0.9)
    on conflict (place_id, source, source_place_id) do update
      set confidence = greatest(public.place_sources.confidence, excluded.confidence);

    update public.places
      set score = coalesce(score, 0) + coalesce(v_rec.score_boost, 0) + 10
    where id = v_place_id;

    update public.curated_candidates
      set status = 'approved', updated_at = now()
    where id = v_rec.candidate_id;
  end loop;

  return query
  select c.id, c.status, pl.id as place_id
  from public.curated_candidates c
  left join public.places pl on pl.province_id = c.province_id and pl.district_id = c.district_id and pl.name = c.name
  where c.id = any(p_candidate_ids);
end;
$$;

commit;
