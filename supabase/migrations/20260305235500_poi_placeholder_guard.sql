-- POI placeholder/fake guard
-- Goal: keep fake names out of production feeds by automatically disabling provenance.

create or replace function public.pois_disable_placeholder_names()
returns trigger
language plpgsql
as $$
declare
  v_name text := lower(coalesce(new.name, ''));
begin
  if v_name ~ '(core[[:space:]]*spot|placeholder|\\mtest\\M|\\mdemo\\M|örnek|ornek)' then
    new.provenance_verified := false;
    new.provenance_checked_at := now();
    new.provenance_checked_by := null;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_pois_disable_placeholder_names on public.pois;
create trigger trg_pois_disable_placeholder_names
before insert or update of name, provenance_verified
on public.pois
for each row
execute function public.pois_disable_placeholder_names();

-- Backfill existing placeholders.
update public.pois
set provenance_verified = false,
    provenance_checked_at = now(),
    provenance_checked_by = null
where provenance_verified = true
  and lower(coalesce(name, '')) ~ '(core[[:space:]]*spot|placeholder|\\mtest\\M|\\mdemo\\M|örnek|ornek)';
