# License Evidence Log

Amaç: Kullanılan görseller için kaynak/lisans/kanıt izini tutmak.

## Kullanım Kuralı
- Her yeni görsel eklendiğinde bu tabloya kayıt aç.
- Kanıt bağlantısı (orijinal URL, lisans sayfası, ekran görüntüsü linki) zorunlu.
- Lisans belirsizse görsel yayın build'ine alınmaz.

## Kayıt Tablosu

| asset_path | place_id | city | district | source_type | source_url | license | attribution | proof_link | checked_by | checked_at |
|---|---|---|---|---|---|---|---|---|---|---|
| public-media/open-license/izmir/kordon/1.jpg | 00000000-0000-0000-0000-000000000000 | İzmir | Konak | wikimedia | https://commons.wikimedia.org/... | CC BY-SA 4.0 | Author Name | https://drive.google.com/... | @owner | 2026-02-25 |

## source_type Değerleri
- `osm`
- `wikidata`
- `user`
- `licensed`

## Yayın Öncesi Kontrol
- [ ] Tüm store screenshot görselleri için log kaydı var.
- [ ] Tüm uygulama içi medya kayıtlarında lisans ve attribution bilgisi mevcut.
- [ ] `proof_link` erişilebilir ve ekip içinde doğrulanmış.
