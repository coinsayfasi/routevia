-- Real-data-only guardrails: placeholder name detection + one-time cleanup

create or replace function public.is_placeholder_place_name(p_name text)
returns boolean
language sql
immutable
as $$
  select
    coalesce(p_name, '') = ''
    or p_name ilike '%core spot%'
    or p_name ilike '%çekirdek%'
    or p_name ~* '\\bspot\\s*[0-9]+\\b';
$$;

create or replace view public.placeholder_place_rows as
select id, province_id, district_id, name, slug, is_published, source_kind
from public.places
where public.is_placeholder_place_name(name);

update public.places
set is_published = false,
    updated_at = now()
where is_published = true
  and public.is_placeholder_place_name(name);
