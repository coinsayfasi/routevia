begin;

create schema if not exists extensions;
grant usage on schema extensions to postgres, anon, authenticated, service_role;

revoke all on public.district_density_stats from anon, authenticated;

do $$
begin
  if exists (
    select 1
    from pg_extension e
    join pg_namespace n on n.oid = e.extnamespace
    where e.extname = 'citext'
      and n.nspname = 'public'
  ) then
    execute 'alter extension citext set schema extensions';
  end if;
end
$$;

do $$
begin
  -- PostGIS is non-relocatable on modern Supabase/PostGIS installs.
  -- Keep the migration non-failing and leave this to a support-assisted move.
  null;
end
$$;

commit;
