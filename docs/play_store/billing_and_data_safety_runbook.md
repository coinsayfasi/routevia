# Billing and Data Safety Runbook

## Billing urunleri
- Android monthly product id: `routevia_pro_monthly`
- Android yearly product id: `routevia_pro_yearly`
- Entitlement key: `routevia_pro`

## Yapilacaklar
1. Play Console > Monetize > Products icinde aylik ve yillik urunleri olustur.
2. App Store Connect tarafinda ayni urunleri esdeger product id ile ac.
3. Billing entegrasyonu acildiginda mobil istemci `IAP_PRO_MONTHLY` ve `IAP_PRO_YEARLY` dart-define ile baglansin.
4. Satin alma sonrasi backend tarafinda store receipt / purchase token dogrulama katmani eklenip `user_entitlements` tablosu guncellensin.

## Data Safety / Consent
- Hesap verisi: e-posta, kullanici kimligi
- Kullanici icerigi: yorum, puan, plan, favori
- Konum: only while-in-use
- Reklam/Tracking:
  - Consent yoksa yalnizca baglamsal sponsorlu icerik
  - Consent varsa personalized ads toggles store disclosure ile uyumlu olmali

## Console checklist
- Privacy Policy URL: `https://legal.routevia.tabserve.com.tr/privacy`
- Terms URL: `https://legal.routevia.tabserve.com.tr/terms`
- Business / ad policy URL: `https://legal.routevia.tabserve.com.tr/business`
- Data Safety formu consent ekranindaki secimlerle uyumlu olmali
