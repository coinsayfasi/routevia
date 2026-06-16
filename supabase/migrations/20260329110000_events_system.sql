-- ═══════════════════════════════════════════════════════════════════════════
-- Events System — Festival & Etkinlik Altyapısı
-- Migration: 20260329110000_events_system.sql
-- ═══════════════════════════════════════════════════════════════════════════

-- ── events tablosu ──────────────────────────────────────────────────────────
CREATE TABLE public.events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  province_id uuid NOT NULL REFERENCES public.provinces(id) ON DELETE CASCADE,
  province_name text NOT NULL,
  district text,
  name text NOT NULL,
  slug text NOT NULL,
  description text,
  month_start int NOT NULL CHECK (month_start BETWEEN 1 AND 12),
  month_end int NOT NULL CHECK (month_end BETWEEN 1 AND 12),
  category text NOT NULL CHECK (category IN ('festival','müzik','kültür','yemek','spor','sanat','doğa','geleneksel')),
  is_recurring bool NOT NULL DEFAULT true,
  tags text[] DEFAULT '{}',
  lat double precision,
  lng double precision,
  source_url text,
  is_active bool NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (province_id, slug)
);

-- RLS
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "events_read_all" ON public.events FOR SELECT USING (is_active = true);
CREATE POLICY "events_admin_write" ON public.events FOR ALL USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

-- ── user_event_reminders tablosu ────────────────────────────────────────────
CREATE TABLE public.user_event_reminders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  event_id uuid NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  last_notified_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, event_id)
);
ALTER TABLE public.user_event_reminders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "reminders_own" ON public.user_event_reminders FOR ALL USING (user_id = auth.uid());

-- ── indexes ──────────────────────────────────────────────────────────────────
CREATE INDEX events_province_month_idx ON public.events(province_id, month_start, month_end);
CREATE INDEX events_category_idx ON public.events(category);
CREATE INDEX events_active_month_idx ON public.events(month_start) WHERE is_active = true;
CREATE INDEX user_event_reminders_user_idx ON public.user_event_reminders(user_id, last_notified_at);

-- ═══════════════════════════════════════════════════════════════════════════
-- SEED DATA — 170 Etkinlik
-- ═══════════════════════════════════════════════════════════════════════════

-- ADANA
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Adana', 'Merkez', 'Uluslararası Adana Lezzet Festivali', 'adana-lezzet',
  'Türkiye''nin kebap başkentinde Adana kebabı ve yöresel lezzetlerin tanıtıldığı büyük açık hava festivali.',
  9, 9, 'yemek', ARRAY['kebap','gastronomi','açık-hava'], 37.0, 35.32, NULL
FROM public.provinces p WHERE p.slug = 'adana';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Adana', 'Merkez', 'Altın Koza Film Festivali', 'altin-koza',
  'Türkiye''nin köklü film festivallerinden biri; yerli yapımlar yarışır.',
  9, 9, 'sanat', ARRAY['film','sinema','ulusal'], 37.0, 35.32, NULL
FROM public.provinces p WHERE p.slug = 'adana';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Adana', 'Saimbeyli', 'Saimbeyli Kiraz Festivali', 'saimbeyli-kiraz',
  'Kiraz hasadı döneminde düzenlenen yöresel festival.',
  6, 6, 'yemek', ARRAY['kiraz','hasat','yöresel'], 37.97, 36.09, NULL
FROM public.provinces p WHERE p.slug = 'adana';

-- ADIYAMAN
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Adıyaman', 'Kahta', 'Nemrut Gün Dönümü Festivali', 'nemrut-gun-donumu',
  'Yaz gün dönümünde Nemrut Dağı zirvesinde gün doğumunu izlemeye yönelik uluslararası kültür etkinliği.',
  6, 6, 'kültür', ARRAY['nemrut','gündönümü','uluslararası','doğa'], 37.87, 38.74, NULL
FROM public.provinces p WHERE p.slug = 'adiyaman';

-- AFYONKARAHİSAR
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Afyonkarahisar', 'Merkez', 'Afyonkarahisar Haşhaş ve Kültür Festivali', 'afyon-hasha',
  'Türkiye''nin haşhaş üretiminin merkezi Afyon''da tarımsal gelenekleri kutlayan festival.',
  7, 7, 'kültür', ARRAY['haşhaş','tarım','geleneksel'], 38.75, 30.54, NULL
FROM public.provinces p WHERE p.slug = 'afyonkarahisar';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Afyonkarahisar', 'Merkez', 'Zafer Bayramı Kutlamaları', 'afyon-zafer',
  'Büyük Taarruz''un merkezi olarak özel tören ve etkinlikler.',
  8, 8, 'kültür', ARRAY['zafer','tören','tarih'], 38.75, 30.54, NULL
FROM public.provinces p WHERE p.slug = 'afyonkarahisar';

-- AĞRI
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Ağrı', 'Doğubayazıt', 'İshak Paşa Sarayı Kültür ve Sanat Festivali', 'ishak-pasa-festival',
  '2000 yıllık tarihi sarayda konserler ve halk oyunları.',
  7, 8, 'kültür', ARRAY['tarih','saray','konser','halk-oyunları'], 39.54, 44.06, NULL
FROM public.provinces p WHERE p.slug = 'agri';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Ağrı', 'Merkez', 'Ağrı Âşıklar Şöleni', 'agri-asiklar',
  'Halk ozanlarının katıldığı geleneksel âşık geleneği festivali.',
  6, 7, 'kültür', ARRAY['âşık','halk-müziği','ozanlar'], 39.72, 43.05, NULL
FROM public.provinces p WHERE p.slug = 'agri';

-- AKSARAY
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Aksaray', 'Güzelyurt', 'Ihlara Vadisi Yürüyüş Festivali', 'ihlara-yuruyu',
  'Ihlara Vadisi''nde doğa yürüyüşleri ve Kapadokya kültürü.',
  5, 5, 'doğa', ARRAY['ihlara','yürüyüş','kapadokya','vadi'], 38.14, 34.01, NULL
FROM public.provinces p WHERE p.slug = 'aksaray';

-- AMASYA
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Amasya', 'Merkez', 'Amasya Elma Festivali', 'amasya-elma',
  'Türkiye''nin ünlü Amasya elmasını kutlayan geleneksel festival.',
  9, 9, 'yemek', ARRAY['elma','hasat','yöresel'], 40.65, 35.83, NULL
FROM public.provinces p WHERE p.slug = 'amasya';

-- ANKARA
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Ankara', 'Çankaya', 'Ankara Uluslararası Müzik Festivali', 'ankara-muzik',
  '40 yıldır düzenlenen, CSO ile birlikte Nisan boyunca klasik müzik etkinlikleri.',
  4, 4, 'müzik', ARRAY['klasik-müzik','orkestra','CSO','uluslararası'], 39.92, 32.85, NULL
FROM public.provinces p WHERE p.slug = 'ankara';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Ankara', 'Çankaya', 'Ankara Uluslararası Film Festivali', 'ankara-film',
  'Başkentin en prestijli kültür etkinliği; ulusal ve uluslararası yapımlar.',
  3, 3, 'sanat', ARRAY['film','sinema','uluslararası'], 39.92, 32.85, NULL
FROM public.provinces p WHERE p.slug = 'ankara';

-- ANTALYA
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Antalya', 'Merkez', 'Antalya Altın Portakal Film Festivali', 'altin-portakal',
  '1964''ten bu yana Türkiye''nin en prestijli ulusal film festivali.',
  10, 10, 'sanat', ARRAY['film','sinema','ulusal','prestij'], 36.89, 30.71, NULL
FROM public.provinces p WHERE p.slug = 'antalya';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Antalya', 'Serik', 'Aspendos Uluslararası Opera ve Bale Festivali', 'aspendos-opera',
  '2000 yıllık Aspendos Antik Tiyatrosu''nda dünya sanatçılarını ağırlayan opera ve bale festivali.',
  9, 9, 'müzik', ARRAY['opera','bale','antik-tiyatro','uluslararası'], 36.94, 31.17, NULL
