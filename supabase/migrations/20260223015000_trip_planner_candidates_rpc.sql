create or replace function public.trip_planner_candidates_rpc(
  p_province_id uuid,
  p_district_id uuid default null,
  p_limit integer default 2000
)
returns table (
  id uuid,
  province_id uuid,
  district_id uuid,
  name text,
  slug citext,
  category public.place_category,
  short_summary text,
  best_time public.best_time,
  duration_min integer,
  tags text[],
  popularity_score integer,
  is_free boolean,
  source_kind public.source_kind,
  source_url text,
  google_rating real,
  google_review_count integer,
  lat double precision,
  lng double precision
)
language sql
stable
security invoker
as $$
  select
    p.id,
    p.province_id,
    p.district_id,
    p.name,
    p.slug,
    p.category,
    p.short_summary,
    p.best_time,
    p.duration_min,
    p.tags,
    p.popularity_score,
    p.is_free,
    p.source_kind,
    p.source_url,
    p.google_rating,
    p.google_review_count,
    st_y(p.geog::geometry) as lat,
    st_x(p.geog::geometry) as lng
  from public.places p
  where p.province_id = p_province_id
    and (p_district_id is null or p.district_id = p_district_id)
    and coalesce(p.is_published, true) = true
  order by p.popularity_score desc, p.id asc
  limit greatest(100, least(5000, coalesce(p_limit, 2000)));
$$;

grant execute on function public.trip_planner_candidates_rpc(uuid, uuid, integer)
to anon, authenticated;
