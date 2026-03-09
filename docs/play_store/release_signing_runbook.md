# Routevia Release Signing Runbook

## Amac
Debug imzasi ile uretilen test APK'den, store release signing akisine gecmek.

## Gerekenler
- Android keystore (`.jks` veya `.keystore`)
- Guvenli saklanan keystore sifreleri
- Play Console uygulama kaydi

## Android tarafinda
1. `apps/mobile/android/key.properties` olustur.
2. Asagidaki degerleri guvenli sekilde doldur:
   - `storePassword`
   - `keyPassword`
   - `keyAlias`
   - `storeFile`
3. `apps/mobile/android/app/build.gradle.kts` icinde release signing config'i debug key yerine bu dosyadan oku.

## Play Console tarafinda
1. App signing by Google Play etkinlestir.
2. Internal testing track'e ilk AAB yukle.
3. Privacy policy URL, store listing ve Data Safety alanlarini tamamla.

## Release checklist
- Privacy policy ve terms linkleri uygulama icinden ulasilabilir
- Consent/tracking ayarlari profil ekraninda acik
- Sponsorlu icerik politikalari tanimli
- Resend / SMTP anahtarlari rotate edilmis
- Store metadata TR/EN gozden gecirilmis
