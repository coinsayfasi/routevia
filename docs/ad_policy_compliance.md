# Ad Policy Compliance (App Store / Play)

## Current implementation
- Promo area is explicitly labeled as `Sponsorlu / Reklam`.
- Promo copy states that sponsored placement is separate from organic ranking.
- Promo CTA routes to external business application URL with email fallback.
- No hidden/deceptive ad click behavior is used in the app UI.

## Required before production ads
- Add Privacy Policy section for ad processing (if personalized ads are enabled).
- Add in-app consent flow (KVKK/GDPR style) before personalized ad targeting.
- Ensure ad creatives are clearly separated from core navigation controls.
- Ensure all sponsored cards keep visible `Reklam`/`Sponsorlu` badge.
- Keep age-sensitive and restricted category ad filters active.

## Release checklist
- Verify promo CTA URL is live: `https://routevia.tabserve.com.tr/business`
- Verify fallback contact mail works: `routevia@tabserve.com.tr`
- Verify policy links are reachable from app profile/settings pages.
