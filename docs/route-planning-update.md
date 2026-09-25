# Süreye göre plan, gezi modu, Pro dönüş saati ve gezi günlüğü (v1.2.48)

## Hızlı plan (ücretsiz)
- “Şimdi Çıkalım”: 120/240/480 dakika; yürüme/otomobil.
- Yol ve ziyaret süreleri birlikte bütçeye sığdırılır; ziyaret süreleri kısaltılmaz, sığmayan durak elenir, hiçbiri sığmazsa açıklama gösterilir.
- Konum yoksa ilk durak başlangıç kabul edilir.
- “Bugünü optimize et” yalnız seçilen günü değiştirir, durak silmez, daha uzun sonucu uygulamaz; gezi başladıysa sıra korunur. Sonuç yeni gezi sürümü olarak kaydedilir (eski paylaşım bağlantısı değişmez).
- Yol matrisi yönlüdür. Yol servisi yoksa mesafe/hız tahmini kullanılır ve “tahmini” olarak etiketlenir; ulaşılamayan yol sıfır süre sayılmaz.
- Günlük ücretsiz plan sayacı her plan için tam bir kez artar (sunucu kaydı başarılı/başarısız fark etmez).

## Gezi modu (ücretsiz)
- Geziye başla → sıradaki durak → Yol tarifi / Gezdim / Bu durağı atla / Geri al.
- İlerleme gezi+gün bazında yalnız cihazda saklanır; herkese açık check-in kayıtlarından ayrıdır.

## Gezi günlüğü (ücretsiz)
- Kullanıcı gezi kartında “Rotamı kaydet”i açarsa gerçek GPS izi **yalnız uygulama açıkken** kaydedilir (arka plan konumu yok). Kötü doğruluklu (>50 m), 15 m altı kıpırtı ve imkânsız hızdaki sıçrama noktaları elenir; gün başına en çok 3000 nokta.
- İz cihazda kalır; uygulama kapanınca kayıt kendiliğinden devam etmez.
- Günlük ekranı: iz varsa gerçek iz (düz çizgi, mesafe/süre); yoksa gezilen durakları bağlayan **kesikli** çizgi ve “gerçek iz değildir” etiketi. Plan çizgisi gerçek iz gibi sunulmaz.
- “Toplulukta paylaş” mevcut gönderi editörünü rota bağlı ve özet dolu açar; gönderi moderasyondan geçer, rumuzla görünür. **Ham GPS izi ve konum paylaşılmaz.** Kullanıcı izi silebilir.

## Pro dönüş saati
- Başlangıç noktasına veya favorideki bir yere dönüş; bugünkü dönüş saati; dönüş yolculuğu + 15 dk zaman payı; isteğe bağlı mutlaka görülecek durak (sığmazsa açık hata).
- Dönüş noktası yol matrisine eklenir. Bilgiler `trip_days_clean.planning_metadata` (yalnız sahip RLS) kolonunda saklanır; paylaşım uçları bu kolonu seçmez. Kolon yoksa uygulama eski şemaya düşer.
- Sunucu Pro kontrolü (`get_route_polyline`, `pro_feature: return_deadline`): admin rolü veya `user_entitlements` aktif kaydı; yoksa RevenueCat REST ile canlı doğrulama (`_shared/revenuecat.ts`) ve kaydın yenilenmesi. Girişsiz 401, Pro yok 403, doğrulanamazsa 503.

## Sunucu ayarları
- `OSRM_BASE_URL` (otomobil), `OSRM_WALKING_BASE_URL` (yaya), `OSRM_CYCLING_BASE_URL` (bisiklet). Profil URL’si veri setini değiştirmez.
- **Şu an OSRM tanımlı değil** → matris `unavailable`, uygulama tahmini sürelerle çalışır; `get_route_polyline` rota çizgisi de 500 yerine işaretli düz çizgi döndürür.
- Açılış saatleri, canlı trafik ve toplu taşıma tarifeleri hesaba katılmaz.

## Doğrulama
- `./scripts/mobile_flutter.sh analyze --no-pub` → temiz
- `./scripts/mobile_flutter.sh test --no-pub` → 27 test (planlayıcı, dönüş planı, gezi ilerlemesi, GPS izi)
- Canlı fonksiyon: matris 200/unavailable, girişsiz Pro 401, geçersiz istek 400, rota çizgisi 200/straight.
- Cihazda kontrol edilecekler: konum açık/kapalı hızlı plan; Pro dönüş planı (aktif abone); rota kaydı açık/kapalı ve ekrandan çıkış; günlük paylaşım akışı.
