create or replace function public.boost_merkez_ingest_jobs(
  p_limit int default 200,
  p_min_priority int default 120,
  p_max_place_count int default 20,
  p_include_done boolean default false
)
returns table (
  targeted int,
  updated int,
  skipped_running int
)
language sql
security definer
set search_path = public
as $$
  with merkez as (
    select d.id as district_id
    from public.districts d
    where d.name ilike 'Merkez%'
  ),
  weak as (
    select m.district_id
    from merkez m
    left join public.places p on p.district_id = m.district_id
    group by m.district_id
    having count(p.id) <= greatest(0, coalesce(p_max_place_count, 20))
    order by count(p.id) asc, m.district_id asc
    limit greatest(1, least(2000, coalesce(p_limit, 200)))
  ),
  running as (
    select count(*)::int as c
    from public.district_ingest_jobs j
    join weak w on w.district_id = j.district_id
    where j.status = 'running'
  ),
  upd as (
    update public.district_ingest_jobs j
    set
      status = 'queued',
      next_run_at = now(),
      attempts = 0,
      last_error = null,
      priority_score = greatest(coalesce(j.priority_score, 0), coalesce(p_min_priority, 120)),
      updated_at = now()
    from weak w
    where j.district_id = w.district_id
      and j.status <> 'running'
      and (coalesce(p_include_done, false) or j.status <> 'done')
    returning j.id
  )
  select
    (select count(*)::int from weak) as targeted,
    (select count(*)::int from upd) as updated,
    coalesce((select c from running), 0) as skipped_running;
$$;

grant execute on function public.boost_merkez_ingest_jobs(int, int, int, boolean) to authenticated;
