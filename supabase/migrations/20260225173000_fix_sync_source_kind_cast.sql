create or replace function public.sync_curated_archive_to_clean(
  p_limit int default 50000,
  p_offset int default 0
)
returns table(scanned int, upserted_places int, upserted_details int, upserted_media int)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_scanned int := 0;
  v_places int := 0;
  v_details int := 0;
  v_media int := 0;
begin
  with src as (
    select
      p.id as raw_place_id,
      p.province_id,
      p.district_id,
      p.name,
      p.slug,
      public.map_place_category_to_clean(p.category::text) as category,
      p.geog,
      left(coalesce(p.short_summary, p.name), 160) as short_summary,
      case
        when coalesce(p.best_time::text, 'day') in ('morning','day','sunset','night') then p.best_time::text
        else 'day'
      end::public.best_time as best_time,
      greatest(15, least(coalesce(p.duration_min, 60), 240)) as duration_min,
      coalesce(p.tags, '{}'::text[]) as tags,
      greatest(0, coalesce(p.popularity_score, 0)) as popularity_score
    from public.places p
    where p.source_kind = 'curated'
      and p.name is not null
      and p.slug is not null
      and p.province_id is not null
      and p.geog is not null
      and (p.is_published is true or p.is_published is null)
    order by p.created_at asc, p.id asc
    limit greatest(1, least(p_limit, 200000))
    offset greatest(0, p_offset)
  ), upserted as (
    insert into public.places_clean (
      province_id,district_id,name,slug,category,geog,short_summary,best_time,duration_min,tags,popularity_score
    )
    select
      s.province_id,
      s.district_id,
      s.name,
      s.slug,
      s.category,
      s.geog,
      s.short_summary,
      s.best_time,
      s.duration_min,
      s.tags,
      s.popularity_score
    from src s
    on conflict (province_id, slug) do update
      set district_id = excluded.district_id,
          name = excluded.name,
          category = excluded.category,
          geog = excluded.geog,
          short_summary = excluded.short_summary,
          best_time = excluded.best_time,
          duration_min = excluded.duration_min,
          tags = excluded.tags,
          popularity_score = excluded.popularity_score,
          updated_at = now()
    returning id, province_id, slug
  ), linked as (
    select
      u.id as clean_place_id,
      s.raw_place_id
    from upserted u
    join src s on s.province_id = u.province_id and s.slug = u.slug
  ), details_upsert as (
    insert into public.place_details_clean(place_id, history_bullets, eat_drink_bullets, tips_bullets)
    select
      l.clean_place_id,
      coalesce(pd.history_bullets[1:3], '{}'::text[]),
      coalesce(pd.eat_drink_bullets[1:3], '{}'::text[]),
      coalesce(pd.tips_bullets[1:4], '{}'::text[])
    from linked l
    join public.place_details pd on pd.place_id = l.raw_place_id
    on conflict (place_id) do update
      set history_bullets = excluded.history_bullets,
          eat_drink_bullets = excluded.eat_drink_bullets,
          tips_bullets = excluded.tips_bullets
    returning place_id
  ), media_src as (
    select
      l.clean_place_id,
      pm.storage_path,
      row_number() over (partition by l.clean_place_id order by coalesce(pm.sort_order, 0), pm.created_at, pm.id) - 1 as rn,
      case
        when lower(coalesce(pm.source_kind::text, pm.source, 'curated')) in ('user_upload','curated','placeholder','open_license')
          then lower(coalesce(pm.source_kind::text, pm.source, 'curated'))
        else 'curated'
      end as mapped_source
    from linked l
    join public.place_media pm on pm.place_id = l.raw_place_id
    where pm.storage_path is not null
      and pm.storage_path <> ''
      and pm.storage_path not ilike '%google%'
  ), media_upsert as (
    insert into public.place_media_clean(place_id, storage_path, source, sort_order)
    select clean_place_id, storage_path, mapped_source, rn
    from media_src
    on conflict (place_id, storage_path) do update
      set source = excluded.source,
          sort_order = excluded.sort_order
    returning id
  )
  select
    (select count(*) from src),
    (select count(*) from upserted),
    (select count(*) from details_upsert),
    (select count(*) from media_upsert)
  into v_scanned, v_places, v_details, v_media;

  return query select v_scanned, v_places, v_details, v_media;
end;
$$;
