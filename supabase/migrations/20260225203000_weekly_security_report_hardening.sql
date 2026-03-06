-- Weekly security hardening (Supabase report: 2026-02-22)

-- 1) Tighten sensitive RLS policies
DROP POLICY IF EXISTS curated_candidates_read_authenticated ON public.curated_candidates;
CREATE POLICY curated_candidates_admin_select
ON public.curated_candidates
FOR SELECT
TO authenticated
USING (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS user_signals_select_public ON public.user_signals;
CREATE POLICY user_signals_select_owner_or_admin
ON public.user_signals
FOR SELECT
TO authenticated
USING (auth.uid() = user_id OR public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "place_reviews_clean_public_read" ON public.place_reviews_clean;
CREATE POLICY "place_reviews_clean_owner_or_admin_read"
ON public.place_reviews_clean
FOR SELECT
TO authenticated
USING (auth.uid() = user_id OR public.is_admin(auth.uid()));

-- 2) Harden SECURITY DEFINER job-claim RPC against direct abuse by non-admin users
CREATE OR REPLACE FUNCTION public.claim_district_ingest_jobs(p_limit integer DEFAULT 5)
RETURNS SETOF public.district_ingest_jobs
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_role text := COALESCE(current_setting('request.jwt.claim.role', true), '');
BEGIN
  IF v_role <> 'service_role' AND (auth.uid() IS NULL OR NOT public.is_admin(auth.uid())) THEN
    RAISE EXCEPTION 'admin_required';
  END IF;

  RETURN QUERY
  WITH candidate AS (
    SELECT j.id
    FROM public.district_ingest_jobs j
    WHERE j.status IN ('queued', 'failed')
      AND j.next_run_at <= now()
    ORDER BY j.next_run_at ASC, j.created_at ASC
    LIMIT greatest(1, least(50, COALESCE(p_limit, 5)))
    FOR UPDATE SKIP LOCKED
  )
  UPDATE public.district_ingest_jobs j
  SET status = 'running',
      updated_at = now()
  WHERE j.id IN (SELECT id FROM candidate)
  RETURNING j.*;
END;
$$;

REVOKE ALL ON FUNCTION public.claim_district_ingest_jobs(integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.claim_district_ingest_jobs(integer) TO authenticated, service_role;

-- 3) Restrict high-risk maintenance/definer RPCs to service_role only
DO $$
BEGIN
  IF to_regprocedure('public.qc_weak_districts(integer)') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.qc_weak_districts(integer) FROM PUBLIC, anon, authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.qc_weak_districts(integer) TO service_role';
  END IF;
  IF to_regprocedure('public.qc_category_distribution()') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.qc_category_distribution() FROM PUBLIC, anon, authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.qc_category_distribution() TO service_role';
  END IF;
  IF to_regprocedure('public.qc_duplicate_names(integer)') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.qc_duplicate_names(integer) FROM PUBLIC, anon, authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.qc_duplicate_names(integer) TO service_role';
  END IF;
  IF to_regprocedure('public.qc_low_quality_food(integer)') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.qc_low_quality_food(integer) FROM PUBLIC, anon, authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.qc_low_quality_food(integer) TO service_role';
  END IF;
  IF to_regprocedure('public.recompute_place_scores(integer,integer)') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.recompute_place_scores(integer,integer) FROM PUBLIC, anon, authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.recompute_place_scores(integer,integer) TO service_role';
  END IF;
  IF to_regprocedure('public.qc_weak_district_ids(integer,integer,boolean)') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.qc_weak_district_ids(integer,integer,boolean) FROM PUBLIC, anon, authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.qc_weak_district_ids(integer,integer,boolean) TO service_role';
  END IF;
  IF to_regprocedure('public.force_coverage_queue(integer,integer,boolean)') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.force_coverage_queue(integer,integer,boolean) FROM PUBLIC, anon, authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.force_coverage_queue(integer,integer,boolean) TO service_role';
  END IF;
  IF to_regprocedure('public.retro_cleanup_low_quality_food(text,integer)') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.retro_cleanup_low_quality_food(text,integer) FROM PUBLIC, anon, authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.retro_cleanup_low_quality_food(text,integer) TO service_role';
  END IF;
  IF to_regprocedure('public.boost_merkez_ingest_jobs(integer,integer,integer,boolean)') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.boost_merkez_ingest_jobs(integer,integer,integer,boolean) FROM PUBLIC, anon, authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.boost_merkez_ingest_jobs(integer,integer,integer,boolean) TO service_role';
  END IF;
  IF to_regprocedure('public.fix_curated_district_assignments(integer,integer)') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.fix_curated_district_assignments(integer,integer) FROM PUBLIC, anon, authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.fix_curated_district_assignments(integer,integer) TO service_role';
  END IF;
  IF to_regprocedure('public.quarantine_curated_geofence_outliers(integer,integer)') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.quarantine_curated_geofence_outliers(integer,integer) FROM PUBLIC, anon, authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.quarantine_curated_geofence_outliers(integer,integer) TO service_role';
  END IF;
  IF to_regprocedure('public.sync_curated_archive_to_clean(integer,integer)') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.sync_curated_archive_to_clean(integer,integer) FROM PUBLIC, anon, authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.sync_curated_archive_to_clean(integer,integer) TO service_role';
  END IF;
  IF to_regprocedure('public.export_curated_rows()') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.export_curated_rows() FROM PUBLIC, anon, authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.export_curated_rows() TO service_role';
  END IF;
END$$;
