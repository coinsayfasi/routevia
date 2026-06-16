# Routevia Uretim Seviyesi Icerik ve Moderasyon Blueprint'i

## 1. Mevcut Sistem Audit Checklist

Denetlenen alanlar:

- Veritabani migration gecmisi
- Flutter `routevia_repository.dart` yazma/okuma akislari
- Mevcut admin yuzeyi
- Storage bucket ve object path desenleri
- RLS ve `public.is_admin(...)` rol kontrolu
- Story / hidden feature / local tip / photo / suggestion veri yollari

Audit sonucu:

- Gercek bir web admin uygulamasi yoktu. Mevcut admin, Flutter icinde tek ekranlik operasyon araci.
- Moderasyon tek merkezli degil:
  - `place_suggestions`
  - `place_story_submissions`
  - `place_photos`
  - `community_posts`
  - `poi_reviews`
- Status sozlugu tutarsiz:
  - `draft`
  - `pending`
  - `approved`
  - `rejected`
  - `hidden`
  - `reviewed`
  - `dismissed`
  - `actioned`
- Public / moderation / editorial katmanlari birbirine karismis.
- Story onay akisi sadece submission satirini `approved` yapiyor; guvenilir bir public projection tablosu yok.
- Merkezi `moderation_queue` yok. Bu da admin tarafinda “hangi pending kayitlar islem bekliyor?” sorusuna tek cevap olusmasini engelliyor.
- Storage yapisi da daginik:
  - `place-photos`
  - `community-posts`
  - `public-media`
- `place_story_submissions` RLS tarafinda admin okuyabiliyor olsa da, bu sadece o tabloyu okuyan admin UI varsa anlamli. Moderasyonun tek kaynagi degil.

## 2. Mevcut Bug'in Kok Nedeni

Kullanici hikaye / hidden feature / local tip gonderdiginde uygulama “moderasyona gonderildi” mesaji veriyor; fakat admin tarafi bunu guvenilir sekilde goremedigi icin publish edemiyor.

Muhtemel ve kodda gozlenen ana sebepler:

1. Flutter story gonderimi dogrudan `place_story_submissions` tablosuna yaziyor.
2. Bu insert sonrasi merkezi bir queue kaydi olusmuyor.
3. Admin tarafi tek bir moderasyon tablosu okumuyor; farkli veri tipleri farkli query’lerle okunuyor.
4. Story onayi public `place_stories` benzeri kanonik bir tabloya projection yapmiyor.
5. Basari mesaji, sadece tek tabloya insert tamamlandigi icin veriliyor; “submission + queue” garantisi yok.
6. Sistemde web tabanli, server-side guvenli admin panel yok. Mobil admin ekrani operasyonel olarak yetersiz.

Kritik sonuc:

- “Insert oldu” ile “gercekten moderasyona dustu ve admin gorebilir” ayni sey degildi.

## 3. Yeni Final Mimari

### 3.1 Prensipler

- Tum user-generated content once submission katmanina yazar
- Submission kaydi ile moderasyon queue kaydi ayni transaction zincirinde olusur
- Public uygulama sadece public/published tablolardan okur
- Admin aksiyonlari sadece server-side / SECDEF function veya service-role server action ile calisir
- Tum moderasyon statusleri tek sozluk kullanir:
  - `pending`
  - `approved`
  - `rejected`
  - `needs_edit`

### 3.2 Public Icerik Katmani

- `cities`
- `categories`
- `tags`
- `place_images`
- `place_stories`
- `place_tag_map`
- `featured_places`
- `weekly_routes`

Not:

- Mevcut public uygulama halen agirlikli olarak `pois`, `places_clean`, `places_clean_with_coords` gibi mevcut veri yapilarini kullaniyor.
- Bu blueprint mevcut yapilari aniden kirmaz; yeni moderasyon/public projection katmanini paralel kurar.

### 3.3 Submission Katmani

- `user_place_submissions`
- `user_story_submissions`
- `user_photo_submissions`

### 3.4 Moderasyon ve Audit Katmani

- `moderation_queue`
- `admin_audit_logs`

### 3.5 Legacy Uyumluluk Katmani

Yeni migration su legacy tablolari otomatik mirror eder:

- `place_suggestions` -> `user_place_submissions`
- `place_story_submissions` -> `user_story_submissions`
- `place_photos` -> `user_photo_submissions`

Bu sayede mevcut mobil akislari aninda koparmadan yeni queue calisir.

## 4. Eklendigim / Degistirdigim Dosyalar

- `supabase/migrations/20260314120000_unified_content_moderation_system.sql`
- `apps/mobile/lib/src/data/routevia_repository.dart`
- `apps/admin/*`

## 5. SQL Uygulama Paketi

Yeni migration su bileşenleri ekler:

- enum:
  - `moderation_status`
  - `moderation_submission_type`
  - `story_kind`
  - `place_image_kind`
- yeni tablolar:
  - `cities`
  - `categories`
  - `tags`
  - `place_images`
  - `place_stories`
  - `place_tag_map`
  - `featured_places`
  - `weekly_routes`
  - `user_place_submissions`
  - `user_story_submissions`
  - `user_photo_submissions`
  - `moderation_queue`
  - `admin_audit_logs`
