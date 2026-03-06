create or replace function public.qc_weak_district_ids(
  p_limit int default 200,
  p_max_places int default 20,
  p_merkez_only boolean default false
)
returns table (
  district_id uuid,
  district text,
  province text,
  place_count int
)
language sql
stable
security definer
set search_path = public
as $$
  select
    d.id as district_id,
    d.name as district,
    p2.name as province,
    count(pl.id)::int as place_count
  from public.districts d
  join public.provinces p2 on p2.id = d.province_id
  left join public.places pl on pl.district_id = d.id
  group by d.id, d.name, p2.name
  having count(pl.id) <= greatest(0, coalesce(p_max_places, 20))
     and (not coalesce(p_merkez_only, false) or d.name ilike 'Merkez%')
  order by count(pl.id) asc, p2.name asc, d.name asc
  limit greatest(1, least(2000, coalesce(p_limit, 200)));
$$;

create or replace function public.force_coverage_queue(
  p_limit int default 200,
  p_max_places int default 20,
  p_merkez_only boolean default true
)
returns table (
  targeted int,
  updated int,
  running_skipped int
)
language sql
security definer
set search_path = public
as $$
  with target as (
    select *
    from public.qc_weak_district_ids(p_limit, p_max_places, p_merkez_only)
  ),
  running as (
    select count(*)::int as c
    from public.district_ingest_jobs j
    join target t on t.district_id = j.district_id
    where j.status = 'running'
  ),
  upd as (
    update public.district_ingest_jobs j
    set
      status = 'queued',
      next_run_at = now(),
      last_error = null,
      priority_score = greatest(coalesce(j.priority_score, 0), 5000) + (20 - least(t.place_count, 20)) * 10,
      updated_at = now()
    from target t
    where j.district_id = t.district_id
      and j.status <> 'running'
    returning j.id
  )
  select
    (select count(*)::int from target) as targeted,
    (select count(*)::int from upd) as updated,
    coalesce((select c from running), 0) as running_skipped;
$$;

create or replace function public.retro_cleanup_low_quality_food(
  p_action text default 'demote',
  p_limit int default 5000
)
returns table (
  action text,
  affected int
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_action text := lower(coalesce(p_action, 'demote'));
  v_limit int := greatest(1, least(100000, coalesce(p_limit, 5000)));
begin
  if v_action not in ('demote', 'unpublish') then
    raise exception 'invalid_action';
  end if;

  if v_action = 'demote' then
    return query
    with target as (
      select p.id
      from public.places p
      left join public.community_place_stats cps on cps.place_id = p.id
      where p.category in ('food', 'cafe', 'lodging')
        and p.source_kind <> 'curated'
        and (
          (
            coalesce(p.google_rating, 0) > 0
            and not (
              (p.google_rating >= 4.3 and coalesce(p.google_review_count, 0) >= 150)
              or (p.google_rating >= 4.5 and coalesce(p.google_review_count, 0) >= 80)
            )
            and not (coalesce(cps.avg_rating, 0) >= 4.4 and coalesce(cps.review_count, 0) >= 20)
          )
          or (
            coalesce(p.google_rating, 0) = 0
            and coalesce(cps.review_count, 0) < 20
          )
        )
      order by p.updated_at asc, p.id asc
      limit v_limit
    ), upd as (
      update public.places p
      set
        score = greatest(0, coalesce(p.score, 0) - 8),
        popularity_score = greatest(0, coalesce(p.popularity_score, 0) - 15),
        updated_at = now()
      where p.id in (select id from target)
      returning p.id
    )
    select 'demote'::text as action, count(*)::int as affected
    from upd;
  else
    return query
    with target as (
      select p.id
      from public.places p
      left join public.community_place_stats cps on cps.place_id = p.id
      where p.category in ('food', 'cafe', 'lodging')
        and p.source_kind <> 'curated'
        and (
          (
            coalesce(p.google_rating, 0) > 0
            and not (
              (p.google_rating >= 4.3 and coalesce(p.google_review_count, 0) >= 150)
              or (p.google_rating >= 4.5 and coalesce(p.google_review_count, 0) >= 80)
            )
            and not (coalesce(cps.avg_rating, 0) >= 4.4 and coalesce(cps.review_count, 0) >= 20)
          )
          or (
            coalesce(p.google_rating, 0) = 0
            and coalesce(cps.review_count, 0) < 20
          )
        )
      order by p.updated_at asc, p.id asc
      limit v_limit
    ), upd as (
      update public.places p
      set
        is_published = false,
        updated_at = now()
      where p.id in (select id from target)
      returning p.id
    )
    select 'unpublish'::text as action, count(*)::int as affected
    from upd;
  end if;
end;
$$;

grant execute on function public.qc_weak_district_ids(int, int, boolean) to authenticated;
grant execute on function public.force_coverage_queue(int, int, boolean) to authenticated;
grant execute on function public.retro_cleanup_low_quality_food(text, int) to authenticated;
