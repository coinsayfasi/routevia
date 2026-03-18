# Routevia Root Domain Vercel Runbook

## Amac
`routevia.tabserve.com.tr` kok domaininde en azindan asagidaki endpoint'leri canli tutmak:

- `/app-ads.txt`
- `/robots.txt`
- `/business`
- `/privacy`
- `/terms`
- `/ads`
- `/community`
- `/account-deletion`

## Repo tarafinda hazir olanlar
- Koke yayinlanacak `app-ads.txt`: `/app-ads.txt`
- Koke yayinlanacak `robots.txt`: `/robots.txt`
- Root landing redirect: `/index.html`
- Legal alt sayfa redirectleri:
  - `/business/index.html`
  - `/privacy/index.html`
  - `/terms/index.html`
  - `/ads/index.html`
  - `/community/index.html`
  - `/account-deletion/index.html`

## Vercel tarafinda
1. Vercel dashboard'da bu repo icin bir proje olustur veya mevcut projeyi yeniden bagla.
2. Framework Preset secimi gelirse `Other` sec.
3. Build command bos olabilir.
4. Output directory bos olabilir.
5. Deploy et.

## Domain baglantisi
1. Proje ayarlarindan `routevia.tabserve.com.tr` domainini ekle.
2. DNS zaten Vercel'e bakiyorsa sadece alias'i bu projeye dogru bagla.
3. SSL olusumunu bekle.

## Canli kontrol
- `https://routevia.tabserve.com.tr/app-ads.txt`
- `https://routevia.tabserve.com.tr/robots.txt`
- `https://routevia.tabserve.com.tr/business`

## Beklenen sonuc
- `app-ads.txt` 200 donecek.
- `robots.txt` 200 donecek.
- Legal sayfa path'leri `legal.routevia.tabserve.com.tr` altina yonlenecek.
