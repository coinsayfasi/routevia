-- Persist manual city/district corrections in DB layer and expose RPC apply function.

create table if not exists public.poi_location_overrides (
  poi_id uuid primary key references public.pois(id) on delete cascade,
  city text not null,
  district text not null,
  reason text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_poi_location_overrides_updated_at
before update on public.poi_location_overrides
for each row execute function public.set_updated_at();

alter table public.poi_location_overrides enable row level security;

drop policy if exists poi_location_overrides_admin_read on public.poi_location_overrides;
create policy poi_location_overrides_admin_read
on public.poi_location_overrides
for select
using (public.is_admin(auth.uid()));

drop policy if exists poi_location_overrides_admin_write on public.poi_location_overrides;
create policy poi_location_overrides_admin_write
on public.poi_location_overrides
for all
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

create or replace function public.apply_poi_location_overrides()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer := 0;
begin
  with upd as (
    update public.pois p
    set city = o.city,
        district = o.district,
        updated_at = now()
    from public.poi_location_overrides o
    where o.is_active = true
      and p.id = o.poi_id
      and (
        coalesce(p.city, '') <> coalesce(o.city, '')
        or coalesce(p.district, '') <> coalesce(o.district, '')
      )
    returning 1
  )
  select count(*) into v_count from upd;

  return v_count;
end;
$$;

grant execute on function public.apply_poi_location_overrides() to authenticated;
grant execute on function public.apply_poi_location_overrides() to service_role;

insert into public.poi_location_overrides (poi_id, city, district, reason, is_active)
values
  ('10fcd19f-af91-46ac-a1f1-5707178fd2ec', 'Uşak', 'Merkez', 'manual_geocode_tail_fix_2026_03_06', true),
  ('2a35f3f6-e569-46eb-8f8e-c69083f936f0', 'Uşak', 'Merkez', 'manual_geocode_tail_fix_2026_03_06', true),
  ('5a632054-79f7-493c-943b-ed2fda9b0f75', 'Uşak', 'Merkez', 'manual_geocode_tail_fix_2026_03_06', true),
  ('6da4b668-bbd7-4587-889e-80a1e3b492a9', 'Uşak', 'Merkez', 'manual_geocode_tail_fix_2026_03_06', true),
  ('8ba55e7c-8d4d-4bb1-b199-7e534d70c2e4', 'Uşak', 'Merkez', 'manual_geocode_tail_fix_2026_03_06', true),
  ('982dabe2-9722-49f6-96d8-d22a00215985', 'Uşak', 'Merkez', 'manual_geocode_tail_fix_2026_03_06', true),
  ('99afa5f3-0335-4339-a8ef-df4fe92fbf3a', 'Uşak', 'Merkez', 'manual_geocode_tail_fix_2026_03_06', true),
  ('d2129694-f349-4fb5-aa78-153a904b72ae', 'Uşak', 'Merkez', 'manual_geocode_tail_fix_2026_03_06', true),
  ('db8d825c-c473-4ee9-b8f2-9d673c0c1922', 'Uşak', 'Merkez', 'manual_geocode_tail_fix_2026_03_06', true),
  ('fb30a980-f338-48b7-bb13-0f5c02f6e511', 'Uşak', 'Merkez', 'manual_geocode_tail_fix_2026_03_06', true),
  ('8968107f-00dd-48d5-9b70-9f81208a390a', 'Amasya', 'Merkez', 'manual_geocode_tail_fix_2026_03_06', true),
  ('f9c43dc9-ac6e-4200-9b9b-5755801d6789', 'Amasya', 'Merkez', 'manual_geocode_tail_fix_2026_03_06', true),
  ('fe393e0d-6633-4541-b6a4-53161b7f3a86', 'Amasya', 'Merkez', 'manual_geocode_tail_fix_2026_03_06', true),
  ('463bb7cb-187f-4064-9b62-362ce43ad666', 'Tunceli', 'Nazımiye', 'manual_geocode_tail_fix_2026_03_06', true),
  ('e27ae363-f675-428c-8f2f-2f99e6727cad', 'Tunceli', 'Nazımiye', 'manual_geocode_tail_fix_2026_03_06', true),
  ('7d086fff-9295-4f57-8145-381ad7d7dd5f', 'Malatya', 'Darende', 'manual_geocode_tail_fix_2026_03_06', true),
  ('baac7a26-2cd7-4ff2-87a6-f80a41aa5f5f', 'Kocaeli', 'Dilovası', 'manual_geocode_tail_fix_2026_03_06', true)
on conflict (poi_id) do update
set city = excluded.city,
    district = excluded.district,
    reason = excluded.reason,
    is_active = excluded.is_active,
    updated_at = now();

select public.apply_poi_location_overrides();
