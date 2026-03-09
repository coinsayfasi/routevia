set lock_timeout = '10s';
set statement_timeout = '15min';

-- Keep legacy Google-origin rows only as unpublished archive material.
update public.places
set
  is_published = false,
  published_at = null
where source_kind = 'google'::public.source_kind
  and coalesce(is_published, false) = true;

-- Non-Google rows must not retain Google-origin metadata.
update public.places
set
  google_place_id = null,
  google_rating = null,
  google_review_count = null,
  google_price_level = null,
  google_types = '{}'::text[],
  google_photo_refs = '{}'::text[],
  google_last_sync = null,
  google_source_url = null,
  source_url = case
    when coalesce(source_url, '') like 'https://maps.google.com/%' then null
    else source_url
  end
where source_kind <> 'google'::public.source_kind
  and (
    google_place_id is not null
    or google_rating is not null
    or google_review_count is not null
    or google_price_level is not null
    or google_types is not null
    or google_photo_refs is not null
    or google_last_sync is not null
    or google_source_url is not null
    or coalesce(source_url, '') like 'https://maps.google.com/%'
  );

-- Google-origin media should never remain attached to user-visible non-Google records.
delete from public.place_media pm
using public.places p
where p.id = pm.place_id
  and p.source_kind <> 'google'::public.source_kind
  and (
    pm.source_kind = 'google'::public.source_kind
    or coalesce(pm.storage_path, '') like 'public-media/google_refs/%'
  );

create or replace function public.sync_place_denorm_fields()
returns trigger
language plpgsql
as $$
declare
  v_province text;
  v_district text;
begin
  new.normalized_name := lower(regexp_replace(coalesce(new.name, ''), '[^a-zA-Z0-9ığüşöçİĞÜŞÖÇ]+', ' ', 'g'));

  if new.geog is not null then
    new.lat := st_y(new.geog::geometry);
    new.lng := st_x(new.geog::geometry);
  end if;

  if new.short_desc is null then
    new.short_desc := new.short_summary;
  end if;

  if new.category_key is null then
    new.category_key := case new.category::text
      when 'museum' then 'museum'
      when 'historical' then 'historical_site'
      when 'nature' then 'forest_park'
      when 'beach' then 'beach'
      when 'viewpoint' then 'viewpoint'
      when 'market' then 'street_food'
      when 'cafe' then 'cafe'
      when 'food' then 'food_restaurant'
      when 'activity' then 'activity_family'
      when 'lodging' then 'lodging_hotel'
      when 'tour' then 'tour_city'
      when 'ski' then 'ski_resort'
      when 'waterfall' then 'waterfall'
      when 'canyon' then 'canyon'
      else null
    end;
  end if;

  if new.province_id is not null then
    select p.name into v_province from public.provinces p where p.id = new.province_id;
    new.province := v_province;
  end if;

  if new.district_id is not null then
    select d.name into v_district from public.districts d where d.id = new.district_id;
    new.district := v_district;
  end if;

  if new.source_kind = 'google'::public.source_kind then
    new.is_published := false;
    new.published_at := null;
  else
    new.google_place_id := null;
    new.google_rating := null;
    new.google_review_count := null;
    new.google_price_level := null;
    new.google_types := '{}'::text[];
    new.google_photo_refs := '{}'::text[];
    new.google_last_sync := null;
    new.google_source_url := null;
    if coalesce(new.source_url, '') like 'https://maps.google.com/%' then
      new.source_url := null;
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_sync_place_denorm_fields on public.places;
create trigger trg_sync_place_denorm_fields
before insert or update of
  name, geog, category, category_key, province_id, district_id,
  short_summary, rating, rating_count, source_kind,
  google_place_id, google_rating, google_review_count,
  google_price_level, google_types, google_photo_refs, google_last_sync, source_url
on public.places
for each row
execute function public.sync_place_denorm_fields();

create or replace function public.compute_place_score_v2(p_place_id uuid)
returns numeric
language sql
stable
as $$
  with b as (
    select
      p.id,
      p.name,
      p.source_kind,
      coalesce(p.rating, 0)::numeric as rating,
      coalesce(p.rating_count, 0)::numeric as rating_count,
      coalesce(p.popularity_score, 0)::numeric as popularity,
      coalesce(cd.default_priority, 1)::numeric as cat_priority,
      exists (
        select 1 from public.place_media pm
        where pm.place_id = p.id and (pm.is_primary = true or pm.sort_order = 0)
      ) as has_primary_photo,
      (coalesce(nullif(trim(p.hap_history), ''), '') <> ''
        or exists (
          select 1 from public.place_details pd
          where pd.place_id = p.id and coalesce(array_length(pd.history_bullets, 1), 0) > 0
        )
      ) as has_hap_history,
      (coalesce(nullif(trim(p.hap_eat), ''), '') <> ''
        or exists (
          select 1 from public.place_details pd
          where pd.place_id = p.id and coalesce(array_length(pd.eat_drink_bullets, 1), 0) > 0
        )
      ) as has_hap_eat,
      (coalesce(nullif(trim(p.hap_tips), ''), '') <> ''
        or exists (
          select 1 from public.place_details pd
          where pd.place_id = p.id and coalesce(array_length(pd.tips_bullets, 1), 0) > 0
        )
      ) as has_hap_tips,
      lower(trim(coalesce(p.name, ''))) as lname,
      coalesce(p.category_key, '') as category_key,
      p.category::text as category_raw
    from public.places p
    left join public.category_dictionary cd on cd.category_key = p.category_key
    where p.id = p_place_id
  )
  select greatest(
    0,
    (b.rating * 2.4)
    + (ln(1 + b.rating_count) * 1.2)
    + (b.popularity * 0.06)
    + (case when b.has_primary_photo then 2.2 else 0 end)
    + (case when b.has_hap_history then 0.8 else 0 end)
    + (case when b.has_hap_eat then 0.8 else 0 end)
    + (case when b.has_hap_tips then 0.8 else 0 end)
    + (case when b.source_kind::text = 'curated' then 1.6 else 0 end)
    + (b.cat_priority * 1.3)
    - (
      case
        when b.lname in ('park', 'çocuk parkı', 'semt pazarı', 'pazar', 'market', 'parkı')
             and b.category_key not in ('historical_site', 'archeological_site', 'viewpoint', 'waterfall', 'canyon', 'beach', 'national_park')
             and b.category_raw not in ('historical', 'viewpoint', 'waterfall', 'canyon', 'beach')
        then 6.5
        else 0
      end
    )
  )
  from b;
