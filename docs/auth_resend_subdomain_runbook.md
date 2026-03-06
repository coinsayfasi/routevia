# Routevia Auth + Resend Subdomain Runbook

Bu dokuman, mobil giris akisini production'a tasimak icin `Resend + Supabase Auth + subdomain` kurulumunu standartlastirir.

## 1) Domain ve DNS modeli

- Auth redirect domain: `auth.routevia.app`
- Mail sender domain: `mail.routevia.app`
- Iletisim mailbox (onerilen): `routevia@tabserve.com`

Neden: ana domain reputasyonunu korur, auth linkleri ve mail deliverability ayrik olur.

## 2) Supabase Auth ayarlari

Supabase Dashboard > Authentication > URL Configuration:

- `Site URL`: `https://auth.routevia.app`
- `Additional Redirect URLs`:
  - `routevia://auth-callback`
  - `https://auth.routevia.app/*`

Not:
- Mobil app icin birincil geri donus `routevia://auth-callback` olmalidir.
- Web fallback ve e-posta acilis senaryolari icin `auth.routevia.app` kalir.

## 3) Resend domain kurulumu

Resend Dashboard:

1. Sender domain olarak `mail.routevia.app` ekle.
2. Verilen DNS kayitlarini zone'a ekle:
   - SPF (TXT)
   - DKIM (CNAME/TXT)
   - DMARC (TXT)
3. Domain status "verified" olana kadar bekle.

## 4) Supabase SMTP -> Resend baglantisi

Supabase Dashboard > Authentication > SMTP Settings:

- Host: Resend SMTP host
- Port: Resend SMTP port
- Username: Resend API/SMTP user
- Password: Resend SMTP key
- Sender email: `no-reply@mail.routevia.app`
- Sender name: `Routevia`

## 5) Mobil login UX standardi

- Ekran basligi: `Giris Yap`
- Akis:
  1. E-posta gir
  2. Kod gonder
  3. 6 haneli kodu dogrula
- Metinde "magic link" teknik ifadesi kullanma.
- Misafir giris kalsin, ancak premium ve profil ozellikleri kisitli olsun.

## 6) Go-live checklist

1. DNS kayitlari verified
2. Supabase SMTP test mail basarili
3. iOS + Android login smoke testi:
   - kod gonder
   - kod dogrula
   - onboarding redirect
4. Auth callback test:
   - `routevia://auth-callback`
   - `https://auth.routevia.app/*`
5. Mail spam test:
   - Gmail / Outlook / iCloud inbox placement kontrolu

## 7) Operasyonel not

- Auth ve mail sorunlarinda ilk kontrol noktasi: `Profile > Baglanti Durumu` karti (mobil app).
- Build alirken `SUPABASE_URL` ve `SUPABASE_ANON_KEY` her zaman `--dart-define` ile gecilmelidir.
