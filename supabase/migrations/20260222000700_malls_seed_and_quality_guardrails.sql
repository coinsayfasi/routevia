begin;

create or replace function public.validate_place_publish_quality()
returns trigger
language plpgsql
as $$
declare
  media_count int;
  details_ok boolean;
begin
  if tg_op = 'UPDATE' and new.is_published = true then
    if char_length(coalesce(new.short_summary, '')) = 0 or char_length(new.short_summary) > 160 then
      raise exception 'Published place must have short_summary <= 160';
    end if;

    select count(*) into media_count
    from public.place_media pm
    where pm.place_id = new.id;

    select exists (
      select 1
      from public.place_details pd
      where pd.place_id = new.id
        and coalesce(array_length(pd.history_bullets, 1), 0) <= 3
        and coalesce(array_length(pd.eat_drink_bullets, 1), 0) <= 3
        and coalesce(array_length(pd.tips_bullets, 1), 0) <= 4
    ) into details_ok;

    if media_count < 1 then
      raise exception 'Published place requires at least 1 media item';
    end if;

    if not details_ok then
      raise exception 'Published place requires valid place_details';
    end if;

  end if;

  if new.is_published = true and new.published_at is null then
    new.published_at = now();
  end if;

  return new;
end;
$$;

drop trigger if exists trg_validate_place_publish_quality on public.places;
create trigger trg_validate_place_publish_quality
before insert or update on public.places
for each row execute function public.validate_place_publish_quality();

create or replace view public.province_content_coverage
with (security_invoker = on)
as
select
  p.id as province_id,
  p.name as province_name,
  p.slug as province_slug,
  count(distinct d.id)::int as district_total,
  count(distinct case when pl.id is not null then d.id end)::int as districts_with_places,
  count(pl.id)::int as place_total,
  count(case when pl.is_published then 1 end)::int as published_place_total
from public.provinces p
left join public.districts d on d.province_id = p.id
left join public.places pl on pl.province_id = p.id and (pl.district_id = d.id or pl.district_id is null)
group by p.id, p.name, p.slug;

grant select on public.province_content_coverage to authenticated;

create temporary table tmp_malls_seed (
  province_slug text,
  district_slug text,
  name text,
  slug text,
  lat double precision,
  lng double precision,
  short_summary text,
  popularity_score int
) on commit drop;

