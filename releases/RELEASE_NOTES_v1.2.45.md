# Routevia v1.2.45 (+105) — Sürüm Notları

**Tarih:** 2026-07-06
**Odak:** iOS push bildirimi düzeltmesi (Android zaten çalışıyor)

## iOS push fix

- **Sorun:** iOS'ta `FirebaseMessaging.getToken()` APNs token'ını gerektiriyor;
  ilk açılışta APNs kaydı birkaç saniye geciktiği için token gelmeden `getToken()`
  null dönüyordu → cihaz `blog` topic'ine abone olamıyor, FCM token kaydedilmiyor
  → iOS'a push HİÇ ulaşmıyordu. (Canlı doğrulama: `user_push_tokens` tablosunda
  0 iOS token, sadece Android.)
- **Çözüm:** `refreshRegistration()` içinde `getToken()`'dan önce iOS'ta
  `getAPNSToken()` beklenip doğrulanıyor; hazır değilse kontrollü retry döngüsüne
  düşülüyor. Retry aralıkları da uzatıldı (0/2/5/10/15 sn) — ilk açılışta APNs
  kaydına daha çok süre.
- **Etki:** Sadece iOS (`Platform.isIOS` korumalı); Android akışı değişmedi.

## Doğrulama

- `flutter analyze` temiz.
- Build: production APNs entitlement (App Store).
- Firebase APNs Auth Key (M9A3VYSVUD, Team A6KKZ4WJ49) yüklü ve production.

## App Store — What's New

Fixed push notifications not arriving on iOS devices. Notification delivery
reliability improved.
