create or replace function public.ingest_priority_score(
  p_province_slug text,
  p_district_slug text
)
returns int
language sql
immutable
as $$
  select
    case
      when lower(coalesce(p_district_slug, '')) in (
        'fatih','beyoglu','besiktas','uskudar','sisli','kadikoy','sariyer',
        'konyaalti','muratpasa','alanya','manavgat','kas','kemer','kalkan',
        'fethiye','bodrum','marmaris','datca','ortaca','seydikemer','milas',
        'cesme','konak','selcuk','kusadasi','didim','ayvalik','edremit',
        'pamukkale','goreme','avanos','urgup','trabzon-ortahisar','ortahisar'
      ) then 100
      when lower(coalesce(p_province_slug, '')) in (
        'istanbul','antalya','mugla','izmir','nevsehir','aydin','canakkale',
        'balikesir','denizli','trabzon','rize','bursa','ankara','mersin',
        'adana','kayseri','konya'
      ) then 70
      when lower(coalesce(p_province_slug, '')) in (
        'samsun','eskisehir','bolu','sakarya','ordu','artvin','elazig','van',
        'erzurum','kars','giresun','amasya','sinop'
      ) then 40
      else 10
    end;
$$;

update public.district_ingest_jobs j
set priority_score = public.ingest_priority_score(p.slug::text, d.slug::text)
from public.districts d
join public.provinces p on p.id = d.province_id
where d.id = j.district_id;
