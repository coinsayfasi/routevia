-- Routevia · Olmazsa olmaz (must-see) curated seed/migration
-- 2026-06-16, canlı prod'dan birebir dump. TAM IDEMPOTENT (name+city bazlı), insert-only, DDL yok.
-- 157 curated POI + 434 featured pin. Koordinatlar resolve_admin_by_point ile doğrulandı.
-- city/district pois trigger'ı ile lat/lng'den otomatik dolar. Mevcut yapıyı bozmaz: sadece eksikse ekler.

begin;

-- 1) Curated POIs (aynı isim+yakın koordinat yoksa ekle)
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Anavarza Antik Kenti$$,'historical',37.25,35.9,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Anavarza Antik Kenti$$) and abs(lat-37.25)<0.0015 and abs(lng-35.9)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Misis Antik Kenti$$,'historical',36.96,35.62,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Misis Antik Kenti$$) and abs(lat-36.96)<0.0015 and abs(lng-35.62)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Afyon Kalesi$$,'historical',38.7569,30.5387,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Afyon Kalesi$$) and abs(lat-38.7569)<0.0015 and abs(lng-30.5387)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Ayazini Frig Kenti$$,'historical',39.05,30.55,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Ayazini Frig Kenti$$) and abs(lat-39.05)<0.0015 and abs(lng-30.55)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Frig Vadisi$$,'nature',39.045,30.55,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Frig Vadisi$$) and abs(lat-39.045)<0.0015 and abs(lng-30.55)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Gazlıgöl Kaplıcaları$$,'activity',38.95,30.55,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Gazlıgöl Kaplıcaları$$) and abs(lat-38.95)<0.0015 and abs(lng-30.55)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Ağrı Dağı$$,'nature',39.5468,44.0876,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Ağrı Dağı$$) and abs(lat-39.5468)<0.0015 and abs(lng-44.0876)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Aksaray Ulu Camii$$,'historical',38.37,34.03,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Aksaray Ulu Camii$$) and abs(lat-38.37)<0.0015 and abs(lng-34.03)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Hasan Dağı$$,'viewpoint',38.13,34.17,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Hasan Dağı$$) and abs(lat-38.13)<0.0015 and abs(lng-34.17)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Amasya Evleri$$,'historical',40.6547,35.8389,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Amasya Evleri$$) and abs(lat-40.6547)<0.0015 and abs(lng-35.8389)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Amasya Kalesi$$,'historical',40.6556,35.8333,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Amasya Kalesi$$) and abs(lat-40.6556)<0.0015 and abs(lng-35.8333)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Borabay Gölü$$,'nature',40.74,36.34,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Borabay Gölü$$) and abs(lat-40.74)<0.0015 and abs(lng-36.34)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kral Kaya Mezarları$$,'historical',40.6539,35.8336,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kral Kaya Mezarları$$) and abs(lat-40.6539)<0.0015 and abs(lng-35.8336)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Anıtkabir$$,'historical',39.9251,32.8369,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Anıtkabir$$) and abs(lat-39.9251)<0.0015 and abs(lng-32.8369)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Hamamönü$$,'historical',39.94,32.86,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Hamamönü$$) and abs(lat-39.94)<0.0015 and abs(lng-32.86)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Afrodisias$$,'historical',37.7086,28.7244,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Afrodisias$$) and abs(lat-37.7086)<0.0015 and abs(lng-28.7244)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Didyma Apollon Tapınağı$$,'historical',37.385,27.256,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Didyma Apollon Tapınağı$$) and abs(lat-37.385)<0.0015 and abs(lng-27.256)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Cunda Adası$$,'historical',39.33,26.62,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Cunda Adası$$) and abs(lat-39.33)<0.0015 and abs(lng-26.62)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kaz Dağları Milli Parkı$$,'nature',39.7,26.9,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kaz Dağları Milli Parkı$$) and abs(lat-39.7)<0.0015 and abs(lng-26.9)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Manyas Kuş Cenneti$$,'nature',40.18,27.96,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Manyas Kuş Cenneti$$) and abs(lat-40.18)<0.0015 and abs(lng-27.96)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Güzelcehisar Lav Sütunları$$,'nature',41.65,32.2,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Güzelcehisar Lav Sütunları$$) and abs(lat-41.65)<0.0015 and abs(lng-32.2)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Hasankeyf$$,'historical',37.7142,41.4097,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Hasankeyf$$) and abs(lat-37.7142)<0.0015 and abs(lng-41.4097)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Aydıntepe Yeraltı Şehri$$,'historical',40.38,40.15,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Aydıntepe Yeraltı Şehri$$) and abs(lat-40.38)<0.0015 and abs(lng-40.15)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Harmankaya Kanyonu$$,'nature',40.1,30.45,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Harmankaya Kanyonu$$) and abs(lat-40.1)<0.0015 and abs(lng-30.45)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Pelitözü Göleti$$,'nature',40.135,29.97,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Pelitözü Göleti$$) and abs(lat-40.135)<0.0015 and abs(lng-29.97)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Söğüt Ertuğrul Gazi Türbesi$$,'historical',40.0233,30.1869,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Söğüt Ertuğrul Gazi Türbesi$$) and abs(lat-40.0233)<0.0015 and abs(lng-30.1869)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kiğı Kalesi$$,'historical',39.31,40.35,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kiğı Kalesi$$) and abs(lat-39.31)<0.0015 and abs(lng-40.35)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Yüzen Adalar$$,'nature',38.95,41.05,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Yüzen Adalar$$) and abs(lat-38.95)<0.0015 and abs(lng-41.05)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$El-Aman Kervansarayı$$,'historical',38.3,42.3,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$El-Aman Kervansarayı$$) and abs(lat-38.3)<0.0015 and abs(lng-42.3)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Sagalassos$$,'historical',37.6783,30.5189,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Sagalassos$$) and abs(lat-37.6783)<0.0015 and abs(lng-30.5189)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Salda Gölü$$,'nature',37.55,29.68,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Salda Gölü$$) and abs(lat-37.55)<0.0015 and abs(lng-29.68)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Bursa Ulu Camii$$,'historical',40.1828,29.0617,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Bursa Ulu Camii$$) and abs(lat-40.1828)<0.0015 and abs(lng-29.0617)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Cumalıkızık$$,'historical',40.18,29.18,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Cumalıkızık$$) and abs(lat-40.18)<0.0015 and abs(lng-29.18)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$İznik$$,'historical',40.43,29.72,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$İznik$$) and abs(lat-40.43)<0.0015 and abs(lng-29.72)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Tirilye$$,'historical',40.3897,28.7906,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Tirilye$$) and abs(lat-40.3897)<0.0015 and abs(lng-28.7906)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Uludağ$$,'nature',40.1,29.13,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Uludağ$$) and abs(lat-40.1)<0.0015 and abs(lng-29.13)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Çankırı Taş Mescit$$,'historical',40.6,33.61,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Çankırı Taş Mescit$$) and abs(lat-40.6)<0.0015 and abs(lng-33.61)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Çankırı Tuz Mağarası$$,'nature',40.61,33.58,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Çankırı Tuz Mağarası$$) and abs(lat-40.61)<0.0015 and abs(lng-33.58)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Ilgaz Dağı$$,'nature',40.83,33.62,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Ilgaz Dağı$$) and abs(lat-40.83)<0.0015 and abs(lng-33.62)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Alacahöyük$$,'historical',40.2333,34.6833,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Alacahöyük$$) and abs(lat-40.2333)<0.0015 and abs(lng-34.6833)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Çorum Kalesi$$,'historical',40.55,34.95,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Çorum Kalesi$$) and abs(lat-40.55)<0.0015 and abs(lng-34.95)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Hattuşa$$,'historical',40.0192,34.6153,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Hattuşa$$) and abs(lat-40.0192)<0.0015 and abs(lng-34.6153)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Hierapolis$$,'historical',37.9256,29.1289,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Hierapolis$$) and abs(lat-37.9256)<0.0015 and abs(lng-29.1289)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kaklık Mağarası$$,'nature',37.83,29.43,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kaklık Mağarası$$) and abs(lat-37.83)<0.0015 and abs(lng-29.43)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Laodikya$$,'historical',37.83,29.11,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Laodikya$$) and abs(lat-37.83)<0.0015 and abs(lng-29.11)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Pamukkale$$,'nature',37.9203,29.1206,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Pamukkale$$) and abs(lat-37.9203)<0.0015 and abs(lng-29.1206)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Akçakoca$$,'beach',41.0867,31.1167,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Akçakoca$$) and abs(lat-41.0867)<0.0015 and abs(lng-31.1167)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Güzeldere Şelalesi$$,'nature',40.75,31.3,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Güzeldere Şelalesi$$) and abs(lat-40.75)<0.0015 and abs(lng-31.3)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Samandere Şelalesi$$,'nature',40.76,31.28,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Samandere Şelalesi$$) and abs(lat-40.76)<0.0015 and abs(lng-31.28)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Edirne Sarayı$$,'historical',41.685,26.55,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Edirne Sarayı$$) and abs(lat-41.685)<0.0015 and abs(lng-26.55)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Selimiye Camii$$,'historical',41.6783,26.5594,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Selimiye Camii$$) and abs(lat-41.6783)<0.0015 and abs(lng-26.5594)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Keban Baraj Gölü$$,'nature',38.8,38.74,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Keban Baraj Gölü$$) and abs(lat-38.8)<0.0015 and abs(lng-38.74)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Ergan Dağı$$,'nature',39.7,39.45,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Ergan Dağı$$) and abs(lat-39.7)<0.0015 and abs(lng-39.45)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kemaliye$$,'historical',39.26,38.5,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kemaliye$$) and abs(lat-39.26)<0.0015 and abs(lng-38.5)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Odunpazarı Evleri$$,'historical',39.7667,30.5256,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Odunpazarı Evleri$$) and abs(lat-39.7667)<0.0015 and abs(lng-30.5256)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Bakırcılar Çarşısı$$,'market',37.0639,37.3781,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Bakırcılar Çarşısı$$) and abs(lat-37.0639)<0.0015 and abs(lng-37.3781)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Gaziantep Kalesi$$,'historical',37.0658,37.3833,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Gaziantep Kalesi$$) and abs(lat-37.0658)<0.0015 and abs(lng-37.3833)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Giresun Adası$$,'nature',40.9236,38.3992,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Giresun Adası$$) and abs(lat-40.9236)<0.0015 and abs(lng-38.3992)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Mavi Göl$$,'nature',40.55,38.4,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Mavi Göl$$) and abs(lat-40.55)<0.0015 and abs(lng-38.4)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Karaca Mağarası$$,'nature',40.36,39.27,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Karaca Mağarası$$) and abs(lat-40.36)<0.0015 and abs(lng-39.27)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Limni Gölü$$,'nature',40.3,39.4,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Limni Gölü$$) and abs(lat-40.3)<0.0015 and abs(lng-39.4)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Cilo Dağları$$,'nature',37.55,43.95,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Cilo Dağları$$) and abs(lat-37.55)<0.0015 and abs(lng-43.95)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Meydan Medresesi$$,'historical',37.57,43.74,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Meydan Medresesi$$) and abs(lat-37.57)<0.0015 and abs(lng-43.74)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Sat Gölleri$$,'nature',37.42,44.18,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Sat Gölleri$$) and abs(lat-37.42)<0.0015 and abs(lng-44.18)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Harbiye Şelaleleri$$,'nature',36.13,36.13,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Harbiye Şelaleleri$$) and abs(lat-36.13)<0.0015 and abs(lng-36.13)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Hatay Arkeoloji Müzesi$$,'museum',36.2025,36.1606,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Hatay Arkeoloji Müzesi$$) and abs(lat-36.2025)<0.0015 and abs(lng-36.1606)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$St. Pierre Kilisesi$$,'historical',36.2056,36.1769,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$St. Pierre Kilisesi$$) and abs(lat-36.2056)<0.0015 and abs(lng-36.1769)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Karakale$$,'historical',39.97,43.78,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Karakale$$) and abs(lat-39.97)<0.0015 and abs(lng-43.78)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kasımcan Kervansarayı$$,'historical',39.92,44.04,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kasımcan Kervansarayı$$) and abs(lat-39.92)<0.0015 and abs(lng-44.04)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Tuzluca Tuz Mağaraları$$,'nature',40.04,43.65,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Tuzluca Tuz Mağaraları$$) and abs(lat-40.04)<0.0015 and abs(lng-43.65)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Eğirdir Gölü$$,'nature',38.05,30.85,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Eğirdir Gölü$$) and abs(lat-38.05)<0.0015 and abs(lng-30.85)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Lavanta Bahçeleri$$,'nature',37.95,31.05,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Lavanta Bahçeleri$$) and abs(lat-37.95)<0.0015 and abs(lng-31.05)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Fener Balat$$,'historical',41.0294,28.9497,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Fener Balat$$) and abs(lat-41.0294)<0.0015 and abs(lng-28.9497)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Alaçatı$$,'historical',38.28,26.37,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Alaçatı$$) and abs(lat-38.28)<0.0015 and abs(lng-26.37)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Bergama Akropolü$$,'historical',39.132,27.184,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Bergama Akropolü$$) and abs(lat-39.132)<0.0015 and abs(lng-27.184)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$İzmir Agora$$,'historical',38.4189,27.1389,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$İzmir Agora$$) and abs(lat-38.4189)<0.0015 and abs(lng-27.1389)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Klaros$$,'historical',37.99,27.2,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Klaros$$) and abs(lat-37.99)<0.0015 and abs(lng-27.2)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Şirince$$,'historical',37.95,27.42,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Şirince$$) and abs(lat-37.95)<0.0015 and abs(lng-27.42)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Ali Kayası$$,'viewpoint',37.59,36.92,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Ali Kayası$$) and abs(lat-37.59)<0.0015 and abs(lng-36.92)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kahramanmaraş Kalesi$$,'historical',37.5833,36.9333,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kahramanmaraş Kalesi$$) and abs(lat-37.5833)<0.0015 and abs(lng-36.9333)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Bulak Mencilis Mağarası$$,'nature',41.27,32.55,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Bulak Mencilis Mağarası$$) and abs(lat-41.27)<0.0015 and abs(lng-32.55)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Binbir Kilise$$,'historical',37.43,33.18,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Binbir Kilise$$) and abs(lat-37.43)<0.0015 and abs(lng-33.18)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Karaman Kalesi$$,'historical',37.1806,33.2208,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Karaman Kalesi$$) and abs(lat-37.1806)<0.0015 and abs(lng-33.2208)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Taşkale Manazan Mağaraları$$,'historical',37.07,33.42,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Taşkale Manazan Mağaraları$$) and abs(lat-37.07)<0.0015 and abs(lng-33.42)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Yeşildere Kanyonu$$,'nature',36.95,33.25,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Yeşildere Kanyonu$$) and abs(lat-36.95)<0.0015 and abs(lng-33.25)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Boğatepe Köyü$$,'historical',40.65,43.3,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Boğatepe Köyü$$) and abs(lat-40.65)<0.0015 and abs(lng-43.3)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Sarıkamış Kayak Merkezi$$,'activity',40.33,42.58,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Sarıkamış Kayak Merkezi$$) and abs(lat-40.33)<0.0015 and abs(lng-42.58)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Ilıca Şelalesi$$,'nature',41.7,33.1,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Ilıca Şelalesi$$) and abs(lat-41.7)<0.0015 and abs(lng-33.1)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Küre Dağları$$,'nature',41.8,33.7,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Küre Dağları$$) and abs(lat-41.8)<0.0015 and abs(lng-33.7)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Valla Kanyonu$$,'nature',41.65,33.55,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Valla Kanyonu$$) and abs(lat-41.65)<0.0015 and abs(lng-33.55)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Hunat Hatun Külliyesi$$,'historical',38.7225,35.4869,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Hunat Hatun Külliyesi$$) and abs(lat-38.7225)<0.0015 and abs(lng-35.4869)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kapuzbaşı Şelaleleri$$,'nature',37.7667,35.509,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kapuzbaşı Şelaleleri$$) and abs(lat-37.7667)<0.0015 and abs(lng-35.509)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Sultan Sazlığı$$,'nature',38.32,35.3,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Sultan Sazlığı$$) and abs(lat-38.32)<0.0015 and abs(lng-35.3)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kilis Kalesi$$,'historical',36.718,37.117,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kilis Kalesi$$) and abs(lat-36.718)<0.0015 and abs(lng-37.117)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kilis Ulu Camii$$,'historical',36.716,37.115,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kilis Ulu Camii$$) and abs(lat-36.716)<0.0015 and abs(lng-37.115)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Hasandede Camii$$,'historical',39.75,33.4,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Hasandede Camii$$) and abs(lat-39.75)<0.0015 and abs(lng-33.4)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$MKE Silah Sanayi Müzesi$$,'museum',39.84,33.51,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$MKE Silah Sanayi Müzesi$$) and abs(lat-39.84)<0.0015 and abs(lng-33.51)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$İğneada Longoz Ormanları$$,'nature',41.82,27.97,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$İğneada Longoz Ormanları$$) and abs(lat-41.82)<0.0015 and abs(lng-27.97)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Ahi Evran Türbesi$$,'historical',39.143,34.165,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Ahi Evran Türbesi$$) and abs(lat-39.143)<0.0015 and abs(lng-34.165)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Seyfe Gölü$$,'nature',39.22,34.42,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Seyfe Gölü$$) and abs(lat-39.22)<0.0015 and abs(lng-34.42)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kartepe$$,'activity',40.68,30.1,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kartepe$$) and abs(lat-40.68)<0.0015 and abs(lng-30.1)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Çatalhöyük$$,'historical',37.6669,32.8281,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Çatalhöyük$$) and abs(lat-37.6669)<0.0015 and abs(lng-32.8281)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Sille$$,'historical',37.93,32.45,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Sille$$) and abs(lat-37.93)<0.0015 and abs(lng-32.45)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Tuz Gölü$$,'nature',38.55,33.2,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Tuz Gölü$$) and abs(lat-38.55)<0.0015 and abs(lng-33.2)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Dumlupınar Zafertepe Anıtı$$,'historical',39.07,29.85,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Dumlupınar Zafertepe Anıtı$$) and abs(lat-39.07)<0.0015 and abs(lng-29.85)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Germiyan Sokağı$$,'historical',39.4181,29.9869,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Germiyan Sokağı$$) and abs(lat-39.4181)<0.0015 and abs(lng-29.9869)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kütahya Çini Müzesi$$,'museum',39.42,29.98,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kütahya Çini Müzesi$$) and abs(lat-39.42)<0.0015 and abs(lng-29.98)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Arslantepe Höyüğü$$,'historical',38.382,38.362,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Arslantepe Höyüğü$$) and abs(lat-38.382)<0.0015 and abs(lng-38.362)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Battalgazi Ulu Camii$$,'historical',38.45,38.36,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Battalgazi Ulu Camii$$) and abs(lat-38.45)<0.0015 and abs(lng-38.36)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Levent Vadisi$$,'nature',38.3,37.85,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Levent Vadisi$$) and abs(lat-38.3)<0.0015 and abs(lng-37.85)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Somuncu Baba Külliyesi$$,'historical',38.5476,37.4968,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Somuncu Baba Külliyesi$$) and abs(lat-38.5476)<0.0015 and abs(lng-37.4968)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Ağlayan Kaya$$,'historical',38.61,27.43,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Ağlayan Kaya$$) and abs(lat-38.61)<0.0015 and abs(lng-27.43)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Sardes Antik Kenti$$,'historical',38.49,28.04,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Sardes Antik Kenti$$) and abs(lat-38.49)<0.0015 and abs(lng-28.04)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Dara Antik Kenti$$,'historical',37.18,40.95,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Dara Antik Kenti$$) and abs(lat-37.18)<0.0015 and abs(lng-40.95)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Mardin Eski Şehir$$,'historical',37.3128,40.735,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Mardin Eski Şehir$$) and abs(lat-37.3128)<0.0015 and abs(lng-40.735)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Midyat Konukevi$$,'historical',37.42,41.37,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Midyat Konukevi$$) and abs(lat-37.42)<0.0015 and abs(lng-41.37)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Cennet Cehennem Obrukları$$,'nature',36.45,34.1,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Cennet Cehennem Obrukları$$) and abs(lat-36.45)<0.0015 and abs(lng-34.1)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kanlıdivane$$,'historical',36.5,34.13,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kanlıdivane$$) and abs(lat-36.5)<0.0015 and abs(lng-34.13)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kızkalesi$$,'historical',36.4644,34.1453,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kızkalesi$$) and abs(lat-36.4644)<0.0015 and abs(lng-34.1453)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Tarsus Şelalesi$$,'nature',36.92,34.9,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Tarsus Şelalesi$$) and abs(lat-36.92)<0.0015 and abs(lng-34.9)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kabak Koyu$$,'beach',36.51,29.1,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kabak Koyu$$) and abs(lat-36.51)<0.0015 and abs(lng-29.1)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Hamurpet Gölü$$,'nature',39.1,41.55,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Hamurpet Gölü$$) and abs(lat-39.1)<0.0015 and abs(lng-41.55)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Malazgirt Meydan Muharebesi Alanı$$,'historical',39.14,42.54,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Malazgirt Meydan Muharebesi Alanı$$) and abs(lat-39.14)<0.0015 and abs(lng-42.54)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Avanos$$,'historical',38.7156,34.8456,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Avanos$$) and abs(lat-38.7156)<0.0015 and abs(lng-34.8456)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kozaklı Kaplıcaları$$,'activity',39.21,34.85,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kozaklı Kaplıcaları$$) and abs(lat-39.21)<0.0015 and abs(lng-34.85)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Paşabağları$$,'nature',38.65,34.84,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Paşabağları$$) and abs(lat-38.65)<0.0015 and abs(lng-34.84)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Tyana Antik Kenti$$,'historical',37.83,34.58,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Tyana Antik Kenti$$) and abs(lat-37.83)<0.0015 and abs(lng-34.58)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Boztepe$$,'viewpoint',40.97,37.88,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Boztepe$$) and abs(lat-40.97)<0.0015 and abs(lng-37.88)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Ulugöl$$,'nature',40.65,37.7,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Ulugöl$$) and abs(lat-40.65)<0.0015 and abs(lng-37.7)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Karatepe-Aslantaş$$,'historical',37.3,36.25,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Karatepe-Aslantaş$$) and abs(lat-37.3)<0.0015 and abs(lng-36.25)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Fırtına Vadisi$$,'nature',41.1,41.1,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Fırtına Vadisi$$) and abs(lat-41.1)<0.0015 and abs(lng-41.1)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Pokut Yaylası$$,'nature',40.85,41.05,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Pokut Yaylası$$) and abs(lat-40.85)<0.0015 and abs(lng-41.05)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Bandırma Vapuru$$,'museum',41.288,36.331,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Bandırma Vapuru$$) and abs(lat-41.288)<0.0015 and abs(lng-36.331)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Bandırma Vapuru Müzesi$$,'museum',41.2867,36.3306,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Bandırma Vapuru Müzesi$$) and abs(lat-41.2867)<0.0015 and abs(lng-36.3306)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Karahantepe$$,'historical',37.1,38.95,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Karahantepe$$) and abs(lat-37.1)<0.0015 and abs(lng-38.95)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Şanlıurfa Kalesi$$,'historical',37.15,38.79,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Şanlıurfa Kalesi$$) and abs(lat-37.15)<0.0015 and abs(lng-38.79)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Botan Vadisi$$,'nature',37.85,42.1,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Botan Vadisi$$) and abs(lat-37.85)<0.0015 and abs(lng-42.1)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Tillo (Aydınlar)$$,'historical',37.94,42.05,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Tillo (Aydınlar)$$) and abs(lat-37.94)<0.0015 and abs(lng-42.05)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Divriği Ulu Camii$$,'historical',39.3719,38.1156,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Divriği Ulu Camii$$) and abs(lat-39.3719)<0.0015 and abs(lng-38.1156)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kangal Balıklı Kaplıca$$,'activity',39.1,37.45,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kangal Balıklı Kaplıca$$) and abs(lat-39.1)<0.0015 and abs(lng-37.45)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Tödürge Gölü$$,'nature',39.8805336,37.5993827,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Tödürge Gölü$$) and abs(lat-39.8805336)<0.0015 and abs(lng-37.5993827)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Cizre Nuh Peygamber Türbesi$$,'historical',37.33,42.19,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Cizre Nuh Peygamber Türbesi$$) and abs(lat-37.33)<0.0015 and abs(lng-42.19)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Cudi Dağı$$,'nature',37.38,42.45,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Cudi Dağı$$) and abs(lat-37.38)<0.0015 and abs(lng-42.45)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Kasrik Boğazı$$,'nature',37.45,42.4,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Kasrik Boğazı$$) and abs(lat-37.45)<0.0015 and abs(lng-42.4)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Uçmakdere$$,'nature',40.78,27.32,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Uçmakdere$$) and abs(lat-40.78)<0.0015 and abs(lng-27.32)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Sulusaray Sebastopolis$$,'historical',39.96,36.07,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Sulusaray Sebastopolis$$) and abs(lat-39.96)<0.0015 and abs(lng-36.07)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Pülümür Vadisi$$,'nature',39.5,39.9,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Pülümür Vadisi$$) and abs(lat-39.5)<0.0015 and abs(lng-39.9)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Ulubey Kanyonu$$,'nature',38.42,29.3,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Ulubey Kanyonu$$) and abs(lat-38.42)<0.0015 and abs(lng-29.3)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Akdamar Adası$$,'historical',38.34,43.04,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Akdamar Adası$$) and abs(lat-38.34)<0.0015 and abs(lng-43.04)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Çavuştepe Kalesi$$,'historical',38.35,43.55,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Çavuştepe Kalesi$$) and abs(lat-38.35)<0.0015 and abs(lng-43.55)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Van Gölü$$,'nature',38.5,43.05,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Van Gölü$$) and abs(lat-38.5)<0.0015 and abs(lng-43.05)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Sudüşen Şelalesi$$,'nature',40.6,29.18,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Sudüşen Şelalesi$$) and abs(lat-40.6)<0.0015 and abs(lng-29.18)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Termal Kaplıcaları$$,'activity',40.6,29.15,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Termal Kaplıcaları$$) and abs(lat-40.6)<0.0015 and abs(lng-29.15)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Çamlık Milli Parkı$$,'nature',39.77,34.83,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Çamlık Milli Parkı$$) and abs(lat-39.77)<0.0015 and abs(lng-34.83)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Çapanoğlu Camii$$,'historical',39.82,34.8,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Çapanoğlu Camii$$) and abs(lat-39.82)<0.0015 and abs(lng-34.8)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Sarıkaya Roma Hamamı$$,'historical',39.69,35.4,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Sarıkaya Roma Hamamı$$) and abs(lat-39.69)<0.0015 and abs(lng-35.4)<0.0015);
insert into pois (name,category,lat,lng,source,coordinate_source,provenance_verified,provenance_checked_at,tags)
select $$Filyos Antik Kenti$$,'historical',41.57,32.02,'wikidata','admin_verified',true,now(),'["must_see","curated_mustsee_v1"]'::jsonb
where not exists (select 1 from pois where lower(name)=lower($$Filyos Antik Kenti$$) and abs(lat-41.57)<0.0015 and abs(lng-32.02)<0.0015);