FROM public.provinces p WHERE p.slug = 'antalya';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Antalya', 'Alanya', 'Alanya Uluslararası Triatlon', 'alanya-triatlon',
  'Dünya Triatlon Serisi kapsamında Alanya sahillerinde uluslararası yarış.',
  11, 11, 'spor', ARRAY['triatlon','yüzme','koşu','bisiklet'], 36.54, 32.0, NULL
FROM public.provinces p WHERE p.slug = 'antalya';

-- ARDAHAN
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Ardahan', 'Çıldır', 'Uluslararası Çıldır Kristal Göl Atlı Kış Şöleni', 'cildir-kis-soleni',
  'Donmuş Çıldır Gölü üzerinde atlı kızak, cirit, atlı okçuluk.',
  1, 1, 'spor', ARRAY['kış','atlı-kızak','cirit','donmuş-göl'], 41.12, 43.15, NULL
FROM public.provinces p WHERE p.slug = 'ardahan';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Ardahan', 'Merkez', 'Ardahan Bal Festivali', 'ardahan-bal',
  'Ardahan yaban balının tanıtımı ve yarışmaları.',
  6, 6, 'yemek', ARRAY['bal','yaban-balı','doğa'], 41.11, 42.70, NULL
FROM public.provinces p WHERE p.slug = 'ardahan';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Ardahan', 'Göle', 'Göle Ulusal Kaşar Peyniri Festivali', 'gole-kasar',
  '1996''dan beri düzenlenen Göle kaşarını tanıtan gastronomi festivali.',
  7, 7, 'yemek', ARRAY['kaşar','peynir','gastronomi'], 40.79, 42.60, NULL
FROM public.provinces p WHERE p.slug = 'ardahan';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Ardahan', 'Çıldır', 'Uluslararası Çıldır Göl Festivali', 'cildir-gol-festival',
  'Çıldır Gölü kenarında halk oyunları ve akraba ülkelerden katılım.',
  7, 7, 'kültür', ARRAY['göl','halk-oyunları','uluslararası'], 41.12, 43.15, NULL
FROM public.provinces p WHERE p.slug = 'ardahan';

-- ARTVİN
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Artvin', 'Merkez', 'Artvin Kafkasör Kültür ve Sanat Festivali', 'kafkasor',
  '1800''lü yıllardan bu yana süregelen boğa güreşi, halk oyunları ve müzik festivali.',
  7, 7, 'geleneksel', ARRAY['boğa-güreşi','halk-oyunları','geleneksel','tarihî'], 41.18, 41.82, NULL
FROM public.provinces p WHERE p.slug = 'artvin';

-- AYDIN
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Aydın', 'Selçuk', 'Selçuk Efes Deve Güreşleri', 'selcuk-deve-guresi',
  'Her yıl Ocak ayında Selçuk''ta düzenlenen, yüzyıllık deve güreşi festivali.',
  1, 1, 'geleneksel', ARRAY['deve-güreşi','geleneksel','efes'], 37.95, 27.37, NULL
FROM public.provinces p WHERE p.slug = 'aydin';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Aydın', 'Nazilli', 'Nazilli İncir Festivali', 'nazilli-incir',
  'Türkiye''nin incir ihracat merkezi Nazilli''de hasat döneminde festival.',
  9, 9, 'yemek', ARRAY['incir','hasat','ihracat'], 37.91, 28.34, NULL
FROM public.provinces p WHERE p.slug = 'aydin';

-- BALIKESİR
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Balıkesir', 'Ayvalık', 'Ayvalık Uluslararası Müzik Akademisi Festivali', 'ayvalik-muzik',
  'Ege''de klasik müzik akademisi öğrencilerini ve ustaları buluşturan festival.',
  7, 8, 'müzik', ARRAY['klasik-müzik','akademi','uluslararası'], 39.31, 26.70, NULL
FROM public.provinces p WHERE p.slug = 'balikesir';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Balıkesir', 'Ayvalık', 'Ayvalık Uluslararası Zeytin Hasat Festivali', 'ayvalik-zeytin',
  '19. kez düzenlenen Türkiye''nin en köklü zeytin festivali.',
  11, 11, 'yemek', ARRAY['zeytin','hasat','ege'], 39.31, 26.70, NULL
FROM public.provinces p WHERE p.slug = 'balikesir';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Balıkesir', 'Orhangazi', 'Orhangazi Zeytin Festivali', 'orhangazi-zeytin',
  '1978''den beri, 47. yılında Kasım ayının son haftasında.',
  11, 11, 'yemek', ARRAY['zeytin','geleneksel'], 40.49, 29.31, NULL
FROM public.provinces p WHERE p.slug = 'balikesir';

-- BARTIN
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Bartın', 'Amasra', 'Amasra Deniz ve Kültür Festivali', 'amasra-deniz',
  'Tarihi liman kenti Amasra''da denizcilik ve yerel kültür festivali.',
  8, 8, 'kültür', ARRAY['deniz','liman','tarih','kültür'], 41.74, 32.38, NULL
FROM public.provinces p WHERE p.slug = 'bartin';

-- BATMAN
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Batman', 'Hasankeyf', 'Hasankeyf Kültür Festivali', 'hasankeyf-kultur',
  'Antik kentin tarihi mirasını yaşatmaya yönelik festival.',
  9, 9, 'kültür', ARRAY['hasankeyf','antik','miras','tarih'], 37.71, 41.40, NULL
FROM public.provinces p WHERE p.slug = 'batman';

-- BAYBURT
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Bayburt', 'Merkez', 'Bayburt Dede Korkut Uluslararası Kültür Şöleni', 'dede-korkut',
  '29 yıldır kesintisiz düzenlenen Dede Korkut destanlarını yaşatan festival.',
  7, 7, 'kültür', ARRAY['dede-korkut','destan','uluslararası'], 40.25, 40.22, NULL
FROM public.provinces p WHERE p.slug = 'bayburt';

-- BİLECİK
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Bilecik', 'Söğüt', 'Söğüt Ertuğrul Gazi Şenliği', 'sogut-ertugrul',
  'Osmanlı''nın kuruluş yurdu Söğüt''te her yıl Eylül''de binlerce kişinin katıldığı anma töreni.',
  9, 9, 'geleneksel', ARRAY['osmanlı','ertuğrul','kuruluş','anma'], 40.02, 30.18, NULL
FROM public.provinces p WHERE p.slug = 'bilecik';

-- BİNGÖL
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Bingöl', 'Kiğı', 'Kiğı Bal ve Doğa Festivali', 'kigi-bal',
  'Kiğı balının tanıtımı ve yerel kültür etkinlikleri.',
  7, 7, 'yemek', ARRAY['bal','doğa','yöresel'], 39.34, 40.30, NULL
FROM public.provinces p WHERE p.slug = 'bingol';

-- BİTLİS
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Bitlis', 'Ahlat', 'Ahlat Malazgirt Zaferi Kutlamaları', 'malazgirt-zafer',
  '1071 Malazgirt Zaferini anmak amacıyla düzenlenen Selçuklu mirası etkinlikleri.',
  8, 8, 'kültür', ARRAY['malazgirt','selçuklu','zafer','anma'], 38.75, 42.48, NULL
FROM public.provinces p WHERE p.slug = 'bitlis';

-- BOLU
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Bolu', 'Mengen', 'Mengen Aşçılar Festivali', 'mengen-ascılar',
  'Türkiye''nin aşçılık geleneği merkezi Mengen''de aşçıların yarıştığı büyük festival.',
  8, 8, 'yemek', ARRAY['aşçılık','gastronomi','yarışma'], 40.84, 32.03, NULL
FROM public.provinces p WHERE p.slug = 'bolu';

-- BURDUR
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Burdur', 'Yeşilova', 'Salda Gölü Tanıtım Festivali', 'salda-golu',
  '"Türkiye''nin Maldivleri" Salda Gölü çevresinde doğa etkinlikleri.',
  7, 7, 'doğa', ARRAY['salda','göl','doğa','turizm'], 37.54, 29.63, NULL
