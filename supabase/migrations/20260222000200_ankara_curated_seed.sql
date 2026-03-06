begin;

create temporary table tmp_ankara_seed (
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

insert into tmp_ankara_seed values
('ankara','cankaya','Anitkabir','anitkabir-ankara','historical',39.9250,32.8369,'Cumhuriyet tarihinin simge mekani; anitsal alan ve muze deneyimi sunar.','morning',120,array['history','family','walkable'],980,true,'public-media/seed/ankara/anitkabir/1.jpg',array['Cumhuriyet tarihinin en onemli anit alanlarindandir.','Aslanli Yol ve mozole ziyaret akisiyla gezilir.','Muze bolumu donem anlatimi sunar.'],array['Merkezde yemek secenekleri fazladir.','Kafe molasi kolayca planlanabilir.'],array['Resmi gunlerde erken saatleri hedefle.','Acik alan icin mevsime uygun giyin.','En az 90 dakika ayir.']),
('ankara','altindag','Ankara Kalesi','ankara-kalesi','historical',39.9393,32.8622,'Sehir manzarasi, surlari ve tarihi sokaklariyla klasik Ankara duragidir.','sunset',90,array['sunset','instagrammable','walkable','history'],940,true,'public-media/seed/ankara/ankara-kalesi/1.jpg',array['Kale cevresi farkli donemlerin izlerini tasir.','Surlar manzara icin guclu noktalardir.'],array['Cevrede yerel lezzet secenekleri bulunur.','Kahve molasi icin sokaklar uygundur.'],array['Gun batimindan once surlara cik.','Rahat ayakkabi tercih et.']),
('ankara','altindag','Anadolu Medeniyetleri Muzesi','anadolu-medeniyetleri-muzesi','museum',39.9370,32.8642,'Anadolu arkeolojisini kronolojik olarak sunan kapsamli bir muze deneyimi.','morning',120,array['history','rainy_day','family'],930,false,'public-media/seed/ankara/anadolu-medeniyetleri-muzesi/1.jpg',array['Hitit eserleri uluslararasi duzeyde onemlidir.','Koleksiyon Paleolitikten modern donemlere uzanir.'],array['Muze sonrasi Hamamonu hattinda yemek secenegi vardir.'],array['Acilis saatini onceden kontrol et.','Muze icin en az 90 dk ayir.']),
('ankara','altindag','Hamamonu','hamamonu','historical',39.9338,32.8591,'Tarihi Ankara evleri, sanat dukkalari ve yuruyus atmosferi sunar.','day',75,array['walkable','instagrammable','budget'],900,true,'public-media/seed/ankara/hamamonu/1.jpg',array['Osmanli sivil mimarisinin korunmus orneklerini barindirir.'],array['Yerel tatli ve kahve noktalari boldur.','Butce dostu secenekler bulunur.'],array['Hafta sonu kalabalik olabilir.','Kale rotasiyla birlestir.']),
('ankara','altindag','Haci Bayram Veli Camii','haci-bayram-veli-camii','historical',39.9444,32.8575,'Tarihi merkezde manevi atmosferi ve meydan dokusuyla onemli bir ziyaret noktasi.','day',45,array['history','walkable','family'],860,true,'public-media/seed/ankara/haci-bayram-veli/1.jpg',array['Kulliye, Ankara tarihindeki temel odaklardan biridir.'],array['Meydan cevresinde atistirmalik ve cay secenekleri vardir.'],array['Meydan ve cevresini birlikte gez.']),
('ankara','cankaya','Atakule','atakule','viewpoint',39.8862,32.8607,'Seyir terasi ve sehir panoramasiyla gun batimi icin guclu bir noktadir.','sunset',60,array['sunset','instagrammable','family'],850,false,'public-media/seed/ankara/atakule/1.jpg',array['Ankara siluetinin taninan simgelerindendir.'],array['Cevrede kafe ve restoran yogundur.'],array['Gun batimindan 30 dk once konumlan.']),
('ankara','cankaya','Kugulu Park','kugulu-park','nature',39.9056,32.8586,'Sehir icinde yesil mola ve kisa yuruyus icin ideal bir park alanidir.','day',40,array['family','walkable','budget'],800,true,'public-media/seed/ankara/kugulu-park/1.jpg',array['Kent merkezinin bilinen yesil bulusma noktalarindandir.'],array['Tunali hattinda yemek secenegi fazladir.'],array['Kisa mola rotasi olarak planla.']),
('ankara','cankaya','Segmenler Parki','segmenler-parki','nature',39.8948,32.8648,'Yuruyus parkurlari ve yesil dokusuyla merkezde aktif dinlenme imkani sunar.','day',60,array['walkable','family','free'],790,true,'public-media/seed/ankara/segmenler/1.jpg',array['Park, modern Ankara yesil alanlarinin guclu orneklerindendir.'],array['Cevrede kafe secenekleri bulunur.'],array['Egimli alanlar icin rahat ayakkabi giy.']),
('ankara','golbasi','Eymir Golu','eymir-golu','nature',39.7884,32.8090,'Bisiklet, yuruyus ve gun batimi manzarasi icin Ankara yakininda guclu bir kacis noktasi.','sunset',120,array['sunset','walkable','instagrammable','family'],910,true,'public-media/seed/ankara/eymir-golu/1.jpg',array['Golu cevreleyen rota spor ve manzara deneyimi sunar.'],array['Uzun rota icin su ve atistirmalik planla.'],array['Hafta sonu park yogunlugunu hesaba kat.']),
('ankara','golbasi','Mogan Golu','mogan-golu','nature',39.7810,32.8106,'Kiyidan yuruyus ve sakin manzara ile aile dostu bir gunluk rota sunar.','sunset',90,array['family','budget','sunset','free'],840,true,'public-media/seed/ankara/mogan-golu/1.jpg',array['Mogan, sehir yakininda yaygin dinlenme alanidir.'],array['Kiyida uygun fiyatli mekan secenekleri vardir.'],array['Aksam serinligi icin hafif ustluk al.']),
('ankara','kizilcahamam','Soguksu Milli Parki','soguksu-milli-parki','nature',40.4728,32.6507,'Orman dokusu ve patikalariyla doga yuruyusu icin guclu bir alternatif sunar.','morning',150,array['nature','family','hidden_gem'],870,true,'public-media/seed/ankara/soguksu-milli-parki/1.jpg',array['Park biyocesitlilik acisindan degerli bir alandir.'],array['Piknik noktalarinda temel ihtiyaclar karsilanabilir.'],array['Hava durumunu cikmadan kontrol et.']),
('ankara','beypazari','Beypazari Tarihi Carsi','beypazari-tarihi-carsi','market',40.1670,31.9206,'Tarihi sokaklar, el sanatlari ve yerel lezzetlerle guclu bir kultur carsi deneyimi sunar.','day',120,array['walkable','budget','family','culture'],900,true,'public-media/seed/ankara/beypazari-carsi/1.jpg',array['Beypazari Osmanli sivil mimarisiyle taninir.'],array['Yerel yemek ve tatli secenekleri genistir.'],array['Hafta sonu otopark yogunluguna dikkat et.']),
('ankara','nallihan','Nallihan Kus Cenneti','nallihan-kus-cenneti','nature',40.1881,31.3401,'Kus gozlemi ve jeolojik renkli manzarasiyla fotografa uygun benzersiz bir doga rotasi.','sunset',120,array['instagrammable','sunset','hidden_gem','nature'],860,true,'public-media/seed/ankara/nallihan-kus-cenneti/1.jpg',array['Bolge jeolojik ve ornitolojik acidan yuksek deger tasir.'],array['Uzun rota icin kumanya planla.'],array['Cekim saati icin isik durumunu takip et.']),
('ankara','polatli','Gordion Muzesi','gordion-muzesi','museum',39.6709,31.9939,'Frig uygarligi buluntularini bir arada sunan tarih odakli temel bir duraktir.','morning',90,array['history','culture','rainy_day'],820,false,'public-media/seed/ankara/gordion-muzesi/1.jpg',array['Gordion, Frig uygarliginin merkezi kabul edilir.'],array['Bolgede mekanlar sinirli oldugu icin planli git.'],array['Yarim gun ayirmak en verimli secenektir.']),
('ankara','altindag','Ulucanlar Cezaevi Muzesi','ulucanlar-cezaevi-muzesi','museum',39.9317,32.8670,'Yakin donem toplumsal hafizayi etkileyici bir anlatimla sunan guclu bir muze deneyimi.','day',75,array['history','rainy_day','culture'],760,false,'public-media/seed/ankara/ulucanlar/1.jpg',array['Mekan, yakin donem tarihindeki kritik olaylara taniklik eder.'],array['Ziyaret sonrasi cevrede kafe secenekleri vardir.'],array['Icerigin duygusal etkisini dikkate alarak planla.']);

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
  is_free
)
select
  p.id,
  d.id,
  s.name,
  s.slug,
  s.category::public.place_category,
  st_setsrid(st_makepoint(s.lng, s.lat), 4326)::geography,
  s.short_summary,
  s.best_time::public.best_time,
  s.duration_min,
  s.tags,
  s.popularity_score,
  s.is_free
from tmp_ankara_seed s
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
  updated_at = now();

insert into public.place_details (place_id, history_bullets, eat_drink_bullets, tips_bullets)
select
  pl.id,
  s.history_bullets,
  s.eat_drink_bullets,
  s.tips_bullets
from tmp_ankara_seed s
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
from tmp_ankara_seed s
join public.provinces p on p.slug = s.province_slug
join public.places pl on pl.province_id = p.id and pl.slug = s.slug
where s.image_path is not null
on conflict do nothing;

commit;
