# Routevia v1.2.36 (build 96)

**Önceki sürüm:** 1.2.35 (95) · **Yeni sürüm:** 1.2.36 (96)
**Tarih:** 2026-06-06 · **Platform:** Android (AAB) + iOS (IPA)

---

## 🇹🇷 Mağaza "Yenilikler" metni (kısa — Play Console / App Store)

```
• Konum doğruluğu: Gezilecek yerlerin il/ilçe bilgisi gerçek harita
  sınırlarına göre yeniden düzenlendi. Artık yerler doğru ilde görünüyor.
• İlçe filtresi: Bir ilçe seçtiğinizde yalnızca o ilçedeki yerler listelenir;
  sadece il seçtiğinizde ilin tamamı gösterilir.
• Tekrar eden kayıtlar temizlendi — aynı yer artık tek kez görünüyor.
• Genel veri kalitesi ve performans iyileştirmeleri.
```

## Ayrıntılı değişiklikler (dahili)

### Veri / Backend
- 27.031 → 10.493 POI: gerçek OSM il/ilçe sınır poligonlarıyla (point-in-polygon)
  konum atamaları düzeltildi. **878 yanlış il + 16.793 yanlış ilçe** giderildi.
- Fan-out duplicate temizliği: 16.538 pois + 383 places_clean fazlalık kopya
  silindi (0 kullanıcı içeriği kaybı; kullanıcı gezileri korundu).
- Yeni `admin_boundaries_province/district` tabloları (81 il + 905 ilçe) + RLS.
- `pois` autofill trigger'ı centroid yerine **poligon-bazlı** (`resolve_admin_by_point`)
  → bundan sonra eklenen yerler de doğru il/ilçeye düşer.
- Migration: `supabase/migrations/20260606120000_polygon_admin_resolution.sql`

### Uygulama (Flutter)
- `listProvinceHubPlaces` + `local_hub_screen`: ilçe açıkça seçilince **ilçe-bazlı**
  filtre; sadece il seçilince il geneli (eski "hepsini getir" davranışı kaldırıldı).

---

## Yükleme

**Android (AAB)** — `releases/routevia-v1.2.36-96.aab`
→ Play Console → Üretim → Yeni sürüm oluştur → AAB'yi yükle.

**iOS (IPA)** — `releases/routevia-v1.2.36-96.ipa`
→ **Transporter** uygulaması → IPA'yı sürükle → Teslim Et (Deliver).
(veya `xcrun altool --upload-app -f releases/routevia-v1.2.36-96.ipa -t ios --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>`)
