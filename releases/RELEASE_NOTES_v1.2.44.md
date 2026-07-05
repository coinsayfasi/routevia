# Routevia v1.2.44 (+104) — Sürüm Notları

**Tarih:** 2026-07-05  
**Android:** `routevia-v1.2.44-104.aab`  
**iOS:** `routevia-v1.2.44-104.ipa`

## Kritik bildirim düzeltmesi (1.2.43 üzerine tamamlayıcı)

- İlk kurulumda `init()` içindeki erken `subscribeToTopic('blog')` çağrısı kaldırıldı.
  Bu çağrı token oluşmadan yapıldığında `SERVICE_NOT_AVAILABLE` atıp `init`'i
  düşürüyor ve yeni eklenen kontrollü tekrar deneme mekanizmasını **bypass**
  ediyordu.
- Artık tüm abonelik akışı tek noktadan: **token oluştur → `blog` topic'e abone ol
  → kaydet**, 0/2/8 sn kontrollü retry ile `refreshRegistration()` içinde yapılıyor.
- Böylece ilk kurulumda geçici Firebase/Play Services hataları güvenilir şekilde
  toparlanıyor; cihaz topic'e katılamadan akış sessizce sonlanmıyor.

## Play Store — Yenilikler

İlk kurulumdan sonra bildirimlerin bazı cihazlara ulaşmamasına neden olan Firebase
abonelik sorunu tamamen giderildi. Bildirim teslimatı ve uygulama kararlılığı
iyileştirildi.

## App Store — What's New

First-install notification subscription is now fully reliable. Notification
delivery and app stability improved.
