begin;

create temporary table tmp_ankara_quality (
  province_slug text,
  district_slug text,
  name text,
  slug text,
  category text,
  lat double precision,
  lng double precision,
  short_summary text,
  best_time text,
  duration_min int,
  tags text[],
  popularity_score int,
  is_free boolean,
  image_path text,
  history_bullets text[],
  eat_drink_bullets text[],
  tips_bullets text[]
) on commit drop;

insert into tmp_ankara_quality values
('ankara','altindag','Ankara Resim ve Heykel Muzesi','ankara-resim-heykel-muzesi','museum',39.9289,32.8538,'Cumhuriyet donemi sanat birikimini guclu koleksiyonlarla sunan Ankara merkezli ana sanat muzesi.','day',90,array['culture','rainy_day','walkable','instagrammable'],900,false,'public-media/seed/ankara/resim-heykel/1.jpg',array['Muze Cumhuriyet donemi Turk resim sanatinin temel koleksiyonlarina sahiptir.','Surekli koleksiyon disinda donemsel sergilerle program yenilenir.','Yapi Ankara sanat tarihinde kurumsal bir esiktir.'],array['Opera-Ulus hattinda orta butce yemek secenekleri bulunur.','Ziyaret sonrasi Hamamonu veya Kale rotasina baglanmak pratiktir.','Kisa kahve molasi icin yuruus mesafesinde alternatifler vardir.'],array['Salonlar arasinda kronolojik gezi rotasi kurarsan deneyim artar.','Sergi takvimini onceden kontrol et.','Hafta ici ogleden once saatleri daha sakindir.']),
('ankara','altindag','Rahmi M. Koc Muzesi Ankara','rahmi-koc-muzesi-ankara','museum',39.9410,32.8664,'Sanayi, ulasim ve teknoloji odakli interaktif koleksiyonlariyla aileler icin guclu deneyim sunar.','day',90,array['family','rainy_day','culture','instagrammable'],880,false,'public-media/seed/ankara/rahmi-koc/1.jpg',array['Muze endustri tarihi ve ulasim teknolojileri ekseninde kurgulanmistir.','Objeler yalniz sergilenmez; baglamsal anlatimla sunulur.','Aile odakli egitsel deneyim icin sehirdeki en iyi kapali alanlardan biridir.'],array['Muze cevresinde aileye uygun yemek secenegi bulunur.','Ulus bolgesi rota sonrasi tatli-kahve duraklari icin uygundur.','Cocuklu gezi icin mola noktalarini onceden planla.'],array['Yogun gunlerde bilet kuyrugu olabilecegi icin erken giris yap.','Foto/video kurallarini giriste kontrol et.','Maksimum verim icin 90-120 dakika ayir.']),
('ankara','altindag','Ankara Kalesi','ankara-kalesi','historical',39.9393,32.8622,'Surlar, seyir noktasi ve tarihi mahalle dokusuyla Ankara manzarasini en iyi veren ana durak.','sunset',100,array['sunset','history','instagrammable','walkable'],970,true,'public-media/seed/ankara/ankara-kalesi/1.jpg',array['Kale hattinda Roma-Bizans-Osmanli donem izleri ayni aks uzerinde gorulur.','Ic kale ve cevre sokaklar geleneksel Ankara dokusunu yansitir.','Seyir teraslari baskent topografyasini okumak icin ideal noktalar sunar.'],array['Kale eteginde yerel yemek ve tatli secenekleri gucludur.','Hamamonu ve Ulucanlar ile birlestirilince tam gunluk kultur rotasi olusur.','Aksamustu cay molasi icin avlulu mekanlari tercih et.'],array['Gun batimi cekimleri icin en az 30 dakika once surlara cik.','Dar sokaklarda kaymaz tabanli ayakkabi kullan.','Hafta sonu park ve trafik yogunlugunu hesaba kat.']),
('ankara','cankaya','Anadolu Medeniyetleri Muzesi Seckisi','anadolu-medeniyetleri-muzesi-seckisi-ankara','museum',39.9370,32.8642,'Anadolu Medeniyetleri Muzesi ile birlikte okunacak secki rota: Hitit, Frig ve Roma katmanlari tek gun icinde.','morning',110,array['history','culture','rainy_day'],850,false,'public-media/seed/ankara/anadolu-secki/1.jpg',array['Secki rota Anadolu Medeniyetleri Muzesi cekirdegi etrafinda tarihsel sureklilik okur.','Hitit-Frig-Roma baglantisi sahadaki baska duraklarla tamamlanir.','Ankara merkezde arkeoloji odakli one-day rota icin verimlidir.'],array['Muze sonrasi kale-hamamonu hattinda yemek secenekleri oldukca fazladir.','Arada kahve molasi icin ulus cevresinde uygun fiyatli alternatif bulunur.'],array['Bu rota icin not alarak gezmek deneyimi guclendirir.','Muze + acik alan kombinasyonu icin rahat ayakkabi sec.']);

insert into public.places (
  province_id,
  district_id,
  name,
  slug,
  category,
  geog,
  short_summary,
  best_time,
  duration_min,
  tags,
  popularity_score,
  is_free,
  is_published,
  published_at
)
select
  p.id,
  d.id,
  s.name,
  s.slug,
  s.category::public.place_category,
  st_setsrid(st_makepoint(s.lng, s.lat), 4326)::geography,
  left(s.short_summary, 160),
  s.best_time::public.best_time,
  s.duration_min,
  s.tags,
  s.popularity_score,
  s.is_free,
  true,
  now()
from tmp_ankara_quality s
join public.provinces p on p.slug = s.province_slug
left join public.districts d on d.province_id = p.id and d.slug = s.district_slug
on conflict (province_id, slug) do update set
  district_id = excluded.district_id,
  name = excluded.name,
  category = excluded.category,
  geog = excluded.geog,
  short_summary = excluded.short_summary,
  best_time = excluded.best_time,
  duration_min = excluded.duration_min,
  tags = excluded.tags,
  popularity_score = excluded.popularity_score,
  is_free = excluded.is_free,
  is_published = true,
  published_at = coalesce(public.places.published_at, now()),
  updated_at = now();

insert into public.place_details (place_id, history_bullets, eat_drink_bullets, tips_bullets)
select
  pl.id,
  s.history_bullets,
  s.eat_drink_bullets,
  s.tips_bullets
from tmp_ankara_quality s
join public.provinces p on p.slug = s.province_slug
join public.places pl on pl.province_id = p.id and pl.slug = s.slug
on conflict (place_id) do update set
  history_bullets = excluded.history_bullets,
  eat_drink_bullets = excluded.eat_drink_bullets,
  tips_bullets = excluded.tips_bullets;

insert into public.place_media (place_id, storage_path, source, sort_order)
select
  pl.id,
  s.image_path,
  'curated',
  0
from tmp_ankara_quality s
join public.provinces p on p.slug = s.province_slug
join public.places pl on pl.province_id = p.id and pl.slug = s.slug
where s.image_path is not null
on conflict do nothing;

commit;