FROM public.provinces p WHERE p.slug = 'burdur';

-- BURSA
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Bursa', 'Osmangazi', 'Bursa Uluslararası Kültür ve Sanat Festivali', 'bursa-kultur',
  'Osmanlı başkentinde tiyatro, müzik, dans ve folklor gösterileri.',
  6, 7, 'kültür', ARRAY['osmanlı','tiyatro','dans','folklor'], 40.18, 29.07, NULL
FROM public.provinces p WHERE p.slug = 'bursa';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Bursa', 'İznik', 'İznik Çini ve Kültür Festivali', 'iznik-cini',
  'UNESCO listesindeki İznik çini sanatını yaşatan festival.',
  6, 6, 'sanat', ARRAY['çini','seramik','UNESCO','zanaat'], 40.43, 29.72, NULL
FROM public.provinces p WHERE p.slug = 'bursa';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Bursa', 'Gemlik', 'Gemlik Zeytin Hasat Festivali', 'gemlik-zeytin',
  'Türkiye''nin en ünlü zeytinini yetiştiren Gemlik''te hasat şenliği.',
  11, 11, 'yemek', ARRAY['zeytin','hasat','gemlik'], 40.43, 29.15, NULL
FROM public.provinces p WHERE p.slug = 'bursa';

-- ÇANAKKALE
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Çanakkale', 'Merkez', 'Çanakkale Deniz Zaferi Anma Törenleri', 'canakkale-zafer',
  '18 Mart''ta Çanakkale Şehitler Abidesi''nde düzenlenen ulusal anma.',
  3, 3, 'kültür', ARRAY['çanakkale','şehitler','anma','ulusal'], 40.15, 26.41, NULL
FROM public.provinces p WHERE p.slug = 'canakkale';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Çanakkale', 'Merkez', 'Uluslararası Troia Festivali', 'troia-festival',
  'Her yıl Ağustos''ta düzenlenen, 62. kez 2025''te yapılan tarihi kostüm ve kültür festivali.',
  8, 8, 'kültür', ARRAY['troia','mitoloji','kostüm','arkeoloji'], 39.95, 26.24, NULL
FROM public.provinces p WHERE p.slug = 'canakkale';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Çanakkale', 'Bozcaada', 'Bozcaada Bağ Bozumu Şenliği', 'bozcaada-bag',
  'Ege adacığında yerel şarap ve üzüm kültürünü tanıtan geleneksel şenlik.',
  9, 9, 'yemek', ARRAY['şarap','üzüm','ada','ege'], 39.83, 26.06, NULL
FROM public.provinces p WHERE p.slug = 'canakkale';

-- ÇANKIRI
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Çankırı', 'Merkez', 'Çankırı Kültür ve Turizm Festivali', 'cankiri-kultur',
  'İlin tuz madenlerini ve tarihi mirasını tanıtan festival.',
  6, 6, 'kültür', ARRAY['tuz','maden','tarih','kültür'], 40.60, 33.61, NULL
FROM public.provinces p WHERE p.slug = 'cankiri';

-- ÇORUM
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Çorum', 'Boğazkale', 'Hitit Festivali', 'hitit-festival',
  'Hattuşa''da antik Hitit medeniyetini canlandıran kostümlü gösteriler.',
  7, 7, 'kültür', ARRAY['hitit','hattuşa','arkeoloji','kostüm'], 40.01, 34.62, NULL
FROM public.provinces p WHERE p.slug = 'corum';

-- DENİZLİ
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Denizli', 'Pamukkale', 'Pamukkale Uluslararası Yüzme Maratonu', 'pamukkale-yuzu',
  'Pamukkale travertenlerinde uluslararası yüzme yarışması.',
  8, 8, 'spor', ARRAY['yüzme','travertenler','uluslararası'], 37.92, 29.12, NULL
FROM public.provinces p WHERE p.slug = 'denizli';

-- DİYARBAKIR
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Diyarbakır', 'Sur', 'Diyarbakır Karpuz Festivali', 'diyarbakir-karpuz',
  'Türkiye''nin en büyük karpuzunu yetiştiren Diyarbakır''da Karacadağ karpuzu festivali.',
  8, 8, 'yemek', ARRAY['karpuz','karacadağ','hasat'], 37.91, 40.23, NULL
FROM public.provinces p WHERE p.slug = 'diyarbakir';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Diyarbakır', 'Merkez', 'Diyarbakır Kültür ve Sanat Festivali', 'diyarbakir-kultur',
  'UNESCO surlarının gölgesinde çok kültürlü gösteri ve etkinlikler.',
  6, 6, 'kültür', ARRAY['surlar','UNESCO','çok-kültürlü'], 37.91, 40.23, NULL
FROM public.provinces p WHERE p.slug = 'diyarbakir';

-- DÜZCE
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Düzce', 'Akçakoca', 'Akçakoca Turizm ve Kültür Festivali', 'akcakoca-festival',
  'Batı Karadeniz kıyısında yaz döneminde kültür festivali.',
  7, 7, 'kültür', ARRAY['karadeniz','kıyı','yaz'], 41.08, 31.12, NULL
FROM public.provinces p WHERE p.slug = 'duzce';

-- EDİRNE
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Edirne', 'Merkez', 'Kırkpınar Yağlı Güreş Festivali', 'kirkpinar',
  '1346''dan bu yana UNESCO tescilli, dünyanın en eski spor organizasyonu.',
  7, 7, 'spor', ARRAY['güreş','UNESCO','geleneksel','yağlı-güreş'], 41.68, 26.56, 'https://www.kirkpinar.com'
FROM public.provinces p WHERE p.slug = 'edirne';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Edirne', 'Merkez', 'Edirne Kakava Hıdırellez Şenliği', 'kakava-hidrellez',
  'Roman kültürünün kutladığı Hıdırellez''de Tunca Nehri kıyısında müzik ve dans şenliği.',
  5, 5, 'geleneksel', ARRAY['hıdırellez','roman','müzik','dans'], 41.68, 26.56, NULL
FROM public.provinces p WHERE p.slug = 'edirne';

-- ELAZIĞ
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Elazığ', 'Merkez', 'Elazığ Harput Kültür ve Turizm Festivali', 'harput-kultur',
  'Tarihi Harput kalesi çevresinde halk oyunları ve müzik.',
  7, 7, 'kültür', ARRAY['harput','kale','halk-oyunları'], 38.67, 39.22, NULL
FROM public.provinces p WHERE p.slug = 'elazig';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Elazığ', 'Sivrice', 'Hazar Gölü Su Sporları Festivali', 'hazar-golu-spor',
  'Hazar Gölü''nde tekne yarışları ve su sporları.',
  7, 8, 'spor', ARRAY['su-sporları','göl','tekne'], 38.48, 39.41, NULL
FROM public.provinces p WHERE p.slug = 'elazig';

-- ERZİNCAN
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Erzincan', 'Kemaliye', 'Kemaliye Kültür ve Doğa Festivali', 'kemaliye-kultur',
  'Tarihi Eğin ilçesinde Fırat kıyısında doğa yürüyüşleri ve kültür.',
  7, 7, 'doğa', ARRAY['fırat','yürüyüş','kanyon','doğa'], 39.26, 38.49, NULL
FROM public.provinces p WHERE p.slug = 'erzincan';

-- ERZURUM
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Erzurum', 'Palandöken', 'Erzurum Kış Oyunları Festivali', 'erzurum-kis',
  'Türkiye''nin en önemli kayak merkezi Palandöken''de kış sporları şenlikleri.',
  2, 2, 'spor', ARRAY['kayak','kış-sporları','palandöken'], 39.90, 41.27, NULL
FROM public.provinces p WHERE p.slug = 'erzurum';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Erzurum', 'Merkez', 'Erzurum Bar ve Cırcır Festivali', 'erzurum-bar',
  'UNESCO tescilli "Bar" dansını yaşatan, yüzlerce dansçının katıldığı etkinlik.',
  8, 8, 'geleneksel', ARRAY['bar-dansı','UNESCO','halk-oyunları'], 39.90, 41.27, NULL
