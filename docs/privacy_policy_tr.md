# Routevia Gizlilik Politikası

Son güncelleme: 25 Şubat 2026

## 1. Toplanan Veriler
- Hesap verisi: e-posta ve kullanıcı kimliği (Supabase Auth).
- Uygulama içi içerik: favoriler, yorumlar, puanlamalar, plan kayıtları.
- Konum verisi: yalnızca uygulama kullanım sırasında (while-in-use) yakın öneri ve rota için.

## 2. Verilerin Kullanım Amacı
- Gezi planı üretmek ve kişiselleştirilmiş öneri sunmak.
- Kullanıcıya yakın konumları göstermek.
- Kullanıcı katkılarıyla (puan/yorum) öneri kalitesini artırmak.

## 3. Üçüncü Taraflar ve Lisans
- Harita altyapısı: OpenStreetMap (OSM).
- Rota hesaplama: OSRM (self-hosted).
- Ücretli/Google tabanlı API kullanılmaz.
- Görseller yalnızca şu kaynaklardan alınır:
  - `user_upload`
  - `curated`
  - `open_license`
  - `placeholder`

## 4. Konum İzni
- Konum erişimi zorunlu değildir.
- Konum izni verilmezse kullanıcı il/ilçe seçerek uygulamayı kullanabilir.
- Arka plan konum takibi yapılmaz.

## 5. Veri Saklama ve Güvenlik
- Veriler Supabase üzerinde RLS politikalarıyla korunur.
- Kullanıcı sadece kendi özel verisini (ör. kendi planları, kendi yorumları) değiştirebilir.

## 6. Veri Silme Talebi
- Kullanıcı hesabı silme veya veri kaldırma talebi için uygulama destek kanalı üzerinden başvuru yapabilir.
- Talep doğrulandıktan sonra ilgili kullanıcı verisi sistemden kaldırılır.

## 7. Değişiklikler
- Gizlilik politikası güncellendiğinde uygulama içinde ve depoda güncel sürüm yayımlanır.
