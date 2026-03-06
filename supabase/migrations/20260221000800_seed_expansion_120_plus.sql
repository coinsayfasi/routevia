with extra_places(
  province_slug,
  district_slug,
  name,
  slug,
  category,
  lat,
  lng,
  short_summary,
  best_time,
  duration_min,
  tags,
  popularity_score,
  price_level,
  is_free
) as (
  values
    ('izmir','konak','Izmir Archaeology Museum','izmir-archaeology-museum','museum',38.4193,27.1265,'Compact museum with key Aegean artifacts and clear historical context.','day',75,array['rainy_day','family','walkable'],84,1,false),
    ('izmir','konak','Agora Open Air Ruins','agora-open-air-ruins-izmir','historical',38.4248,27.1482,'Roman agora remains in city center with easy tram access.','morning',75,array['history','walkable','budget'],82,0,true),
    ('izmir','selcuk','Selcuk Fortress','selcuk-fortress','historical',37.9499,27.3714,'Hill fortress ruins overlooking Selcuk plain and old town.','sunset',60,array['history','photo','sunset'],80,0,true),
    ('izmir','cesme','Ayios Haralambos Church','ayios-haralambos-cesme','museum',38.3219,26.3057,'Small cultural venue inside Cesme old quarter and marina area.','day',45,array['rainy_day','walkable','budget'],70,1,false),
    ('izmir','seferihisar','Akkum Beach','akkum-beach-seferihisar','beach',38.1860,26.7890,'Family-friendly beach close to Sigacik with calm water.','day',120,array['family','budget','sunset'],81,0,true),
    ('izmir','konak','Alsancak Business Hotel','alsancak-business-hotel','lodging',38.4357,27.1432,'Central lodging option near tram, restaurants, and waterfront walk.','night',45,array['walkable','family','budget'],72,2,false),
    ('izmir','cesme','Alacati Stone House Hotel','alacati-stone-house-hotel','lodging',38.2878,26.3748,'Boutique lodging in Alacati with easy evening street access.','night',45,array['instagrammable','photo','walkable'],78,3,false),

    ('mugla','fethiye','Butterfly Valley View','butterfly-valley-view','viewpoint',36.4915,29.1142,'Cliff viewpoint over Butterfly Valley with iconic blue tones.','sunset',60,array['instagrammable','sunset','photo'],88,0,true),
    ('mugla','fethiye','Paspatur Old Town','paspatur-old-town-fethiye','market',36.6211,29.1169,'Old bazaar lanes with cafes, spices, and handmade souvenirs.','day',60,array['walkable','food','budget'],83,0,true),
    ('mugla','fethiye','Amyntas Rock Tombs','amyntas-rock-tombs','historical',36.6203,29.1129,'Rock-cut tombs above city with strong sunset panorama.','sunset',60,array['history','instagrammable','sunset'],86,1,false),
    ('mugla','fethiye','Gocek Marina Walk','gocek-marina-walk','activity',36.7536,28.9441,'Palm-lined marina stroll and yacht views in relaxed setting.','sunset',60,array['walkable','romantic','sunset'],79,0,true),
    ('mugla','fethiye','Fethiye Museum','fethiye-museum','museum',36.6219,29.1162,'City museum with Lycian artifacts and concise local history.','day',60,array['rainy_day','history','budget'],74,1,false),
    ('mugla','fethiye','Calis Sunset Hotel','calis-sunset-hotel','lodging',36.6639,29.1065,'Beachfront stay option with quick access to promenade dining.','night',45,array['sunset','family','walkable'],75,3,false),
    ('mugla','bodrum','Bodrum Harbor Hostel','bodrum-harbor-hostel','lodging',37.0341,27.4291,'Budget-friendly harbor lodging near old town night life.','night',45,array['budget','walkable','photo'],69,1,false),

    ('aydin','kusadasi','Kusadasi Castle Viewpoint','kusadasi-castle-viewpoint','viewpoint',37.8604,27.2570,'Easy lookout over harbor and Pigeon Island fort walls.','sunset',45,array['sunset','walkable','photo'],77,0,true),
    ('aydin','kusadasi','Ephesus Museum Selcuk','ephesus-museum-selcuk','museum',37.9490,27.3682,'Well-curated museum ideal before or after Ephesus visit.','day',75,array['history','rainy_day','family'],85,1,false),
    ('aydin','didim','Mavisehir Night Market','mavisehir-night-market-didim','market',37.3808,27.2514,'Evening market by waterfront with snacks and local crafts.','night',60,array['budget','food','walkable'],76,0,true),
    ('aydin','kusadasi','Kusadasi Caravan Park','kusadasi-caravan-park','lodging',37.8111,27.2482,'Simple caravan and bungalow stays close to long beach strip.','night',45,array['budget','family','nature'],68,1,false),
    ('aydin','didim','Didim Beach Pension','didim-beach-pension','lodging',37.3618,27.2627,'Affordable pension near Altinkum beach and food streets.','night',45,array['budget','walkable','family'],70,1,false),
    ('aydin','kusadasi','Oleander Coastal Walk','oleander-coastal-walk-kusadasi','nature',37.8422,27.2448,'Light seaside walk route with benches and open sea breeze.','sunset',45,array['walkable','free','sunset'],72,0,true),
    ('aydin','didim','Akbuk Bay','akbuk-bay-didim','beach',37.3954,27.4178,'Quiet bay with calmer water and family picnic spots.','day',120,array['family','budget','sunrise'],80,0,true),

    ('denizli','pamukkale','Pamukkale Village Bazaar','pamukkale-village-bazaar','market',37.9228,29.1212,'Small local bazaar near travertine entrance with quick snacks.','day',45,array['budget','walkable','food'],69,0,true),
    ('denizli','pamukkale','Denizli Old City Mosques Walk','denizli-old-city-mosques-walk','historical',37.7744,29.0867,'Short walking route through old center landmarks and tea stops.','day',60,array['walkable','budget','history'],67,0,true),
    ('denizli','pamukkale','Bagbasi Forest Cafe','bagbasi-forest-cafe','cafe',37.7788,29.0318,'Cool terrace cafe area after cable car and plateau visit.','day',45,array['cafe','family','nature'],73,2,false),
    ('denizli','pamukkale','Pamukkale Thermal Hotel','pamukkale-thermal-hotel','lodging',37.9249,29.1198,'Thermal stay option suitable for slow-pace recovery trips.','night',45,array['family','relax','budget'],71,3,false),
    ('denizli','pamukkale','Karahayit Boutique Stay','karahayit-boutique-stay','lodging',37.9457,29.2014,'Boutique lodging near red springs and local thermal routes.','night',45,array['relax','family','hidden_gem'],70,2,false),
    ('denizli','pamukkale','Colossae Panorama Spot','colossae-panorama-spot','viewpoint',37.8542,29.0774,'Open panorama stop over fields and mountain horizon.','sunset',45,array['sunset','photo','free'],68,0,true),
    ('denizli','pamukkale','Tripolis Ruins','tripolis-ruins-denizli','historical',37.9788,29.2594,'Less crowded ancient ruins with long colonnaded street remains.','morning',90,array['history','hidden_gem','walkable'],75,0,true),

    ('antalya','muratpasa','Mermerli Beach','mermerli-beach','beach',36.8838,30.7070,'Small old-town beach cove for quick swim between city walks.','day',75,array['walkable','family','sunset'],79,1,false),
    ('antalya','muratpasa','Yivli Minaret Square','yivli-minaret-square','historical',36.8862,30.7058,'Historic square connecting Kaleici streets and tram access.','day',45,array['history','walkable','budget'],82,0,true),
    ('antalya','kas','Kas Peninsula Trail','kas-peninsula-trail','nature',36.1875,29.6240,'Scenic peninsula trail with sea coves and photo stops.','sunset',90,array['photo','walkable','sunset'],85,0,true),
    ('antalya','kemer','Moonlight Beach Park','moonlight-beach-park-kemer','beach',36.6015,30.5638,'Central beach park with cafes and easy evening stroll.','day',120,array['family','walkable','budget'],84,0,true),
    ('antalya','muratpasa','Antalya Old Port Hotel','antalya-old-port-hotel','lodging',36.8843,30.7062,'Stay inside old town with fast access to harbor and museums.','night',45,array['walkable','history','photo'],76,3,false),
    ('antalya','kas','Kas Seaside Pension','kas-seaside-pension','lodging',36.1999,29.6405,'Budget pension near marina and sunset cafés in Kas center.','night',45,array['budget','walkable','sunset'],73,1,false),
    ('antalya','kemer','Adrasan Bay','adrasan-bay-antalya','beach',36.3059,30.4682,'Wide bay known for calm mornings and boat trip departures.','day',150,array['family','sunrise','nature'],87,0,true),

    ('mersin','erdemli','Kizkalesi Beach Walk','kizkalesi-beach-walk','viewpoint',36.4590,34.1432,'Flat beach walk facing sea castle with clear sunset frames.','sunset',60,array['walkable','sunset','family'],82,0,true),
    ('mersin','tarsus','Tarsus Grand Bazaar','tarsus-grand-bazaar','market',36.9186,34.8948,'Historic bazaar streets with local sweets and artisan stalls.','day',60,array['budget','food','walkable'],78,0,true),
    ('mersin','erdemli','Narlikuyu Mosaic Museum','narlikuyu-mosaic-museum','museum',36.4468,34.1508,'Small museum highlighting ancient mosaic craftsmanship.','day',45,array['history','rainy_day','family'],72,1,false),
    ('mersin','tarsus','Tarsus Culture Route','tarsus-culture-route','historical',36.9173,34.8938,'Walkable culture route linking key old city monuments.','day',75,array['history','walkable','budget'],79,0,true),
    ('mersin','erdemli','Limonlu Nature Camp','limonlu-nature-camp','lodging',36.5180,34.1912,'Simple nature camp stay near river and mountain breeze.','night',45,array['budget','family','nature'],67,1,false),
    ('mersin','tarsus','Tarsus City Hotel','tarsus-city-hotel','lodging',36.9182,34.8950,'Practical city hotel close to museum and bazaar loop.','night',45,array['walkable','budget','family'],71,2,false),
    ('mersin','erdemli','Akkale Cove','akkale-cove-mersin','beach',36.5847,34.2511,'Quieter cove option with clear water and fewer crowds.','day',120,array['hidden_gem','sunset','nature'],74,0,true)
)
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
  price_level,
  is_free
)
select
  p.id,
  d.id,
  x.name,
  x.slug,
  x.category::public.place_category,
  st_setsrid(st_makepoint(x.lng, x.lat), 4326)::geography,
  x.short_summary,
  x.best_time::public.best_time,
  x.duration_min,
  x.tags,
  x.popularity_score,
  x.price_level,
  x.is_free
