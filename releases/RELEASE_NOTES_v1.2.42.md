# Routevia v1.2.42 (+102) — Sürüm Notları

**Tarih:** 2026-07-05  
**Android:** `routevia-v1.2.42-102.aab`  
**iOS:** `routevia-v1.2.42-102.ipa`

## Yeni

- Gezi rehberi bildirimleri artık Routevia içindeki güvenli okuyucuda açılıyor.
- Yazılar gerçek `gezi.tabserve.com.tr` adresinden yüklendiği için web trafiği
  ve analitik ölçümü korunuyor.
- Okuyucuda paylaşma ve tarayıcıda açma seçenekleri eklendi.
- Uygulama açıkken gelen bildirimler, kullanıcıyı bölmeden uygulama içi banner
  olarak gösteriliyor.
- Profil ekranına bildirimleri açma/kapatma ayarı eklendi.

## Bildirim altyapısı

- Firebase token ve topic kaydı tek serviste birleştirildi.
- Cold start, arka plan ve foreground bildirim akışları tamamlandı.
- iOS production APNs entitlement ve Firebase APNs Authentication Key kuruldu.
- Blog push sıklığı Çarşamba/Cumartesi ile sınırlandı.
- Pazartesi kişiselleştirilmiş haftalık rota bildirimi korunuyor.
- Haftalık rota ve etkinlik backend'leri kullanıcı bildirim tercihini kontrol ediyor.

## Doğrulama

- `flutter analyze`: 0 issue
- `flutter test`: tüm testler başarılı
- Android App Bundle release build: başarılı
- iOS no-codesign release build: başarılı
- App Store archive ve imzalı IPA export: başarılı
- IPA entitlement: `aps-environment = production`
- Firebase proje/bundle eşleşmesi: `routevia-prod` / `com.yunusgunes.routevia`
- RevenueCat Android ve iOS anahtarları build ortamında mevcut
- Supabase `weekly_push_digest` ve `send_event_reminders` production deploy: başarılı

## Play Store — Yenilikler (TR)

Gezi rehberleri artık Routevia içinde açılıyor. Bildirim deneyimi geliştirildi,
bildirim tercihleri eklendi ve uygulama kararlılığı artırıldı.

## App Store — What's New (TR)

Gezi rehberleri artık uygulamadan çıkmadan okunabiliyor. Bildirim deneyimi ve
kullanıcı tercihleri geliştirildi; performans ve kararlılık iyileştirildi.

## App Store — What's New (EN)

Travel guides now open inside Routevia. We improved notification controls,
in-app reading, performance, and overall reliability.
