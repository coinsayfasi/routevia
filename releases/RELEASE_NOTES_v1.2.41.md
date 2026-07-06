# Routevia v1.2.41 (+101) — Sürüm Notları

**Tarih:** 2026-07-05
**Paket:** `routevia-v1.2.41-101.aab` (58.4 MB)
**Platform:** Android (AAB) — iOS'a build gerekmedi (sorun Android'e özgü, iOS %100 crash-free)

---

## 🐛 Kritik hata düzeltmesi — Android reklam çökmesi

Crashlytics'te tekrar eden `_AdWidgetState.build` çökmesi giderildi
("AdWidget requires Ad to be loaded before it is added to the widget tree").

- **Sebep:** Klavye açılıp kapandığında (yer detayında yorum/arama) banner reklam
  widget ağacından tamamen çıkarılıp tekrar ekleniyordu. `google_mobile_ads`
  bir banner'ın platform view'ını detach → re-attach etmeyi desteklemiyor.
- **Etki:** Android crash-free %85.7 → hedef ~%99+. iOS zaten %100 (platform view
  yaşam döngüsü farklı olduğundan orada tetiklenmiyordu).
- **Çözüm:** Reklam artık ağaçtan çıkarılmıyor; `Offstage` ile gizleniyor
  (platform view canlı kalıyor) + `AdWidget`'a sabit `ValueKey` verildi.

## ✨ Yeni — Blog bildirimleri

- Android 13+ için bildirim izni akışı eklendi.
- `blog` topic aboneliği: gezi-blog otomasyonundan gelen yeni yazı bildirimleri.
- Blog push'una dokununca yazı, cihazın tarayıcısında açılıyor.

---

## ✅ Yayın öncesi doğrulama

- `flutter analyze` — temiz (0 issue)
- Binary doğrulaması: `SUPABASE_URL` doğru gömülü (`xfswonqskciufcnsehfc.supabase.co`),
  dart-define sızıntısı yok, RevenueCat Android key gömülü (`goog_…`)
- Supabase migration senkronu: local 123 = remote 123 (nearest_district_fallback
  + mustsee_curated_seed canlıya işlendi, idempotent)

---

## 📝 Play Console "Yenilikler" (kopyala-yapıştır, TR)

Bu güncellemede reklam kaynaklı nadir bir çökme sorunu giderildi ve uygulama
kararlılığı artırıldı. Ayrıca gezi rehberi bildirimleri eklendi. İyi gezmeler!
</content>
