begin;

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
    on conflict on constraint place_sources_pkey do update
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