insert into tmp_malls_seed values
('ankara',null,'Ankamall','ankamall-ankara',39.9668,32.8144,'Ankara''nin en buyuk AVM merkezlerinden; alisveris, yemek ve aile etkinligi icin guclu bir hub.',920),
('ankara',null,'Armada AVM','armada-avm-ankara',39.9135,32.8082,'Is-kent aksinda ulasilabilir konumuyla alisveris ve yeme-icme icin dengeli bir AVM secenegi.',860),
('ankara',null,'Panora AVM','panora-avm-ankara',39.8658,32.8607,'Cankaya hattinda premium magaza karmasi ve yemek noktalarini bir araya getiren AVM.',850),
('istanbul',null,'IstinyePark','istinyepark-istanbul',41.1091,29.0331,'Istanbul''da premium marka karmasi ve acik-kapali alan deneyimiyle one cikan AVM.',940),
('istanbul',null,'Zorlu Center','zorlu-center-istanbul',41.0675,29.0125,'Alisveris, gastronomi ve etkinlik deneyimini tek merkezde sunan ust segment kompleks.',930),
('istanbul',null,'Cevahir AVM','cevahir-avm-istanbul',41.0603,28.9872,'Merkezi konumu ve genis magaza karmasiyla yuksek erisilebilir AVM duragi.',910),
('izmir',null,'Forum Bornova','forum-bornova-izmir',38.4637,27.2163,'Izmir''de acik hava konsepti ve genis marka karmasiyla aile dostu AVM alternatifi.',870),
('izmir',null,'IstinyePark Izmir','istinyepark-izmir',38.3907,27.0432,'Premium ve orta segment markalari bir araya getiren yeni nesil AVM deneyimi.',880),
('antalya',null,'MarkAntalya','markantalya-antalya',36.8951,30.6998,'Merkeze yakin konumda alisveris ve yeme-icme ihtiyacini hizli cozen AVM.',860),
('antalya',null,'TerraCity','terracity-antalya',36.8591,30.7674,'Lara hattinda secici magaza karmasi ve sosyal alanlariyla one cikan AVM.',880),
('mugla',null,'Midtown Bodrum','midtown-bodrum',37.0998,27.3632,'Bodrum''da acik alan tasarimi ve guncel magaza karmasiyla guclu AVM noktasi.',840),
('aydin',null,'Forum Aydin','forum-aydin',37.8500,27.8410,'Aydin merkezde alisveris, sinema ve ailece vakit icin pratik AVM secenegi.',810),
('denizli',null,'Forum Camlik','forum-camlik-denizli',37.7765,29.0864,'Denizli''de merkez ulasim avantaji ve cesitli magaza karmasiyla populer AVM.',820),
('mersin',null,'Forum Mersin','forum-mersin',36.7992,34.6158,'Mersin''de ulasilabilir konum ve genis yeme-icme secenekleriyle one cikan AVM.',840),
('bursa',null,'Korupark','korupark-bursa',40.2578,28.9970,'Bursa''da buyuk olcekli magaza karmasi ve aile odakli alanlariyla guclu AVM merkezi.',850),
('bursa',null,'Kent Meydani AVM','kent-meydani-avm-bursa',40.1963,29.0589,'Sehir merkezinde hizli erisimli alisveris ve yeme-icme odagi.',820),
('eskisehir',null,'Espark','espark-eskisehir',39.7805,30.5084,'Eskişehir merkezde ogrenci ve aile kullanimi icin dengeli AVM secenegi.',830),
('eskisehir',null,'Ozdilek AVM Eskisehir','ozdilek-avm-eskisehir',39.7733,30.4981,'Ulasimi kolay konumuyla alisveris ve market ihtiyacini bir arada sunar.',790),
('nevsehir',null,'Nevsehir Forum Kapadokya','forum-kapadokya-nevsehir',38.6275,34.7148,'Kapadokya rotasinda sehir ici alisveris ve temel ihtiyaclar icin pratik AVM.',770),
('adana',null,'Optimum Adana','optimum-adana',37.0051,35.3213,'Adana''da yuksek magaza cesidi ve ulasim avantajiyla one cikan AVM merkezi.',860),
('konya',null,'Kent Plaza','kent-plaza-konya',37.9080,32.5130,'Konya''da aile ve genc kullanima uygun magaza-yeme icme karmasi sunar.',820),
('gaziantep',null,'Forum Gaziantep','forum-gaziantep',37.0744,37.3836,'Gaziantep''te merkezi konum ve genis magaza secenegiyle populer AVM.',840),
('samsun',null,'Piazza AVM Samsun','piazza-samsun',41.3009,36.3356,'Samsun merkezde alisveris, sinema ve sosyal zaman icin guclu AVM secenegi.',830),
('trabzon',null,'Forum Trabzon','forum-trabzon',40.9968,39.7394,'Trabzon''da ulasilabilir lokasyon ve aile odakli karmasiyla one cikan AVM.',820),
('kayseri',null,'Forum Kayseri','forum-kayseri',38.7342,35.4924,'Kayseri''de ana ulasim aksina yakin alisveris ve yeme-icme merkezi.',830);

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
  'mall'::public.place_category,
  st_setsrid(st_makepoint(s.lng, s.lat), 4326)::geography,
  left(s.short_summary, 160),
  'day'::public.best_time,
  90,
  array['family','walkable','budget'],
  s.popularity_score,
  false,
  true,
  now()
from tmp_malls_seed s
join public.provinces p on p.slug = s.province_slug
left join public.districts d on d.province_id = p.id and d.slug = s.district_slug
on conflict (province_id, slug) do update set
  name = excluded.name,
  district_id = excluded.district_id,
  geog = excluded.geog,
  short_summary = excluded.short_summary,
  popularity_score = excluded.popularity_score,
  tags = excluded.tags,
  is_published = true,
  updated_at = now();

insert into public.place_details (place_id, history_bullets, eat_drink_bullets, tips_bullets)
select
  pl.id,
  array['Bu AVM sehir ici alisveris davranisini merkeze toplayan modern bir ticaret odagidir.'],
  array['Food court saatlerinde yogunluk artabilir, erken saatler daha rahattir.','Butceyi korumak icin kampanya gunlerini takip et.'],
  array['Hafta sonu otopark dolulugunu hesaba kat.','Cocuklu ziyaretlerde oyun alanlarini onceden kontrol et.']
from tmp_malls_seed s
join public.provinces p on p.slug = s.province_slug
join public.places pl on pl.province_id = p.id and pl.slug = s.slug
on conflict (place_id) do update set
  history_bullets = excluded.history_bullets,
  eat_drink_bullets = excluded.eat_drink_bullets,
  tips_bullets = excluded.tips_bullets;

insert into public.place_media (place_id, storage_path, source, sort_order)
select
  pl.id,
  format('public-media/seed/%s/%s/1.jpg', s.province_slug, s.slug),
  'curated',
  0
from tmp_malls_seed s
join public.provinces p on p.slug = s.province_slug
join public.places pl on pl.province_id = p.id and pl.slug = s.slug
on conflict do nothing;

commit;
