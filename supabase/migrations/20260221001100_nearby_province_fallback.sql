create or replace function public.nearest_places_in_province_rpc(
  p_lat double precision,
  p_lng double precision,
  p_province_id uuid,
  p_category text default null,
  p_tags text[] default null,
  p_is_free_only boolean default false,
  p_limit integer default 30
)
returns table (
  id uuid,
  name text,
  lat double precision,
  lng double precision,
  distance_m double precision,
  short_summary text,
  category public.place_category,
  tags text[],
  best_time public.best_time,
  duration_min int,
  is_free boolean,
  popularity_score int,
  rating numeric,
  review_count int,
  image_path text,
  image_sort_order int
)
language sql
stable
security invoker
as $$
  with origin as (
    select st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography as g
  )
  select
    p.id,
    p.name,
    st_y(p.geog::geometry) as lat,
    st_x(p.geog::geometry) as lng,
    st_distance(p.geog, o.g) as distance_m,
    p.short_summary,
    p.category,
    p.tags,
    p.best_time,
    p.duration_min,
    p.is_free,
    p.popularity_score,
    coalesce(ps.avg_rating, 0)::numeric as rating,
    coalesce(ps.review_count, 0)::int as review_count,
    pm.storage_path as image_path,
    pm.sort_order as image_sort_order
  from public.places p
  cross join origin o
  left join public.place_stats ps on ps.place_id = p.id
  left join lateral (
    select m.storage_path, m.sort_order
    from public.place_media m
    where m.place_id = p.id
    order by m.sort_order asc
    limit 1
  ) pm on true
  where p.province_id = p_province_id
    and (p_category is null or p.category::text = p_category)
    and (
      p_tags is null
      or coalesce(array_length(p_tags, 1), 0) = 0
      or p.tags && p_tags
    )
    and (not p_is_free_only or p.is_free = true)
  order by st_distance(p.geog, o.g) asc, p.popularity_score desc
  limit greatest(1, least(p_limit, 30));
$$;

grant execute on function public.nearest_places_in_province_rpc(double precision, double precision, uuid, text, text[], boolean, integer) to anon, authenticated;
