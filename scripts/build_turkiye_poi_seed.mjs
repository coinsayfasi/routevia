#!/usr/bin/env node

const PROJECT_URL = process.env.PROJECT_URL;
const ANON_KEY = process.env.ANON_KEY;
const OUTPUT_PATH = process.env.OUTPUT_PATH || 'supabase/migrations/20260221001300_turkiye_poi_ingest.sql';
const PER_PROVINCE_LIMIT = Number(process.env.PER_PROVINCE_LIMIT || 80);
const PROVINCE_SLUGS = (process.env.PROVINCE_SLUGS || '').split(',').map((s) => s.trim()).filter(Boolean);

const headers = {
  apikey: ANON_KEY,
  Authorization: `Bearer ${ANON_KEY}`,
};

const categoryMap = [
  { match: (t) => t.tourism === 'museum' || t.tourism === 'gallery', category: 'museum', tags: ['rainy_day', 'history'] },
  { match: (t) => t.historic || t.tourism === 'attraction', category: 'historical', tags: ['history'] },
  { match: (t) => t.natural === 'beach', category: 'beach', tags: ['sunset', 'family'] },
  { match: (t) => ['bay', 'waterfall', 'peak', 'cape'].includes(t.natural), category: 'nature', tags: ['instagrammable'] },
  { match: (t) => t.tourism === 'viewpoint', category: 'viewpoint', tags: ['sunset', 'instagrammable'] },
  { match: (t) => t.shop === 'mall' || t.shop === 'marketplace', category: 'market', tags: ['budget', 'walkable'] },
  { match: (t) => t.amenity === 'cafe', category: 'cafe', tags: ['walkable'] },
  { match: (t) => ['restaurant', 'fast_food', 'food_court'].includes(t.amenity), category: 'food', tags: ['family'] },
  { match: (t) => t.leisure || t.sport || t.tourism === 'theme_park', category: 'activity', tags: ['family'] },
  { match: (t) => ['hotel', 'guest_house', 'hostel', 'motel', 'camp_site'].includes(t.tourism), category: 'lodging', tags: ['family'] },
];

