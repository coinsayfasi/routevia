# Admin (il/ilçe) re-sync — 2026-06-06

POI'lerin il/ilçe atamalarındaki sistematik hatayı (fan-out duplicate + yanlış il)
gerçek OSM idari sınır poligonlarıyla point-in-polygon yaparak düzeltti.

## Ne yapıldı
1. **Kaynak**: `pois` (27.031) + `places_clean` (10.567) canlıdan çekildi (PostgREST).
2. **Sınırlar**: izzetkalic OSM admin-level-4 (il) + admin-level-6 (ilçe); eksik
   Iğdır ili alpers'tan tamamlandı. Her POI'nin gerçek il/ilçesi `shapely` ile bulundu
   (il = il poligonu otorite; ilçe = ili tutan ilçe poligonu, yoksa il içinde en yakın
   DB ilçe merkezi).
3. **Düzeltme**: 878 yanlış il + 16.793 yanlış ilçe → doğru değer.
4. **Dedup**: aynı isim+koordinat fan-out kopyaları tekilleştirildi
   (16.538 pois + 383 places_clean silindi). **0 kullanıcı içeriği kaybı**
   (içerik taşıyan satır asla silinmedi; 3 gezi referansı survivor'a taşındı).
5. **App**: `listProvinceHubPlaces` + `local_hub_screen` — ilçe açıkça seçilince
   ilçe-bazlı filtre; sadece il seçilince il geneli.

Sonuç: pois 27.031 → **10.493**, places_clean 10.567 → **10.184**, 0 il uyuşmazlığı.

## Backup / rollback (canlı DB'de)
- `public._bak_pois_admin_0606`        — pois(id,city,district) değişiklik öncesi
- `public._bak_places_clean_admin_0606`— places_clean(id,province_id,district_id) öncesi
- `public._bak_del_pois`               — silinen pois satırlarının TAM kopyası (16.538)
- `public._bak_del_pc`                 — silinen places_clean satırları (383)
- `public._admin_fix`                  — staging (id→pid,did,keep,survivor_id)

Geri almak için: silinenleri `_bak_del_*`'ten re-insert, il/ilçeyi `_bak_*_admin_0606`'tan
geri yaz. Her şey doğrulandıktan sonra bu tabloları `drop table` ile temizleyebilirsin.

## Scriptler
- `analyze.py`       — point-in-polygon motoru → `poi_corrections.json`
- `load_staging.py`  — staging tabloyu yükler
- `runsql.sh`        — Management API ile SQL çalıştırır (token Keychain'den)
