do $$
begin
  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    where t.typname = 'persona_mode' and e.enumlabel = 'foodie'
  ) then
    alter type public.persona_mode add value 'foodie';
  end if;
end $$;

create or replace function public.nearby_places_rpc(
  p_lat double precision,
  p_lng double precision,
  p_radius_m integer,
  p_province_id uuid default null,
  p_tags text[] default null,
  p_categories text[] default null,
  p_limit integer default 30
)
returns table (
  id uuid,
  province_id uuid,
  name text,
  slug citext,
  category public.place_category,
  short_summary text,
  best_time public.best_time,
  duration_min int,
  tags text[],
  lat double precision,
  lng double precision,
  meters_from_user double precision,
  media_storage_path text,
  media_sort_order int
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
    p.province_id,
    p.name,
    p.slug,
    p.category,
    p.short_summary,
    p.best_time,
    p.duration_min,
    p.tags,
    st_y(p.geog::geometry) as lat,
    st_x(p.geog::geometry) as lng,
    st_distance(p.geog, o.g) as meters_from_user,
    pm.storage_path as media_storage_path,
    pm.sort_order as media_sort_order
  from public.places p
  cross join origin o
  left join lateral (
    select storage_path, sort_order
    from public.place_media m
    where m.place_id = p.id
    order by m.sort_order asc
    limit 1
  ) pm on true
  where st_dwithin(p.geog, o.g, p_radius_m)
    and (p_province_id is null or p.province_id = p_province_id)
    and (
      p_tags is null
      or coalesce(array_length(p_tags, 1), 0) = 0
      or p.tags && p_tags
    )
    and (
      p_categories is null
      or coalesce(array_length(p_categories, 1), 0) = 0
      or p.category::text = any(p_categories)
    )
  order by p.geog <-> o.g
  limit greatest(1, least(p_limit, 100));
$$;

grant execute on function public.nearby_places_rpc(double precision, double precision, integer, uuid, text[], text[], integer) to anon, authenticated;
