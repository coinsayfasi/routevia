-- Final pass for Supabase Security Advisor findings that were reintroduced
-- by later CREATE OR REPLACE statements after the earlier cleanup migrations.

begin;

-- Re-assert SECURITY INVOKER on public views that are queried by PostgREST.
do $$
declare
  v_name text;
begin
  foreach v_name in array array[
    'places_public',
    'pois_public',
    'places_clean_with_coords',
    'raw_archive_tables_inventory',
    'placeholder_place_rows',
    'curated_district_mismatch_report'
  ]
  loop
    if exists (
      select 1
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public'
        and c.relname = v_name
        and c.relkind = 'v'
    ) then
      begin
        execute format(
          'alter view public.%I set (security_invoker = true)',
          v_name
        );
      exception
        when others then
          raise notice 'Skip security_invoker for view public.%: %', v_name, sqlerrm;
      end;
    end if;
  end loop;
end
$$;

-- Force a stable search_path for all current public schema functions.
-- Later CREATE OR REPLACE statements had reintroduced mutable search_path warnings.
do $$
declare
  r record;
begin
  for r in
    select
      n.nspname as schema_name,
      p.proname as function_name,
      pg_get_function_identity_arguments(p.oid) as args
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
  loop
    begin
      execute format(
        'alter function %I.%I(%s) set search_path = public, extensions, pg_temp',
        r.schema_name,
        r.function_name,
        r.args
      );
    exception
      when others then
        raise notice 'Skip ALTER FUNCTION %.%(%) search_path: %',
          r.schema_name, r.function_name, r.args, sqlerrm;
    end;
  end loop;
end
$$;

-- Best-effort hardening for the PostGIS metadata table flagged by Security Advisor.
-- Some environments will refuse this when the extension owns the table.
do $$
begin
  if exists (
    select 1
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'spatial_ref_sys'
      and c.relkind = 'r'
  ) then
    begin
      execute 'alter table public.spatial_ref_sys enable row level security';
      execute 'alter table public.spatial_ref_sys force row level security';
      execute 'drop policy if exists spatial_ref_sys_read_all on public.spatial_ref_sys';
      execute $policy$
        create policy spatial_ref_sys_read_all
        on public.spatial_ref_sys
        for select
        using (true)
      $policy$;
    exception
      when insufficient_privilege then
        raise notice 'Skip spatial_ref_sys RLS hardening: insufficient_privilege';
    end;
  end if;
end
$$;

commit;
