# Routevia Closed Beta Smoke Checklist

Tarih: 2026-03-12

## 1. Auth ve oturum

- Giris yap
- Uygulamayi kapat ve yeniden ac
- 5-10 dakika sonra tekrar kritik aksiyon dene
- Beklenen: "oturum suresi doldu" false-positive cikmamali

## 2. Place detay aksiyonlari

- Haritada bir yere gir
- Favori butonuna bas
- Check-in yap
- Kisa yorum + puan gonder
- Topluluk fotografi yukle
- Beklenen: aksiyonlar generic hata vermemeli

## 3. Admin moderasyon

- Admin paneli yalniz admin hesapta gorunmeli
- Foto yuklemesinden sonra `Fotograflar > Bekleyen` ekraninda kayit gorunmeli
- Yorumu gonderdikten sonra `Yorumlar > Bekleyen` ekraninda kayit gorunmeli
- Foto `Onayla` ve `Ana Gorsel Yap` calismali
- Yorum `Onayla` sonrasi ilgili place detayinda topluluk yorumu gorunmeli

## 4. Oneri ve feedback

- Normal kullanici `Yer Oner` gondersin
- Admin `Oneriler` sekmesinde gorsun
- Normal kullanici geri bildirim gondersin
- Admin `Feedback` sekmesinde gorsun

## 5. Home ve kesif

- Trend harita acilsin
- Canli durum kartlari veri gosteriyorsa hata vermesin
- Mevsim onerileri yuklensin
- Local hub / il hub plan olustursun

## 6. Premium

- Routevia Pro ekrani acilsin
- Store urunu yoksa ekran kontrollu fallback gostersin
- Davet kodu olustur / paylas aksiyonu calissin
- Pro davet erisimi olan hesapta durum metni dogru gorunsun

## 7. Paylasim

- Place share butonu calissin
- Liste / rota paylasimi token uretebilsin
- Paylasilan link gecersizse net hata metni donsun

## 8. Profil

- Yorumlarim ve Fotograflarim ekranlari acilsin
- Sadece mevcut kullanicinin icerigi gorunsun
- Icerik durumlari dogru gorunsun (`pending`, `approved`, `hidden`)

## 9. Kapali test cikis kriteri

- Kritik akislarda blocker yok
- Admin moderasyon zinciri uc uca calisiyor
- Generic "Bir sorun olustu" mesaji tekrar eden pattern olmaktan cikti
- Tekrarlanabilir crash yok
