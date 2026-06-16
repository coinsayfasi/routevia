-- ─────────────────────────────────────────────────────────────────────────────
-- Polygon-based province/district resolution for POIs (replaces centroid logic)
--
-- Root cause of historical misassignments (e.g. Perge/Köprülü showing in Muş):
-- districts only had centroids, so the autofill trigger used nearest-centroid
-- which is wrong at province/district borders, and a one-time fan-out had copied
-- flagship POIs into many districts. Data was re-synced on 2026-06-06 using real
-- OSM admin boundary polygons (point-in-polygon). This migration captures the
-- schema + trigger so the logic is version-controlled and survives db push.
--
-- Boundary polygon DATA (81 provinces, 905 districts, simplified ~80m) is loaded
-- separately via tools/admin_fix/load_boundaries.py (4.3MB, too large for a
-- migration). Tables are created here so the function/trigger compile.
-- ─────────────────────────────────────────────────────────────────────────────

create table if not exists public.admin_boundaries_province(
  province_id uuid primary key references public.provinces(id) on delete cascade,
  geom geometry(Geometry, 4326) not null);
create table if not exists public.admin_boundaries_district(
  district_id uuid primary key references public.districts(id) on delete cascade,
  province_id uuid not null references public.provinces(id) on delete cascade,
  geom geometry(Geometry, 4326) not null);
create index if not exists abp_geom_gix on public.admin_boundaries_province using gist(geom);
create index if not exists abd_geom_gix on public.admin_boundaries_district using gist(geom);
create index if not exists abd_prov_idx on public.admin_boundaries_district(province_id);

-- Internal reference data only (read by the security-definer resolver, which
-- bypasses RLS as owner). Keep RLS on + no grants so PostgREST never exposes it.
alter table public.admin_boundaries_province enable row level security;
alter table public.admin_boundaries_district enable row level security;
revoke all on public.admin_boundaries_province from anon, authenticated;
revoke all on public.admin_boundaries_district from anon, authenticated;

-- Point -> (province_id, district_id): province by polygon, district by
-- province-consistent polygon, else nearest district centroid within province.
create or replace function public.resolve_admin_by_point(p_lat double precision, p_lng double precision)
returns table(province_id uuid, district_id uuid)
language sql stable security definer set search_path = public as $fn$
  with pt as (select st_setsrid(st_makepoint(p_lng, p_lat), 4326) as g),
  prov as (
    select bp.province_id as pid
    from public.admin_boundaries_province bp, pt
    where st_intersects(bp.geom, pt.g)
    limit 1
  )
  select
    (select pid from prov),
    coalesce(
      (select bd.district_id from public.admin_boundaries_district bd, pt
       where bd.province_id = (select pid from prov) and st_intersects(bd.geom, pt.g)
       limit 1),
      (select d.id from public.districts d, pt
       where d.province_id = (select pid from prov)
       order by st_distance(d.center_geog, pt.g::geography)
       limit 1)
    )
$fn$;

-- Autofill trigger: polygon-accurate; places_clean rows are skipped (their own
-- sync trigger is authoritative); points outside all polygons (e.g. just
-- offshore) fall back to the legacy centroid scope so coastal POIs still resolve.
create or replace function public.pois_autofill_city_and_district()
returns trigger language plpgsql as $fn$
declare
  v_pid uuid; v_did uuid; v_city text; v_dist text; v_scope record;
begin
  if new.lat is null or new.lng is null then return new; end if;
  if exists (select 1 from public.places_clean where id = new.id) then return new; end if;

  select province_id, district_id into v_pid, v_did
  from public.resolve_admin_by_point(new.lat, new.lng);

  if v_pid is not null then
    select name into v_city from public.provinces where id = v_pid;
    select name into v_dist from public.districts where id = v_did;
    new.city := v_city;
    new.district := coalesce(v_dist, new.district);
    return new;
  end if;

  select * into v_scope from public.resolve_poi_admin_scope(new.lat, new.lng);
  if v_scope.distance_m is not null and v_scope.distance_m <= 120000 then
    new.city := v_scope.province_name;
    new.district := public.resolve_poi_district_name_smart(new.name, v_scope.province_name, new.lat, new.lng);
  end if;
  return new;
end;
$fn$;

-- (trigger trg_pois_autofill_city_and_district already bound to pois; unchanged)