FROM public.provinces p WHERE p.slug = 'erzurum';

-- ESKİŞEHİR
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Eskişehir', 'Odunpazarı', 'Uluslararası Eskişehir Film Festivali', 'eskisehir-film',
  'Genç sinemacıları öne çıkaran uluslararası film festivali.',
  3, 3, 'sanat', ARRAY['film','sinema','uluslararası','genç'], 39.77, 30.52, NULL
FROM public.provinces p WHERE p.slug = 'eskisehir';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Eskişehir', 'Odunpazarı', 'Odunpazarı Tarihi Evler Kültür Festivali', 'odunpazari-kultur',
  'UNESCO listesindeki Odunpazarı''nda kültür ve sanat etkinlikleri.',
  6, 6, 'kültür', ARRAY['odunpazarı','tarihi-evler','UNESCO'], 39.77, 30.52, NULL
FROM public.provinces p WHERE p.slug = 'eskisehir';

-- GAZİANTEP
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Gaziantep', 'Şahinbey', 'Gaziantep Gastronomi Festivali', 'gaziantep-gastronomi',
  'UNESCO Yaratıcı Şehir Gaziantep''te baklava ve kebap başta uluslararası gastronomi.',
  9, 9, 'yemek', ARRAY['gastronomi','baklava','kebap','UNESCO'], 37.06, 37.38, NULL
FROM public.provinces p WHERE p.slug = 'gaziantep';

-- GİRESUN
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Giresun', 'Merkez', 'Uluslararası Giresun Aksu Festivali', 'giresun-aksu',
  '3000 yıllık gelenek, 20 Mayıs; Giresun Adası turunu içeren antik su festivali.',
  5, 5, 'geleneksel', ARRAY['aksu','ada','antik','su'], 40.91, 38.39, NULL
FROM public.provinces p WHERE p.slug = 'giresun';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Giresun', 'Merkez', 'Giresun Fındık Festivali', 'giresun-findik',
  'Türkiye''nin fındık başkentinde hasat sezonunda festival.',
  8, 8, 'yemek', ARRAY['fındık','hasat','karadeniz'], 40.91, 38.39, NULL
FROM public.provinces p WHERE p.slug = 'giresun';

-- GÜMÜŞHANE
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Gümüşhane', 'Merkez', 'Gümüşhane Kültür ve Sanat Festivali', 'gumushane-kultur',
  'Doğu Karadeniz''in bu dağlık ilinde halk müziği ve el sanatları.',
  7, 7, 'kültür', ARRAY['halk-müziği','el-sanatları','dağ'], 40.46, 39.48, NULL
FROM public.provinces p WHERE p.slug = 'gumushane';

-- HAKKARİ
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Hakkari', 'Yüksekova', 'Cilo-Sat Dağları Doğa Festivali', 'cilo-sat-doga',
  'Türkiye''nin en yüksek dağlarında dağcılık ve trekking etkinlikleri.',
  7, 8, 'doğa', ARRAY['dağcılık','trekking','cilo','sat'], 37.57, 44.22, NULL
FROM public.provinces p WHERE p.slug = 'hakkari';

-- HATAY
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Hatay', 'Antakya', 'Hatay Gastronomi Festivali', 'hatay-gastronomi',
  'UNESCO Yaratıcı Gastronomi Şehri Hatay''da Akdeniz ve Ortadoğu mutfakları.',
  10, 10, 'yemek', ARRAY['gastronomi','UNESCO','akdeniz','ortadoğu'], 36.20, 36.16, NULL
FROM public.provinces p WHERE p.slug = 'hatay';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Hatay', 'Altınözü', 'Altınözü Zeytin Festivali', 'altinözu-zeytin',
  'Hatay''ın zeytinyağı kültürünü tanıtan festival.',
  10, 10, 'yemek', ARRAY['zeytin','zeytinyağı','hasat'], 36.08, 36.41, NULL
FROM public.provinces p WHERE p.slug = 'hatay';

-- IĞDIR
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Iğdır', 'Merkez', 'Iğdır Tarım Ürünleri Festivali', 'igdir-tarim',
  'Iğdır''ın kayısı, karpuz ürünlerinin tanıtımı.',
  7, 7, 'yemek', ARRAY['kayısı','karpuz','tarım'], 39.92, 44.04, NULL
FROM public.provinces p WHERE p.slug = 'igdir';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Iğdır', 'Merkez', 'Iğdır Mağara Festivali', 'igdir-magara',
  'Türkiye''nin ilk mağara festivali; mağaracılık ve doğa yürüyüşü.',
  7, 8, 'doğa', ARRAY['mağara','mağaracılık','doğa'], 39.92, 44.04, NULL
FROM public.provinces p WHERE p.slug = 'igdir';

-- ISPARTA
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Isparta', 'Keçiborlu', 'Isparta Uluslararası Gül ve Lavanta Festivali', 'isparta-gul',
  '"Türkiye''nin Parfüm Bahçesi" Isparta''da gül hasadını konu alan uluslararası festival.',
  6, 6, 'doğa', ARRAY['gül','lavanta','parfüm','hasat'], 37.76, 30.55, NULL
FROM public.provinces p WHERE p.slug = 'isparta';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Isparta', 'Uluborlu', 'Uluborlu Kiraz Festivali ve Yağlı Güreşler', 'uluborlu-kiraz',
  '46. kez düzenlenen, kiraz hasadı ve pehlivan güreşlerini bir araya getiren festival.',
  6, 7, 'geleneksel', ARRAY['kiraz','yağlı-güreş','pehlivan'], 38.00, 30.45, NULL
FROM public.provinces p WHERE p.slug = 'isparta';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Isparta', 'Eğirdir', 'Eğirdir Doğa Sporları Festivali', 'egirdir-doga',
  'Eğirdir Gölü''nde su sporları, kano ve doğa yürüyüşü.',
  9, 9, 'spor', ARRAY['su-sporları','kano','göl','yürüyüş'], 37.87, 30.85, NULL
FROM public.provinces p WHERE p.slug = 'isparta';

-- İSTANBUL
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'İstanbul', 'Beyoğlu', 'İstanbul Uluslararası Müzik Festivali', 'istanbul-muzik',
  '1973''ten bu yana tarihi mekânlarda dünya klasik müzik ustalarını ağırlayan festival.',
  6, 7, 'müzik', ARRAY['klasik-müzik','uluslararası','tarihi-mekânlar'], 41.03, 28.98, NULL
FROM public.provinces p WHERE p.slug = 'istanbul';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'İstanbul', 'Beyoğlu', 'İstanbul Uluslararası Caz Festivali', 'istanbul-caz',
  'Açık hava sahnelerinde dünya caz yıldızlarını ağırlayan yaz festivali.',
  7, 7, 'müzik', ARRAY['caz','açık-hava','uluslararası'], 41.03, 28.98, NULL
FROM public.provinces p WHERE p.slug = 'istanbul';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'İstanbul', 'Beyoğlu', 'İstanbul Bienali', 'istanbul-bienal',
  'İki yılda bir (tek yıllarda) düzenlenen çağdaş sanatın dünya çapındaki en prestijli etkinliği.',
  9, 11, 'sanat', ARRAY['bienal','çağdaş-sanat','uluslararası'], 41.03, 28.98, NULL
FROM public.provinces p WHERE p.slug = 'istanbul';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'İstanbul', 'Fatih', 'İstanbul Kitap Fuarı', 'istanbul-kitap',
  'TÜYAP''ta Türkiye''nin en büyük kitap etkinliği.',
  11, 11, 'kültür', ARRAY['kitap','yayıncılık','tüyap'], 41.01, 28.94, NULL