from extra_places x
join public.provinces p on p.slug = x.province_slug
left join public.districts d on d.slug = x.district_slug and d.province_id = p.id
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
  price_level = excluded.price_level,
  is_free = excluded.is_free;

insert into public.place_details (place_id, history_bullets, eat_drink_bullets, tips_bullets)
select
  pl.id,
  case
    when pl.category in ('historical', 'museum') then array[
      'Tarih katmanlarini girmekten once giris panolarindan hizlica oku.',
      'Sabah saatleri daha sakin gezi icin uygundur.',
      'Rotayi ana noktadan periferiye dogru kurmak verimi artirir.'
    ]
    else array[
      'Yerel ritim mevsime gore degisir; son durumu yerinde sor.',
      'Yakindaki ara sokaklar beklenmedik iyi duraklar verebilir.'
    ]
  end,
  case
    when pl.category in ('food', 'market', 'cafe', 'lodging') then array[
      'Yogun saatlere kalmadan imza urunu dene.',
      'Nakit tasimak kucuk esnaf icin hiz saglar.',
      'Aksam saatlerinde rezervasyon avantajlidir.'
    ]
    else array[
      '10 dakika cevrede genelde iyi bir yemek noktasi bulunur.',
      'Hafta ici erken saatler daha rahattir.'
    ]
  end,
  case
    when pl.best_time = 'sunset' then array[
      'Gunes batimindan 30 dakika once konumlan.',
      'Ruzgar icin ince bir ustluk bulundur.',
      'Yuksek acili cekimler icin kenar noktalari tercih et.'
    ]
    else array[
      'Toplu tasima saatlerini onceden kontrol et.',
      'Su ve basit atistirmalik tasimak ritmi korur.',
      'Planini 60-90 dakikalik bloklarla tut.'
    ]
  end
from public.places pl
where not exists (select 1 from public.place_details pd where pd.place_id = pl.id)
on conflict (place_id) do nothing;

insert into public.place_media (place_id, storage_path, source, sort_order)
select
  pl.id,
  'public-media/seed/' || pr.slug || '/' || replace(pl.slug::text, '-', '_') || '_1.jpg',
  'seed',
  0
from public.places pl
join public.provinces pr on pr.id = pl.province_id
where not exists (
  select 1 from public.place_media pm where pm.place_id = pl.id
)
on conflict do nothing;
