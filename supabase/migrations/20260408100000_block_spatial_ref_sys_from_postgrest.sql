-- PostGIS system tables (spatial_ref_sys, geometry_columns, geography_columns)
-- are extension-owned and cannot have RLS enabled without superuser.
-- Revoking SELECT from PostgREST roles silences the Security Advisor warning
-- and is the correct approach: these tables contain no user data and the
-- mobile/admin apps never query them directly.

revoke select on public.spatial_ref_sys    from anon, authenticated;
revoke select on public.geometry_columns   from anon, authenticated;
revoke select on public.geography_columns  from anon, authenticated;
