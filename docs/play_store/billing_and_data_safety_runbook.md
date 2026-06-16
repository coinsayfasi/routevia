# Billing and Data Safety Runbook

## Billing urunleri
- Android monthly product id: `routevia_pro_monthly`
- Android yearly product id: `routevia_pro_yearly`
- Entitlement key: `routevia_pro`
- Hedef aylik fiyat: `49.99 TL`
- Hedef yillik fiyat: `500 TL`
- Android package: `com.yunusgunes.routevia`
- iOS bundle id: `com.yunusgunes.routevia`

## Yapilacaklar
1. Play Console > Monetize > Products icinde aylik ve yillik urunleri olustur.
2. App Store Connect tarafinda ayni urunleri esdeger product id ile ac.
3. Billing entegrasyonu acildiginda mobil istemci `IAP_PRO_MONTHLY` ve `IAP_PRO_YEARLY` dart-define ile baglansin.
4. Supabase secrets:
   - `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
   - `GOOGLE_PLAY_PACKAGE_NAME=com.yunusgunes.routevia`
   - `APPLE_SHARED_SECRET`
   - `APPLE_BUNDLE_ID=com.yunusgunes.routevia`
5. `verify_purchase` edge function'i Google Play Developer API ve Apple verifyReceipt ile gerçek store dogrulamasi yapar; dogrulanan bitis tarihi `user_entitlements` tablosuna yazilir.
6. Public release oncesi test kartlari ile Android ve iOS satin alma + restore akisi gercek cihazda smoke test edilmeli.

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
