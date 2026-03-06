# Store Metadata Clean Checklist

Bu dosya, mağazaya yüklenecek metin ve görsellerin compliance kontrolü içindir.

## 1) Metin Kontrolü
- [ ] Uygulama adı, kısa açıklama, tam açıklamada Google/Google Places/Google Maps markası geçmiyor.
- [ ] "Google verisi", "Google rating" gibi ifadeler yok.
- [ ] Veri kaynağı ifadesi nötr ve doğru: OSM, Wikidata, user, licensed.
- [ ] Harita attribution metni doğru: `© OpenStreetMap contributors`.

## 2) Görsel Kontrolü (Screenshot/Feature Graphic)
- [ ] UI içinde Google logosu/markası yok.
- [ ] Harita ekranlarında OSM attribution görünür.
- [ ] Demo verilerde Google-origin içerik görünmüyor.
- [ ] Top Picks / Place Detail ekranlarında `pois_public` kaynaklı temiz kayıtlar gösteriliyor.

## 3) Teknik Kontrol (Release öncesi)
- [ ] `flutter run` ile fiziksel cihaz smoke test tamam.
- [ ] Anon kullanıcı ile `google_origin=true` kayıtların görünmediği doğrulandı.
- [ ] Legacy provider endpoint'leri `410 disabled_by_policy`.

## 4) Paketleme Notu
- [ ] `docs/production-handover-report.md` gibi iç teknik raporlar mağaza paketine dahil edilmez.
- [ ] Mağazaya sadece `docs/play_store/*` içeriğinden onaylı metin/görseller çıkarılır.
