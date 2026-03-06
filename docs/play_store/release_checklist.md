# Release Checklist

## Sürümleme
- [ ] versionName / versionCode güncellendi
- [ ] changelog hazır

## Stabilite
- [ ] `flutter analyze` temiz
- [ ] kritik ekran crash-free test edildi
- [ ] iPhone ve Android cihaz testleri tamam

## İzinler
- [ ] Konum izni açıklaması açık ve anlaşılır
- [ ] Bildirim izni soft ask ile isteniyor
- [ ] İzin reddinde uygulama akışı bloklanmıyor

## Güvenlik
- [ ] Client tarafında service role key yok
- [ ] Referral redemption server-side doğrulanıyor
- [ ] RLS politikaları aktif
- [ ] `public.spatial_ref_sys` için known exception notu ve telafi kontrolleri doğrulandı (`docs/COMPLIANCE_NOTES.md`, bölüm 7)

## Büyüme
- [ ] Plan paylaşımı çalışıyor
- [ ] Yer paylaşımı çalışıyor
- [ ] Davet kodu üretim/bozum test edildi
- [ ] Entitlement banner görünüyor

## Play Store Hazırlığı
- [ ] App icon + adaptive icon doğru
- [ ] Splash görselleri güncel
- [ ] 8 screenshot storyboard üretildi
- [ ] TR listing metinleri yüklendi

## Android Manifest / Deep Link
- [ ] `routevia://` intent-filter aktif
- [ ] `https://routevia.app` intent-filter aktif

## Gizlilik
- [ ] Privacy policy URL hazır
- [ ] Veri kullanım açıklamaları güncel
