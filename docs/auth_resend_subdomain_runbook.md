# Routevia Auth + Resend Subdomain Runbook

Bu dokuman, mobil giris akisini production'a tasimak icin `Resend + Supabase Auth + subdomain` kurulumunu standartlastirir.

## 1) Domain ve DNS modeli

- Auth redirect domain: `auth.routevia.tabserve.com.tr`
- Mail sender domain: `mail.routevia.tabserve.com.tr`
- Iletisim mailbox (onerilen): `routevia@tabserve.com`

Neden: ana domain reputasyonunu korur, auth linkleri ve mail deliverability ayrik olur.

## 2) Supabase Auth ayarlari

Supabase Dashboard > Authentication > URL Configuration:

- `Site URL`: `https://auth.routevia.tabserve.com.tr`
- `Additional Redirect URLs`:
  - `routevia://auth-callback`
  - `https://auth.routevia.tabserve.com.tr/*`

Not:
- Mobil app icin birincil geri donus `routevia://auth-callback` olmalidir.
- Web fallback ve e-posta acilis senaryolari icin `auth.routevia.tabserve.com.tr` kalir.

## 3) Resend domain kurulumu

Resend Dashboard:

1. Sender domain olarak `mail.routevia.tabserve.com.tr` ekle.
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
- Sender email: `no-reply@mail.routevia.tabserve.com.tr`
- Sender name: `Routevia`

## 4.1) Email template zorunlulugu

Supabase Dashboard > Authentication > Email Templates ekraninda giris maili sadecce baglanti icermemeli. Kullaniciya 6 haneli kod da gosterilmelidir.

Kritik nokta:

- Mailde `{{ .Token }}` yoksa kullanici sadece link gorur.
- Mailde sadece `{{ .ConfirmationURL }}` varsa uygulamadaki "6 haneli kod gir" akisi eksik kalir.
- En guvenli yapi: hem `{{ .Token }}` hem `{{ .ConfirmationURL }}` kullanmak.

Onerilen metin:

```html
<h2>Routevia Giris Kodu</h2>
<p>6 haneli giris kodun:</p>
<p style="font-size:28px;font-weight:700;letter-spacing:6px">{{ .Token }}</p>
<p>Uygulama acilmadiysa bu baglantiyi kullan:</p>
<p><a href="{{ .ConfirmationURL }}">Giris yap</a></p>
```

Not:

- Kullanici sadece kodla ilerleyecekse bile `{{ .ConfirmationURL }}` kalsin; bu deep link fallback'idir.
- Kodun uzunlugu bu repoda `supabase/config.toml` icinde `otp_length = 6` olarak ayarli.

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
   - `https://auth.routevia.tabserve.com.tr/*`
5. Mail spam test:
   - Gmail / Outlook / iCloud inbox placement kontrolu

## 7) Operasyonel not

- Auth ve mail sorunlarinda ilk kontrol noktasi: `Profile > Baglanti Durumu` karti (mobil app).
- Build alirken `SUPABASE_URL` ve `SUPABASE_ANON_KEY` her zaman `--dart-define` ile gecilmelidir.
