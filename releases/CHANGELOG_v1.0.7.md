# Routevia v1.0.7+8 — 18 Mart 2026

## Düzeltmeler

### Premium / Billing
- Pro aktifken "Satın Al" butonu artık görünmüyor; yerine "Aktif Üyelik" kartı gösteriliyor
- Premium yüklenirken satın alma butonu artık disabled — yükleme sırasında yanlış satın alım önlendi
- `user_entitlements` tablosuna unique constraint eklendi; duplicate entitlement satırları temizlendi
- RevenueCat sync (`rc_sync_entitlement`) `updated_at` hatası giderildi — satın alma artık doğru kaydediliyor
- Referral (`redeem_referral`) duplicate insert → upsert; referrer duplicate entitlement sorunu giderildi

### Gezgin İstatistikleri
- Admin ve Pro kullanıcılar artık "Pro'yu Keşfet" görmüyor (yükleme sırasındaki race condition giderildi)
- Premium state yüklenirken kilitleme yapılmıyor — yükleme bitince doğru durum gösteriliyor

### Davet Kodu
- Deep link davet kodunda "Bu kod daha önce kullanıldı" mesajı eklendi
- Deep link hata mesajları artık Türkçe ve kullanıcı dostu

### Günlük Plan (Local Hub)
- Plan artık hep aynı mekanları vermiyor — her üretimde farklı kombinasyon (shuffle topK)
- Kategori çeşitliliği: müze/tarihi + doğa/sahil + aktivite + yemek/kafe ayrı slotlara atandı
- Yemek/kafe mekanlar artık planlara dahil ediliyor (daha önce yanlışlıkla filtreden çıkarılıyordu)
- Kategori bazlı gerçekçi ziyaret süreleri: müze 90 dk, kafe 45 dk, viewpoint 35 dk vb.
- `routevia_pro` entitlement key artık rota optimizasyonunda da tanınıyor
