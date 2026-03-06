-- Security Advisor cleanup v2
-- Re-applies hardening with a new migration timestamp so remote executes it.

BEGIN;

-- 1) Ensure listed views run as SECURITY INVOKER.
DO $$
DECLARE
  v_name text;
BEGIN
  FOREACH v_name IN ARRAY ARRAY[
    'places_public',
    'pois_public',
    'places_clean_with_coords',
    'raw_archive_tables_inventory',
    'placeholder_place_rows',
    'curated_district_mismatch_report'
  ]
  LOOP
    IF EXISTS (
      SELECT 1
      FROM pg_class c
      JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE n.nspname = 'public'
        AND c.relname = v_name
        AND c.relkind = 'v'
    ) THEN
      BEGIN
        EXECUTE format('ALTER VIEW public.%I SET (security_invoker = true)', v_name);
      EXCEPTION
        WHEN OTHERS THEN
          RAISE NOTICE 'Skip security_invoker for view public.%: %', v_name, SQLERRM;
      END;
    END IF;
  END LOOP;
END
$$;

-- 2) Try to satisfy "RLS Disabled in Public" for PostGIS table.
-- Some projects cannot alter this table because extension ownership is restricted.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relname = 'spatial_ref_sys'
      AND c.relkind = 'r'
  ) THEN
    BEGIN
      EXECUTE 'ALTER TABLE public.spatial_ref_sys ENABLE ROW LEVEL SECURITY';
      EXECUTE 'DROP POLICY IF EXISTS spatial_ref_sys_read_all ON public.spatial_ref_sys';
      EXECUTE $p$
        CREATE POLICY spatial_ref_sys_read_all
        ON public.spatial_ref_sys
        FOR SELECT
        USING (true)
      $p$;
    EXCEPTION
      WHEN insufficient_privilege THEN
        RAISE NOTICE 'Skip spatial_ref_sys RLS hardening: insufficient_privilege';
    END;
  END IF;
END
$$;

-- 3) Set immutable search_path on all public functions.
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT
      n.nspname AS schema_name,
      p.proname AS function_name,
      pg_get_function_identity_arguments(p.oid) AS args
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
  LOOP
    BEGIN
      EXECUTE format(
        'ALTER FUNCTION %I.%I(%s) SET search_path = public, extensions, pg_temp',
        r.schema_name,
        r.function_name,
        r.args
      );
    EXCEPTION
      WHEN OTHERS THEN
        RAISE NOTICE 'Skip ALTER FUNCTION %.%(%) search_path: %',
          r.schema_name, r.function_name, r.args, SQLERRM;
    END;
  END LOOP;
END
$$;

COMMIT;
