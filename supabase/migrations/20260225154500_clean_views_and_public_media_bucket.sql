create or replace view public.places_clean_with_coords as
select
  p.id,
  p.province_id,
  p.district_id,
  p.name,
  p.slug,
  p.category::text as category,
  p.short_summary,
  p.best_time::text as best_time,
  p.duration_min,
  p.tags,
  p.popularity_score,
  st_y(p.geog::geometry) as lat,
  st_x(p.geog::geometry) as lng,
  coalesce(rs.avg_rating, 0)::numeric(3,2) as app_rating,
  coalesce(rs.review_count, 0)::int as rating_count
from public.places_clean p
left join public.place_rating_summary_clean rs on rs.place_id = p.id;

grant select on public.places_clean_with_coords to anon, authenticated;

insert into storage.buckets (id, name, public)
values ('public-media', 'public-media', true)
on conflict (id) do update set public = excluded.public;