-- 2) Featured pins (o isim+şehir için AKTİF pin yoksa bir tane pinle)
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Misis Antik Kenti$$) and p.city='Adana'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Misis Antik Kenti$$) and p2.city='Adana' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Anavarza Antik Kenti$$) and p.city='Adana'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Anavarza Antik Kenti$$) and p2.city='Adana' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Sabancı Merkez Camii$$) and p.city='Adana'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sabancı Merkez Camii$$) and p2.city='Adana' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Taşköprü$$) and p.city='Adana'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Taşköprü$$) and p2.city='Adana' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Varda Köprüsü$$) and p.city='Adana'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Varda Köprüsü$$) and p2.city='Adana' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kommagene Nemrut Turları - İrfan Çetinkaya$$) and p.city='Adıyaman'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kommagene Nemrut Turları - İrfan Çetinkaya$$) and p2.city='Adıyaman' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Nemrut Dağı Milli Parkı$$) and p.city='Adıyaman'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Nemrut Dağı Milli Parkı$$) and p2.city='Adıyaman' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Cendere Köprüsü$$) and p.city='Adıyaman'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Cendere Köprüsü$$) and p2.city='Adıyaman' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Nemrut Dağı$$) and p.city='Adıyaman'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Nemrut Dağı$$) and p2.city='Adıyaman' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Karakuş Tümülüsü$$) and p.city='Adıyaman'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Karakuş Tümülüsü$$) and p2.city='Adıyaman' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Ayazini Frig Kenti$$) and p.city='Afyonkarahisar'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ayazini Frig Kenti$$) and p2.city='Afyonkarahisar' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Gazlıgöl Kaplıcaları$$) and p.city='Afyonkarahisar'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Gazlıgöl Kaplıcaları$$) and p2.city='Afyonkarahisar' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Afyon Kalesi$$) and p.city='Afyonkarahisar'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Afyon Kalesi$$) and p2.city='Afyonkarahisar' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Frig Vadisi$$) and p.city='Afyonkarahisar'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Frig Vadisi$$) and p2.city='Afyonkarahisar' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$İshak Paşa Sarayı$$) and p.city='Ağrı'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$İshak Paşa Sarayı$$) and p2.city='Ağrı' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Ishakpasa Sarayinda$$) and p.city='Ağrı'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ishakpasa Sarayinda$$) and p2.city='Ağrı' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Ağrı Dağı$$) and p.city='Ağrı'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ağrı Dağı$$) and p2.city='Ağrı' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Aksaray Ulu Camii$$) and p.city='Aksaray'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Aksaray Ulu Camii$$) and p2.city='Aksaray' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Sultanhanı Kervansarayı$$) and p.city='Aksaray'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sultanhanı Kervansarayı$$) and p2.city='Aksaray' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Ihlara Vadisi$$) and p.city='Aksaray'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ihlara Vadisi$$) and p2.city='Aksaray' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Hasan Dağı$$) and p.city='Aksaray'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hasan Dağı$$) and p2.city='Aksaray' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Amasya Kalesi$$) and p.city='Amasya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Amasya Kalesi$$) and p2.city='Amasya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Amasya Evleri$$) and p.city='Amasya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Amasya Evleri$$) and p2.city='Amasya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Borabay Gölü$$) and p.city='Amasya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Borabay Gölü$$) and p2.city='Amasya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Kral Kaya Mezarları$$) and p.city='Amasya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kral Kaya Mezarları$$) and p2.city='Amasya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Anıtkabir$$) and p.city='Ankara'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Anıtkabir$$) and p2.city='Ankara' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Ankara Kalesi$$) and p.city='Ankara'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ankara Kalesi$$) and p2.city='Ankara' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Anadolu Medeniyetleri Müzesi$$) and p.city='Ankara'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Anadolu Medeniyetleri Müzesi$$) and p2.city='Ankara' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Hamamönü$$) and p.city='Ankara'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hamamönü$$) and p2.city='Ankara' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Atakule$$) and p.city='Ankara'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Atakule$$) and p2.city='Ankara' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Hamamonu$$) and p.city='Ankara'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hamamonu$$) and p2.city='Ankara' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Anitkabir$$) and p.city='Ankara'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Anitkabir$$) and p2.city='Ankara' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Olympos$$) and p.city='Antalya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Olympos$$) and p2.city='Antalya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Karain Mağarası$$) and p.city='Antalya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Karain Mağarası$$) and p2.city='Antalya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Termessos$$) and p.city='Antalya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Termessos$$) and p2.city='Antalya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Alanya Kalesi$$) and p.city='Antalya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Alanya Kalesi$$) and p2.city='Antalya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Duden Selalesi$$) and p.city='Antalya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Duden Selalesi$$) and p2.city='Antalya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kaleici$$) and p.city='Antalya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kaleici$$) and p2.city='Antalya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Çıldır Gölü Konağı - Lake Cildir Lodge$$) and p.city='Ardahan'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Çıldır Gölü Konağı - Lake Cildir Lodge$$) and p2.city='Ardahan' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Şeytan Kalesi$$) and p.city='Ardahan'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Şeytan Kalesi$$) and p2.city='Ardahan' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Çıldır Gölü$$) and p.city='Ardahan'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Çıldır Gölü$$) and p2.city='Ardahan' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Ardahan Kalesi$$) and p.city='Ardahan'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ardahan Kalesi$$) and p2.city='Ardahan' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Borçka Karagöl Kamp Alanı$$) and p.city='Artvin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Borçka Karagöl Kamp Alanı$$) and p2.city='Artvin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Borçka Karagöl Tabiat Parkı$$) and p.city='Artvin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Borçka Karagöl Tabiat Parkı$$) and p2.city='Artvin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Karagöl-Sahara Milli Parkı$$) and p.city='Artvin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Karagöl-Sahara Milli Parkı$$) and p2.city='Artvin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$KARAGÖL-ŞAVŞAT$$) and p.city='Artvin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$KARAGÖL-ŞAVŞAT$$) and p2.city='Artvin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Mençuna Şelalesi$$) and p.city='Artvin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Mençuna Şelalesi$$) and p2.city='Artvin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Dilek Yarımadası Büyük Menderes Deltası Milli Parkı$$) and p.city='Aydın'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Dilek Yarımadası Büyük Menderes Deltası Milli Parkı$$) and p2.city='Aydın' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Didyma Apollon Tapınağı$$) and p.city='Aydın'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Didyma Apollon Tapınağı$$) and p2.city='Aydın' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Afrodisias$$) and p.city='Aydın'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Afrodisias$$) and p2.city='Aydın' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Priene Ören Yeri$$) and p.city='Aydın'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Priene Ören Yeri$$) and p2.city='Aydın' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Afrodisias Antik Kenti$$) and p.city='Aydın'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Afrodisias Antik Kenti$$) and p2.city='Aydın' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Afrodisias Antik Kenti Örenyeri$$) and p.city='Aydın'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Afrodisias Antik Kenti Örenyeri$$) and p2.city='Aydın' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Apollon Tapinagi$$) and p.city='Aydın'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Apollon Tapinagi$$) and p2.city='Aydın' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Didim$$) and p.city='Aydın'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Didim$$) and p2.city='Aydın' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Cunda Merkez$$) and p.city='Balıkesir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Cunda Merkez$$) and p2.city='Balıkesir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Cunda Taksiyarhis Kilisesi$$) and p.city='Balıkesir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Cunda Taksiyarhis Kilisesi$$) and p2.city='Balıkesir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kaz Dağları Milli Parkı$$) and p.city='Balıkesir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kaz Dağları Milli Parkı$$) and p2.city='Balıkesir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Manyas Kuş Cenneti$$) and p.city='Balıkesir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Manyas Kuş Cenneti$$) and p2.city='Balıkesir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Cunda Adası$$) and p.city='Balıkesir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Cunda Adası$$) and p2.city='Balıkesir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Şeytan Sofrası$$) and p.city='Balıkesir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Şeytan Sofrası$$) and p2.city='Balıkesir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Cunda Rahmi M. Koç Müzesi$$) and p.city='Balıkesir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Cunda Rahmi M. Koç Müzesi$$) and p2.city='Balıkesir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kaz dağları$$) and p.city='Balıkesir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kaz dağları$$) and p2.city='Balıkesir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Güzelcehisar Lav Sütunları$$) and p.city='Bartın'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Güzelcehisar Lav Sütunları$$) and p2.city='Bartın' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$İnkumu Plajı$$) and p.city='Bartın'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$İnkumu Plajı$$) and p2.city='Bartın' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$GÜZELCEHİSAR LAV SÜTUNLARI$$) and p.city='Bartın'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$GÜZELCEHİSAR LAV SÜTUNLARI$$) and p2.city='Bartın' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Güzelcehisar Plajı$$) and p.city='Bartın'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Güzelcehisar Plajı$$) and p2.city='Bartın' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Amasra Kalesi$$) and p.city='Bartın'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Amasra Kalesi$$) and p2.city='Bartın' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Amasra Müzesi$$) and p.city='Bartın'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Amasra Müzesi$$) and p2.city='Bartın' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Amasra Merkez$$) and p.city='Bartın'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Amasra Merkez$$) and p2.city='Bartın' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Hasankeyf$$) and p.city='Batman'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hasankeyf$$) and p2.city='Batman' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Hasankeyf Eski Köprü$$) and p.city='Batman'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hasankeyf Eski Köprü$$) and p2.city='Batman' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Hasankeyf Limanı$$) and p.city='Batman'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hasankeyf Limanı$$) and p2.city='Batman' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Hasankeyf müzesi$$) and p.city='Batman'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hasankeyf müzesi$$) and p2.city='Batman' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Hasankeyf Kalesi$$) and p.city='Batman'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hasankeyf Kalesi$$) and p2.city='Batman' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Hasankeyf Yeni Kültürel Park Alanı$$) and p.city='Batman'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hasankeyf Yeni Kültürel Park Alanı$$) and p2.city='Batman' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Bayburt Kalesi$$) and p.city='Bayburt'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Bayburt Kalesi$$) and p2.city='Bayburt' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Baksı Müzesi$$) and p.city='Bayburt'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Baksı Müzesi$$) and p2.city='Bayburt' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Aydıntepe Yeraltı Şehri$$) and p.city='Bayburt'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Aydıntepe Yeraltı Şehri$$) and p2.city='Bayburt' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Pelitözü Göleti$$) and p.city='Bilecik'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Pelitözü Göleti$$) and p2.city='Bilecik' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Harmankaya Kanyonu$$) and p.city='Bilecik'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Harmankaya Kanyonu$$) and p2.city='Bilecik' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Söğüt Ertuğrul Gazi Türbesi$$) and p.city='Bilecik'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Söğüt Ertuğrul Gazi Türbesi$$) and p2.city='Bilecik' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Şeyh Edebali Türbesi$$) and p.city='Bilecik'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Şeyh Edebali Türbesi$$) and p2.city='Bilecik' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Yüzen Adalar$$) and p.city='Bingöl'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Yüzen Adalar$$) and p2.city='Bingöl' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Bingöl Hesarek Kayak Merkezi$$) and p.city='Bingöl'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Bingöl Hesarek Kayak Merkezi$$) and p2.city='Bingöl' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Yüzen Adalar Tabiat Anıtı$$) and p.city='Bingöl'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Yüzen Adalar Tabiat Anıtı$$) and p2.city='Bingöl' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Kiğı Kalesi$$) and p.city='Bingöl'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kiğı Kalesi$$) and p2.city='Bingöl' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$El-Aman Kervansarayı$$) and p.city='Bitlis'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$El-Aman Kervansarayı$$) and p2.city='Bitlis' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$NEMRUT KRATER GÖLÜ$$) and p.city='Bitlis'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$NEMRUT KRATER GÖLÜ$$) and p2.city='Bitlis' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Ahlat Selçuklu Mezarlığı$$) and p.city='Bitlis'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ahlat Selçuklu Mezarlığı$$) and p2.city='Bitlis' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Bitlis Kalesi$$) and p.city='Bitlis'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Bitlis Kalesi$$) and p2.city='Bitlis' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Gölcük Tabiat Parkı$$) and p.city='Bolu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Gölcük Tabiat Parkı$$) and p2.city='Bolu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Abant Gölü Milli Parkı$$) and p.city='Bolu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Abant Gölü Milli Parkı$$) and p2.city='Bolu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Büyük Abant Oteli$$) and p.city='Bolu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Büyük Abant Oteli$$) and p2.city='Bolu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Yedigöller Şelalesi$$) and p.city='Bolu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Yedigöller Şelalesi$$) and p2.city='Bolu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Abant Tabiat Müzesi$$) and p.city='Bolu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Abant Tabiat Müzesi$$) and p2.city='Bolu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Yedigöller Milli Parkı$$) and p.city='Bolu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Yedigöller Milli Parkı$$) and p2.city='Bolu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Salda Gölü$$) and p.city='Burdur'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Salda Gölü$$) and p2.city='Burdur' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Salda Gölü Plajı$$) and p.city='Burdur'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Salda Gölü Plajı$$) and p2.city='Burdur' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Salda Gölü Tabiat Parkı$$) and p.city='Burdur'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Salda Gölü Tabiat Parkı$$) and p2.city='Burdur' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$SALDA GÖLÜ BELEDİYE HALK PLAJI$$) and p.city='Burdur'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$SALDA GÖLÜ BELEDİYE HALK PLAJI$$) and p2.city='Burdur' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Sagalassos$$) and p.city='Burdur'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sagalassos$$) and p2.city='Burdur' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$İnsuyu Mağarası$$) and p.city='Burdur'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$İnsuyu Mağarası$$) and p2.city='Burdur' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Sagalassos Örenyeri$$) and p.city='Burdur'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sagalassos Örenyeri$$) and p2.city='Burdur' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Sagalassos Antik Kenti$$) and p.city='Burdur'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sagalassos Antik Kenti$$) and p2.city='Burdur' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$İznik$$) and p.city='Bursa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$İznik$$) and p2.city='Bursa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Cumalıkızık Köyü$$) and p.city='Bursa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Cumalıkızık Köyü$$) and p2.city='Bursa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Cumalıkızık$$) and p.city='Bursa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Cumalıkızık$$) and p2.city='Bursa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Uludağ$$) and p.city='Bursa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Uludağ$$) and p2.city='Bursa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Cumalikizik$$) and p.city='Bursa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Cumalikizik$$) and p2.city='Bursa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Golyazi$$) and p.city='Bursa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Golyazi$$) and p2.city='Bursa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$İznik Gölü$$) and p.city='Bursa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$İznik Gölü$$) and p2.city='Bursa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Tirilye$$) and p.city='Bursa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tirilye$$) and p2.city='Bursa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Bursa Ulu Camii$$) and p.city='Bursa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Bursa Ulu Camii$$) and p2.city='Bursa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Assos Örenyeri$$) and p.city='Çanakkale'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Assos Örenyeri$$) and p2.city='Çanakkale' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Assos Antik Kenti$$) and p.city='Çanakkale'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Assos Antik Kenti$$) and p2.city='Çanakkale' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Troya Antik Kenti$$) and p.city='Çanakkale'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Troya Antik Kenti$$) and p2.city='Çanakkale' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Troya Müzesi$$) and p.city='Çanakkale'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Troya Müzesi$$) and p2.city='Çanakkale' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Bozcaada$$) and p.city='Çanakkale'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Bozcaada$$) and p2.city='Çanakkale' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Çankırı Taş Mescit$$) and p.city='Çankırı'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Çankırı Taş Mescit$$) and p2.city='Çankırı' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Çankırı Kalesi$$) and p.city='Çankırı'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Çankırı Kalesi$$) and p2.city='Çankırı' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Çankırı Tuz Mağarası$$) and p.city='Çankırı'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Çankırı Tuz Mağarası$$) and p2.city='Çankırı' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Ilgaz Dağı$$) and p.city='Çankırı'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ilgaz Dağı$$) and p2.city='Çankırı' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Alacahöyük$$) and p.city='Çorum'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Alacahöyük$$) and p2.city='Çorum' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Çorum Kalesi$$) and p.city='Çorum'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Çorum Kalesi$$) and p2.city='Çorum' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Hattuşa$$) and p.city='Çorum'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hattuşa$$) and p2.city='Çorum' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Alacahöyük Müzesi$$) and p.city='Çorum'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Alacahöyük Müzesi$$) and p2.city='Çorum' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Boğazköy-alacahöyük Milli Parkı$$) and p.city='Çorum'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Boğazköy-alacahöyük Milli Parkı$$) and p2.city='Çorum' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Hattuşaş Antik Kenti$$) and p.city='Çorum'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hattuşaş Antik Kenti$$) and p2.city='Çorum' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$İncesu Kanyonu$$) and p.city='Çorum'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$İncesu Kanyonu$$) and p2.city='Çorum' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Hattuşa Örenyeri$$) and p.city='Çorum'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hattuşa Örenyeri$$) and p2.city='Çorum' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Pamukkale Belediyesi Seyir Tepesi$$) and p.city='Denizli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Pamukkale Belediyesi Seyir Tepesi$$) and p2.city='Denizli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Pamukkale Travertenleri - Güney Kapı Otopark$$) and p.city='Denizli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Pamukkale Travertenleri - Güney Kapı Otopark$$) and p2.city='Denizli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kaklık Mağarası$$) and p.city='Denizli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kaklık Mağarası$$) and p2.city='Denizli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Denizli Hierapolis (Pamukkale) Ören yeri$$) and p.city='Denizli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Denizli Hierapolis (Pamukkale) Ören yeri$$) and p2.city='Denizli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Laodikya$$) and p.city='Denizli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Laodikya$$) and p2.city='Denizli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Hierapolis$$) and p.city='Denizli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hierapolis$$) and p2.city='Denizli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Pamukkale$$) and p.city='Denizli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Pamukkale$$) and p2.city='Denizli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Pamukkale Travertenleri$$) and p.city='Denizli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Pamukkale Travertenleri$$) and p2.city='Denizli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Ramada Resort by Wyndham Pamukkale Thermal$$) and p.city='Denizli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ramada Resort by Wyndham Pamukkale Thermal$$) and p2.city='Denizli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$On Gözlü Köprü$$) and p.city='Diyarbakır'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$On Gözlü Köprü$$) and p2.city='Diyarbakır' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Hasan Paşa Hanı$$) and p.city='Diyarbakır'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hasan Paşa Hanı$$) and p2.city='Diyarbakır' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Diyarbakır Surları$$) and p.city='Diyarbakır'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Diyarbakır Surları$$) and p2.city='Diyarbakır' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Güzeldere Şelalesi$$) and p.city='Düzce'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Güzeldere Şelalesi$$) and p2.city='Düzce' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Akçakoca$$) and p.city='Düzce'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Akçakoca$$) and p2.city='Düzce' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Samandere Şelalesi$$) and p.city='Düzce'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Samandere Şelalesi$$) and p2.city='Düzce' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Aydınpınar Şelalesi Tabiat Parkı$$) and p.city='Düzce'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Aydınpınar Şelalesi Tabiat Parkı$$) and p2.city='Düzce' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Akçakoca Merkez Camii$$) and p.city='Düzce'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Akçakoca Merkez Camii$$) and p2.city='Düzce' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Güzeldere Şelalesi Tabiat Parkı$$) and p.city='Düzce'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Güzeldere Şelalesi Tabiat Parkı$$) and p2.city='Düzce' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$SELİMİYE PALACE$$) and p.city='Edirne'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$SELİMİYE PALACE$$) and p2.city='Edirne' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Selimiye Camii$$) and p.city='Edirne'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Selimiye Camii$$) and p2.city='Edirne' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Meriç Köprüsü$$) and p.city='Edirne'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Meriç Köprüsü$$) and p2.city='Edirne' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Μουσείο Τέχνης Μεταξιού$$) and p.city='Edirne'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Μουσείο Τέχνης Μεταξιού$$) and p2.city='Edirne' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Selimiye Vakfı Müzesi$$) and p.city='Edirne'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Selimiye Vakfı Müzesi$$) and p2.city='Edirne' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Edirne Sarayı$$) and p.city='Edirne'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Edirne Sarayı$$) and p2.city='Edirne' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Saklıkapı Kanyonu$$) and p.city='Elazığ'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Saklıkapı Kanyonu$$) and p2.city='Elazığ' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Buzluk Mağarası$$) and p.city='Elazığ'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Buzluk Mağarası$$) and p2.city='Elazığ' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Hazar Gölü$$) and p.city='Elazığ'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hazar Gölü$$) and p2.city='Elazığ' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Harput Kalesi$$) and p.city='Elazığ'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Harput Kalesi$$) and p2.city='Elazığ' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Keban Baraj Gölü$$) and p.city='Elazığ'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Keban Baraj Gölü$$) and p2.city='Elazığ' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kemaliye$$) and p.city='Erzincan'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kemaliye$$) and p2.city='Erzincan' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Ergan Dağı$$) and p.city='Erzincan'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ergan Dağı$$) and p2.city='Erzincan' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Başpınar Vali Recep Yazıcıoğlu Köprüsü,Ocak Köyü/Kemaliye/Erzincan, Türkiye$$) and p.city='Erzincan'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Başpınar Vali Recep Yazıcıoğlu Köprüsü,Ocak Köyü/Kemaliye/Erzincan, Türkiye$$) and p2.city='Erzincan' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kemaliye Tarihi Kenti$$) and p.city='Erzincan'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kemaliye Tarihi Kenti$$) and p2.city='Erzincan' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Karanlık Kanyon$$) and p.city='Erzincan'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Karanlık Kanyon$$) and p2.city='Erzincan' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kemah Kalesi$$) and p.city='Erzincan'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kemah Kalesi$$) and p2.city='Erzincan' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Girlevik Şelalesi$$) and p.city='Erzincan'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Girlevik Şelalesi$$) and p2.city='Erzincan' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Altıntepe Ören Yeri$$) and p.city='Erzincan'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Altıntepe Ören Yeri$$) and p2.city='Erzincan' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Polat Palandöken$$) and p.city='Erzurum'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Polat Palandöken$$) and p2.city='Erzurum' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Dedeman Palandoken Ski Lodge$$) and p.city='Erzurum'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Dedeman Palandoken Ski Lodge$$) and p2.city='Erzurum' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Dedeman Palandöken$$) and p.city='Erzurum'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Dedeman Palandöken$$) and p2.city='Erzurum' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Palandöken Kayak Merkezi$$) and p.city='Erzurum'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Palandöken Kayak Merkezi$$) and p2.city='Erzurum' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Tortum Şelalesi$$) and p.city='Erzurum'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tortum Şelalesi$$) and p2.city='Erzurum' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Çifte Minareli Medrese$$) and p.city='Erzurum'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Çifte Minareli Medrese$$) and p2.city='Erzurum' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Porsuk Cayi$$) and p.city='Eskişehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Porsuk Cayi$$) and p2.city='Eskişehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Tarihi Odunpazarı Evleri$$) and p.city='Eskişehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tarihi Odunpazarı Evleri$$) and p2.city='Eskişehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Odunpazarı Evleri$$) and p.city='Eskişehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Odunpazarı Evleri$$) and p2.city='Eskişehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Eskişehir Odunpazarı Evleri$$) and p.city='Eskişehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Eskişehir Odunpazarı Evleri$$) and p2.city='Eskişehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Odunpazari Evleri$$) and p.city='Eskişehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Odunpazari Evleri$$) and p2.city='Eskişehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Porsuk Çayı$$) and p.city='Eskişehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Porsuk Çayı$$) and p2.city='Eskişehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Odunpazarı Modern Müze (OMM)$$) and p.city='Eskişehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Odunpazarı Modern Müze (OMM)$$) and p2.city='Eskişehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Zeugma Antik Kenti$$) and p.city='Gaziantep'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Zeugma Antik Kenti$$) and p2.city='Gaziantep' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Zeugma Mozaik Müzesi$$) and p.city='Gaziantep'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Zeugma Mozaik Müzesi$$) and p2.city='Gaziantep' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Bakırcılar Çarşısı$$) and p.city='Gaziantep'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Bakırcılar Çarşısı$$) and p2.city='Gaziantep' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Gaziantep Kalesi$$) and p.city='Gaziantep'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Gaziantep Kalesi$$) and p2.city='Gaziantep' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Mavi Göl$$) and p.city='Giresun'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Mavi Göl$$) and p2.city='Giresun' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Giresun Adası$$) and p.city='Giresun'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Giresun Adası$$) and p2.city='Giresun' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kulakkaya Yaylası Giresun$$) and p.city='Giresun'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kulakkaya Yaylası Giresun$$) and p2.city='Giresun' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Mavigöl$$) and p.city='Giresun'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Mavigöl$$) and p2.city='Giresun' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Giresun Adası Botanik Bahçesi$$) and p.city='Giresun'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Giresun Adası Botanik Bahçesi$$) and p2.city='Giresun' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Limni Gölü$$) and p.city='Gümüşhane'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Limni Gölü$$) and p2.city='Gümüşhane' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Limni Gölü Tabiat Parkı$$) and p.city='Gümüşhane'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Limni Gölü Tabiat Parkı$$) and p2.city='Gümüşhane' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Torul Cam Teras$$) and p.city='Gümüşhane'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Torul Cam Teras$$) and p2.city='Gümüşhane' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Karaca Mağarası$$) and p.city='Gümüşhane'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Karaca Mağarası$$) and p2.city='Gümüşhane' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Meydan Medresesi$$) and p.city='Hakkari'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Meydan Medresesi$$) and p2.city='Hakkari' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$شيرانك$$) and p.city='Hakkari'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$شيرانك$$) and p2.city='Hakkari' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Cilo Dağları$$) and p.city='Hakkari'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Cilo Dağları$$) and p2.city='Hakkari' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Sat Gölleri$$) and p.city='Hakkari'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sat Gölleri$$) and p2.city='Hakkari' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Harbiye Şelaleleri$$) and p.city='Hatay'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Harbiye Şelaleleri$$) and p2.city='Hatay' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Hatay Arkeoloji Müzesi$$) and p.city='Hatay'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hatay Arkeoloji Müzesi$$) and p2.city='Hatay' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Antakya Uzun Çarşı$$) and p.city='Hatay'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Antakya Uzun Çarşı$$) and p2.city='Hatay' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Harbiye Şelalesi$$) and p.city='Hatay'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Harbiye Şelalesi$$) and p2.city='Hatay' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$St. Pierre Kilisesi$$) and p.city='Hatay'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$St. Pierre Kilisesi$$) and p2.city='Hatay' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kasımcan Kervansarayı$$) and p.city='Iğdır'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kasımcan Kervansarayı$$) and p2.city='Iğdır' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Tuzluca Tuz Mağaraları$$) and p.city='Iğdır'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tuzluca Tuz Mağaraları$$) and p2.city='Iğdır' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Tuzluca Tuz Mağarası$$) and p.city='Iğdır'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tuzluca Tuz Mağarası$$) and p2.city='Iğdır' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$TUZLUCA GÖKKUŞAĞI TEPELERİ$$) and p.city='Iğdır'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$TUZLUCA GÖKKUŞAĞI TEPELERİ$$) and p2.city='Iğdır' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Karakale$$) and p.city='Iğdır'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Karakale$$) and p2.city='Iğdır' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Lavanta Bahçeleri$$) and p.city='Isparta'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Lavanta Bahçeleri$$) and p2.city='Isparta' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Isparta Lavanta Köyü | Lavanta Garden ( lavender )$$) and p.city='Isparta'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Isparta Lavanta Köyü | Lavanta Garden ( lavender )$$) and p2.city='Isparta' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Lavanta diyari$$) and p.city='Isparta'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Lavanta diyari$$) and p2.city='Isparta' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kovada Gölü$$) and p.city='Isparta'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kovada Gölü$$) and p2.city='Isparta' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Ispartamdan (Kuyucak Isparta Lavanta Köyü)$$) and p.city='Isparta'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ispartamdan (Kuyucak Isparta Lavanta Köyü)$$) and p2.city='Isparta' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Eğirdir Gölü$$) and p.city='Isparta'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Eğirdir Gölü$$) and p2.city='Isparta' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Topkapı Sarayı$$) and p.city='İstanbul'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Topkapı Sarayı$$) and p2.city='İstanbul' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Ayasofya$$) and p.city='İstanbul'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ayasofya$$) and p2.city='İstanbul' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kız Kulesi$$) and p.city='İstanbul'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kız Kulesi$$) and p2.city='İstanbul' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Galata Kulesi$$) and p.city='İstanbul'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Galata Kulesi$$) and p2.city='İstanbul' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Fener Balat$$) and p.city='İstanbul'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Fener Balat$$) and p2.city='İstanbul' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Bergama Akropolü$$) and p.city='İzmir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Bergama Akropolü$$) and p2.city='İzmir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Şirince$$) and p.city='İzmir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Şirince$$) and p2.city='İzmir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Alaçatı$$) and p.city='İzmir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Alaçatı$$) and p2.city='İzmir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Asansör$$) and p.city='İzmir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Asansör$$) and p2.city='İzmir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kordon$$) and p.city='İzmir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kordon$$) and p2.city='İzmir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Asklepion$$) and p.city='İzmir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Asklepion$$) and p2.city='İzmir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Çeşme Kalesi$$) and p.city='İzmir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Çeşme Kalesi$$) and p2.city='İzmir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Klaros$$) and p.city='İzmir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Klaros$$) and p2.city='İzmir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$İzmir Agora$$) and p.city='İzmir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$İzmir Agora$$) and p2.city='İzmir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kahramanmaraş Kalesi$$) and p.city='Kahramanmaraş'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kahramanmaraş Kalesi$$) and p2.city='Kahramanmaraş' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Ali Kayası$$) and p.city='Kahramanmaraş'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ali Kayası$$) and p2.city='Kahramanmaraş' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kapalı çarşı girişi$$) and p.city='Kahramanmaraş'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kapalı çarşı girişi$$) and p2.city='Kahramanmaraş' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kapalı Çarşı$$) and p.city='Kahramanmaraş'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kapalı Çarşı$$) and p2.city='Kahramanmaraş' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Ali Kayası Cam Terası$$) and p.city='Kahramanmaraş'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ali Kayası Cam Terası$$) and p2.city='Kahramanmaraş' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Safranbolu Eski Çarşı$$) and p.city='Karabük'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Safranbolu Eski Çarşı$$) and p2.city='Karabük' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Yörük Köyü Safranbolu$$) and p.city='Karabük'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Yörük Köyü Safranbolu$$) and p2.city='Karabük' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Cam Teras Safranbolu$$) and p.city='Karabük'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Cam Teras Safranbolu$$) and p2.city='Karabük' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Safranbolu Evleri$$) and p.city='Karabük'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Safranbolu Evleri$$) and p2.city='Karabük' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Tokatlı Kanyonu$$) and p.city='Karabük'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tokatlı Kanyonu$$) and p2.city='Karabük' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Bulak Mencilis Mağarası$$) and p.city='Karabük'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Bulak Mencilis Mağarası$$) and p2.city='Karabük' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Yeşildere Kanyonu$$) and p.city='Karaman'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Yeşildere Kanyonu$$) and p2.city='Karaman' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Taşkale Manazan Mağaraları$$) and p.city='Karaman'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Taşkale Manazan Mağaraları$$) and p2.city='Karaman' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Karaman Kalesi$$) and p.city='Karaman'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Karaman Kalesi$$) and p2.city='Karaman' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Binbir Kilise$$) and p.city='Karaman'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Binbir Kilise$$) and p2.city='Karaman' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Sarıkamış Kayak Merkezi$$) and p.city='Kars'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sarıkamış Kayak Merkezi$$) and p2.city='Kars' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Boğatepe Köyü$$) and p.city='Kars'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Boğatepe Köyü$$) and p2.city='Kars' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kars Kalesi$$) and p.city='Kars'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kars Kalesi$$) and p2.city='Kars' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Ani Harabeleri$$) and p.city='Kars'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ani Harabeleri$$) and p2.city='Kars' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Ilgaz Dağı Milli Parkı$$) and p.city='Kastamonu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ilgaz Dağı Milli Parkı$$) and p2.city='Kastamonu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Küre Dağları$$) and p.city='Kastamonu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Küre Dağları$$) and p2.city='Kastamonu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Ilıca Şelalesi$$) and p.city='Kastamonu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ilıca Şelalesi$$) and p2.city='Kastamonu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Valla Kanyonu$$) and p.city='Kastamonu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Valla Kanyonu$$) and p2.city='Kastamonu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Ilgaz Yurduntepe Kayak Merkezi$$) and p.city='Kastamonu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ilgaz Yurduntepe Kayak Merkezi$$) and p2.city='Kastamonu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Valla Kanyonu Milli Park Giriş Yeri$$) and p.city='Kastamonu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Valla Kanyonu Milli Park Giriş Yeri$$) and p2.city='Kastamonu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Rıfat Ilgaz Evi$$) and p.city='Kastamonu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Rıfat Ilgaz Evi$$) and p2.city='Kastamonu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kastamonu Kalesi$$) and p.city='Kastamonu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kastamonu Kalesi$$) and p2.city='Kastamonu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Mimar Sinan Evi$$) and p.city='Kayseri'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Mimar Sinan Evi$$) and p2.city='Kayseri' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Sultan Sazlığı$$) and p.city='Kayseri'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sultan Sazlığı$$) and p2.city='Kayseri' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Erciyes Kayak Merkezi$$) and p.city='Kayseri'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Erciyes Kayak Merkezi$$) and p2.city='Kayseri' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Hunat Hatun Külliyesi$$) and p.city='Kayseri'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hunat Hatun Külliyesi$$) and p2.city='Kayseri' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Kapuzbaşı Şelaleleri$$) and p.city='Kayseri'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kapuzbaşı Şelaleleri$$) and p2.city='Kayseri' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kilis Kalesi$$) and p.city='Kilis'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kilis Kalesi$$) and p2.city='Kilis' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kilis Ulu Camii$$) and p.city='Kilis'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kilis Ulu Camii$$) and p2.city='Kilis' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$KİLİS MÜZESİ$$) and p.city='Kilis'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$KİLİS MÜZESİ$$) and p2.city='Kilis' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Ravanda Kalesi$$) and p.city='Kilis'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ravanda Kalesi$$) and p2.city='Kilis' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Hasandede Camii$$) and p.city='Kırıkkale'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hasandede Camii$$) and p2.city='Kırıkkale' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$MKE Silah Sanayi Müzesi$$) and p.city='Kırıkkale'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$MKE Silah Sanayi Müzesi$$) and p2.city='Kırıkkale' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$İğneada Plajı$$) and p.city='Kırklareli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$İğneada Plajı$$) and p2.city='Kırklareli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$İğneada Feneri$$) and p.city='Kırklareli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$İğneada Feneri$$) and p2.city='Kırklareli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Dupnisa Mağarası$$) and p.city='Kırklareli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Dupnisa Mağarası$$) and p2.city='Kırklareli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$İğneada Longoz Ormanları$$) and p.city='Kırklareli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$İğneada Longoz Ormanları$$) and p2.city='Kırklareli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Ahi Evran Türbesi$$) and p.city='Kırşehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ahi Evran Türbesi$$) and p2.city='Kırşehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kırşehir Ahilik Müzesi$$) and p.city='Kırşehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kırşehir Ahilik Müzesi$$) and p2.city='Kırşehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Cacabey Medresesi$$) and p.city='Kırşehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Cacabey Medresesi$$) and p2.city='Kırşehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Seyfe Gölü$$) and p.city='Kırşehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Seyfe Gölü$$) and p2.city='Kırşehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Dedeman Kartepe Kocaeli$$) and p.city='Kocaeli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Dedeman Kartepe Kocaeli$$) and p2.city='Kocaeli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kartepe Teleferik$$) and p.city='Kocaeli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kartepe Teleferik$$) and p2.city='Kocaeli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kartepe$$) and p.city='Kocaeli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kartepe$$) and p2.city='Kocaeli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kartepe Seyir Tepesi$$) and p.city='Kocaeli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kartepe Seyir Tepesi$$) and p2.city='Kocaeli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Ormanya$$) and p.city='Kocaeli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ormanya$$) and p2.city='Kocaeli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Seka Park$$) and p.city='Kocaeli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Seka Park$$) and p2.city='Kocaeli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Sille Seyir Tepesi$$) and p.city='Konya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sille Seyir Tepesi$$) and p2.city='Konya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Çatalhöyük$$) and p.city='Konya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Çatalhöyük$$) and p2.city='Konya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Sille$$) and p.city='Konya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sille$$) and p2.city='Konya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Sille Aya Elenia Kilisesi$$) and p.city='Konya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sille Aya Elenia Kilisesi$$) and p2.city='Konya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Çatalhöyük Neolitik Kenti$$) and p.city='Konya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Çatalhöyük Neolitik Kenti$$) and p2.city='Konya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Mevlana Müzesi$$) and p.city='Konya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Mevlana Müzesi$$) and p2.city='Konya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Tuz Gölü$$) and p.city='Konya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tuz Gölü$$) and p2.city='Konya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Dumlupınar Zafertepe Anıtı$$) and p.city='Kütahya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Dumlupınar Zafertepe Anıtı$$) and p2.city='Kütahya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kütahya Çini Müzesi$$) and p.city='Kütahya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kütahya Çini Müzesi$$) and p2.city='Kütahya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Aizanoi Antik Kenti$$) and p.city='Kütahya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Aizanoi Antik Kenti$$) and p2.city='Kütahya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Germiyan Sokağı$$) and p.city='Kütahya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Germiyan Sokağı$$) and p2.city='Kütahya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Somuncu Baba Külliyesi$$) and p.city='Malatya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Somuncu Baba Külliyesi$$) and p2.city='Malatya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Battalgazi Ulu Camii$$) and p.city='Malatya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Battalgazi Ulu Camii$$) and p2.city='Malatya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Levent Vadisi$$) and p.city='Malatya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Levent Vadisi$$) and p2.city='Malatya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Levent Vadisi Seyir Terası$$) and p.city='Malatya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Levent Vadisi Seyir Terası$$) and p2.city='Malatya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Arslantepe Höyüğü$$) and p.city='Malatya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Arslantepe Höyüğü$$) and p2.city='Malatya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Sardes Antik Kenti$$) and p.city='Manisa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sardes Antik Kenti$$) and p2.city='Manisa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Ağlayan Kaya$$) and p.city='Manisa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ağlayan Kaya$$) and p2.city='Manisa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Niobe Ağlayan Kaya$$) and p.city='Manisa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Niobe Ağlayan Kaya$$) and p2.city='Manisa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Sardes Antik Kenti - Manisa$$) and p.city='Manisa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sardes Antik Kenti - Manisa$$) and p2.city='Manisa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Spil Dağı Milli Parkı$$) and p.city='Manisa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Spil Dağı Milli Parkı$$) and p2.city='Manisa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Dara Antik Kenti$$) and p.city='Mardin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Dara Antik Kenti$$) and p2.city='Mardin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Midyat Konukevi$$) and p.city='Mardin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Midyat Konukevi$$) and p2.city='Mardin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Deyrulzafaran Süryani Manastırı$$) and p.city='Mardin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Deyrulzafaran Süryani Manastırı$$) and p2.city='Mardin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Deyrulzafaran Manastırı$$) and p.city='Mardin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Deyrulzafaran Manastırı$$) and p2.city='Mardin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Dara Antik Kenti Batı Yeraltı Su Sarnıcı$$) and p.city='Mardin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Dara Antik Kenti Batı Yeraltı Su Sarnıcı$$) and p2.city='Mardin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Mardin Eski Şehir$$) and p.city='Mardin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Mardin Eski Şehir$$) and p2.city='Mardin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kızkalesi$$) and p.city='Mersin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kızkalesi$$) and p2.city='Mersin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Tarsus Şelalesi$$) and p.city='Mersin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tarsus Şelalesi$$) and p2.city='Mersin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kanlıdivane$$) and p.city='Mersin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kanlıdivane$$) and p2.city='Mersin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kızkalesi Halk Plajı$$) and p.city='Mersin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kızkalesi Halk Plajı$$) and p2.city='Mersin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Cennet Cehennem Sinkholes$$) and p.city='Mersin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Cennet Cehennem Sinkholes$$) and p2.city='Mersin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Cennet Cehennem Obrukları$$) and p.city='Mersin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Cennet Cehennem Obrukları$$) and p2.city='Mersin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kizkalesi Beach Walk$$) and p.city='Mersin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kizkalesi Beach Walk$$) and p2.city='Mersin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Tarsus Selalesi$$) and p.city='Mersin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tarsus Selalesi$$) and p2.city='Mersin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kizkalesi$$) and p.city='Mersin'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kizkalesi$$) and p2.city='Mersin' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Saklıkent$$) and p.city='Muğla'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Saklıkent$$) and p2.city='Muğla' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Ölüdeniz$$) and p.city='Muğla'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ölüdeniz$$) and p2.city='Muğla' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kelebekler Vadisi$$) and p.city='Muğla'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kelebekler Vadisi$$) and p2.city='Muğla' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kayaköy$$) and p.city='Muğla'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kayaköy$$) and p2.city='Muğla' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Oludeniz$$) and p.city='Muğla'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Oludeniz$$) and p2.city='Muğla' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Kabak Koyu$$) and p.city='Muğla'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kabak Koyu$$) and p2.city='Muğla' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Malazgirt Meydan Muharebesi TMP (1)$$) and p.city='Muş'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Malazgirt Meydan Muharebesi TMP (1)$$) and p2.city='Muş' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Malazgirt Müzesi$$) and p.city='Muş'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Malazgirt Müzesi$$) and p2.city='Muş' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Malazgirt Kalesi$$) and p.city='Muş'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Malazgirt Kalesi$$) and p2.city='Muş' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$26 Ağustos 1071 Malazğirt Zafer Anıtı$$) and p.city='Muş'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$26 Ağustos 1071 Malazğirt Zafer Anıtı$$) and p2.city='Muş' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Hamurpet Gölü$$) and p.city='Muş'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hamurpet Gölü$$) and p2.city='Muş' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Malazgirt Meydan Muharebesi Alanı$$) and p.city='Muş'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Malazgirt Meydan Muharebesi Alanı$$) and p2.city='Muş' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Avanos$$) and p.city='Nevşehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Avanos$$) and p2.city='Nevşehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Paşabağları$$) and p.city='Nevşehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Paşabağları$$) and p2.city='Nevşehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Göreme Açık Hava Müzesi$$) and p.city='Nevşehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Göreme Açık Hava Müzesi$$) and p2.city='Nevşehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Goreme Acik Hava Muzesi$$) and p.city='Nevşehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Goreme Acik Hava Muzesi$$) and p2.city='Nevşehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Üç Güzeller$$) and p.city='Nevşehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Üç Güzeller$$) and p2.city='Nevşehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kapadokya$$) and p.city='Nevşehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kapadokya$$) and p2.city='Nevşehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Kozaklı Kaplıcaları$$) and p.city='Nevşehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kozaklı Kaplıcaları$$) and p2.city='Nevşehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Güvercinlik Vadisi$$) and p.city='Nevşehir'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Güvercinlik Vadisi$$) and p2.city='Nevşehir' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Aladağlar Camping Bungalow Climber’s House$$) and p.city='Niğde'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Aladağlar Camping Bungalow Climber’s House$$) and p2.city='Niğde' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Aladağlar Milli Parkı$$) and p.city='Niğde'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Aladağlar Milli Parkı$$) and p2.city='Niğde' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Gümüşler Manastırı$$) and p.city='Niğde'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Gümüşler Manastırı$$) and p2.city='Niğde' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Tyana Antik Kenti$$) and p.city='Niğde'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tyana Antik Kenti$$) and p2.city='Niğde' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Ulugöl$$) and p.city='Ordu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ulugöl$$) and p2.city='Ordu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Boztepe$$) and p.city='Ordu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Boztepe$$) and p2.city='Ordu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Ulugöl Tabiat Parkı$$) and p.city='Ordu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ulugöl Tabiat Parkı$$) and p2.city='Ordu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Yason Burnu$$) and p.city='Ordu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Yason Burnu$$) and p2.city='Ordu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Yason Burnu Feneri$$) and p.city='Ordu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Yason Burnu Feneri$$) and p2.city='Ordu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Boztepe Teleferik$$) and p.city='Ordu'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Boztepe Teleferik$$) and p2.city='Ordu' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Karatepe Aslantaş Milli Parkı$$) and p.city='Osmaniye'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Karatepe Aslantaş Milli Parkı$$) and p2.city='Osmaniye' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Karatepe-Aslantaş$$) and p.city='Osmaniye'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Karatepe-Aslantaş$$) and p2.city='Osmaniye' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Toprakkale Kalesi$$) and p.city='Osmaniye'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Toprakkale Kalesi$$) and p2.city='Osmaniye' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Kastabala Antik Kenti$$) and p.city='Osmaniye'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kastabala Antik Kenti$$) and p2.city='Osmaniye' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Karatepe Aslantaş Açık Hava Müzesi$$) and p.city='Osmaniye'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Karatepe Aslantaş Açık Hava Müzesi$$) and p2.city='Osmaniye' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Pokut Yaylası$$) and p.city='Rize'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Pokut Yaylası$$) and p2.city='Rize' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$شلال اوسميت اوغلو$$) and p.city='Rize'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$شلال اوسميت اوغلو$$) and p2.city='Rize' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Ayder Yaylası$$) and p.city='Rize'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ayder Yaylası$$) and p2.city='Rize' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$POKUT$$) and p.city='Rize'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$POKUT$$) and p2.city='Rize' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Zil Kale$$) and p.city='Rize'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Zil Kale$$) and p2.city='Rize' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Fırtına Vadisi$$) and p.city='Rize'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Fırtına Vadisi$$) and p2.city='Rize' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Maden Deresi Pamuk Ana Çiftliği Mesire Alanı$$) and p.city='Sakarya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Maden Deresi Pamuk Ana Çiftliği Mesire Alanı$$) and p2.city='Sakarya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$KOCAALİ Maden Deresi$$) and p.city='Sakarya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$KOCAALİ Maden Deresi$$) and p2.city='Sakarya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Sapanca Gölü$$) and p.city='Sakarya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sapanca Gölü$$) and p2.city='Sakarya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Sapanca Gölü Yürüyüş Yolu$$) and p.city='Sakarya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sapanca Gölü Yürüyüş Yolu$$) and p2.city='Sakarya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Acarlar Longozu$$) and p.city='Sakarya'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Acarlar Longozu$$) and p2.city='Sakarya' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Vezirköprü Şahinkaya Kanyonu Kanyon2 Tekne Turu$$) and p.city='Samsun'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Vezirköprü Şahinkaya Kanyonu Kanyon2 Tekne Turu$$) and p2.city='Samsun' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Bandırma Vapuru$$) and p.city='Samsun'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Bandırma Vapuru$$) and p2.city='Samsun' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Amisos Tepesi$$) and p.city='Samsun'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Amisos Tepesi$$) and p2.city='Samsun' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Şahinkaya Kanyonu Gezisi - Çataloğlu Turizm$$) and p.city='Samsun'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Şahinkaya Kanyonu Gezisi - Çataloğlu Turizm$$) and p2.city='Samsun' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Şahinkaya Kanyonu$$) and p.city='Samsun'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Şahinkaya Kanyonu$$) and p2.city='Samsun' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Bandırma Vapuru Müzesi$$) and p.city='Samsun'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Bandırma Vapuru Müzesi$$) and p2.city='Samsun' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Karahantepe$$) and p.city='Şanlıurfa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Karahantepe$$) and p2.city='Şanlıurfa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Şanlıurfa Kalesi$$) and p.city='Şanlıurfa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Şanlıurfa Kalesi$$) and p2.city='Şanlıurfa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Tarihi Harran Firdevs Ulucami$$) and p.city='Şanlıurfa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tarihi Harran Firdevs Ulucami$$) and p2.city='Şanlıurfa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Harran Kültür Evi$$) and p.city='Şanlıurfa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Harran Kültür Evi$$) and p2.city='Şanlıurfa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Harran Evi$$) and p.city='Şanlıurfa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Harran Evi$$) and p2.city='Şanlıurfa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Harran Evleri$$) and p.city='Şanlıurfa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Harran Evleri$$) and p2.city='Şanlıurfa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Göbeklitepe$$) and p.city='Şanlıurfa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Göbeklitepe$$) and p2.city='Şanlıurfa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Balıklıgöl$$) and p.city='Şanlıurfa'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Balıklıgöl$$) and p2.city='Şanlıurfa' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Botan Vadisi$$) and p.city='Siirt'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Botan Vadisi$$) and p2.city='Siirt' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Hz.Veysel Karani Tabiat Parkı$$) and p.city='Siirt'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hz.Veysel Karani Tabiat Parkı$$) and p2.city='Siirt' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Tillo (Aydınlar)$$) and p.city='Siirt'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tillo (Aydınlar)$$) and p2.city='Siirt' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Botan Vadisi Milli Parkı$$) and p.city='Siirt'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Botan Vadisi Milli Parkı$$) and p2.city='Siirt' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Tillo Kale$$) and p.city='Siirt'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tillo Kale$$) and p2.city='Siirt' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Tillo Tabiat Parkı$$) and p.city='Siirt'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tillo Tabiat Parkı$$) and p2.city='Siirt' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Hamsilos Tabiat Parkı$$) and p.city='Sinop'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hamsilos Tabiat Parkı$$) and p2.city='Sinop' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$İnceburun$$) and p.city='Sinop'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$İnceburun$$) and p2.city='Sinop' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Hamsilos Koyu$$) and p.city='Sinop'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Hamsilos Koyu$$) and p2.city='Sinop' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Sinop Tarihi Cezaevi$$) and p.city='Sinop'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sinop Tarihi Cezaevi$$) and p2.city='Sinop' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Tödürge Gölü$$) and p.city='Sivas'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tödürge Gölü$$) and p2.city='Sivas' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Divriği Ulu Camii$$) and p.city='Sivas'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Divriği Ulu Camii$$) and p2.city='Sivas' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Gök Medrese$$) and p.city='Sivas'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Gök Medrese$$) and p2.city='Sivas' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$..$$) and p.city='Sivas'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$..$$) and p2.city='Sivas' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Divriği Ulu Camii ve Darüşşifası$$) and p.city='Sivas'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Divriği Ulu Camii ve Darüşşifası$$) and p2.city='Sivas' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Kangal Balıklı Kaplıca$$) and p.city='Sivas'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kangal Balıklı Kaplıca$$) and p2.city='Sivas' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Kasrik Boğazı$$) and p.city='Şırnak'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Kasrik Boğazı$$) and p2.city='Şırnak' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Cizre Nuh Peygamber Türbesi$$) and p.city='Şırnak'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Cizre Nuh Peygamber Türbesi$$) and p2.city='Şırnak' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Cudi Dağı$$) and p.city='Şırnak'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Cudi Dağı$$) and p2.city='Şırnak' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Şarköy Plajı$$) and p.city='Tekirdağ'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Şarköy Plajı$$) and p2.city='Tekirdağ' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Rakoczi Müzesi$$) and p.city='Tekirdağ'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Rakoczi Müzesi$$) and p2.city='Tekirdağ' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$ŞARKÖY İSKELESİ$$) and p.city='Tekirdağ'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$ŞARKÖY İSKELESİ$$) and p2.city='Tekirdağ' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Uçmakdere$$) and p.city='Tekirdağ'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Uçmakdere$$) and p2.city='Tekirdağ' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Tokat Kalesi$$) and p.city='Tokat'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Tokat Kalesi$$) and p2.city='Tokat' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Ballıca Mağarası Tabiat Parkı$$) and p.city='Tokat'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ballıca Mağarası Tabiat Parkı$$) and p2.city='Tokat' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Ballıca Mağarası$$) and p.city='Tokat'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ballıca Mağarası$$) and p2.city='Tokat' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Sulusaray Sebastopolis$$) and p.city='Tokat'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sulusaray Sebastopolis$$) and p2.city='Tokat' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Sumela Manastiri$$) and p.city='Trabzon'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sumela Manastiri$$) and p2.city='Trabzon' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Uzungöl Seyir Terası$$) and p.city='Trabzon'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Uzungöl Seyir Terası$$) and p2.city='Trabzon' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$شاطئ جانيتا$$) and p.city='Trabzon'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$شاطئ جانيتا$$) and p2.city='Trabzon' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Sümela Manastırı$$) and p.city='Trabzon'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sümela Manastırı$$) and p2.city='Trabzon' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$UZUNGÖL$$) and p.city='Trabzon'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$UZUNGÖL$$) and p2.city='Trabzon' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Atatürk Köşkü$$) and p.city='Trabzon'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Atatürk Köşkü$$) and p2.city='Trabzon' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Pülümür Vadisi$$) and p.city='Tunceli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Pülümür Vadisi$$) and p2.city='Tunceli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Pertek Kalesi$$) and p.city='Tunceli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Pertek Kalesi$$) and p2.city='Tunceli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Munzur Vadisi Milli Parkı$$) and p.city='Tunceli'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Munzur Vadisi Milli Parkı$$) and p2.city='Tunceli' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Ulubey Kanyonu$$) and p.city='Uşak'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ulubey Kanyonu$$) and p2.city='Uşak' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Clandras Köprüsü$$) and p.city='Uşak'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Clandras Köprüsü$$) and p2.city='Uşak' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Blaundus Antik Kenti$$) and p.city='Uşak'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Blaundus Antik Kenti$$) and p2.city='Uşak' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Ulubey Kanyonu Tabiat Parkı$$) and p.city='Uşak'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Ulubey Kanyonu Tabiat Parkı$$) and p2.city='Uşak' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Akdamar Adası$$) and p.city='Van'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Akdamar Adası$$) and p2.city='Van' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Çavuştepe Kalesi$$) and p.city='Van'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Çavuştepe Kalesi$$) and p2.city='Van' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Akdamar İskelesi$$) and p.city='Van'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Akdamar İskelesi$$) and p2.city='Van' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Akdamar Adası Kilisesi$$) and p.city='Van'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Akdamar Adası Kilisesi$$) and p2.city='Van' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Muradiye Şelalesi$$) and p.city='Van'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Muradiye Şelalesi$$) and p2.city='Van' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Van Kalesi$$) and p.city='Van'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Van Kalesi$$) and p2.city='Van' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Van Gölü$$) and p.city='Van'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Van Gölü$$) and p2.city='Van' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Termal Kaplıcaları$$) and p.city='Yalova'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Termal Kaplıcaları$$) and p2.city='Yalova' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Yürüyen Köşk$$) and p.city='Yalova'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Yürüyen Köşk$$) and p2.city='Yalova' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Sudüşen Şelalesi$$) and p.city='Yalova'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sudüşen Şelalesi$$) and p2.city='Yalova' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Çapanoğlu Camii$$) and p.city='Yozgat'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Çapanoğlu Camii$$) and p2.city='Yozgat' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Aydıncık Kazankaya Kanyonu$$) and p.city='Yozgat'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Aydıncık Kazankaya Kanyonu$$) and p2.city='Yozgat' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Sarıkaya Roma Hamamı$$) and p.city='Yozgat'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Sarıkaya Roma Hamamı$$) and p2.city='Yozgat' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',50,true
from pois p where lower(p.name)=lower($$Çamlık Milli Parkı$$) and p.city='Yozgat'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Çamlık Milli Parkı$$) and p2.city='Yozgat' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',35,true
from pois p where lower(p.name)=lower($$Filyos Antik Kenti$$) and p.city='Zonguldak'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Filyos Antik Kenti$$) and p2.city='Zonguldak' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Filyos Plaji$$) and p.city='Zonguldak'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Filyos Plaji$$) and p2.city='Zonguldak' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Gökgöl Mağarası$$) and p.city='Zonguldak'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Gökgöl Mağarası$$) and p2.city='Zonguldak' and f.is_active) limit 1;
insert into featured_places (place_id,city_id,title,subtitle,sort_order,is_active)
select p.id,(select ci.id from cities ci where ci.name=p.city limit 1),p.name,'Olmazsa olmaz',40,true
from pois p where lower(p.name)=lower($$Filyos Kalesi$$) and p.city='Zonguldak'
  and not exists (select 1 from featured_places f join pois p2 on p2.id=f.place_id
    where lower(p2.name)=lower($$Filyos Kalesi$$) and p2.city='Zonguldak' and f.is_active) limit 1;

commit;