- trigger/fonksiyonlar:
  - unified updated_at trigger
  - legacy status map
  - submission -> queue sync
  - legacy -> unified mirror
  - `approve_place_submission`
  - `publish_story_submission`
  - `publish_photo_submission`
  - `admin_moderate_submission`
  - `admin_unpublish_story`
  - audit log yazici
- backfill:
  - provinces -> cities
  - enum / existing tags -> `categories` ve `tags`
  - legacy submissions -> unified submissions
  - approved legacy rows -> `place_stories` ve `place_images`
- RLS:
  - public tablolar sadece publish/active satirlari okur
  - kullanici sadece kendi submission’larini gorur
  - admin `moderation_queue` ve `admin_audit_logs` uzerinde tam erisime sahiptir
- storage:
  - `place-covers`
  - `place-gallery`
  - `community-photos`
  - `story-assets`
  - `temp-uploads`

## 6. Admin Panel Yapisi

`apps/admin` altinda Next.js 15 App Router iskeleti eklendi.

### Route yapisi

- `/`
- `/moderation`
- `/moderation/[submissionType]/[submissionId]`
- `/places`
- `/stories`
- `/images`
- `/cities`
- `/categories`
- `/tags`
- `/editorial`

### Yapinin amaci

- Queue listeleme server-side
- Queue detayinda server action ile karar verme
- Service-role client sadece server tarafinda
- Admin role dogrulamasi `profiles.role = 'admin'`

### Eklenen typed katmanlar

- `lib/types/moderation.ts`
- `lib/zod/moderation.ts`
- `lib/data/moderation.ts`
- `lib/actions/moderation.ts`
- `lib/supabase/server.ts`
- `lib/auth.ts`

## 7. Flutter Tarafinda Yapilan Degisiklik

### Guncellenen akış

`submitPlaceStoryContribution(...)`

- Eski: `place_story_submissions`
- Yeni: `user_story_submissions`

Ek garanti:

- Insert `select(...).single()` ile donus kontrolu yapiliyor
- Donen `status = pending` degilse hata atiliyor
- Yeni DB trigger’i ayni transaction akisinda `moderation_queue` satiri olusturuyor

### Public story okuma

`getApprovedPlaceStories(...)`

- Eski: `place_story_submissions` tablosundan `status=approved`
- Yeni: `place_stories` tablosundan `is_published=true`

Bu kritik, cunku submission tablosu artik public source olmamali.

### Admin story okuma

`adminGetPlaceStorySubmissions(...)`

- Eski: `place_story_submissions`
- Yeni: `user_story_submissions`

### Admin story karar verme

`adminReviewPlaceStorySubmission(...)`

- Eski: dogrudan table update
- Yeni: `admin_moderate_submission(...)` RPC

Bu sayede:

- status guncelleme
- queue guncelleme
- publish projection
- audit log

tek bir server-side transaction mantigi altinda toplandi.

## 8. Migration / Refactor Sirasi

Onayladigim sira:

1. Unified tablolari ekle
2. Legacy mirror triggerlarini devreye al
3. Mevcut pending legacy veriyi backfill et
4. Story Flutter akisini yeni tablolara gecir
5. Story read akisini `place_stories`’e tası
6. Web admin queue’yu yeni `moderation_queue` uzerinden calistir
7. Photo ve place suggestion akisini ikinci adimda full canonical tablolara tası
8. Son fazda legacy admin query’lerini kaldir

Bu siralama mobil uygulamayi bir anda kirmaz.

## 9. Storage Mimarisi

Hedef object path yapisi:

- `place-covers/{city_slug}/{place_id}/cover.webp`
- `place-gallery/{city_slug}/{place_id}/{image_id}.webp`
- `community-photos/{user_id}/{submission_id}/{filename}.webp`
- `story-assets/{user_id}/{submission_id}/{filename}.webp`
- `temp-uploads/{user_id}/{uuid}.jpg`

Mevcut sistemde:

- `place-photos` bucket’i halen aktif
- migration bunu mirror ederek yeni `user_photo_submissions` ve `place_images` projection’ina tasiyor

Onerilen sonraki adim:

- Upload once `temp-uploads`
- processing worker:
  - metadata extraction
  - orientation normalize
  - WebP conversion
  - thumbnail / medium / large derivation
- moderasyon onayinda final bucket’a tasima

## 10. Performans Stratejisi

### 10.1 Veritabani

Yuksek frekansli sorgular icin indeksler eklendi:

- queue: `status + submission_type + submitted_at`
- user submission history: `user_id + status + created_at`
- place bazli admin/public filtre: `place_id + status + created_at`
- stories: `place_id + is_published + created_at`
- images: `place_id + is_published + image_type + sort_order`
- audit: `target_table + target_id + created_at`

### 10.2 Payload minimizasyonu

Liste payload’i:

- sade alanlar
- tam body yerine `searchable_excerpt`
- image gallery listelerde yok
- detay sayfasinda tam detail cagrisi