FROM public.provinces p WHERE p.slug = 'istanbul';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'İstanbul', 'Sarıyer', 'Emirgan Lale Festivali', 'emirgan-lale',
  'Emirgan Korusu''nda milyonlarca lalenin açtığı İstanbul''un bahar simgesi.',
  4, 4, 'doğa', ARRAY['lale','bahar','emirgan','park'], 41.11, 29.05, NULL
FROM public.provinces p WHERE p.slug = 'istanbul';

-- İZMİR
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'İzmir', 'Konak', 'İzmir Uluslararası Fuarı', 'izmir-fuar',
  '1936''dan bu yana Türkiye''nin en büyük ticaret fuarı; 29 Ağustos–9 Eylül.',
  8, 9, 'kültür', ARRAY['fuar','ticaret','uluslararası'], 38.42, 27.14, NULL
FROM public.provinces p WHERE p.slug = 'izmir';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'İzmir', 'Çeşme', 'Çeşme Uluslararası Müzik Festivali', 'cesme-muzik',
  'Ege kıyısında pop ve rock konserlerini ağırlayan yaz festivali.',
  7, 7, 'müzik', ARRAY['pop','rock','ege','yaz'], 38.33, 26.30, NULL
FROM public.provinces p WHERE p.slug = 'izmir';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'İzmir', 'Selçuk', 'Efes Kültür Yolu Festivali', 'efes-kultur',
  'Antik Efes''te tarihi mimariyle müzik, dans ve kültür.',
  5, 5, 'kültür', ARRAY['efes','antik','arkeoloji','müzik'], 37.94, 27.34, NULL
FROM public.provinces p WHERE p.slug = 'izmir';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'İzmir', 'Urla', 'Urla Uluslararası Enginar Festivali', 'urla-enginar',
  '"Enginar başkenti" Urla''da enginar gastronomi festivali.',
  4, 4, 'yemek', ARRAY['enginar','gastronomi','ege'], 38.32, 26.76, NULL
FROM public.provinces p WHERE p.slug = 'izmir';

-- KAHRAMANMARAŞ
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Kahramanmaraş', 'Merkez', 'Kahramanmaraş Dondurma Festivali', 'maras-dondurma',
  'Türkiye''nin meşhur uzayan dondurmasının anavatanında ustalar şenliği.',
  8, 8, 'yemek', ARRAY['dondurma','maraş','gelenek'], 37.58, 36.93, NULL
FROM public.provinces p WHERE p.slug = 'kahramanmaras';

-- KARABÜK
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Karabük', 'Safranbolu', 'Safranbolu Kültür ve Turizm Festivali', 'safranbolu-kultur',
  'UNESCO Dünya Mirası Safranbolu''da Osmanlı konak yaşamını tanıtan festival.',
  7, 7, 'kültür', ARRAY['safranbolu','osmanlı','UNESCO','konak'], 41.25, 32.69, NULL
FROM public.provinces p WHERE p.slug = 'karabuk';

-- KARAMAN
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Karaman', 'Merkez', 'Karaman Kültür ve Turizm Festivali', 'karaman-kultur',
  'Karamanoğulları başkentinde tarihi mirası yaşatan festival.',
  6, 6, 'kültür', ARRAY['karamanoğulları','tarih','miras'], 37.18, 33.22, NULL
FROM public.provinces p WHERE p.slug = 'karaman';

-- KARS
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Kars', 'Merkez', 'Kars Boğa Güreşleri Festivali', 'kars-boga',
  'Sarıkamış yaylalarında yüzyıllık boğa güreşleri geleneği.',
  7, 7, 'geleneksel', ARRAY['boğa-güreşi','yayla','geleneksel'], 40.60, 43.09, NULL
FROM public.provinces p WHERE p.slug = 'kars';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Kars', 'Merkez', 'Kars Kış Turizm Festivali', 'kars-kis',
  'Sarıkamış Kayak Merkezi çevresinde kış sporları.',
  1, 2, 'spor', ARRAY['kayak','kış','sarıkamış'], 40.58, 43.07, NULL
FROM public.provinces p WHERE p.slug = 'kars';

-- KASTAMONU
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Kastamonu', 'Merkez', 'Kastamonu Kültür ve Turizm Festivali', 'kastamonu-kultur',
  'Osmanlı konak mimarisi Kastamonu''da yöresel müzik ve el sanatları.',
  7, 7, 'kültür', ARRAY['osmanlı','konak','el-sanatları'], 41.37, 33.78, NULL
FROM public.provinces p WHERE p.slug = 'kastamonu';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Kastamonu', 'Taşköprü', 'Taşköprü Sarımsak Festivali', 'taskopru-sarimsak',
  'Türkiye''nin sarımsak üretim merkezi Taşköprü''de hasat festivali.',
  7, 7, 'yemek', ARRAY['sarımsak','hasat','tarım'], 41.50, 34.22, NULL
FROM public.provinces p WHERE p.slug = 'kastamonu';

-- KAYSERİ
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Kayseri', 'Erciyes', 'Erciyes Kış ve Kar Festivali', 'erciyes-kis',
  'Türkiye''nin en büyük kayak merkezlerinden Erciyes''te kış sporları.',
  2, 2, 'spor', ARRAY['kayak','erciyes','kış'], 38.53, 35.45, NULL
FROM public.provinces p WHERE p.slug = 'kayseri';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Kayseri', 'Merkez', 'Kayseri Pastırma ve Sucuk Festivali', 'kayseri-pastirma',
  '"Pastırmanın başkenti" Kayseri''de coğrafi işaretli pastırma ve sucuk festivali.',
  10, 10, 'yemek', ARRAY['pastırma','sucuk','gastronomi','coğrafi-işaret'], 38.73, 35.49, NULL
FROM public.provinces p WHERE p.slug = 'kayseri';

-- KİLİS
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Kilis', 'Merkez', 'Kilis Yöresel Ürünler ve Zeytinyağı Festivali', 'kilis-zeytin',
  '4500 yıllık zeytin kültürü; Ekim-Kasım hasat döneminde.',
  10, 11, 'yemek', ARRAY['zeytin','zeytinyağı','tarih','hasat'], 36.71, 37.12, NULL
FROM public.provinces p WHERE p.slug = 'kilis';

-- KIRIKKALE
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Kırıkkale', 'Karakeçili', 'Uluslararası Karakeçili Kültür Festivali', 'karakecili-kultur',
  'Ertuğrul Gazi temalı yerel halk oyunları ve yöresel yemek festivali.',
  9, 9, 'kültür', ARRAY['ertuğrul','halk-oyunları','yöresel'], 39.82, 33.51, NULL
FROM public.provinces p WHERE p.slug = 'kirikkale';

-- KIRKLARELİ
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Kırklareli', 'İğneada', 'İğneada Uzun Ada Maraton ve Doğa Festivali', 'igneada-maraton',
  'Longoz ormanlarıyla ünlü İğneada''da doğa koşusu.',
  10, 10, 'spor', ARRAY['maraton','koşu','longoz','doğa'], 41.87, 27.97, NULL
FROM public.provinces p WHERE p.slug = 'kirklareli';

-- KIRŞEHİR
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Kırşehir', 'Merkez', 'Kırşehir Ahilik Kültürü Haftası', 'ahilik-haftasi',
  'Ahilik teşkilatının doğduğu Kırşehir''de esnaf geleneği ve Ahi Evran anması.',
  10, 10, 'kültür', ARRAY['ahilik','esnaf','ahi-evran','gelenek'], 39.14, 34.16, NULL
FROM public.provinces p WHERE p.slug = 'kirsehir';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Kırşehir', 'Merkez', 'Neşet Ertaş Müzik Festivali', 'neset-ertas',
  'Halk müziğinin büyük ozanı Neşet Ertaş''ın memleketinde bağlama festivali.',
  9, 9, 'müzik', ARRAY['bağlama','halk-müziği','neşet-ertaş'], 39.14, 34.16, NULL
FROM public.provinces p WHERE p.slug = 'kirsehir';

