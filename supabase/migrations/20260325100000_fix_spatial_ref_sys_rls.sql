-- Enable RLS on PostGIS extension table to silence Supabase Security Advisor.
-- spatial_ref_sys contains only public coordinate system definitions (read-only data).
-- Permissive SELECT policy is intentional.
do $$
begin
  execute 'alter table public.spatial_ref_sys enable row level security';
  execute 'alter table public.spatial_ref_sys force row level security';

  execute $p$
    drop policy if exists spatial_ref_sys_read_all on public.spatial_ref_sys;
    create policy spatial_ref_sys_read_all
      on public.spatial_ref_sys
      for select
      using (true)
  $p$;
exception
  when insufficient_privilege then
    raise notice 'spatial_ref_sys RLS: insufficient_privilege, skipping';
  when others then
    raise notice 'spatial_ref_sys RLS: %, skipping', sqlerrm;
end;
$$;
