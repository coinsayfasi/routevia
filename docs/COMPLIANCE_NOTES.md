# RouteVia Compliance Notes

## 1) Google Places data usage policy
- RouteVia product surface does **not** serve Google-origin POIs to end users.
- Legacy Google-origin rows remain in DB for internal archival/ops only.
- Product-facing reads are constrained by DB-level compliance filters.

## 2) DB-level blocking
- `public.places` now has:
  - `source text not null default 'google'`
  - `google_origin boolean not null default true`
- Legacy rows are explicitly marked:
  - `source = 'google'`
  - `google_origin = true`
- RLS policy `read_compliant_places` allows read only when:
  - `google_origin = false`
  - `source <> 'google'`
- Safe view:
  - `public.places_public`

## 3) Compliant product dataset
- New table: `public.pois`
- Allowed sources only:
  - `osm`
  - `wikidata`
  - `user`
  - `licensed`
- No Google-derived records are allowed by source constraint.
- Additional provenance lock:
  - `provenance_verified = true` is required for client-visible reads.
  - Unverified records stay hidden at DB policy level.

## 4) Map legal compliance
- Map stack uses `flutter_map` + OpenStreetMap tiles.
- Required attribution is shown in UI:
  - `© OpenStreetMap contributors`
- No Google Maps SDK / branding is used in map surface.

## 5) Runtime privacy & permissions
- Location permission is requested only after explicit user action ("Konumum" button).
- App includes loading, empty, and offline/error states for map data loading.

## 6) Operational checks before release
- Confirm migrations are applied in production.
- Confirm `public.pois` data ingestion only from compliant sources.
- Confirm no API route returns Google-origin rows on user-facing endpoints.
- Confirm OSM attribution text is visible on map screen.

## 7) Known exception (PostGIS extension-owned object)
- Record date: **2026-02-26**
- Exception item: `public.spatial_ref_sys` flagged by Security Advisor as `RLS Disabled in Public`.
- Why it remains:
  - `spatial_ref_sys` is a PostGIS extension-owned system table.
  - Migration role may not own this table, so `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` can fail with `insufficient_privilege`.
- Risk classification:
  - **Low (accepted)** for RouteVia product data exposure.
  - Table contains spatial reference metadata, not user/tenant business rows.
- Mandatory compensating checks before every release:
  - Verify app APIs and RPCs do not query `public.spatial_ref_sys` directly.
  - Verify user-facing reads continue via compliant views/tables (`places_public`, `pois_public`).
  - Verify no direct grants to `anon`/`authenticated` on this table.

```sql
-- Check grants on spatial_ref_sys
select grantee, privilege_type
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name = 'spatial_ref_sys'
order by grantee, privilege_type;

-- Check whether table is in exposed PostgREST schema (operational visibility check)
show pgrst.db_schemas;
```
