create or replace function public.qc_weak_districts(p_limit int default 30)
returns table (district text, province text, place_count int)
language sql
stable
security definer
set search_path = public
as $$
  select
    d.name as district,
    p2.name as province,
    count(pl.id)::int as place_count
  from public.districts d
  join public.provinces p2 on p2.id = d.province_id
  left join public.places pl on pl.district_id = d.id
  group by d.id, d.name, p2.name
  order by count(pl.id) asc, p2.name asc, d.name asc
  limit greatest(1, least(200, coalesce(p_limit, 30)));
$$;

create or replace function public.qc_category_distribution()
returns table (category text, total int)
language sql
stable
security definer
set search_path = public
as $$
  select p.category::text as category, count(*)::int as total
  from public.places p
  group by p.category
  order by count(*) desc;
$$;

create or replace function public.qc_duplicate_names(p_limit int default 30)
returns table (name text, c int)
language sql
stable
security definer
set search_path = public
as $$
  select p.name, count(*)::int as c
  from public.places p
  group by p.name
  having count(*) > 3
  order by count(*) desc, p.name asc
  limit greatest(1, least(200, coalesce(p_limit, 30)));
$$;

create or replace function public.qc_low_quality_food(p_limit int default 30)
returns table (name text, category text, google_rating real, google_review_count int)
language sql
stable
security definer
set search_path = public
as $$
  select p.name, p.category::text, p.google_rating, p.google_review_count
  from public.places p
  where p.category in ('food','cafe','lodging')
  order by p.google_rating asc nulls last, p.google_review_count asc nulls last, p.name asc
  limit greatest(1, least(200, coalesce(p_limit, 30)));
$$;

grant execute on function public.qc_weak_districts(int) to authenticated;
grant execute on function public.qc_category_distribution() to authenticated;
grant execute on function public.qc_duplicate_names(int) to authenticated;
grant execute on function public.qc_low_quality_food(int) to authenticated;
