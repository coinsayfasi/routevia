# Legal Site Deploy Runbook

## Amac
`legal.routevia.tabserve.com.tr` alaninda Routevia'nin public policy ve legal sayfalarini canli yayinlamak.

## Repo tarafinda hazir olanlar
- Statik site kaynagi: `site/`
- GitHub Pages workflow: `.github/workflows/legal-site-pages.yml`
- Custom domain kaydi: `site/CNAME`
- Public sayfalar:
  - `/privacy`
  - `/terms`
  - `/ads`
  - `/community`
  - `/account-deletion`
  - `/business`

## GitHub tarafinda
1. Repo Settings > Pages ac.
2. Source olarak `GitHub Actions` sec.
3. `legal-site-pages` workflow'unu bir kez tetikle veya `main` branch'e push yap.
4. Deploy tamamlandiktan sonra Pages URL olusur.

## DNS tarafinda
1. `legal.routevia.tabserve.com.tr` icin bir `CNAME` kaydi olustur.
2. Hedef olarak GitHub Pages hostunu kullan:
   - `<github-kullanici-adi>.github.io`
3. DNS yayildiktan sonra GitHub Pages custom domain alanina `legal.routevia.tabserve.com.tr` yaz.
4. HTTPS zorunlu secenegini ac.

## Canli kontrol
- `https://legal.routevia.tabserve.com.tr/`
- `https://legal.routevia.tabserve.com.tr/privacy`
- `https://legal.routevia.tabserve.com.tr/terms`
- `https://legal.routevia.tabserve.com.tr/ads`
- `https://legal.routevia.tabserve.com.tr/community`
- `https://legal.routevia.tabserve.com.tr/account-deletion`
- `https://legal.routevia.tabserve.com.tr/business`

## Uygulama eslesmesi
- Privacy URL: `https://legal.routevia.tabserve.com.tr/privacy`
- Terms URL: `https://legal.routevia.tabserve.com.tr/terms`
- Ads URL: `https://legal.routevia.tabserve.com.tr/ads`
- Community URL: `https://legal.routevia.tabserve.com.tr/community`
- Account deletion URL: `https://legal.routevia.tabserve.com.tr/account-deletion`
- Business URL: `https://legal.routevia.tabserve.com.tr/business`
