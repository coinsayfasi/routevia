begin;

create temporary table tmp_curated_seed (
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

insert into tmp_curated_seed values
-- Istanbul
('istanbul','fatih','Ayasofya Camii','ayasofya-istanbul','historical',41.0086,28.9802,'Bizans ve Osmanli mirasini ayni yapida sunan dunyaca unlu tarihi merkez.','morning',120,array['history','family','instagrammable','walkable'],980,false,'public-media/seed/istanbul/ayasofya/1.jpg',array['Yapi hem kilise hem cami olarak tarihsel katman tasir.','Mimari detaylar Bizans sanatinin zirvesindendir.'],array['Cevrede kahvalti ve kahve secenekleri fazladir.'],array['Sabah erken saatlerde daha rahat gezilir.','Giyim kurallarina dikkat et.']),
('istanbul','fatih','Topkapi Sarayi','topkapi-sarayi-istanbul','museum',41.0115,28.9834,'Osmanli saray yasamini koleksiyonlarla anlatan kapsamli bir muze deneyimi.','morning',140,array['history','rainy_day','family'],950,false,'public-media/seed/istanbul/topkapi/1.jpg',array['Saray devlet yonetiminin merkeziydi.','Harem bolumu farkli bilet plani gerektirebilir.'],array['Sirkeci ve Sultanahmet hattinda yemek secenegi genis.'],array['Bilet kuyrugu icin erken git.','En az 2 saat ayir.']),
('istanbul','beyoglu','Galata Kulesi','galata-kulesi-istanbul','viewpoint',41.0256,28.9741,'Bogaz ve Tarihi Yarimada manzarasini tek karede veren klasik seyir noktasi.','sunset',60,array['sunset','instagrammable','walkable'],920,false,'public-media/seed/istanbul/galata/1.jpg',array['Orta cagin en bilinen Ceneviz yapilarindandir.'],array['Kule cevresinde ucuz-orta butce kafe secenekleri var.'],array['Gun batimindan once siraya gir.']),
('istanbul','besiktas','Ortakoy Sahili','ortakoy-sahili-istanbul','viewpoint',41.0470,29.0263,'Bogaz kiyisinda cami ve kopru siluetiyle fotograf ve aksamustu yuruyus noktasi.','sunset',50,array['sunset','family','walkable','instagrammable'],860,true,'public-media/seed/istanbul/ortakoy/1.jpg',array['Semt bogaz kulturuyle taninir.'],array['Kumpir ve sokak lezzetleri populerdir.'],array['Aksam saatlerinde yogunluk artar.']),

-- Izmir
('izmir','konak','Kordon','kordon-izmir','viewpoint',38.4383,27.1382,'Deniz kenari yuruyus, bisiklet ve gun batimi atmosferiyle Izmirin ikonik hattidir.','sunset',70,array['sunset','walkable','family','free'],930,true,'public-media/seed/izmir/kordon/1.jpg',array['Kordon kent yasamiyla butunlesmis bir sahil aksidir.'],array['Cevrede kafe ve yemek secenekleri coktur.'],array['Gun batiminda cim alani hizla dolar.']),
('izmir','selcuk','Efes Antik Kenti','efes-antik-kenti-izmir','historical',37.9390,27.3410,'Roma donemi kalintilariyla Turkiyenin en etkileyici acik hava arkeoloji alani.','morning',150,array['history','instagrammable','family'],970,false,'public-media/seed/izmir/efes/1.jpg',array['Celsus Kutuphanesi en bilinen yapilardandir.','Liman Caddesi antik kent planini gosterir.'],array['Selcuk merkezde uygun fiyatli yemek secenegi var.'],array['Yaz sicaginda sabah gezisi cok daha iyi.']),
('izmir','cesme','Alacati Carsi','alacati-carsi-izmir','market',38.2871,26.3775,'Tas evler, kafeler ve sokak dokusuyla fotograf ve yeme-icme icin populer merkez.','day',90,array['instagrammable','walkable','family'],870,false,'public-media/seed/izmir/alacati/1.jpg',array['Belde ruzgar ve tas mimari ile taninir.'],array['Kahvalti ve ucuncu nesil kahve secenegi boldur.'],array['Hafta sonu kalabaligi yuksektir.']),
('izmir','selcuk','Sirince Koyu','sirince-koyu-izmir','historical',37.9166,27.3678,'Yamac yerlesimi, tas sokaklari ve koy atmosferiyle sakin gezi icin ideal.','day',80,array['hidden_gem','walkable','family'],820,false,'public-media/seed/izmir/sirince/1.jpg',array['Koy dokusu Rum yerlesimi izleri tasir.'],array['Ev yemekleri ve yerel urun dukkanlari vardir.'],array['Arac parkini giriste planla.']),

-- Antalya
('antalya','muratpasa','Kaleici','kaleici-antalya','historical',36.8841,30.7056,'Dar sokaklar, liman ve tarihi ev dokusuyla Antalya merkezde klasik rota.','day',100,array['history','walkable','instagrammable'],920,true,'public-media/seed/antalya/kaleici/1.jpg',array['Bolge Roma, Bizans ve Osmanli katmanlarini tasir.'],array['Liman cevresinde yemek secenegi cesitlidir.'],array['Aksam saatlerinde sokaklar cok canlidir.']),
('antalya','muratpasa','Duden Selalesi','duden-selalesi-antalya','nature',36.8587,30.7929,'Sehir icinde guclu su dokusu ve manzara noktasi sunan kolay erisilebilir doga duragi.','day',70,array['family','instagrammable','free'],860,true,'public-media/seed/antalya/duden/1.jpg',array['Selale denize dokulen koluyla unlenmistir.'],array['Park cevresinde atistirmalik noktalar var.'],array['Islak zemine uygun ayakkabi kullan.']),
('antalya','konyaalti','Konyaalti Plaji','konyaalti-plaji-antalya','beach',36.8714,30.6361,'Uzun sahil bandi ve dag manzarasiyla yuzme ve gun batimi icin guclu secenek.','sunset',120,array['sunset','family','free','walkable'],900,true,'public-media/seed/antalya/konyaalti/1.jpg',array['Plaj kent merkezine yakinligi ile one cikar.'],array['Sahil boyunca kafe ve restoran bulunur.'],array['Yaz sezonunda erken saatler daha rahattir.']),
('antalya','kas','Kas Marina Seyir','kas-marina-seyir-antalya','viewpoint',36.1997,29.6414,'Kucuk liman silueti ve gun batimi renkleriyle kas rotasinin favori manzara noktasi.','sunset',45,array['sunset','instagrammable','walkable'],840,true,'public-media/seed/antalya/kas-marina/1.jpg',array['Kas, likya kiyisinin en karakteristik liman yerlesimidir.'],array['Marina cevresinde deniz urunu secenegi gucludur.'],array['Mavi saat cekimleri icin 20 dk erken git.']),

-- Mugla
('mugla','fethiye','Oludeniz','oludeniz-mugla','beach',36.5483,29.1236,'Turkuaz koy dokusu, plaj keyfi ve yamaç paraşutu manzarasiyla unlu tatil noktasi.','sunset',140,array['sunset','instagrammable','family'],960,false,'public-media/seed/mugla/oludeniz/1.jpg',array['Oludeniz lagunu koruma alani statusu tasir.'],array['Sahil cevresinde her butceye uygun mekan bulunur.'],array['Yuksek sezonda sabah erken saat avantajlidir.']),
('mugla','fethiye','Saklikent Kanyonu','saklikent-kanyonu-mugla','nature',36.4702,29.4027,'Serin su gecisleri ve kanyon duvarlariyla yaz sicaginda benzersiz doga deneyimi sunar.','day',110,array['nature','family','hidden_gem'],900,false,'public-media/seed/mugla/saklikent/1.jpg',array['Kanyon tektonik olusumuyla bilinir.'],array['Giriste gozleme ve atistirmalik secenekleri var.'],array['Su gecisi icin uygun ayakkabi kullan.']),
('mugla','bodrum','Bodrum Kalesi','bodrum-kalesi-mugla','historical',37.0344,27.4305,'Deniz kiyisinda kale silueti ve muze deneyimiyle Bodrum merkezinin ana duragi.','day',100,array['history','instagrammable','family'],910,false,'public-media/seed/mugla/bodrum-kalesi/1.jpg',array['Kale Saint Jean sovalye doneminden kalmadir.'],array['Marina cevresinde kaliteli yeme-icme secenekleri vardir.'],array['Yogun sezonda bilet saatini planla.']),
('mugla','marmaris','Icmeler Sahili','icmeler-sahili-mugla','beach',36.8005,28.2319,'Sakin deniz ve uzun yuruyus hattiyla aile ve rahat tempo tatil icin iyi secenek.','day',100,array['family','budget','walkable'],780,true,'public-media/seed/mugla/icmeler/1.jpg',array['Koy yapisi dalga etkisini azaltir.'],array['Sahil boyunca uygun fiyatli mekanlar bulunur.'],array['Oglen sicaginda golgelik planla.']),

-- Aydin
('aydin','didim','Apollon Tapinagi','apollon-tapinagi-aydin','historical',37.3847,27.2566,'Dev sutunlariyla antik didim tarihinin en guclu simgelerinden biridir.','morning',80,array['history','instagrammable'],900,false,'public-media/seed/aydin/apollon/1.jpg',array['Tapinak antik cag kehanet merkezi olarak bilinir.'],array['Didim merkezde yemek secenegi boldur.'],array['Yaz sicaginda sabah ziyaretini tercih et.']),
('aydin','kusadasi','Guvercinada','guvercinada-aydin','viewpoint',37.8596,27.2578,'Kale adasi ve marina manzarasiyla kusadasinda kisa ama etkili bir seyir noktasi.','sunset',45,array['sunset','walkable','instagrammable'],820,true,'public-media/seed/aydin/guvercinada/1.jpg',array['Ada kusadasi liman tarihinin parcasidir.'],array['Marina cevresinde kahve ve yemek secenegi bulunur.'],array['Aksamustu saatleri manzara icin idealdir.']),
('aydin','soke','Dilek Yarimadasi Milli Parki','dilek-yarimadasi-milli-parki-aydin','nature',37.6946,27.1739,'Koylar, yuruyus ve temiz deniz kombinasyonu ile gunluk doga-plaj rotasi sunar.','day',140,array['nature','family','free'],910,true,'public-media/seed/aydin/dilek/1.jpg',array['Milli park biyocesitlilik acisindan zengindir.'],array['Giris alaninda temel ihtiyac noktasi bulunur.'],array['Uzun rota icin su ve yiyecek al.']),
('aydin','soke','Milet Antik Kenti','milet-antik-kenti-aydin','historical',37.5299,27.2768,'Tiyatro ve hamam kalintilariyla antik kent okumasi icin degerli bir acik hava alani.','day',90,array['history','hidden_gem'],760,false,'public-media/seed/aydin/milet/1.jpg',array['Milet antik donemde onemli bir liman kentiydi.'],array['Bolgede kisa mola icin yerel mekanlar vardir.'],array['Acilis saatini onceden kontrol et.']),

-- Denizli
('denizli','pamukkale','Pamukkale Travertenleri','pamukkale-travertenleri-denizli','nature',37.9250,29.1236,'Beyaz traverten teraslariyla Turkiyenin en ayirt edici doga mirasi deneyimi sunar.','sunset',120,array['instagrammable','family','history'],980,false,'public-media/seed/denizli/pamukkale/1.jpg',array['Travertenler UNESCO miras alaninin parcasidir.'],array['Pamukkale girisinde kafe ve restoran secenegi bulunur.'],array['Ciplak ayakla gezi zorunluluguna hazir ol.']),
('denizli','pamukkale','Hierapolis Antik Kenti','hierapolis-antik-kenti-denizli','historical',37.9246,29.1244,'Pamukkale ile birlikte antik tiyatro ve nekropol deneyimini birlestiren tarih rotasi.','day',120,array['history','instagrammable'],920,false,'public-media/seed/denizli/hierapolis/1.jpg',array['Hierapolis Roma donemi saglik kenti olarak bilinir.'],array['Bolgede tum gun geziye uygun yemek secenekleri vardir.'],array['Traverten ve antik kent gezisini beraber planla.']),
('denizli','pamukkale','Laodikeia','laodikeia-denizli','historical',37.8351,29.1064,'Yenilenmis kazilar ve anitsal yapilarla denizli cevresinde guclu antik kent secenegi.','day',100,array['history','hidden_gem'],820,false,'public-media/seed/denizli/laodikeia/1.jpg',array['Kent Roma doneminde ticaret aginin onemli dugumuydu.'],array['Merkeze donuste yemek secenegi coktur.'],array['Golgesiz alanlar icin sapka bulundur.']),
('denizli','merkezefendi','Bagbasi Yaylasi','bagbasi-yaylasi-denizli','nature',37.7414,29.0913,'Teleferik ve yayla havasiyla yaz-kis farkli karakter sunan yuksek rakimli gezi noktasi.','sunset',80,array['sunset','family','nature'],760,false,'public-media/seed/denizli/bagbasi/1.jpg',array['Yayla hatti sehirden yukariya iklim gecisi sunar.'],array['Yayla cevresinde sicak icecek secenekleri bulunur.'],array['Ruzgarli havaya gore kiyafet planla.']),

-- Mersin
('mersin','erdemli','Kizkalesi','kizkalesi-mersin','historical',36.4619,34.1455,'Deniz ortasindaki kale siluetiyle mersin kiyisinda fotograf ve tarih icin ikonik durak.','sunset',70,array['sunset','instagrammable','family'],900,true,'public-media/seed/mersin/kizkalesi/1.jpg',array['Kale hem kara hem deniz savunma yapisi olarak kullanilmistir.'],array['Sahil boyunca balikk ve gozleme secenekleri vardir.'],array['Tekne turu saatlerini onceden sor.']),
('mersin','erdemli','Cennet Cehennem Obruklari','cennet-cehennem-mersin','nature',36.4516,34.1047,'Dogal obruk olusumlari ve tarihi izlerle mersin gezi planina farkli bir deneyim katar.','day',90,array['nature','family','instagrammable'],860,false,'public-media/seed/mersin/cennet-cehennem/1.jpg',array['Karstik olusumlar bolgenin jeolojik mirasidir.'],array['Ziyaret alani yakininda temel yemek noktasi bulunur.'],array['Merdivenli bolumler icin rahat ayakkabi sec.']),
('mersin','tarsus','Tarsus Selalesi','tarsus-selalesi-mersin','nature',36.9180,34.8950,'Kent icinde serin mola ve kisa yuruyus icin kolay erisilebilir doga noktasi.','day',45,array['family','walkable','budget'],780,true,'public-media/seed/mersin/tarsus-selalesi/1.jpg',array['Selale tarsus kent yasaminin bilinen gezi duragidir.'],array['Cevrede kebap ve tatli secenekleri bulunur.'],array['Hafta sonu kalabaligini hesaba kat.']),
('mersin','anamur','Anemurium Antik Kenti','anemurium-antik-kenti-mersin','historical',36.0744,32.8337,'Deniz kenarinda tiyatro, hamam ve surlariyla guclu acik hava arkeoloji deneyimi sunar.','day',110,array['history','hidden_gem','instagrammable'],840,false,'public-media/seed/mersin/anemurium/1.jpg',array['Anemurium kiyida konumlu nadir antik kentlerden biridir.'],array['Bolgede gezi oncesi su ve atistirmalik almak faydalidir.'],array['Yaz sicaginda oglen saatlerinden kacinin.']),

-- Bursa
('bursa','osmangazi','Uludag Milli Parki','uludag-milli-parki-bursa','nature',40.0690,29.2215,'Dort mevsim doga, kis sporu ve seyir noktalariyla bursa cevresinin ana kacis rotasi.','day',150,array['nature','family','instagrammable'],920,false,'public-media/seed/bursa/uludag/1.jpg',array['Uludag dag ekosistemiyle ulusal park statusundedir.'],array['Dag yolunda farkli butcelerde mekan secenekleri bulunur.'],array['Hava degisimine gore katmanli giyin.']),
('bursa','osmangazi','Koza Han','koza-han-bursa','market',40.1820,29.0608,'Ipek yolu mirasini tasiyan han avlusu, cay molasi ve alisveris icin klasik merkez.','day',60,array['history','walkable','budget'],820,true,'public-media/seed/bursa/koza-han/1.jpg',array['Han osmanli ticaret yapilarinin onemli ornegidir.'],array['Avluda cay-kahve ve tatli secenekleri var.'],array['Ulu Cami ile beraber gezmek pratiktir.']),
('bursa','nilufer','Golyazi','golyazi-bursa','viewpoint',40.2078,28.7177,'Gol kiyisinda tarihi doku ve gun batimi manzarasiyla sakin bir fotograf rotasi sunar.','sunset',70,array['sunset','hidden_gem','instagrammable'],780,true,'public-media/seed/bursa/golyazi/1.jpg',array['Yerlesim antik apollonia kalintilariyla baglantilidir.'],array['Koyde balik ve kahvalti secenekleri bulunur.'],array['Gun batimi saatinde tripod avantaj saglar.']),
('bursa','osmangazi','Cumalikizik','cumalikizik-bursa','historical',40.1836,29.1731,'Korunmus osmanli koy dokusu ve kahvalti kulturuyla populer bir tarih-kultur duragi.','morning',90,array['history','family','instagrammable'],860,false,'public-media/seed/bursa/cumalikizik/1.jpg',array['Koy UNESCO alanlariyla iliskili kultur koridorundadir.'],array['Koy kahvaltisi en populer deneyimdir.'],array['Hafta sonu erken saatler en rahat zamandir.']),

-- Eskisehir
('eskisehir','odunpazari','Odunpazari Evleri','odunpazari-evleri-eskisehir','historical',39.7663,30.5206,'Renkli ev dokusu, muze rotalari ve yuruyus sokaklariyla sehrin kultur cekirdegi.','day',90,array['walkable','instagrammable','history'],900,true,'public-media/seed/eskisehir/odunpazari/1.jpg',array['Bolge geleneksel osmanli konut dokusunu korur.'],array['Muze cevresinde kahve ve yemek secenegi boldur.'],array['Porsuk hattiyla ayni gun planlanabilir.']),
('eskisehir','tepebasi','Sazova Bilim Kultur Parki','sazova-parki-eskisehir','activity',39.7649,30.4545,'Aile odakli etkinlik alanlari, acik hava temalari ve uzun gezinti rotalari sunar.','day',120,array['family','walkable','budget'],850,true,'public-media/seed/eskisehir/sazova/1.jpg',array['Park kentsel rekreasyon alaninin basarili ornegidir.'],array['Park icinde kafe ve atistirmalik secenekleri bulunur.'],array['Cocuklu gezi icin en az 2 saat ayir.']),
('eskisehir','tepebasi','Porsuk Cayi','porsuk-cayi-eskisehir','viewpoint',39.7769,30.5200,'Cay kenari yuruyus ve sehir merkezi atmosferiyle kisa mola ve fotograf icin ideal.','sunset',45,array['sunset','walkable','free'],780,true,'public-media/seed/eskisehir/porsuk/1.jpg',array['Porsuk hatti modern kent yasaminin ana aksidir.'],array['Cay kenarinda kafe secenekleri yogundur.'],array['Aksamustu saatleri daha keyiflidir.']),
('eskisehir','odunpazari','Yilmaz Buyukersen Balmumu Muzesi','balmumu-muzesi-eskisehir','museum',39.7642,30.5227,'Populer figur koleksiyonuyla her yas grubuna hitap eden eglenceli bir muze deneyimi.','day',60,array['family','rainy_day','instagrammable'],760,false,'public-media/seed/eskisehir/balmumu/1.jpg',array['Muze yerel kultur turizminin bilinen duraklarindandir.'],array['Muze sonrasi odunpazari cafeleri pratik secenek sunar.'],array['Yogun saatlerde bilet sirasi olabilir.']),

-- Kapadokya (Nevsehir hatti)
('nevsehir','merkez','Goreme Acik Hava Muzesi','goreme-acik-hava-muzesi-nevsehir','museum',38.6431,34.8462,'Kaya kiliseleri ve freskleriyle kapadokya tarihini dogrudan deneyimleten ana ziyaret noktasi.','morning',110,array['history','instagrammable','family'],960,false,'public-media/seed/nevsehir/goreme-acik-hava/1.jpg',array['Alan erken hristiyanlik donemine ait kaya kiliseleri barindirir.'],array['Goreme merkezde her butceye uygun mekan bulunur.'],array['Sabah saatleri kalabalik oncesi daha verimlidir.']),
('nevsehir','urgup','Asiklar Vadisi Seyir','asiklar-vadisi-seyir-nevsehir','viewpoint',38.6672,34.8396,'Peribacalari manzarasi ve gun batimi renkleriyle kapadokya fotograf rotasinin favori noktasi.','sunset',60,array['sunset','instagrammable','photo_spot'],910,true,'public-media/seed/nevsehir/asiklar-vadisi/1.jpg',array['Vadi jeolojik olusumlariyla bolgenin simgesidir.'],array['Seyir noktasi cevresinde kafe secenekleri var.'],array['Gun batimindan once konumlan.']),
('nevsehir','derinkuyu','Derinkuyu Yeralti Sehri','derinkuyu-yeralti-sehri-nevsehir','historical',38.3732,34.7342,'Katmanli yeralti yasam alaniyla kapadokya tarihinin en etkileyici savunma yapilarindan biri.','day',90,array['history','family','rainy_day'],900,false,'public-media/seed/nevsehir/derinkuyu/1.jpg',array['Yeralti sehirleri bolgesel savunma ihtiyaciyla gelismistir.'],array['Giriste temel atistirmalik secenekleri bulunur.'],array['Dar tuller icin rahat kiyafet sec.']),
('nevsehir','avanos','Avanos Kizilirmak Hatti','avanos-kizilirmak-nevsehir','market',38.7142,34.8445,'Seramik atolyeleri, nehir kiyisi yuruyusu ve yerel carsi ile kultur odakli gezi sunar.','day',80,array['walkable','culture','budget'],780,true,'public-media/seed/nevsehir/avanos/1.jpg',array['Avanos cermik gelenegi ile bilinir.'],array['Nehir cevresinde yeme-icme secenekleri fazladir.'],array['Atolye deneyimi icin rezervasyon dusun.']);

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
from tmp_curated_seed s
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
from tmp_curated_seed s
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
from tmp_curated_seed s
join public.provinces p on p.slug = s.province_slug
join public.places pl on pl.province_id = p.id and pl.slug = s.slug
where s.image_path is not null
on conflict do nothing;

commit;
