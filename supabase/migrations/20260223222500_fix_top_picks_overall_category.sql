-- Fix top_picks overall rows to use non-null category_key.
-- Existing schema uses (district_id, category_key, rank) as PK, so NULL is invalid.

create or replace function public.refresh_top_picks(p_district_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cluster_m int := 350;
begin
  delete from public.top_picks where district_id = p_district_id;

  -- overall top10, curated first and diversity by lightweight geo bucket
  insert into public.top_picks(district_id, category_key, place_id, rank, score_snapshot)
  with base as (
    select
      p.id,
      coalesce(p.category_key, p.category::text) as category_key,
      p.score,
      p.source_kind,
      st_x(p.geog::geometry) as lng,
      st_y(p.geog::geometry) as lat,
      floor((st_x(p.geog::geometry) * 1000)::numeric / (v_cluster_m::numeric / 1000.0))::bigint as gx,
      floor((st_y(p.geog::geometry) * 1000)::numeric / (v_cluster_m::numeric / 1000.0))::bigint as gy
    from public.places p
    where p.district_id = p_district_id
      and p.is_published = true
  ), dedup as (
    select *,
      row_number() over (
        partition by gx, gy
        order by case when source_kind = 'curated' then 0 else 1 end, score desc, id
      ) as bucket_rank
    from base
  ), ranked as (
    select *,
      row_number() over (
        order by case when source_kind = 'curated' then 0 else 1 end, score desc, id
      ) as rn
    from dedup
    where bucket_rank = 1
  )
  select p_district_id, 'overall'::text, id, rn, score
  from ranked
  where rn <= 10;

  -- top8 per category
  insert into public.top_picks(district_id, category_key, place_id, rank, score_snapshot)
  with ranked as (
    select
      p.id,
      coalesce(p.category_key, p.category::text) as category_key,
      p.score,
      row_number() over (
        partition by coalesce(p.category_key, p.category::text)
        order by case when p.source_kind = 'curated' then 0 else 1 end, p.score desc, p.id
      ) as rn
    from public.places p
    where p.district_id = p_district_id
      and p.is_published = true
  )
  select p_district_id, category_key, id, rn, score
  from ranked
  where rn <= 8;
end;
$$;

-- Best effort refresh to repopulate cache under new rule.
select public.refresh_top_picks_all(500);

