insert into storage.buckets (id, name, public)
values ('public-media', 'public-media', true)
on conflict (id) do nothing;

drop policy if exists "Public read public-media" on storage.objects;
create policy "Public read public-media"
on storage.objects
for select
using (bucket_id = 'public-media');

drop policy if exists "Admin write public-media" on storage.objects;
create policy "Admin write public-media"
on storage.objects
for all
using (bucket_id = 'public-media' and public.is_admin(auth.uid()))
with check (bucket_id = 'public-media' and public.is_admin(auth.uid()));

with provinces_seed(name, plate_no, slug, lat, lng) as (
  values
    ('Izmir', 35, 'izmir', 38.4237, 27.1428),
    ('Mugla', 48, 'mugla', 37.2153, 28.3636),
    ('Aydin', 9, 'aydin', 37.8450, 27.8396),
    ('Denizli', 20, 'denizli', 37.7765, 29.0864),
    ('Antalya', 7, 'antalya', 36.8841, 30.7056),
    ('Mersin', 33, 'mersin', 36.8121, 34.6415)
)
insert into public.provinces (name, plate_no, slug, center_geog)
select name, plate_no, slug, st_setsrid(st_makepoint(lng, lat), 4326)::geography
from provinces_seed
on conflict (slug) do update set
  name = excluded.name,
  plate_no = excluded.plate_no,
  center_geog = excluded.center_geog;

with district_seed(province_slug, name, slug, lat, lng) as (
  values
    ('izmir', 'Konak', 'konak', 38.4189, 27.1287),
    ('izmir', 'Selcuk', 'selcuk', 37.9507, 27.3684),
    ('izmir', 'Cesme', 'cesme', 38.3234, 26.3056),
    ('izmir', 'Seferihisar', 'seferihisar', 38.1950, 26.8389),
    ('mugla', 'Bodrum', 'bodrum', 37.0344, 27.4305),
    ('mugla', 'Fethiye', 'fethiye', 36.6219, 29.1164),
    ('mugla', 'Ula', 'ula', 37.1048, 28.4165),
    ('mugla', 'Ortaca', 'ortaca', 36.8391, 28.7643),
    ('aydin', 'Kusadasi', 'kusadasi', 37.8574, 27.2610),
    ('aydin', 'Didim', 'didim', 37.3723, 27.2713),
    ('denizli', 'Pamukkale', 'pamukkale', 37.9204, 29.1219),
    ('antalya', 'Muratpasa', 'muratpasa', 36.8917, 30.7033),
    ('antalya', 'Kas', 'kas', 36.2016, 29.6377),
    ('antalya', 'Kemer', 'kemer', 36.6028, 30.5598),
    ('mersin', 'Tarsus', 'tarsus', 36.9177, 34.8928),
    ('mersin', 'Erdemli', 'erdemli', 36.6048, 34.3082)
)
insert into public.districts (province_id, name, slug, center_geog)
select p.id, d.name, d.slug, st_setsrid(st_makepoint(d.lng, d.lat), 4326)::geography
from district_seed d
join public.provinces p on p.slug = d.province_slug
on conflict (province_id, slug) do update set
  name = excluded.name,
  center_geog = excluded.center_geog;