-- KOCAELİ
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Kocaeli', 'Merkez', 'Kocaeli Uluslararası Karikatür Festivali', 'kocaeli-karikatür',
  'Uluslararası karikatüristleri İzmit''te buluşturan festival.',
  7, 7, 'sanat', ARRAY['karikatür','çizgi','uluslararası'], 40.76, 29.92, NULL
FROM public.provinces p WHERE p.slug = 'kocaeli';

-- KONYA
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Konya', 'Merkez', 'Şeb-i Arus Hz. Mevlana Anma Törenleri', 'sebi-arus',
  'Hz. Mevlana''nın 17 Aralık ölüm yıldönümünde dünyanın dört bir yanından gelen sema törenleri.',
  12, 12, 'kültür', ARRAY['mevlana','sema','semazen','UNESCO'], 37.87, 32.49, NULL
FROM public.provinces p WHERE p.slug = 'konya';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Konya', 'Merkez', 'Konya Uluslararası Mistik Müzik Festivali', 'konya-mistik-muzik',
  'Dünya genelinden sufi müzisyenleri Konya''ya taşıyan uluslararası festival.',
  9, 9, 'müzik', ARRAY['sufi','mistik','uluslararası'], 37.87, 32.49, NULL
FROM public.provinces p WHERE p.slug = 'konya';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Konya', 'Beyşehir', 'Beyşehir Göl Festivali', 'beysehir-gol',
  'Türkiye''nin üçüncü büyük gölü Beyşehir''de su sporları.',
  6, 6, 'doğa', ARRAY['göl','su-sporları','doğa'], 37.68, 31.72, NULL
FROM public.provinces p WHERE p.slug = 'konya';

-- KÜTAHYA
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Kütahya', 'Merkez', 'Kütahya Çini ve Porselen Festivali', 'kutahya-cini',
  'Türkiye''nin çini sanatı merkezi Kütahya''da ustaları buluşturan festival.',
  7, 7, 'sanat', ARRAY['çini','porselen','zanaat','sanat'], 39.42, 29.98, NULL
FROM public.provinces p WHERE p.slug = 'kutahya';

-- MALATYA
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Malatya', 'Merkez', 'Malatya Uluslararası Film Festivali', 'malatya-film',
  'Kayısı başkentinde ulusal ve uluslararası yapımları ağırlayan film festivali.',
  11, 11, 'sanat', ARRAY['film','sinema','uluslararası'], 38.35, 38.31, NULL
FROM public.provinces p WHERE p.slug = 'malatya';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Malatya', 'Merkez', 'Malatya Kayısı Festivali', 'malatya-kayisi',
  'Dünyanın en kaliteli kayısıları Malatya''da hasat festivali.',
  7, 7, 'yemek', ARRAY['kayısı','hasat','meyve'], 38.35, 38.31, NULL
FROM public.provinces p WHERE p.slug = 'malatya';

-- MANİSA
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Manisa', 'Merkez', 'Mesir Macunu Festivali', 'mesir-macunu',
  '16. yüzyıldan beri süregelen, Manisa Ulu Camii minaresinden 40 çeşit macunun halka saçıldığı UNESCO tescilli etkinlik.',
  3, 3, 'geleneksel', ARRAY['mesir','macun','UNESCO','camii'], 38.62, 27.43, NULL
FROM public.provinces p WHERE p.slug = 'manisa';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Manisa', 'Alaşehir', 'Alaşehir Üzüm Festivali', 'alasehir-uzum',
  'Türkiye''nin çekirdeksiz üzüm merkezi Alaşehir''de bağ bozumu festivali.',
  9, 9, 'yemek', ARRAY['üzüm','bağ-bozumu','çekirdeksiz'], 38.35, 28.51, NULL
FROM public.provinces p WHERE p.slug = 'manisa';

-- MARDİN
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Mardin', 'Merkez', 'Mardin Kültür ve Sanat Festivali', 'mardin-kultur',
  'UNESCO Yaratıcı Şehir Mardin''de tarihi taş evlerin gölgesinde çok kültürlü festival.',
  5, 5, 'kültür', ARRAY['taş-evler','UNESCO','çok-kültürlü','mezopotamya'], 37.31, 40.73, NULL
FROM public.provinces p WHERE p.slug = 'mardin';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Mardin', 'Midyat', 'Midyat Tel Kırma El Sanatları Festivali', 'midyat-tel-kirma',
  'Süryani kuyumculuğunun merkezi Midyat''ta geleneksel zanaatlar festivali.',
  6, 6, 'sanat', ARRAY['tel-kırma','kuyumculuk','süryani','zanaat'], 37.42, 41.34, NULL
FROM public.provinces p WHERE p.slug = 'mardin';

-- MERSİN
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Mersin', 'Merkez', 'Mersin Uluslararası Müzik Festivali', 'mersin-muzik',
  'Akdeniz kıyısında klasik ve dünya müziğini bir araya getiren festival.',
  3, 3, 'müzik', ARRAY['klasik-müzik','akdeniz','uluslararası'], 36.79, 34.64, NULL
FROM public.provinces p WHERE p.slug = 'mersin';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Mersin', 'Silifke', 'Silifke Müzik ve Folklor Festivali', 'silifke-muzik',
  'Akdeniz''in tarihi ilçesinde halk müzisyenlerini buluşturan festival.',
  5, 5, 'müzik', ARRAY['halk-müziği','folklor','tarihi'], 36.37, 33.93, NULL
FROM public.provinces p WHERE p.slug = 'mersin';

-- MUĞLA
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Muğla', 'Bodrum', 'Bodrum Uluslararası Bale Festivali', 'bodrum-bale',
  'Bodrum Kalesi''nde dünya bale gruplarını ağırlayan festival.',
  8, 8, 'sanat', ARRAY['bale','kale','uluslararası'], 37.03, 27.43, NULL
FROM public.provinces p WHERE p.slug = 'mugla';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Muğla', 'Bodrum', 'Gümüşlük Uluslararası Müzik Festivali', 'gumusluk-muzik',
  'Gümüşlük''ün eşsiz akustiğinde klasik ve caz konserleri.',
  7, 8, 'müzik', ARRAY['klasik-müzik','caz','akustik'], 37.05, 27.29, NULL
FROM public.provinces p WHERE p.slug = 'mugla';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Muğla', 'Fethiye', 'Ölüdeniz Uluslararası Hava Oyunları Festivali', 'olüdeniz-hava',
  '"Dünyanın en güzel plajı" Ölüdeniz''de yamaç paraşütü festivali.',
  10, 10, 'spor', ARRAY['yamaç-paraşütü','ölüdeniz','hava-sporları'], 36.55, 29.11, NULL
FROM public.provinces p WHERE p.slug = 'mugla';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Muğla', 'Datça', 'Datça Badem Çiçeği Şenliği', 'datca-badem',
  'Badem bahçelerinin beyaza büründüğü şubatta Datça''da bahar şenliği.',
  2, 2, 'doğa', ARRAY['badem','çiçek','bahar','datça'], 36.76, 27.68, NULL
FROM public.provinces p WHERE p.slug = 'mugla';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Muğla', 'Marmaris', 'Marmaris Uluslararası Yelken Yarışı', 'marmaris-yelken',
  'Marmaris Koyu''nda yüzlerce yelkenliyle uluslararası yarış.',
  5, 5, 'spor', ARRAY['yelken','deniz','uluslararası'], 36.85, 28.27, NULL
FROM public.provinces p WHERE p.slug = 'mugla';

-- MUŞ
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Muş', 'Malazgirt', 'Malazgirt Zaferi Kutlamaları', 'mus-malazgirt',
  '1071 Malazgirt Zaferini anmak için atlı gösteriler ve tarihi canlandırmalar.',
  8, 8, 'kültür', ARRAY['malazgirt','zafer','tarih','atlı'], 38.94, 41.51, NULL
FROM public.provinces p WHERE p.slug = 'mus';

