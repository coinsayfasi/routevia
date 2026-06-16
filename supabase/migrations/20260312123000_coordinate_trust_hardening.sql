do $$
begin
  if not exists (
    select 1
    from pg_type
    where typnamespace = 'public'::regnamespace
      and typname = 'coordinate_source_kind'
  ) then
    create type public.coordinate_source_kind as enum (
      'osm_verified',
      'admin_verified',
      'user_verified',
      'legacy_curated_unverified'
    );
  end if;
end
$$;

alter table public.places_clean
  add column if not exists coordinate_source public.coordinate_source_kind not null default 'legacy_curated_unverified',
  add column if not exists coordinate_verified_at timestamptz,
  add column if not exists coordinate_verified_by text;

alter table public.pois
  add column if not exists coordinate_source public.coordinate_source_kind not null default 'legacy_curated_unverified',
  add column if not exists coordinate_verified_at timestamptz,
  add column if not exists coordinate_verified_by text;

create index if not exists places_clean_coordinate_source_idx
  on public.places_clean(coordinate_source);

create index if not exists pois_coordinate_source_idx
  on public.pois(coordinate_source);

create table if not exists public.place_coordinate_verification_queue (
  place_id uuid primary key references public.places_clean(id) on delete cascade,
  status text not null default 'pending'
    check (status in ('pending', 'verified', 'dismissed')),
  reason text not null default 'legacy_curated_coordinate',
  source_snapshot public.coordinate_source_kind not null default 'legacy_curated_unverified',
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by text
);

drop trigger if exists trg_place_coordinate_verification_queue_updated_at
  on public.place_coordinate_verification_queue;
create trigger trg_place_coordinate_verification_queue_updated_at
before update on public.place_coordinate_verification_queue
for each row execute function public.set_updated_at();

alter table public.place_coordinate_verification_queue enable row level security;

drop policy if exists place_coordinate_verification_queue_admin_read
  on public.place_coordinate_verification_queue;
create policy place_coordinate_verification_queue_admin_read
on public.place_coordinate_verification_queue
for select
using (public.is_admin(auth.uid()));

drop policy if exists place_coordinate_verification_queue_admin_write
  on public.place_coordinate_verification_queue;
create policy place_coordinate_verification_queue_admin_write
on public.place_coordinate_verification_queue
for all
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

update public.places_clean
set
  coordinate_source = coalesce(coordinate_source, 'legacy_curated_unverified'),
  coordinate_verified_at = case
    when coordinate_source = 'legacy_curated_unverified' then null
    else coordinate_verified_at
  end,
  coordinate_verified_by = case
    when coordinate_source = 'legacy_curated_unverified' then null
    else coordinate_verified_by
  end
where id is not null;

update public.pois p
set
  coordinate_source = pc.coordinate_source,
  coordinate_verified_at = pc.coordinate_verified_at,
  coordinate_verified_by = pc.coordinate_verified_by,
  updated_at = now()
from public.places_clean pc
where p.id = pc.id;

insert into public.place_coordinate_verification_queue (
  place_id,
  status,
  reason,
  source_snapshot
)
select
  pc.id,
  'pending',
  'legacy_curated_coordinate',
  pc.coordinate_source
from public.places_clean pc
where pc.coordinate_source = 'legacy_curated_unverified'
on conflict (place_id) do update
set
  status = 'pending',
  reason = excluded.reason,
  source_snapshot = excluded.source_snapshot,
  reviewed_at = null,
  reviewed_by = null,
  note = null,
  updated_at = now();

create or replace function public.sync_poi_coordinate_trust_from_places_clean()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.pois
  set
    coordinate_source = new.coordinate_source,
    coordinate_verified_at = new.coordinate_verified_at,
    coordinate_verified_by = new.coordinate_verified_by,
    updated_at = now()
  where id = new.id;

  insert into public.place_coordinate_verification_queue (
    place_id,
    status,
    reason,
    source_snapshot,
    reviewed_at,
    reviewed_by,
    note
  )
  values (
    new.id,
    case
      when new.coordinate_source = 'legacy_curated_unverified' then 'pending'
      else 'verified'
    end,
    case
      when new.coordinate_source = 'legacy_curated_unverified' then 'legacy_curated_coordinate'
      else 'coordinate_verified'
    end,
    new.coordinate_source,
    case
      when new.coordinate_source = 'legacy_curated_unverified' then null
      else coalesce(new.coordinate_verified_at, now())
    end,
    case
      when new.coordinate_source = 'legacy_curated_unverified' then null
      else new.coordinate_verified_by
    end,
    case
      when new.coordinate_source = 'legacy_curated_unverified' then null
      else 'synced_from_places_clean'
    end
  )
  on conflict (place_id) do update
  set
    status = excluded.status,
    reason = excluded.reason,
    source_snapshot = excluded.source_snapshot,
    reviewed_at = excluded.reviewed_at,
    reviewed_by = excluded.reviewed_by,
    note = excluded.note,
    updated_at = now();

  return new;
end;
$$;

drop trigger if exists trg_places_clean_coordinate_trust_sync
  on public.places_clean;
create trigger trg_places_clean_coordinate_trust_sync
after insert or update of coordinate_source, coordinate_verified_at, coordinate_verified_by
on public.places_clean
for each row execute function public.sync_poi_coordinate_trust_from_places_clean();

create or replace function public.mark_place_coordinate_verified(
  p_place_id uuid,
  p_coordinate_source public.coordinate_source_kind,
  p_verified_by text default null,
  p_note text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_coordinate_source = 'legacy_curated_unverified' then
    raise exception 'invalid_verified_coordinate_source';
  end if;

  update public.places_clean
  set
    coordinate_source = p_coordinate_source,
    coordinate_verified_at = now(),
    coordinate_verified_by = coalesce(nullif(trim(coalesce(p_verified_by, '')), ''), 'admin')
  where id = p_place_id;

  update public.place_coordinate_verification_queue
  set
    status = 'verified',
    source_snapshot = p_coordinate_source,
    reviewed_at = now(),
    reviewed_by = coalesce(nullif(trim(coalesce(p_verified_by, '')), ''), 'admin'),
    note = p_note,
    updated_at = now()
  where place_id = p_place_id;
end;
$$;

grant execute on function public.mark_place_coordinate_verified(
  uuid,
  public.coordinate_source_kind,
  text,
  text
) to authenticated;
grant execute on function public.mark_place_coordinate_verified(
  uuid,
  public.coordinate_source_kind,
  text,
  text
) to service_role;

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
  coalesce(rs.review_count, 0)::int as rating_count,
  p.coordinate_source,
  p.coordinate_verified_at,
  p.coordinate_verified_by,
  p.created_at,
  p.updated_at
from public.places_clean p
left join public.place_rating_summary_clean rs on rs.place_id = p.id;
