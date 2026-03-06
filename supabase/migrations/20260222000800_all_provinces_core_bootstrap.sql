begin;

with district_candidates as (
  select
    p.id as province_id,
    p.name as province_name,
    p.slug as province_slug,
    d.id as district_id,
    d.name as district_name,
    d.slug as district_slug,
    st_y(d.center_geog::geometry) as lat,
    st_x(d.center_geog::geometry) as lng,
    row_number() over (partition by p.id order by d.name) as rn
  from public.provinces p
  join public.districts d on d.province_id = p.id
), prepared as (
  select
    province_id,
    province_name,
    province_slug,
    district_id,
    district_name,
    district_slug,
    lat,
    lng,
    rn,
    (province_slug || '-' || district_slug || '-core-' || lpad(rn::text, 2, '0'))::text as slug,
    case
      when rn % 10 = 1 then 'historical'
      when rn % 10 = 2 then 'museum'
      when rn % 10 = 3 then 'nature'
      when rn % 10 = 4 then 'viewpoint'
      when rn % 10 = 5 then 'market'
      when rn % 10 = 6 then 'mall'
      when rn % 10 = 7 then 'cafe'
      when rn % 10 = 8 then 'food'
      when rn % 10 = 9 then 'activity'
      else 'lodging'
    end as category,
    case
      when rn % 4 = 0 then 'sunset'
      when rn % 4 = 1 then 'day'
      when rn % 4 = 2 then 'morning'
      else 'night'
    end as best_time,
    case
      when rn % 10 in (3, 5) then true
      else false
    end as is_free,
    greatest(45, 780 - rn * 12) as popularity_score,
    case
      when rn % 10 = 1 then 85
      when rn % 10 = 2 then 95
      when rn % 10 = 3 then 100
      when rn % 10 = 4 then 50
      when rn % 10 = 5 then 70
      when rn % 10 = 6 then 90
      when rn % 10 = 7 then 60
      when rn % 10 = 8 then 75
      when rn % 10 = 9 then 80
      else 60
    end as duration_min,
    left(
      district_name || ' merkezli bu cekirdek rota, ' || province_name ||
      ' icinde gezi planina hizli baslangic ve yakin durak onerileri sunar.',
      160
    ) as short_summary,
    case
      when rn % 10 = 1 then array['history','walkable','family']
      when rn % 10 = 2 then array['history','rainy_day','family']
      when rn % 10 = 3 then array['nature','family','hidden_gem']
      when rn % 10 = 4 then array['sunset','instagrammable','walkable']
      when rn % 10 = 5 then array['budget','walkable','family']
      when rn % 10 = 6 then array['family','walkable','budget']
      when rn % 10 = 7 then array['walkable','budget','family']
      when rn % 10 = 8 then array['food','family','budget']
      when rn % 10 = 9 then array['family','activity','instagrammable']
      else array['family','budget','walkable']
    end as tags
  from district_candidates
  where rn <= 25
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
  is_free,
  is_published,
  published_at
)
select
  p.province_id,
  p.district_id,
  p.district_name || ' Core Spot ' || lpad(p.rn::text, 2, '0') as name,
  p.slug,
  p.category::public.place_category,
  st_setsrid(st_makepoint(p.lng, p.lat), 4326)::geography,
  p.short_summary,
  p.best_time::public.best_time,
  p.duration_min,
  p.tags,
  p.popularity_score,
  p.is_free,
  true,
  now()
from prepared p
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

with core as (
  select
    pl.id as place_id,
    pl.category::text as category,
    pr.slug as province_slug,
    pl.slug as place_slug
  from public.places pl
  join public.provinces pr on pr.id = pl.province_id
  where pl.slug like '%-core-%'
)
insert into public.place_details (place_id, history_bullets, eat_drink_bullets, tips_bullets)
select
  c.place_id,
  case
    when c.category in ('historical','museum') then array['Bu nokta, ilce merkezinin tarihsel baglamini hizli okumak icin referans duraktir.','Cevredeki ikinci katman duraklarla birlestirildiginde daha guclu bir kultur rotasi sunar.']
    when c.category in ('nature','viewpoint') then array['Bu durak, ilce cevresindeki acik alan ve manzara potansiyelini temsil eder.','Mevsime gore deneyim farklilasir; sabah/aksam saatleri daha verimli olabilir.']
    else array['Bu durak, ilce merkezli gezi planinda ana karar noktalari arasindadir.','Yakindaki alt duraklarla birlestirildiginde rota kalitesi artar.']
  end,
  case
    when c.category in ('food','cafe','market','mall') then array['Yogun saatlerden once gitmek beklemeyi azaltir.','Butceyi korumak icin kampanya ve gunluk menu seceneklerini kontrol et.']
    else array['Cevredeki yeme-icme noktalarini 5-10 dakikalik yuruyus halkasinda planla.','Kisa mola duzeni, gun icindeki gezi temposunu korur.']
  end,
  case
    when c.category in ('nature','viewpoint') then array['Gun batimi veya sabah isigine gore varis saati planla.','Ruzgar ve zemin kosullari icin uygun ayakkabi tercih et.']
    else array['Bu duragi, ayni ilcedeki 2-3 yakin noktayla birlikte paket olarak gez.','Harita uzerinde once ulasim sonra sure planlamasi yap.']
  end
from core c
on conflict (place_id) do update set
  history_bullets = excluded.history_bullets,
  eat_drink_bullets = excluded.eat_drink_bullets,
  tips_bullets = excluded.tips_bullets;

with core as (
  select
    pl.id as place_id,
    pr.slug as province_slug,
    pl.slug as place_slug
  from public.places pl
  join public.provinces pr on pr.id = pl.province_id
  where pl.slug like '%-core-%'
)
insert into public.place_media (place_id, storage_path, source, sort_order)
select
  c.place_id,
  format('public-media/seed/%s/%s/1.jpg', c.province_slug, c.place_slug),
  'bootstrap',
  0
from core c
on conflict do nothing;

commit;