function slugify(input) {
  return input
    .toLowerCase()
    .replaceAll('ç', 'c')
    .replaceAll('ğ', 'g')
    .replaceAll('ı', 'i')
    .replaceAll('ö', 'o')
    .replaceAll('ş', 's')
    .replaceAll('ü', 'u')
    .replace(/[^a-z0-9\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-');
}

function escapeSql(value) {
  return String(value ?? '').replaceAll("'", "''");
}

function haversineMeters(lat1, lon1, lat2, lon2) {
  const R = 6371000;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) ** 2 + Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * Math.sin(dLon / 2) ** 2;
  return 2 * R * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function toBestTime(tags, category) {
  if (tags.includes('sunset') || category === 'viewpoint' || category === 'beach') return 'sunset';
  if (category === 'museum' || category === 'historical') return 'morning';
  if (category === 'cafe' || category === 'food' || category === 'lodging') return 'day';
  return 'day';
}

function toDuration(category) {
  if (category === 'museum') return 90;
  if (category === 'historical') return 90;
  if (category === 'beach') return 120;
  if (category === 'viewpoint') return 45;
  if (category === 'market') return 60;
  if (category === 'food' || category === 'cafe') return 60;
  if (category === 'lodging') return 45;
  return 75;
}

function summaryFor(name, category, districtName) {
  const map = {
    museum: `${name}, ${districtName} icin temel kultur duraklarindan biridir.`,
    historical: `${name}, ${districtName} bolgesinde tarih ve fotograf icin oneri noktadir.`,
    nature: `${name}, ${districtName} cevresinde doga ve manzara deneyimi sunar.`,
    beach: `${name}, ${districtName} cevresinde deniz ve gun batimi keyfi icin ideal.`,
    viewpoint: `${name}, ${districtName} cevresinde yuksek manzara noktasi olarak one cikar.`,
    market: `${name}, ${districtName} yerel urunler ve yeme-icme icin guclu bir merkezdir.`,
    cafe: `${name}, ${districtName} icinde mola ve sosyal deneyim icin uygun bir noktadir.`,
    food: `${name}, ${districtName} gastronomi deneyimi icin populer bir secenektir.`,
    activity: `${name}, ${districtName} cevresinde aktif zaman gecirmek icin iyi bir secenektir.`,
    lodging: `${name}, ${districtName} ziyaretlerinde konaklama icin pratik bir secenektir.`,
  };
  const s = map[category] || `${name}, ${districtName} icin onerilen bir noktadir.`;
  return s.length <= 160 ? s : s.slice(0, 157) + '...';
}

async function fetchJson(path) {
  const r = await fetch(`${PROJECT_URL}${path}`, { headers });
  if (!r.ok) throw new Error(`Fetch failed ${path}: ${r.status}`);
  return r.json();
}

async function fetchProvinces() {
  const rows = await fetchJson('/rest/v1/provinces_with_coords?select=id,name,slug,plate_no,lat,lng&order=plate_no.asc');
  return rows;
}

async function fetchDistricts(provinceId) {
  return fetchJson(`/rest/v1/districts_with_coords?select=id,name,slug,lat,lng,province_id&province_id=eq.${provinceId}`);
}

async function fetchOverpass(lat, lng) {
  const q = `[out:json][timeout:60];(\nnode(around:45000,${lat},${lng})[name][tourism~"museum|gallery|attraction|viewpoint|theme_park|hotel|guest_house|hostel|motel|camp_site"];\nway(around:45000,${lat},${lng})[name][tourism~"museum|gallery|attraction|viewpoint|theme_park|hotel|guest_house|hostel|motel|camp_site"];\nnode(around:45000,${lat},${lng})[name][historic];\nway(around:45000,${lat},${lng})[name][historic];\nnode(around:45000,${lat},${lng})[name][natural~"beach|bay|waterfall|peak|cape"];\nway(around:45000,${lat},${lng})[name][natural~"beach|bay|waterfall|peak|cape"];\nnode(around:45000,${lat},${lng})[name][amenity~"restaurant|fast_food|food_court|cafe|bar|pub|nightclub"];\nway(around:45000,${lat},${lng})[name][amenity~"restaurant|fast_food|food_court|cafe|bar|pub|nightclub"];\nnode(around:45000,${lat},${lng})[name][leisure~"park|nature_reserve"];\nway(around:45000,${lat},${lng})[name][leisure~"park|nature_reserve"];\n);out center tags;`;
  const r = await fetch('https://overpass-api.de/api/interpreter', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded; charset=UTF-8' },
    body: `data=${encodeURIComponent(q)}`,
  });
  if (!r.ok) throw new Error(`Overpass failed ${r.status}`);
  return r.json();
}

function mapCategory(tags) {
  for (const r of categoryMap) {
    if (r.match(tags)) return { category: r.category, tags: [...r.tags] };
  }
  return { category: 'activity', tags: [] };
}

async function main() {
  if (!PROJECT_URL || !ANON_KEY) {
    throw new Error('PROJECT_URL and ANON_KEY env vars are required.');
  }
  const fs = await import('node:fs/promises');
  const provinces = await fetchProvinces();
  const chosen = PROVINCE_SLUGS.length > 0
    ? provinces.filter((p) => PROVINCE_SLUGS.includes(String(p.slug)))
    : provinces;

  const rows = [];

  for (const p of chosen) {
    const districts = await fetchDistricts(p.id);
    const centerLat = Number(p.lat);
    const centerLng = Number(p.lng);
    if (!Number.isFinite(centerLat) || !Number.isFinite(centerLng) || centerLat === 0) continue;

    let osm;
    try {
      osm = await fetchOverpass(centerLat, centerLng);
    } catch {
      continue;
    }

    const seen = new Set();
    const elements = (osm.elements || [])
      .map((el) => {
        const t = el.tags || {};
        const name = t.name;
        if (!name) return null;
        const lat = el.lat ?? el.center?.lat;
        const lng = el.lon ?? el.center?.lon;
        if (!lat || !lng) return null;
        const key = `${slugify(name)}:${Math.round(lat * 10000)}:${Math.round(lng * 10000)}`;
        if (seen.has(key)) return null;
        seen.add(key);

        const mapped = mapCategory(t);
        const nearestDistrict = districts
          .map((d) => ({ d, m: haversineMeters(lat, lng, Number(d.lat), Number(d.lng)) }))
          .sort((a, b) => a.m - b.m)[0]?.d;
        const districtName = nearestDistrict?.name || p.name;

        let extraTags = [...mapped.tags];
        if (t.amenity === 'nightclub' || t.amenity === 'bar' || t.amenity === 'pub') extraTags.push('nightlife');
        if (t.tourism === 'viewpoint') extraTags.push('sunset');
        if (mapped.category === 'lodging') extraTags.push('family');
        if (mapped.category === 'nature' || mapped.category === 'viewpoint') extraTags.push('hidden_gem');
        if (mapped.category === 'market' || mapped.category === 'food') extraTags.push('budget');
        if (mapped.category === 'beach') extraTags.push('sunset', 'family');
        if (mapped.category === 'cafe' || mapped.category === 'market' || mapped.category === 'historical') extraTags.push('walkable');
        extraTags = [...new Set(extraTags)].slice(0, 10);

        const slug = slugify(name);
        const fullSlug = `${slug}-${slugify(String(p.slug))}`;

        const image = t.image || t['wikimedia_commons'] || null;
        const imagePath = image && String(image).startsWith('http') ? String(image) : null;

        const distMeters = haversineMeters(lat, lng, centerLat, centerLng);
        const popularity = Math.max(40, 120 - Math.round(distMeters / 1000));
        const isFree = ['nature', 'viewpoint', 'market'].includes(mapped.category);

        return {
          provinceSlug: String(p.slug),
          districtSlug: String(nearestDistrict?.slug || ''),
          name: String(name).slice(0, 120),
          slug: fullSlug.slice(0, 120),
          category: mapped.category,
          lat,
          lng,
          shortSummary: summaryFor(String(name), mapped.category, String(districtName)),
          bestTime: toBestTime(extraTags, mapped.category),
          durationMin: toDuration(mapped.category),
          tags: extraTags,
          popularity,
          isFree,
          imagePath,
        };
      })
      .filter(Boolean)
      .sort((a, b) => b.popularity - a.popularity)
      .slice(0, PER_PROVINCE_LIMIT);

    rows.push(...elements);
  }

  const insertValues = rows.map((r) => {
    const tagsSql = `array[${r.tags.map((t) => `'${escapeSql(t)}'`).join(',')}]`;
    return `    ('${escapeSql(r.provinceSlug)}','${escapeSql(r.districtSlug)}','${escapeSql(r.name)}','${escapeSql(r.slug)}','${r.category}',${r.lat},${r.lng},'${escapeSql(r.shortSummary)}','${r.bestTime}',${r.durationMin},${tagsSql},${r.popularity},${r.isFree ? 'true' : 'false'},${r.imagePath ? `'${escapeSql(r.imagePath)}'` : 'null'})`;
  });

  const seedSource = insertValues.length > 0
    ? `with seed(province_slug,district_slug,name,slug,category,lat,lng,short_summary,best_time,duration_min,tags,popularity_score,is_free,image_path) as (\n  values\n${insertValues.join(',\n')}\n)`
    : `with seed(province_slug,district_slug,name,slug,category,lat,lng,short_summary,best_time,duration_min,tags,popularity_score,is_free,image_path) as (\n  select null::text, null::text, null::text, null::text, null::text,\n         null::double precision, null::double precision, null::text, null::text,\n         null::int, array[]::text[], null::int, null::boolean, null::text\n  where false\n)`;

  const sql = `${seedSource}\ninsert into public.places (province_id,district_id,name,slug,category,geog,short_summary,best_time,duration_min,tags,popularity_score,is_free)\nselect p.id,d.id,s.name,s.slug,s.category::public.place_category,st_setsrid(st_makepoint(s.lng,s.lat),4326)::geography,s.short_summary,s.best_time::public.best_time,s.duration_min,s.tags,s.popularity_score,s.is_free\nfrom seed s\njoin public.provinces p on p.slug = s.province_slug\nleft join public.districts d on d.slug = s.district_slug and d.province_id = p.id\non conflict (province_id, slug) do update set\n  district_id = excluded.district_id,\n  name = excluded.name,\n  category = excluded.category,\n  geog = excluded.geog,\n  short_summary = excluded.short_summary,\n  best_time = excluded.best_time,\n  duration_min = excluded.duration_min,\n  tags = excluded.tags,\n  popularity_score = excluded.popularity_score,\n  is_free = excluded.is_free;\n\ninsert into public.place_details (place_id, history_bullets, eat_drink_bullets, tips_bullets)\nselect pl.id,\n  case when pl.category in ('historical','museum') then array['Bolgenin tarihi katmanlarini anlamak icin giristeki bilgileri oku.','Sakin deneyim icin sabah saatlerini tercih et.','Ana rotayi once belirleyip detay noktalara gec.'] else array['Mevsime gore deneyim degisebilir; guncel durum icin yerelde sor.','Yakin cevrede ikinci duraklari kontrol et.'] end,\n  case when pl.category in ('food','cafe','market') then array['Yogun saatlerden once gitmek beklemeyi azaltir.','Yerel imza urunleri denemeye oncelik ver.','Nakit tasimak kucuk noktalarda hiz kazandirir.'] else array['Cevrede iyi yeme-icme noktasi genelde yuruus mesafesindedir.','Aksam planlarinda rezervasyon dusun.'] end,\n  case when pl.best_time='sunset' then array['Gun batimindan 30 dakika once konumlan.','Ruzgar icin hafif ustluk bulundur.','Geni aci cekim icin yuksek noktayi sec.'] else array['Toplu tasima saatlerini onceden kontrol et.','Su ve kisa atistirmalik tasimak ritmi korur.','60-90 dakikalik bloklarla planla.'] end\nfrom public.places pl\nwhere not exists (select 1 from public.place_details pd where pd.place_id=pl.id)\non conflict (place_id) do nothing;\n\nwith seed_media as (\n  select pl.id as place_id, s.image_path\n  from seed s\n  join public.provinces p on p.slug = s.province_slug\n  join public.places pl on pl.province_id = p.id and pl.slug = s.slug\n  where s.image_path is not null\n)\ninsert into public.place_media (place_id, storage_path, source, sort_order)\nselect sm.place_id, sm.image_path, 'osm', 0\nfrom seed_media sm\nwhere not exists (select 1 from public.place_media pm where pm.place_id = sm.place_id)\non conflict do nothing;\n`;

  await fs.writeFile(OUTPUT_PATH, sql, 'utf8');
  console.log(`Generated ${OUTPUT_PATH} with ${rows.length} places`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