with place_seed(
  province_slug, district_slug, name, slug, category, lat, lng, short_summary, best_time, duration_min, tags, popularity_score
) as (
  values
    ('izmir','konak','Kordon Promenade','kordon-promenade','viewpoint',38.4383,27.1382,'Seaside walk with sunset colors, street music, and easy tram access.','sunset',60,array['sunset','walkable','family'],95),
    ('izmir','konak','Konak Clock Tower','konak-clock-tower','historical',38.4187,27.1286,'Iconic square landmark in the city core with ferry and bazaar connections.','day',30,array['walkable','budget','instagrammable'],90),
    ('izmir','konak','Kemeralti Bazaar','kemeralti-bazaar','market',38.4199,27.1354,'Historic covered market full of local food, crafts, and tea courtyards.','day',90,array['food','budget','rainy_day'],92),
    ('izmir','konak','Historical Elevator','historical-elevator-izmir','historical',38.4072,27.1166,'Old elevator linking steep streets and a terrace with gulf panorama.','sunset',45,array['sunset','instagrammable','walkable'],88),
    ('izmir','selcuk','Ephesus Ancient City','ephesus-ancient-city','historical',37.9390,27.3410,'World-famous ruins with grand avenues, theater, and layered Roman history.','morning',150,array['walkable','instagrammable','family'],99),
    ('izmir','selcuk','Sirince Village','sirince-village','activity',37.9948,27.4517,'Hillside village with stone houses, fruit wines, and artisan shops.','day',90,array['hidden_gem','romantic','walkable'],87),
    ('izmir','cesme','Alacati Streets','alacati-streets','market',38.2870,26.3775,'Boutique lanes, windmills, and cafe corners ideal for photo walks.','day',90,array['instagrammable','walkable','cafe'],91),
    ('izmir','seferihisar','Sigacik Harbor','sigacik-harbor','food',38.1930,26.7867,'Calm harbor with fish restaurants and a slow town weekend market.','sunset',75,array['food','family','sunset'],86),
    ('izmir','konak','Alsancak Sevgi Yolu','alsancak-sevgi-yolu','cafe',38.4338,27.1458,'Leafy pedestrian strip lined with bookstalls, coffee stops, and locals.','day',45,array['walkable','budget','cafe'],78),
    ('izmir','konak','Kulturpark','kulturpark-izmir','nature',38.4237,27.1390,'Central green park for easy cycling loops and relaxed shade breaks.','morning',60,array['family','walkable','budget'],80),
    ('izmir','selcuk','House of Virgin Mary','house-of-virgin-mary','historical',37.9134,27.3328,'Sacred hilltop chapel and forest approach near ancient Ephesus.','morning',60,array['quiet','walkable','family'],82),
    ('izmir','cesme','Ilica Beach','ilica-beach','beach',38.3209,26.3789,'Shallow thermal sea with long sandy shoreline and easy family access.','day',120,array['family','sunset','budget'],89),
    ('izmir','seferihisar','Teos Ancient City','teos-ancient-city','historical',38.1777,26.7853,'Less crowded Ionian ruins with pine paths and coastal atmosphere.','morning',90,array['hidden_gem','walkable','instagrammable'],76),
    ('izmir','konak','Arkas Art Center','arkas-art-center','museum',38.4314,27.1402,'Compact art museum with rotating exhibits in a restored mansion.','day',60,array['rainy_day','walkable','photo'],74),

    ('mugla','fethiye','Oludeniz Lagoon','oludeniz-lagoon','beach',36.5472,29.1275,'Turquoise lagoon and beach strip popular for swimming and paragliding views.','day',150,array['instagrammable','family','sunset'],98),
    ('mugla','fethiye','Saklikent Canyon','saklikent-canyon','nature',36.4722,29.3965,'Cool river canyon trail great for summer escape and short hikes.','day',120,array['family','budget','walkable'],91),
    ('mugla','bodrum','Bodrum Castle','bodrum-castle','museum',37.0324,27.4297,'Medieval fortress and underwater archaeology museum above the marina.','morning',120,array['history','walkable','photo'],94),
    ('mugla','ula','Akyaka Riverside','akyaka-riverside','nature',37.0522,28.3242,'Slow-paced riverside boardwalk with boat tours and pine-covered hills.','sunset',90,array['relax','family','sunset'],87),
    ('mugla','ortaca','Dalyan Canals','dalyan-canals','activity',36.8330,28.6451,'Reed canals, rock tomb views, and boat rides to Iztuzu beach.','day',120,array['family','instagrammable','nature'],90),
    ('mugla','fethiye','Kabak Bay','kabak-bay','nature',36.4837,29.1334,'Remote bay reached by scenic road and short downhill walk.','sunset',120,array['hidden_gem','sunset','photo'],84),
    ('mugla','bodrum','Gumusluk Coast','gumusluk-coast','food',37.0472,27.2824,'Seafront fish tables and calm sunset horizon over old harbor stones.','sunset',90,array['food','romantic','sunset'],85),
    ('mugla','bodrum','Yalikavak Marina Walk','yalikavak-marina-walk','activity',37.1091,27.2899,'Stylish marina promenade with cafes and clear sea outlooks.','night',75,array['cafe','photo','walkable'],80),
    ('mugla','fethiye','Calis Beach','calis-beach','beach',36.6624,29.1121,'Long sunset beach with bike lane and affordable local eateries.','sunset',90,array['budget','sunset','family'],88),
    ('mugla','fethiye','Kayakoy Ghost Village','kayakoy-ghost-village','historical',36.5753,29.0891,'Stone settlement remains among hills with strong photo potential.','day',90,array['history','instagrammable','walkable'],83),
    ('mugla','ortaca','Iztuzu Beach','iztuzu-beach','beach',36.7658,28.6281,'Protected sandy strip known for turtles and calm shallow water.','day',120,array['family','nature','sunrise'],89),
    ('mugla','ula','Azmak River Boats','azmak-river-boats','activity',37.0501,28.3230,'Glassy river boats glide through reeds and fish-rich clear waters.','day',60,array['family','hidden_gem','photo'],79),
    ('mugla','bodrum','Bodrum Marina','bodrum-marina','viewpoint',37.0349,27.4306,'Palm-lined marina perfect for evening walks and harbor lights.','sunset',60,array['walkable','romantic','sunset'],82),
    ('mugla','fethiye','Babadaf Viewpoint','babadag-viewpoint','viewpoint',36.5338,29.1802,'High mountain platform with panoramic coast and paragliders overhead.','sunset',75,array['instagrammable','sunset','photo'],86),

    ('aydin','didim','Temple of Apollo Didim','temple-of-apollo-didim','historical',37.3890,27.2569,'Monumental Ionian temple with giant columns and strong ancient aura.','morning',90,array['history','walkable','budget'],92),
    ('aydin','kusadasi','Dilek Peninsula Park','dilek-peninsula-park','nature',37.6654,27.1972,'National park coves, forest roads, and clear water viewpoints.','day',180,array['nature','family','sunset'],95),
    ('aydin','didim','Miletus Ruins','miletus-ruins','historical',37.5304,27.2807,'Ancient theater and city remains in broad Meander plain landscapes.','morning',90,array['history','walkable','hidden_gem'],84),
    ('aydin','kusadasi','Ladies Beach','ladies-beach-kusadasi','beach',37.8414,27.2423,'Urban beach with promenade cafes and easy sunset access.','sunset',90,array['family','budget','sunset'],83),
    ('aydin','kusadasi','Guvencinada Castle','guvencinada-castle','historical',37.8600,27.2577,'Small island fort connected by causeway near marina entrance.','day',45,array['walkable','photo','history'],78),
    ('aydin','kusadasi','Kusadasi Bazaar','kusadasi-bazaar','market',37.8595,27.2608,'Compact bazaar lanes for spices, textiles, and local snacks.','day',60,array['budget','walkable','food'],79),
    ('aydin','didim','Altinkum Beach','altinkum-beach','beach',37.3580,27.2658,'Popular family beach with shallow water and evening promenade.','day',120,array['family','budget','sunset'],85),
    ('aydin','kusadasi','Pigeon Island View','pigeon-island-view','viewpoint',37.8589,27.2584,'Harbor lookout with sea breeze and postcard coastline frames.','sunset',45,array['photo','sunset','walkable'],80),
    ('aydin','kusadasi','Oleatrium Olive Museum','oleatrium-olive-museum','museum',37.7580,27.2680,'Specialized olive culture museum with tasting and compact displays.','day',60,array['rainy_day','family','food'],73),
    ('aydin','didim','Didyma Ancient Way','didyma-ancient-way','historical',37.3870,27.2628,'Ancient processional route fragments around temple district streets.','day',45,array['history','walkable','budget'],71),
    ('aydin','kusadasi','Long Beach Kusadasi','long-beach-kusadasi','beach',37.7953,27.2473,'Wide shore and bike-friendly boulevard for relaxed family time.','day',120,array['family','walkable','budget'],77),
    ('aydin','didim','Akkoy Coast Trail','akkoy-coast-trail','nature',37.4368,27.2049,'Windy coast path with uncrowded coves and clear Aegean views.','sunset',90,array['hidden_gem','photo','sunset'],75),

    ('denizli','pamukkale','Pamukkale Travertines','pamukkale-travertines','nature',37.9137,29.1187,'White terraces and thermal pools forming one of Turkiye iconic scenes.','sunset',120,array['instagrammable','family','sunset'],99),
    ('denizli','pamukkale','Hierapolis Theater','hierapolis-theater','historical',37.9257,29.1228,'Grand Roman theater and necropolis paths above travertine basins.','morning',90,array['history','walkable','photo'],94),
    ('denizli','pamukkale','Laodikeia Ancient City','laodikeia-ancient-city','historical',37.8351,29.1061,'Sprawling ruins, colonnaded streets, and active restoration zones.','morning',120,array['history','walkable','hidden_gem'],88),
    ('denizli','pamukkale','Karahayit Red Springs','karahayit-red-springs','nature',37.9463,29.2019,'Mineral-rich red thermal waters with easy village access.','day',60,array['family','budget','hidden_gem'],79),
    ('denizli','pamukkale','Denizli Cable Car','denizli-cable-car','activity',37.7698,29.0468,'Quick ride to hilltop viewpoints over city and plains.','sunset',60,array['photo','sunset','family'],82),
    ('denizli','pamukkale','Bagbasi Plateau','bagbasi-plateau','nature',37.7792,29.0330,'Cool plateau picnic areas and walking paths above Denizli center.','day',90,array['family','nature','budget'],78),
    ('denizli','pamukkale','Pamukkale Antique Pool','pamukkale-antique-pool','activity',37.9242,29.1217,'Warm pool swim among ancient stone fragments and thermal water.','day',75,array['family','instagrammable','activity'],86),
    ('denizli','pamukkale','Servergazi Tomb','servergazi-tomb','historical',37.7831,29.0938,'Seljuk era memorial site with city views and calm grounds.','morning',45,array['history','walkable','budget'],70),
    ('denizli','pamukkale','Ornaz Valley Walk','ornaz-valley-walk','nature',37.7701,29.1105,'Urban valley track good for short hikes and local tea breaks.','day',60,array['walkable','budget','family'],72),
    ('denizli','pamukkale','Kaklik Cave','kaklik-cave','nature',37.6951,29.3824,'Humidity-rich cave nicknamed underground Pamukkale for calcite forms.','day',60,array['rainy_day','hidden_gem','family'],74),
    ('denizli','pamukkale','Ataturk Ethnography House','ataturk-ethnography-house-denizli','museum',37.7760,29.0869,'Small museum with period interiors and local craft context.','day',45,array['rainy_day','history','budget'],69),
    ('denizli','pamukkale','Incilipinar Park','incilipinar-park','nature',37.7618,29.0891,'City park with ponds, cafes, and evening walking loops.','sunset',60,array['family','walkable','cafe'],71),

    ('antalya','muratpasa','Kaleici Old Town','kaleici-old-town','historical',36.8840,30.7053,'Ottoman lanes, harbor viewpoints, and restored mansions in city center.','day',120,array['walkable','photo','history'],97),
    ('antalya','muratpasa','Duden Waterfalls','duden-waterfalls','nature',36.8587,30.7929,'Urban waterfalls dropping to sea cliffs with scenic park paths.','sunset',75,array['family','instagrammable','sunset'],93),
    ('antalya','muratpasa','Konyaalti Beach','konyaalti-beach','beach',36.8714,30.6361,'Long pebble beach with mountain backdrop and bike promenade.','day',150,array['family','budget','sunset'],95),
    ('antalya','kemer','Olympos Ruins','olympos-ruins','historical',36.3961,30.4737,'Forest-hidden Lycian ruins leading to a natural beach cove.','day',120,array['history','nature','hidden_gem'],89),
    ('antalya','kemer','Phaselis Ancient City','phaselis-ancient-city','historical',36.5258,30.5530,'Ancient harbor city where pine forest meets turquoise bays.','morning',120,array['history','family','instagrammable'],92),
    ('antalya','kas','Kas Marina View','kas-marina-view','viewpoint',36.1997,29.6414,'Compact marina and hillside cafes with dramatic sunset colors.','sunset',60,array['romantic','sunset','photo'],90),
    ('antalya','muratpasa','Hadrians Gate','hadrians-gate-antalya','historical',36.8852,30.7084,'Roman triumphal gate marking the old city entrance.','day',30,array['history','walkable','budget'],84),
    ('antalya','muratpasa','Karaalioglu Park','karaalioglu-park','nature',36.8786,30.7044,'Sea cliff park with palm-lined paths and broad gulf panorama.','sunset',60,array['walkable','family','sunset'],83),
    ('antalya','kas','Kaputas Beach','kaputas-beach','beach',36.2275,29.4448,'Small canyon beach with vivid blue water and steep access stairs.','day',120,array['instagrammable','photo','family'],91),
    ('antalya','kas','Patara Ancient City','patara-ancient-city','historical',36.2672,29.3185,'Wide archaeological area next to one of Turkiye longest beaches.','morning',120,array['history','walkable','sunset'],88),
    ('antalya','muratpasa','Antalya Museum','antalya-museum','museum',36.8869,30.6891,'Major regional museum with rich Lycian, Roman, and ethnography halls.','day',120,array['rainy_day','history','family'],90),
    ('antalya','kemer','Cirali Beach','cirali-beach','beach',36.4094,30.4759,'Quiet beach and village vibe with easy nature access.','sunset',120,array['family','hidden_gem','sunset'],86),
    ('antalya','kemer','Tahtali Cable Car','tahtali-cable-car','activity',36.5428,30.4379,'Mountain cable car to high-altitude viewpoints over Mediterranean coast.','sunset',90,array['photo','family','sunset'],87),
    ('antalya','kas','Kas Amphitheater','kas-amphitheater','historical',36.2025,29.6374,'Small ancient theater facing sea and sunset ridge lines.','sunset',45,array['romantic','photo','sunset'],82),

    ('mersin','erdemli','Kizkalesi','kizkalesi','historical',36.4600,34.1443,'Sea castle offshore with beach access and boat rides.','sunset',90,array['family','instagrammable','sunset'],93),
    ('mersin','erdemli','Cennet Cehennem Sinkholes','cennet-cehennem-sinkholes','nature',36.4525,34.1088,'Karst sinkholes with stairs, cave chapel, and dramatic geology.','day',90,array['nature','family','walkable'],90),
    ('mersin','tarsus','Tarsus Waterfall','tarsus-waterfall','nature',36.9240,34.9099,'City-edge waterfall park ideal for short cool breaks.','day',60,array['family','budget','walkable'],84),
    ('mersin','tarsus','St Paul Well','st-paul-well','historical',36.9170,34.8956,'Archaeological site in old Tarsus linked to early Christian history.','day',45,array['history','walkable','budget'],78),
    ('mersin','erdemli','Narlikuyu Coast','narlikuyu-coast','food',36.4472,34.1534,'Small fishing bay known for seafood and sea-facing terraces.','sunset',75,array['food','family','sunset'],81),
    ('mersin','tarsus','Cleopatra Gate','cleopatra-gate-tarsus','historical',36.9179,34.8913,'Roman era city gate remnant near old trade routes.','day',30,array['history','walkable','budget'],72),
    ('mersin','erdemli','Adamkayalar Reliefs','adamkayalar-reliefs','historical',36.4774,34.0328,'Rock relief figures on canyon walls reached by short trekking path.','morning',90,array['hidden_gem','history','walkable'],76),
    ('mersin','erdemli','Kanli Divane','kanli-divane','historical',36.4501,34.1774,'Ancient sinkhole settlement with ruins and sea horizon.','sunset',90,array['history','photo','sunset'],79),
    ('mersin','tarsus','Tarsus Old Street','tarsus-old-street','market',36.9189,34.8952,'Stone houses, local sweets, and bazaar rhythm in compact lanes.','day',60,array['food','budget','walkable'],75),
    ('mersin','erdemli','Aya Thekla Church','aya-thekla-church','historical',36.4158,34.1227,'Early pilgrimage cave church by coastal cliffs and pine shade.','day',60,array['history','hidden_gem','walkable'],74),
    ('mersin','erdemli','Limonlu River Picnic','limonlu-river-picnic','nature',36.5188,34.1920,'Riverside picnic area popular for family breaks and cool summer air.','day',90,array['family','budget','nature'],73),
    ('mersin','tarsus','Tarsus Museum','tarsus-museum','museum',36.9181,34.8944,'Regional museum with mosaics, coins, and local archaeological finds.','day',60,array['rainy_day','history','family'],77)
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
  popularity_score
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
  s.popularity_score
from place_seed s
join public.provinces p on p.slug = s.province_slug
left join public.districts d on d.slug = s.district_slug and d.province_id = p.id
on conflict (province_id, slug) do update set
  district_id = excluded.district_id,
  name = excluded.name,
  category = excluded.category,
  geog = excluded.geog,
  short_summary = excluded.short_summary,
  best_time = excluded.best_time,
  duration_min = excluded.duration_min,
  tags = excluded.tags,
  popularity_score = excluded.popularity_score;

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
  popularity_score
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
  x.popularity_score
from (
  values
    ('izmir', 'konak', 'Kadifekale', 'kadifekale-izmir', 'historical', 38.4183, 27.1588, 'Hilltop castle ruins with broad city views over Izmir gulf and neighborhoods.', 'sunset', 60, array['history','photo','sunset'], 82),
    ('antalya', 'kemer', 'Termessos', 'termessos-antalya', 'historical', 36.9736, 30.4732, 'Mountain-top ancient city with dramatic theater and pine forest setting.', 'morning', 150, array['history','walkable','hidden_gem'], 90),
    ('mersin', 'erdemli', 'Maiden Bay Walk', 'maiden-bay-walk-mersin', 'viewpoint', 36.4629, 34.1501, 'Seafront promenade facing Kizkalesi with sunset breeze and cafes.', 'sunset', 45, array['sunset','walkable','family'], 76),
    ('aydin', 'kusadasi', 'Zeus Cave', 'zeus-cave-kusadasi', 'nature', 37.6596, 27.1766, 'Cool natural pool near Dilek Peninsula entrance, ideal in hot weather.', 'day', 45, array['nature','hidden_gem','family'], 77)
) as x(province_slug, district_slug, name, slug, category, lat, lng, short_summary, best_time, duration_min, tags, popularity_score)
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
  popularity_score = excluded.popularity_score;

insert into public.place_details (place_id, history_bullets, eat_drink_bullets, tips_bullets)
select
  pl.id,
  case
    when pl.category in ('historical', 'museum') then array[
      'Story layers are best understood with a quick map preview before arrival.',
      'Look for restored and unrestored sections to compare time periods.',
      'Morning visits are calmer and better for guided walks.'
    ]
    else array[
      'Local context changes by season, so ask nearby staff for current highlights.',
      'Nearby neighborhoods often add cultural value to the stop.'
    ]
  end,
  case
    when pl.category in ('food', 'market', 'cafe') then array[
      'Try one signature local dish before moving to the next stop.',
      'Most busy places peak between 13:00 and 15:00.',
      'Keep cash for small vendors.'
    ]
    else array[
      'Popular local eateries are usually within a 10 minute walk.',
      'Reserve dinner early during weekends.'
    ]
  end,
  case
    when pl.best_time = 'sunset' then array[
      'Arrive 30 minutes before sunset for stable light.',
      'Carry a light jacket for coastal wind.',
      'Use elevated corners for wide-angle photos.'
    ]
    when pl.category = 'beach' then array[
      'Bring water shoes where shore is pebbly.',
      'Shade is limited around noon.',
      'Check flag conditions before swimming.'
    ]
    else array[
      'Start with a short orientation loop then choose detailed spots.',
      'Weekday mornings are usually less crowded.',
      'Public transport cards save time in city centers.'
    ]
  end
from public.places pl
on conflict (place_id) do update set
  history_bullets = excluded.history_bullets,
  eat_drink_bullets = excluded.eat_drink_bullets,
  tips_bullets = excluded.tips_bullets;

insert into public.place_media (place_id, storage_path, source, sort_order)
select
  pl.id,
  'public-media/seed/' || pr.slug || '/' || replace(pl.slug::text, '-', '_') || '_1.jpg',
  'seed',
  0
from public.places pl
join public.provinces pr on pr.id = pl.province_id
on conflict do nothing;