-- NEVŞEHİR
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Nevşehir', 'Göreme', 'Kapadokya Uluslararası Balon Festivali', 'kapadokya-balon',
  'Dünyanın en önemli balon destinasyonunda uluslararası balon yarışmaları.',
  9, 9, 'spor', ARRAY['balon','kapadokya','uçuş','uluslararası'], 38.64, 34.85, NULL
FROM public.provinces p WHERE p.slug = 'nevsehir';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Nevşehir', 'Hacıbektaş', 'Hacıbektaş Veli Anma Törenleri', 'hacibektas-anma',
  '16-18 Ağustos, Alevi-Bektaşi geleneğinin piri için yüz binlerce kişinin katıldığı anma.',
  8, 8, 'kültür', ARRAY['alevi','bektaşi','hacıbektaş','anma'], 38.95, 34.56, NULL
FROM public.provinces p WHERE p.slug = 'nevsehir';

-- NİĞDE
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Niğde', 'Merkez', 'Niğde Kültür ve Turizm Festivali', 'nigde-kultur',
  'Tarihi ilin yöresel kültür ve el sanatları festivali.',
  7, 7, 'kültür', ARRAY['tarih','el-sanatları','kültür'], 37.97, 34.68, NULL
FROM public.provinces p WHERE p.slug = 'nigde';

-- ORDU
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Ordu', 'Merkez', 'Ordu Uluslararası Fındık Festivali', 'ordu-findik',
  'Türkiye''nin fındık kalesi Ordu''da hasat sezonunda büyük tarımsal festival.',
  8, 8, 'yemek', ARRAY['fındık','hasat','karadeniz','tarım'], 40.98, 37.88, NULL
FROM public.provinces p WHERE p.slug = 'ordu';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Ordu', 'Perşembe', 'Perşembe Yaylası Doğa Festivali', 'persembe-yayla',
  'Karadeniz''in en güzel yaylaları arasında doğa yürüyüşleri.',
  7, 7, 'doğa', ARRAY['yayla','yürüyüş','karadeniz','doğa'], 40.98, 38.25, NULL
FROM public.provinces p WHERE p.slug = 'ordu';

-- OSMANİYE
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Osmaniye', 'Merkez', 'Osmaniye FıstıkFest', 'osmaniye-fistik',
  'Coğrafi işaretli Osmaniye yerfıstığını tanıtan gastronomi festivali.',
  10, 10, 'yemek', ARRAY['yerfıstığı','gastronomi','coğrafi-işaret'], 37.07, 36.25, NULL
FROM public.provinces p WHERE p.slug = 'osmaniye';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Osmaniye', 'Kadirli', 'Kadirli Karatepe Kültür Festivali', 'karatepe-kultur',
  'Karatepe-Aslantaş açık hava müzesinde UNESCO temalı festival.',
  8, 8, 'kültür', ARRAY['karatepe','arkeoloji','UNESCO','açık-hava'], 37.37, 36.07, NULL
FROM public.provinces p WHERE p.slug = 'osmaniye';

-- RİZE
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Rize', 'Çamlıhemşin', 'Ayder Kültür Sanat ve Doğa Festivali', 'ayder-festival',
  'Ayder Yaylası''nda horon, doğa yürüyüşü ve boğa güreşleri.',
  6, 6, 'doğa', ARRAY['ayder','horon','yayla','boğa-güreşi'], 41.05, 40.99, NULL
FROM public.provinces p WHERE p.slug = 'rize';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Rize', 'Çamlıhemşin', 'Ayder Kardan Adam Kış Festivali', 'ayder-kis',
  'Ocak ayında iglo yapımı, kayak ve karda geleneksel oyunlar.',
  1, 1, 'spor', ARRAY['kardan-adam','iglo','kış','kayak'], 41.05, 40.99, NULL
FROM public.provinces p WHERE p.slug = 'rize';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Rize', 'Merkez', 'Rize Çay ve Kültür Festivali', 'rize-cay',
  'Türkiye''nin çay başkentinde çay hasadını kutlayan festival.',
  5, 5, 'yemek', ARRAY['çay','hasat','karadeniz'], 41.02, 40.52, NULL
FROM public.provinces p WHERE p.slug = 'rize';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Rize', 'İkizdere', 'Anzer Balı ve Yayla Şenlikleri', 'anzer-bali',
  'Ağustos''un ilk haftasında Anzer yaban balını tanıtan yayla şenliği.',
  8, 8, 'yemek', ARRAY['anzer','bal','yayla','yaban-balı'], 40.79, 40.68, NULL
FROM public.provinces p WHERE p.slug = 'rize';

-- SAKARYA
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Sakarya', 'Sapanca', 'Sapanca Doğa ve Kültür Festivali', 'sapanca-doga',
  'Sapanca Gölü çevresinde doğa yürüyüşleri ve kültür etkinlikleri.',
  9, 9, 'doğa', ARRAY['sapanca','göl','yürüyüş','doğa'], 40.69, 30.26, NULL
FROM public.provinces p WHERE p.slug = 'sakarya';

-- SAMSUN
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Samsun', 'Merkez', '19 Mayıs Atatürk''ü Anma Gençlik ve Spor Bayramı', 'samsun-19-mayis',
  'Kurtuluş Savaşı''nın başladığı şehirde Türkiye''nin en büyük gençlik kutlaması.',
  5, 5, 'kültür', ARRAY['atatürk','gençlik','kurtuluş','anma'], 41.29, 36.33, NULL
FROM public.provinces p WHERE p.slug = 'samsun';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Samsun', 'Merkez', 'Samsun Uluslararası Film Festivali', 'samsun-film',
  'Karadeniz''in büyük liman kentinde film festivali.',
  11, 11, 'sanat', ARRAY['film','sinema','karadeniz'], 41.29, 36.33, NULL
FROM public.provinces p WHERE p.slug = 'samsun';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Samsun', 'Bafra', 'Bafra Kültür Festivali', 'bafra-kultur',
  'Türkiye''nin tarımsal üretim merkezlerinden Bafra''da yöresel kültür etkinlikleri.',
  8, 8, 'kültür', ARRAY['tarım','kültür','yöresel'], 41.56, 35.90, NULL
FROM public.provinces p WHERE p.slug = 'samsun';

-- SİİRT
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Siirt', 'Merkez', 'Siirt Fıstığı Doğa ve Kültür Festivali', 'siirt-fistik',
  'Siirt fıstığının tanıtımı; yürüyüş, paneller, konserler.',
  9, 10, 'yemek', ARRAY['fıstık','gastronomi','doğa'], 37.93, 41.94, NULL
FROM public.provinces p WHERE p.slug = 'siirt';

-- SİNOP
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Sinop', 'Merkez', 'Sinop Kültür ve Turizm Festivali', 'sinop-kultur',
  'Türkiye''nin en kuzeyinde Karadeniz kıyısında deniz ve kültür etkinlikleri.',
  7, 7, 'kültür', ARRAY['karadeniz','en-kuzey','deniz','kültür'], 42.02, 35.15, NULL
FROM public.provinces p WHERE p.slug = 'sinop';

-- SİVAS
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Sivas', 'Merkez', 'Sivas Kültür Sanat Festivali', 'sivas-kultur',
  'Sivas Kongresi geleneğini ve yöresel kültürü kutlayan festival.',
  7, 7, 'kültür', ARRAY['kongre','tarih','kültür'], 39.74, 37.01, NULL
FROM public.provinces p WHERE p.slug = 'sivas';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Sivas', 'Merkez', 'Pir Sultan Abdal Kültür Festivali', 'pir-sultan-abdal',
  'Alevi ozanı Pir Sultan Abdal''ın mirasını yaşatan bağlama ve türkü festivali.',
  6, 6, 'müzik', ARRAY['pir-sultan-abdal','alevi','bağlama','türkü'], 39.74, 37.01, NULL
FROM public.provinces p WHERE p.slug = 'sivas';

-- ŞANLIURFA
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Şanlıurfa', 'Merkez', 'Şanlıurfa Uluslararası Kültür ve Sanat Festivali', 'sanliurfa-kultur',
  'Hz. İbrahim şehri Şanlıurfa''da Mezopotamya mirasını kutlayan festival.',
  10, 10, 'kültür', ARRAY['mezopotamya','tarih','uluslararası'], 37.16, 38.79, NULL
