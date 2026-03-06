# ROUTEVIA
Türkiye seyahat asistanı (Flutter + Supabase + PostGIS + OSM + OSRM).

## Mimari
- `apps/mobile`: Flutter uygulaması (`flutter_map` + OSM)
- `supabase/migrations`: ileriye dönük SQL migration’lar
- `supabase/functions`: Edge Functions
- `tools/ingest_worker`: admin/ingest araçları

## Güvenlik ve Arşiv Koruması
- Raw arşiv tabloları **dokunulmazdır** (silinmez, truncate edilmez, overwrite edilmez).
- Uygulama ve public API yalnızca clean katmanı okur: `places_clean`, `place_details_clean`, `place_media_clean`.
- Raw envanter görünümü: `public.raw_archive_tables_inventory`.

## Ortam Değişkenleri
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `OSRM_BASE_URL` (örn. `http://localhost:5000`)

## Local Çalıştırma
```bash
cd ~/Desktop/02_Projeler/routevia
supabase start
supabase db reset
```

## Function Deploy
```bash
cd ~/Desktop/02_Projeler/routevia
supabase functions deploy nearby_places --no-verify-jwt
supabase functions deploy generate_trip_plan --no-verify-jwt
supabase functions deploy generate_trip_plan_v2 --no-verify-jwt
supabase functions deploy ai_suggest_now --no-verify-jwt
supabase functions deploy live_explore --no-verify-jwt
supabase functions deploy place_detail --no-verify-jwt
supabase functions deploy get_route_polyline --no-verify-jwt
supabase functions deploy get_shared_trip --no-verify-jwt
supabase functions deploy share_trip
supabase functions deploy admin_import_csv_clean
supabase functions deploy admin_build_clean_dataset_from_raw
supabase functions deploy admin_attach_open_license_media
```

## OSM + OSRM Notları
- Harita katmanı: OpenStreetMap tile (`flutter_map`).
- Rota çizimi: self-host OSRM (`get_route_polyline` Edge Function üzerinden).

## Mobil
```bash
cd ~/Desktop/02_Projeler/routevia/apps/mobile
flutter pub get
flutter analyze
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

## Doğrulama
1. Raw tablolar değişmedi mi:
```sql
select * from public.raw_archive_tables_inventory order by table_name;
```
2. Nearby clean dönüyor mu:
```bash
curl -s -X POST "$SUPABASE_URL/functions/v1/nearby_places" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"lat":41.0082,"lng":28.9784,"radius_m":10000}'
```
3. Trip plan clean dönüyor mu:
```bash
curl -s -X POST "$SUPABASE_URL/functions/v1/generate_trip_plan_v2" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"province_slug":"istanbul","days":3,"pace":"medium","transport_mode":"car"}'
```

4. Legacy provider fonksiyonları kapalı mı:
```bash
curl -s -X POST "$SUPABASE_URL/functions/v1/google_place_enrich" -H "apikey: $SUPABASE_ANON_KEY"
curl -s -X POST "$SUPABASE_URL/functions/v1/ingest_google_district" -H "apikey: $SUPABASE_ANON_KEY"
```
Beklenen: HTTP `410` + `disabled_by_policy`.

## Clean medya akışı
Placeholder otomatik ekleme:
```bash
cd ~/Desktop/02_Projeler/routevia/tools/ingest_worker
npm run clean:media:placeholder -- --limit=3000
```

Açık lisans görsel bağlama (admin):
```bash
curl -s -X POST "$SUPABASE_URL/functions/v1/admin_attach_open_license_media" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  --data '{"items":[{"place_id":"<PLACE_UUID>","storage_path":"public-media/open-license/izmir/kordon/1.jpg","license":"CC BY-SA 4.0","attribution":"Yazar Adı","url_original":"https://commons.wikimedia.org/..."}]}'
```

## Store Uyum
- Konum izni: yalnızca kullanım sırasında.
- Gizlilik politikası: hesap, yorum, kullanım-sırası konum kullanımını net belirtin.
- Üçüncü taraf proprietary içerik scraping yok.
- Medya kaynakları: `user_upload`, `curated`, `placeholder`, `open_license`.
