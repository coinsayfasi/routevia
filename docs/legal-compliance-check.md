# Legal Compliance Check (Google-Free Runtime)

This project is currently configured for `clean_only` operation.

## 1) Runtime Policy
- Mobile map provider: `flutter_map` (OSM tiles)
- Public runtime APIs: clean dataset only (`places_clean*`)
- Legacy Google functions: hard-disabled with `410 disabled_by_policy`

Disabled functions:
- `supabase/functions/ingest_google_district/index.ts`
- `supabase/functions/google_place_enrich/index.ts`
- `supabase/functions/cache_google_thumbnails/index.ts`
- `supabase/functions/photo_proxy/index.ts`

## 2) Mobile SDK/Key Footprint
Android and iOS app config no longer includes Google Maps API keys or Google Maps manifest entries.

Files cleaned:
- `apps/mobile/android/gradle.properties`
- `apps/mobile/android/app/build.gradle.kts`
- `apps/mobile/android/app/src/main/AndroidManifest.xml`
- `apps/mobile/ios/Flutter/Debug.xcconfig`
- `apps/mobile/ios/Flutter/Release.xcconfig`

## 3) Verification Commands
Run these checks before store submission:

```bash
cd ~/Desktop/02_Projeler/routevia

# Mobile footprint
rg -n "GOOGLE_MAPS_ANDROID_API_KEY|com.google.android.geo.API_KEY|google_maps_flutter|maps.googleapis|GoogleMaps|GMS" apps/mobile -S

# Runtime Google legacy endpoints should return 410
curl -i "$SUPABASE_URL/functions/v1/ingest_google_district" -H "apikey: $SUPABASE_ANON_KEY" -X POST
curl -i "$SUPABASE_URL/functions/v1/google_place_enrich" -H "apikey: $SUPABASE_ANON_KEY" -X POST
curl -i "$SUPABASE_URL/functions/v1/cache_google_thumbnails" -H "apikey: $SUPABASE_ANON_KEY" -X POST
curl -i "$SUPABASE_URL/functions/v1/photo_proxy?source=google&ref=test" -H "apikey: $SUPABASE_ANON_KEY"
```

Expected:
- grep output for mobile footprint: empty
- each legacy endpoint: HTTP `410`

## 4) Operational Guardrails
- Worker default: `GOOGLE_RAW_AFTER_BATCH=false`
- Progress endpoint policy marker:
  - `google_pipeline_enabled: false`
  - `policy_mode: "clean_only"`