FROM public.provinces p WHERE p.slug = 'sanliurfa';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Şanlıurfa', 'Halfeti', 'Halfeti Siyah Gül Şenliği', 'halfeti-siyah-gul',
  'Dünyanın başka hiçbir yerinde doğal yetişmeyen siyah güle adanmış Fırat kıyısı şenliği.',
  5, 5, 'doğa', ARRAY['siyah-gül','halfeti','fırat','nadir'], 37.27, 37.87, NULL
FROM public.provinces p WHERE p.slug = 'sanliurfa';

-- ŞIRNAK
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Şırnak', 'Uludere', 'Uludere Gençlik Huzur ve Bal Festivali', 'uludere-festival',
  'Kato Dağı eteklerinde spor, yerel ürünler ve konserler.',
  7, 8, 'kültür', ARRAY['gençlik','bal','dağ','konser'], 37.44, 42.38, NULL
FROM public.provinces p WHERE p.slug = 'sirnak';

-- TEKİRDAĞ
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Tekirdağ', 'Süleymanpaşa', 'Uluslararası Tekirdağ Kiraz Festivali', 'tekirdag-kiraz',
  '1962''den beri 60 yıldır düzenlenen Türkiye''nin en büyük kiraz festivali.',
  6, 6, 'yemek', ARRAY['kiraz','festival','gelenek'], 40.98, 27.51, NULL
FROM public.provinces p WHERE p.slug = 'tekirdag';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Tekirdağ', 'Şarköy', 'Şarköy Bağ Bozumu Festivali', 'sarköy-bag',
  'Türkiye''nin önemli üzüm bölgesinde bağ bozumunu kutlayan festival.',
  9, 9, 'yemek', ARRAY['üzüm','bağ-bozumu','şarap'], 40.61, 27.11, NULL
FROM public.provinces p WHERE p.slug = 'tekirdag';

-- TOKAT
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Tokat', 'Merkez', 'Tokat Tarihi Şehir Kültür Festivali', 'tokat-kultur',
  '"Yaşayan Osmanlı şehri" Tokat''ta tarihi konakları ve mutfağı tanıtan festival.',
  7, 7, 'kültür', ARRAY['osmanlı','konak','tarihi','mutfak'], 40.31, 36.55, NULL
FROM public.provinces p WHERE p.slug = 'tokat';

-- TRABZON
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Trabzon', 'Akçaabat', 'Akçaabat Kalandar Şenliği', 'kalandar',
  'Ocak''ın ortasında kutlanan Bizans kökenli kış geleneği; ateş, maskeler ve horon.',
  1, 1, 'geleneksel', ARRAY['bizans','kış','horon','ateş'], 40.99, 39.56, NULL
FROM public.provinces p WHERE p.slug = 'trabzon';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Trabzon', 'Maçka', 'Sümela Manastırı Meryem Ana Yortusu', 'sumela-ayin',
  'Her yıl 15 Ağustos''ta Ortodoks Hristiyanların kutladığı Meryem Ana Günü ayini.',
  8, 8, 'kültür', ARRAY['sümela','ortodoks','meryem-ana','ayin'], 40.69, 39.66, NULL
FROM public.provinces p WHERE p.slug = 'trabzon';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Trabzon', 'Akçaabat', 'Hıdırnebi Yayla Şenliği', 'hidirnebi-yayla',
  'Hıdırnebi Yaylası''nda tulumlu horon, köy sporu ve yöresel yemekler.',
  7, 7, 'geleneksel', ARRAY['hıdırnebi','yayla','horon','tulum'], 40.99, 39.56, NULL
FROM public.provinces p WHERE p.slug = 'trabzon';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Trabzon', 'Çaykara', 'Uzungöl Kültür ve Turizm Şenliği', 'uzungol-senlik',
  'Uzungöl Gölü kenarında fotoğrafçılık, müzik ve doğa etkinlikleri.',
  8, 8, 'kültür', ARRAY['uzungöl','göl','fotoğraf','doğa'], 40.62, 40.28, NULL
FROM public.provinces p WHERE p.slug = 'trabzon';

-- TUNCELİ
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Tunceli', 'Ovacık', 'Munzur Kültür ve Doğa Festivali', 'munzur-festival',
  'Munzur Vadisi Milli Parkı''nda doğa yürüyüşleri, konserler ve Alevi kültür etkinlikleri.',
  7, 7, 'doğa', ARRAY['munzur','vadi','alevi','doğa'], 39.21, 39.30, NULL
FROM public.provinces p WHERE p.slug = 'tunceli';

-- UŞAK
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Uşak', 'Merkez', 'Uşak Halı ve El Sanatları Festivali', 'usak-hali',
  'Türkiye''nin halıcılık merkezi Uşak''ta el dokuma halı festivali.',
  9, 9, 'sanat', ARRAY['halı','el-dokuma','zanaat'], 38.67, 29.41, NULL
FROM public.provinces p WHERE p.slug = 'usak';

-- VAN
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Van', 'Merkez', 'Van Gölü Festivali', 'van-golu',
  'Türkiye''nin en büyük gölü kıyısında Van kedisi ve yöresel kültür festivali.',
  7, 7, 'kültür', ARRAY['van-gölü','van-kedisi','kültür','doğa'], 38.50, 43.38, NULL
FROM public.provinces p WHERE p.slug = 'van';

INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Van', 'Gevaş', 'Akdamar Kilisesi Ermeni Ayini', 'akdamar-ayin',
  'Her yıl Eylül''de Van Gölü''ndeki Akdamar Adası''nda Ermeni Apostolik Kilisesi ayini.',
  9, 9, 'kültür', ARRAY['akdamar','ermeni','kilise','ayin'], 38.35, 43.08, NULL
FROM public.provinces p WHERE p.slug = 'van';

-- YALOVA
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Yalova', 'Merkez', 'Yalova Lale ve Çiçek Festivali', 'yalova-lale',
  'İstanbul''a yakın Yalova''da ilkbahar döneminde parkları çiçeklerle donatan festival.',
  4, 4, 'doğa', ARRAY['lale','çiçek','bahar','park'], 40.65, 29.27, NULL
FROM public.provinces p WHERE p.slug = 'yalova';

-- YOZGAT
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Yozgat', 'Merkez', 'Yozgat Kültür ve Turizm Festivali', 'yozgat-kultur',
  'İç Anadolu''nun bu sakin ilinde halk oyunları ve yöresel lezzetler.',
  7, 7, 'kültür', ARRAY['halk-oyunları','yöresel','kültür'], 39.82, 34.81, NULL
FROM public.provinces p WHERE p.slug = 'yozgat';

-- ZONGULDAK
INSERT INTO public.events (province_id, province_name, district, name, slug, description, month_start, month_end, category, tags, lat, lng, source_url)
SELECT p.id, 'Zonguldak', 'Merkez', 'Zonguldak Maden ve Kültür Festivali', 'zonguldak-maden',
  'Türkiye''nin kömür merkezi Zonguldak''ta maden kültürü ve işçi geleneği.',
  9, 9, 'kültür', ARRAY['maden','kömür','işçi','endüstri'], 41.45, 31.80, NULL
FROM public.provinces p WHERE p.slug = 'zonguldak';

-- ═══════════════════════════════════════════════════════════════════════════
-- pg_cron: Aylık Etkinlik Hatırlatıcısı
-- ═══════════════════════════════════════════════════════════════════════════
SELECT cron.schedule(
  'monthly-event-reminders',
  '0 9 1 * *',
  $$SELECT net.http_post(
    url := current_setting('app.supabase_url') || '/functions/v1/send_event_reminders',
    headers := jsonb_build_object(
      'Authorization', 'Bearer ' || current_setting('app.service_role_key'),
      'Content-Type', 'application/json'
    ),
    body := '{}'::jsonb
  ) as request_id;$$
);
