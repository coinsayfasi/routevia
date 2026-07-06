# Routevia v1.2.46 (+106) — Sürüm Notları

**Tarih:** 2026-07-06
**Android:** `routevia-v1.2.46-106.aab` → Play Console
**iOS:** `routevia-v1.2.46-106.ipa` → Transporter → App Store Connect

## Ücretsiz deneme (trial) kaldırıldı

- Paywall'da hardcoded "7 Gün Ücretsiz Dene" / trial rozetleri tamamen kaldırıldı
  (premium_gate, home_screen Pro kartı, premium_screen rozeti + paket satırı).
  Buton artık "Routevia Pro'yu Keşfet".
- Legal/Premium koşullarındaki spesifik "7 günlük Pro önizleme" ifadesi genel
  "tanıtım teklifleri (varsa)" olarak güncellendi (yanıltıcı trial vaadi yok).
- Store tarafında (Play + App Store) trial teklifleri zaten kapatıldı; app artık
  hiçbir yerde deneme vaat etmiyor → alan alır, almayan almaz.
- Boşta kalan BillingCatalog importları temizlendi.

## iOS push düzeltmesi (1.2.45'ten devralındı)

- iOS `getToken()` öncesi `getAPNSToken()` beklenip retry uzatıldı (0/2/5/10/15s)
  → ilk kurulumda iOS'a bildirim ulaşmama sorunu giderildi.

## Teknik

- `flutter analyze` temiz. Sürüm 1.2.45+105 → 1.2.46+106.
- Trial UI'ı hardcoded'du → değişiklik iki platformda da build gerektirdi.

## App Store — What's New / Play — Yenilikler

Abonelik akışı sadeleştirildi; bildirim teslimatı iyileştirildi.