### 10.3 Admin hiz

- Queue listesi server-side filtrelenir
- `limit + offset` ile page edilir
- Summary kartlari ve liste sorgulari ayridir
- Detail sayfasi lazy load edilir
- Buyuk client-side tablo yok

### 10.4 Flutter performansi

Zorunlu rehber:

- liste kartlarinda thumbnail
- detail sayfasinda medium
- fullscreen’da large/original on-demand
- `CachedNetworkImage`
- infinite scroll / page size 20-30
- map ekraninda bounding-box sorgu
- tum marker’lari tek seferde indirmeme

## 11. Map / Geo Optimizasyon Notlari

Bu degisiklik dogrudan map query’sini degistirmiyor, ama final sistem icin gereken prensipler:

- viewport-based fetch
- bbox bazli RPC veya SQL filter
- marker clustering
- summary DTO ve detail DTO ayirimi
- place detail lazy load
- full media array’i map card’da tasimama

## 12. Query Optimization Checklist

- `select *` kullanma
- list endpoint’lerde sadece kart alanlarini sec
- `status` filtresi olmayan admin queue sorgusunu default `pending` tut
- `submitted_at desc` ile stable order kullan
- story detail’de full text yalniz detail ekraninda gelsin
- place image listesinde tam boy URL yerine derivable path veya CDN URL kullan

## 13. Flutter Data Contract

### Story / hidden feature / local tip submit

Insert target:

- `user_story_submissions`

Payload:

```json
{
  "place_id": "uuid",
  "user_id": "auth-user-uuid",
  "title": "optional-short-title",
  "story_text": "40-4000 chars",
  "story_kind": "story | local_tip | history_note | hidden_feature",
  "status": "pending"
}
```

Beklenen sonuc:

- insert basarili
- row doner
- `status = pending`
- ayni transaction zincirinde `moderation_queue` row olusmus olur

UI kuralı:

- Basari mesaji sadece insert basariliysa goster
- Hata varsa “moderasyona gitti” deme

### Public story read

Source:

- `place_stories`

Filter:

- `place_id = ?`
- `is_published = true`

### Kullanici kendi submission history

Source:

- `user_story_submissions`
- `user_place_submissions`
- `user_photo_submissions`

Status degerleri sadece:

- `pending`
- `approved`
- `rejected`
- `needs_edit`

## 14. Debug Checklist

Bir kayit admin’de gorunmuyorsa sirasiyla:

1. `user_story_submissions` / ilgili submission tablosunda row var mi?
2. Ayni `id` icin `moderation_queue` row var mi?
3. `moderation_queue.status = pending` mi?
4. Admin kullanicisinin `profiles.role = 'admin'` mi?
5. `moderation_queue_overview` select sonucu donuyor mu?
6. RPC `admin_moderate_submission` hata veriyor mu?
7. Approved ise `place_stories` veya `place_images` projection row olusuyor mu?
8. Public app yeni projection tablosunu mu okuyor, yoksa eski submission tablosunu mu?

## 15. Ne Korundu, Ne Refactor Edildi, Ne Degisti

Korunanlar:

- `public.is_admin(...)` rol stratejisi
- mevcut `pois` public place kimligi
- mevcut mobil uygulamanin place id contract’i
- mevcut legacy tablolarin calismaya devam etmesi

Refactor edilenler:

- story moderation akisi
- admin karar mantigi
- public story projection modeli
- moderasyon queue mantigi
- auditability

Degistirilenler:

- unified status sistemi
- Next.js admin iskeleti
- queue-first moderasyon modeli

## 16. Sonraki Zorunlu Adimlar

Bu commit paketi omurgayi kurar; tam uretim kapanisi icin asagidaki adimlar sonraki sprintte tamamlanmali:

1. Photo upload Flutter akisini `user_photo_submissions` + derivation pipeline’a tasimak
2. Place suggestion Flutter/admin akisini `user_place_submissions` merkezli hale getirmek
3. Admin login / callback / session UI’sini bitirmek
4. Thumbnail / medium / large image derivative worker eklemek
5. `place_images` tabanli public media read tarafini mobilde standardize etmek
6. Public cache stratejisini CDN + mobile cache policy ile finalize etmek

## 17. Neden Bu Mimari Bottleneck Yaratmaz

Bu tasarim bottleneck yaratmaz cunku:

- Pending operasyonlar tek queue tablosunda denormalized index’lerle tutulur
- Public okumalar submission tablolardan degil projection tablolardan gelir
- Liste ve detay payload’lari ayridir
- Admin filtreleme server-side’dir
- Storage binary verisi Postgres’e girmez
- Moderasyon kararları tek RPC ile transaction-safe ilerler
- Legacy uyumluluk katmani sayesinde buyuk patlayici rewrite gerekmez
- Story bug’i gibi “gorunmez moderasyon” hatalari queue zorunlulugu sayesinde sessizce gecemez

En kritik prensip:

- “Submission yazildi” ile “moderasyon icin gercekten gorunur hale geldi” artik ayni transaction zincirinin parcasi.
