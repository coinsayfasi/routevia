#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

function loadEnv() {
  const envPath = path.resolve(__dirname, '../../.env');
  const out = {};
  if (!fs.existsSync(envPath)) return out;
  for (const line of fs.readFileSync(envPath, 'utf8').split(/\r?\n/)) {
    const t = line.trim();
    if (!t || t.startsWith('#')) continue;
    const i = t.indexOf('=');
    if (i <= 0) continue;
    out[t.slice(0, i).trim()] = t.slice(i + 1).trim().replace(/^"|"$/g, '');
  }
  return out;
}

function slugifyTr(value) {
  return String(value ?? '')
    .toLowerCase()
    .replaceAll('ı', 'i')
    .replaceAll('ğ', 'g')
    .replaceAll('ü', 'u')
    .replaceAll('ş', 's')
    .replaceAll('ö', 'o')
    .replaceAll('ç', 'c')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function esc(v) {
  const s = String(v ?? '');
  if (s.includes(',') || s.includes('"') || s.includes('\n')) return `"${s.replaceAll('"', '""')}"`;
  return s;
}

function mapCategory(types) {
  const t = new Set((types || []).map((x) => String(x).toLowerCase()));
  if (t.has('museum')) return 'museum';
  if (t.has('tourist_attraction') || t.has('amusement_park')) return 'activity';
  if (t.has('beach')) return 'beach';
  if (t.has('park') || t.has('natural_feature') || t.has('waterfall') || t.has('canyon')) return 'nature';
  if (t.has('restaurant') || t.has('meal_takeaway')) return 'food';
  if (t.has('cafe') || t.has('coffee_shop') || t.has('bakery')) return 'cafe';
  if (t.has('lodging') || t.has('hotel') || t.has('resort_hotel')) return 'lodging';
  if (t.has('mosque') || t.has('church') || t.has('synagogue') || t.has('historical_landmark')) return 'historical';
  if (t.has('point_of_interest')) return 'viewpoint';
  return 'activity';
}

function inferTags(types, category) {
  const tags = new Set([category]);
  for (const t of (types || []).slice(0, 4)) tags.add(String(t).toLowerCase());
  if (category === 'viewpoint') tags.add('sunset');
  if (category === 'beach') tags.add('swim');
  if (category === 'food' || category === 'cafe') tags.add('local');
  return [...tags].slice(0, 8).join(',');
}

function qualityPass(category, rating, reviews) {
  const r = Number(rating || 0);
  const rc = Number(reviews || 0);
  if (['food', 'cafe', 'lodging'].includes(category)) return (r >= 4.2 && rc >= 80);
  return (r >= 4.0 && rc >= 25);
}

function tipsFor(category, districtName) {
  const base = {
    nature: ['Doğa odaklı Antalya durağı.', 'Bölgenin doğal yapısı korunmaktadır.', `${districtName} çevresinde yemek planını önceden yap.`, 'Sabah saatlerinde daha sakin deneyim sunar.'],
    beach: ['Antalya kıyı hattında popüler deniz noktası.', 'Bölge yaz sezonunda yoğun ziyaret alır.', `${districtName} sahilinde yeme içme seçenekleri değişkendir.`, 'Gün batımı saatinde manzara güçlenir.'],
    historical: ['Antalya tarih rotasının güçlü duraklarından biri.', 'Bölge antik ve Osmanlı dönem izleri taşır.', `${districtName} merkezinde yerel mutfak alternatiflerini dene.`, 'Kalabalıktan kaçmak için erken saatleri seç.'],
    viewpoint: ['Şehir ve kıyı manzarası sunan seyir noktası.', 'Bölge fotoğraf rotalarıyla öne çıkar.', 'Kısa mola için yakında kafe alternatifi olabilir.', 'Gün batımından önce konumlan.'],
    food: ['Yerel yeme içme deneyimi için öne çıkan nokta.', 'Bölge gastronomi hattında görünür.', 'İmza ürünleri denemeyi unutma.', 'Yoğun saatlerde rezervasyon faydalı olur.'],
    cafe: ['Kahve ve kısa mola için tercih edilen nokta.', 'Semt yaşamının parçası olarak öne çıkar.', 'Kahve yanında yerel tatlıları dene.', 'Sabah saatlerinde daha sakin olabilir.'],
    lodging: ['Konaklama odaklı Antalya durağı.', 'Turizm sezonunda doluluk yüksek olabilir.', 'Yakın çevrede yeme içme noktalarını kontrol et.', 'Check-in saatlerini önceden planla.'],
    museum: ['Kültürel içerik sunan müze durağı.', 'Bölgenin tarihsel katmanlarını yansıtır.', 'Müze sonrası merkezde yemek molası verilebilir.', 'Bilet ve ziyaret saatini kontrol et.'],
    activity: ['İlçe içinde deneyim odaklı popüler nokta.', 'Yerel yaşam ve ziyaret akışı burada yoğunlaşır.', 'Yakında farklı yeme içme seçenekleri bulunur.', 'Akşam saatlerinde atmosfer daha canlı olabilir.'],
  };
  return base[category] || base.activity;
}

async function fetchJson(url, init) {
  const res = await fetch(url, { ...init, signal: AbortSignal.timeout(20000) });
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${await res.text()}`);
  return res.json();
}

async function main() {
  const env = { ...process.env, ...loadEnv() };
  const supabaseUrl = env.SUPABASE_URL;
  const serviceKey = env.SUPABASE_SERVICE_ROLE_KEY;
  const googleKey = env.GOOGLE_MAPS_API_KEY || env.GOOGLE_PLACES_API_KEY;
  if (!supabaseUrl || !serviceKey || !googleKey) throw new Error('Missing SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY/GOOGLE key');

  const pRows = await fetchJson(`${supabaseUrl}/rest/v1/provinces?select=id,name,slug&slug=eq.antalya`, {
    headers: { apikey: serviceKey },
  });
  if (!Array.isArray(pRows) || pRows.length === 0) throw new Error('Antalya province not found');
  const province = pRows[0];

  const districts = await fetchJson(`${supabaseUrl}/rest/v1/districts_with_coords?select=id,name,slug,lat,lng&province_id=eq.${province.id}&order=name.asc`, {
    headers: { apikey: serviceKey },
  });
  if (!Array.isArray(districts) || districts.length === 0) throw new Error('No districts for Antalya');

  const queries = [
    'tourist attractions', 'museum', 'historical places', 'beach', 'viewpoint', 'nature park', 'waterfall', 'restaurant', 'cafe', 'hotel',
  ];

  const rows = [];
  const seen = new Set();
  let reqCount = 0;

  for (const d of districts) {
    const districtName = d.name;
    const districtSlug = d.slug;
    const lat = Number(d.lat);
    const lng = Number(d.lng);
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) continue;

    const collected = new Map();

    for (const q of queries) {
      const body = {
        textQuery: `${q} in ${districtName}, Antalya, Turkey`,
        languageCode: 'tr',
        pageSize: 20,
        locationBias: { circle: { center: { latitude: lat, longitude: lng }, radius: 22000 } },
      };

      try {
        const json = await fetchJson('https://places.googleapis.com/v1/places:searchText', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': googleKey,
            'X-Goog-FieldMask': 'places.id,places.displayName,places.location,places.types,places.rating,places.userRatingCount,places.priceLevel',
          },
          body: JSON.stringify(body),
        });
        reqCount += 1;
        for (const p of (json.places || [])) {
          const id = String(p.id || '');
          if (!id) continue;
          if (!collected.has(id)) collected.set(id, p);
        }
      } catch (_) {}

      await new Promise((r) => setTimeout(r, 180));
    }

    const top = [...collected.values()]
      .sort((a, b) => (Number(b.userRatingCount || 0) - Number(a.userRatingCount || 0)))
      .slice(0, 14);

    for (const p of top) {
      const name = String(p.displayName?.text || '').trim();
      const pLat = Number(p.location?.latitude ?? NaN);
      const pLng = Number(p.location?.longitude ?? NaN);
      if (!name || !Number.isFinite(pLat) || !Number.isFinite(pLng)) continue;

      const types = (p.types || []).map((x) => String(x));
      const category = mapCategory(types);
      const rating = Number(p.rating || 0);
      const reviews = Number(p.userRatingCount || 0);
      if (!qualityPass(category, rating, reviews)) continue;

      const slug = `${slugifyTr(name)}-${slugifyTr(districtSlug)}`.slice(0, 120);
      const key = `antalya:${slug}`;
      if (seen.has(key)) continue;
      seen.add(key);

      const tips = tipsFor(category, districtName);
      const priceLevel = (typeof p.priceLevel === 'number') ? Math.max(0, Math.min(4, Math.floor(p.priceLevel))) : 1;
      const duration = category === 'activity' ? 90 : (category === 'food' || category === 'cafe' ? 75 : 120);

      rows.push({
        name,
        province: 'Antalya',
        district: districtName,
        category,
        lat: pLat.toFixed(6),
        lng: pLng.toFixed(6),
        price_level: priceLevel,
        duration_min: duration,
        tags: inferTags(types, category),
        short_desc: tips[0],
        history_tip: tips[1],
        eat_tip: tips[2],
        pro_tip: tips[3],
      });
    }
  }

  const outPath = path.resolve(__dirname, '../../data/seed/incoming_batch.csv');
  const header = 'name,province,district,category,lat,lng,price_level,duration_min,tags,short_desc,history_tip,eat_tip,pro_tip';
  const lines = [header, ...rows.map((r) => [
    esc(r.name), esc(r.province), esc(r.district), esc(r.category), esc(r.lat), esc(r.lng), esc(r.price_level), esc(r.duration_min),
    esc(r.tags), esc(r.short_desc), esc(r.history_tip), esc(r.eat_tip), esc(r.pro_tip),
  ].join(','))];

  fs.writeFileSync(outPath, `${lines.join('\n')}\n`, 'utf8');
  console.log(`Generated Antalya batch rows=${rows.length}, requests=${reqCount}, file=${outPath}`);
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
