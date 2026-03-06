create table if not exists public.place_media_open_license_meta (
  media_id uuid primary key references public.place_media_clean(id) on delete cascade,
  license text not null,
  attribution text,
  url_original text,
  created_at timestamptz not null default now()
);

alter table if exists public.place_media_open_license_meta enable row level security;

drop policy if exists "place_media_open_license_meta_public_read" on public.place_media_open_license_meta;
create policy "place_media_open_license_meta_public_read"
on public.place_media_open_license_meta
for select
using (true);

drop policy if exists "place_media_open_license_meta_admin_write" on public.place_media_open_license_meta;
create policy "place_media_open_license_meta_admin_write"
on public.place_media_open_license_meta
for all
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

create or replace function public.ensure_place_media_placeholders_clean(
  p_limit int default 1000,
  p_placeholder_path text default 'public-media/placeholders/default_16x9.jpg'
)
returns table(updated_count int)
language plpgsql
as $$
declare
  v_count int := 0;
begin
  with target as (
    select p.id as place_id
    from public.places_clean p
    left join public.place_media_clean pm on pm.place_id = p.id
    where pm.id is null
    limit greatest(1, least(p_limit, 10000))
  )
  insert into public.place_media_clean (place_id, storage_path, source, sort_order)
  select t.place_id, p_placeholder_path, 'placeholder', 999
  from target t
  on conflict do nothing;

  get diagnostics v_count = row_count;
  return query select v_count;
end;
$$;