$$;

create or replace function public.compute_place_app_score(p_place_id uuid)
returns numeric
language sql
stable
as $$
  with b as (
    select
      p.id,
      coalesce(p.app_rating, p.rating, 0)::numeric as app_rating,
      coalesce(p.rating_count, 0)::numeric as rating_count,
      coalesce(
        p.source_weight,
        case p.source_kind::text
          when 'curated' then 1.5
          when 'licensed' then 1.2
          when 'wikidata' then 1.0
          when 'user' then 1.0
          when 'osm' then 0.8
          when 'google' then 0.0
          else 1.0
        end
      )::numeric as source_weight,
      coalesce(p.checkin_count, 0)::numeric as checkin_count,
      coalesce(p.favorite_count, 0)::numeric as favorite_count,
      coalesce(p.plan_count, 0)::numeric as plan_count,
      coalesce(p.view_count, 0)::numeric as view_count,
      coalesce(cd.default_priority, 1)::numeric as cat_priority,
      p.name,
      p.category_key,
      p.category::text as category_raw,
      p.geog,
      p.district_id
    from public.places p
    left join public.category_dictionary cd on cd.category_key = p.category_key
    where p.id = p_place_id
  ),
  s as (
    select
      b.*,
      (
        coalesce(b.checkin_count, 0)
        + coalesce(b.favorite_count, 0)
        + coalesce(b.plan_count, 0)
        + (coalesce(b.view_count, 0) * 0.3)
      )::numeric as popularity_signal,
      (
        case when exists (
          select 1 from public.place_media pm
          where pm.place_id = b.id
        ) then 1 else 0 end
      )::numeric as media_score,
      (
        case
          when b.district_id is not null and exists (
            select 1 from public.districts d
            where d.id = b.district_id
              and d.center_geog is not null
              and b.geog is not null
              and st_distance(b.geog, d.center_geog) <= 15000
          ) then 1
          when b.district_id is not null and exists (
            select 1 from public.districts d
            where d.id = b.district_id
              and d.center_geog is not null
              and b.geog is not null
              and st_distance(b.geog, d.center_geog) <= 30000
          ) then 0.6
          else 0.2
        end
      )::numeric as distance_bias
    from b
  )
  select greatest(
    0,
    (0.20 * s.app_rating)
    + (0.10 * ln(s.rating_count + 1))
    + (0.20 * s.source_weight)
    + (0.25 * s.popularity_signal)
    + (0.10 * s.media_score)
    + (0.10 * least(3, greatest(0, s.cat_priority / 4)))
    + (0.05 * s.distance_bias)
    - (
      case
        when lower(trim(coalesce(s.name, ''))) ~* '(core\\s*spot|çekirdek|dummy|test)'
        then 10
        else 0
      end
    )
  )
  from s;
$$;

drop trigger if exists trg_places_refresh_app_score on public.places;
create trigger trg_places_refresh_app_score
after insert or update of
  app_rating, rating, rating_count, source_kind, source_weight,
  checkin_count, favorite_count, plan_count, view_count, popularity_score, category_key, is_published
on public.places
for each row execute function public.trg_places_refresh_app_score();

update public.places p
set
  app_score = coalesce(public.compute_place_app_score(p.id), 0),
  score = coalesce(public.compute_place_app_score(p.id), 0)
where p.source_kind <> 'google'::public.source_kind;

update public.places
set
  app_score = 0,
  score = 0
where source_kind = 'google'::public.source_kind;

create or replace function public.google_compliance_audit()
returns table (
  metric text,
  value bigint
)
language sql
stable
as $$
  select 'places_total'::text, count(*)::bigint from public.places
  union all
  select 'places_google_total', count(*)::bigint from public.places where source_kind = 'google'::public.source_kind
  union all
  select 'places_google_published', count(*)::bigint from public.places where source_kind = 'google'::public.source_kind and coalesce(is_published, false) = true
  union all
  select 'places_non_google_with_google_place_id', count(*)::bigint from public.places where source_kind <> 'google'::public.source_kind and google_place_id is not null
  union all
  select 'places_non_google_with_google_rating', count(*)::bigint from public.places where source_kind <> 'google'::public.source_kind and (google_rating is not null or google_review_count is not null)
  union all
  select 'places_non_google_with_google_url', count(*)::bigint from public.places where source_kind <> 'google'::public.source_kind and coalesce(source_url, '') like 'https://maps.google.com/%'
  union all
  select 'place_media_non_google_google_refs', count(*)::bigint
  from public.place_media pm
  join public.places p on p.id = pm.place_id
  where p.source_kind <> 'google'::public.source_kind
    and (pm.source_kind = 'google'::public.source_kind or coalesce(pm.storage_path, '') like 'public-media/google_refs/%')
  union all
  select 'places_clean_total', count(*)::bigint from public.places_clean;
$$;

grant execute on function public.google_compliance_audit() to authenticated;
