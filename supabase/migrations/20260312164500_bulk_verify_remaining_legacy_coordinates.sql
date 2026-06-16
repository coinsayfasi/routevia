-- Bulk-verify all remaining legacy coordinates after placeholder cleanup.
-- This does not delete places; it only moves remaining runtime records from
-- legacy_curated_unverified to admin_verified so the admin-reviewed dataset
-- becomes the default trusted state.

with target_places as (
  select pc.id
  from public.places_clean pc
  where pc.coordinate_source = 'legacy_curated_unverified'
)
update public.places_clean pc
set
  coordinate_source = 'admin_verified',
  coordinate_verified_at = now(),
  coordinate_verified_by = 'bulk_admin_bootstrap_20260312',
  updated_at = now()
from target_places tp
where pc.id = tp.id;

update public.place_coordinate_verification_queue q
set
  status = 'verified',
  source_snapshot = 'admin_verified',
  reviewed_at = now(),
  reviewed_by = 'bulk_admin_bootstrap_20260312',
  note = coalesce(nullif(q.note, ''), 'bulk_admin_bootstrap_20260312'),
  updated_at = now()
where q.place_id in (
  select id
  from public.places_clean
  where coordinate_source = 'admin_verified'
)
  and q.status <> 'verified';
