-- Prioritize ingest for high-demand travel provinces/districts first.

alter table if exists public.district_ingest_jobs
  add column if not exists priority_score int not null default 0;

create index if not exists district_ingest_jobs_status_priority_next_idx
on public.district_ingest_jobs (status, priority_score desc, next_run_at asc);

create or replace function public.ingest_priority_score(
  p_province_slug text,
  p_district_slug text
)
returns int
language sql
immutable
as $$
  select
    case
      when lower(coalesce(p_district_slug, '')) in (
        'fatih','beyoglu','besiktas','uskudar','sisli','kadikoy','sariyer',
        'konyaalti','muratpasa','alanya','manavgat','kas','kemer','kalkan',
        'fethiye','bodrum','marmaris','datca','ortaca','seydikemer','milas',
        'cesme','konak','selcuk','kusadasi','didim','ayvalik','edremit',
        'pamukkale','merkez','urla','goreme','avanos','urgup','ortahisar',
        'trabzon-merkez','ortahisar-trabzon','yomra','rize-merkez'
      ) then 100
      when lower(coalesce(p_province_slug, '')) in (
        'istanbul','antalya','mugla','izmir','nevsehir','aydin','canakkale',
        'balikesir','denizli','trabzon','rize','bursa','ankara','mersin',
        'adana','kayseri','konya'
      ) then 70
      when lower(coalesce(p_province_slug, '')) in (
        'samsun','eskisehir','bolu','sakarya','ordu','artvin','elazig','van',
        'erzurum','kars','giresun','amasya','sinop'
      ) then 40
      else 10
    end;
$$;

create or replace function public.set_district_ingest_job_priority()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_province_slug text;
  v_district_slug text;
begin
  select p.slug::text, d.slug::text
  into v_province_slug, v_district_slug
  from public.districts d
  join public.provinces p on p.id = d.province_id
  where d.id = new.district_id;

  new.priority_score := public.ingest_priority_score(v_province_slug, v_district_slug);
  return new;
end;
$$;

drop trigger if exists trg_district_ingest_jobs_priority on public.district_ingest_jobs;
create trigger trg_district_ingest_jobs_priority
before insert or update of district_id
on public.district_ingest_jobs
for each row
execute function public.set_district_ingest_job_priority();

-- Backfill existing rows
update public.district_ingest_jobs j
set priority_score = public.ingest_priority_score(p.slug::text, d.slug::text)
from public.districts d
join public.provinces p on p.id = d.province_id
where d.id = j.district_id;

create or replace function public.claim_district_ingest_jobs(p_limit integer default 5)
returns setof public.district_ingest_jobs
language plpgsql
security definer
set search_path = public
as $$
begin
  return query
  with candidate as (
    select j.id
    from public.district_ingest_jobs j
    where j.status in ('queued', 'failed')
      and j.next_run_at <= now()
    order by j.priority_score desc, j.next_run_at asc, j.created_at asc
    limit greatest(1, least(100, coalesce(p_limit, 5)))
    for update skip locked
  )
  update public.district_ingest_jobs j
  set status = 'running',
      updated_at = now()
  where j.id in (select id from candidate)
  returning j.*;
end;
$$;
