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

function parseArgs(argv) {
  const args = {
    input: path.resolve(__dirname, '../../data/seed/curated_places.csv'),
    provinces: [],
    batchSize: 250,
    dryRun: false,
  };
  for (let i = 2; i < argv.length; i += 1) {
    const a = argv[i];
    if (a.startsWith('--input=')) args.input = path.resolve(process.cwd(), a.slice('--input='.length));
    else if (a.startsWith('--provinces=')) args.provinces = a.slice('--provinces='.length).split(',').map((x) => x.trim().toLowerCase()).filter(Boolean);
    else if (a.startsWith('--batch=')) args.batchSize = Math.max(50, Math.min(1000, Number(a.slice('--batch='.length)) || args.batchSize));
    else if (a === '--dry-run') args.dryRun = true;
  }
  return args;
}

function parseCsvLine(line) {
  const out = [];
  let cur = '';
  let inQuotes = false;
  for (let i = 0; i < line.length; i += 1) {
    const ch = line[i];
    const next = i + 1 < line.length ? line[i + 1] : '';
    if (ch === '"') {
      if (inQuotes && next === '"') {
        cur += '"';
        i += 1;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }
    if (ch === ',' && !inQuotes) {
      out.push(cur.trim());
      cur = '';
      continue;
    }
    cur += ch;
  }
  out.push(cur.trim());
  return out;
}

function readCsv(filePath) {
  const raw = fs.readFileSync(filePath, 'utf8');
  const lines = raw.split(/\r?\n/).filter((l) => l.trim().length > 0);
  const headers = parseCsvLine(lines[0]);
  const rows = lines.slice(1).map((line) => {
    const cols = parseCsvLine(line);
    const r = {};
    headers.forEach((h, idx) => {
      r[h] = cols[idx] ?? '';
    });
    return r;
  });
  return { headers, rows };
}

function inferBestTime(tags) {
  const t = String(tags ?? '').toLowerCase();
  if (t.includes('sunset')) return 'sunset';
  if (t.includes('night')) return 'night';
  if (t.includes('morning') || t.includes('kahvalti') || t.includes('kahvalt')) return 'morning';
  return 'day';
}

function clampDuration(v) {
  const n = Number(v ?? 90);
  if (!Number.isFinite(n)) return 90;
  return Math.max(15, Math.min(240, Math.round(n)));
}

function clampPrice(v) {
  const n = Number(v ?? 1);
  if (!Number.isFinite(n)) return 1;
  return Math.max(0, Math.min(4, Math.round(n)));
}

function toTags(s) {
  return String(s ?? '')
    .split(',')
    .map((x) => x.trim().toLowerCase())
    .filter(Boolean)
    .slice(0, 12);
}

function mapCategoryKey(category, tags = []) {
  const c = String(category ?? '').toLowerCase();
  const t = new Set((tags || []).map((x) => String(x).toLowerCase()));
  if (c === 'museum') return 'museum';
  if (c === 'historical') return 'historical_site';
  if (c === 'nature') {
    if (t.has('waterfall')) return 'waterfall';
    if (t.has('canyon')) return 'canyon';
    if (t.has('lake')) return 'lake';
    if (t.has('national_park') || t.has('national-park')) return 'national_park';
    if (t.has('hike') || t.has('hiking') || t.has('trail') || t.has('hiking_trail')) return 'hiking_trail';
    return 'forest_park';
  }
  if (c === 'beach') return 'beach';
  if (c === 'viewpoint') {
    if (t.has('sunrise') || t.has('sunrise_spot')) return 'sunrise_spot';
    if (t.has('sunset') || t.has('sunset_spot')) return 'sunset_spot';
    return 'viewpoint';
  }
  if (c === 'food') {
    if (t.has('dessert')) return 'dessert';
    if (t.has('street_food') || t.has('street-food')) return 'street_food';
    return 'food_restaurant';
  }
  if (c === 'cafe') return 'cafe';
  if (c === 'lodging') return 'lodging_hotel';
  if (c === 'tour') return 'tour_city';
  if (c === 'ski') return 'ski_resort';
  if (c === 'waterfall') return 'waterfall';
  if (c === 'canyon') return 'canyon';
  return 'activity_family';
}

async function fetchJson(url, options) {
  const res = await fetch(url, options);
  const text = await res.text();
  const json = text ? JSON.parse(text) : {};
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${JSON.stringify(json)}`);
  return json;
}

async function fetchAll(url, baseHeaders, pageSize = 1000) {
  let from = 0;
  const out = [];
  while (true) {
    const to = from + pageSize - 1;
    const res = await fetch(url, {
      headers: {
        ...baseHeaders,
        Range: `${from}-${to}`,
        Prefer: 'count=exact',
      },
    });
    const text = await res.text();
    const json = text ? JSON.parse(text) : [];
    if (!res.ok) throw new Error(`HTTP ${res.status}: ${JSON.stringify(json)}`);
    if (!Array.isArray(json) || json.length === 0) break;
    out.push(...json);
    if (json.length < pageSize) break;
    from += pageSize;
  }
  return out;
}

function chunk(arr, size) {
  const out = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

function haversineMeters(lat1, lng1, lat2, lng2) {
  const R = 6371000;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a = Math.sin(dLat / 2) ** 2
    + Math.cos((lat1 * Math.PI) / 180) * Math.cos((lat2 * Math.PI) / 180) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

async function main() {
  const args = parseArgs(process.argv);
  const env = { ...process.env, ...loadEnv() };
  const url = env.SUPABASE_URL;
  const key = env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !key) throw new Error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY');
  if (!fs.existsSync(args.input)) throw new Error(`Input not found: ${args.input}`);

  const { rows } = readCsv(args.input);
  const filtered = args.provinces.length > 0
    ? rows.filter((r) => args.provinces.includes(String(r.province_slug ?? '').toLowerCase()))
    : rows;

  const headers = { apikey: key, Authorization: `Bearer ${key}`, 'Content-Type': 'application/json', Prefer: 'return=representation' };

  const provinces = await fetchJson(`${url}/rest/v1/provinces?select=id,slug`, { headers: { apikey: key, Authorization: `Bearer ${key}` } });
  const provinceBySlug = new Map(provinces.map((p) => [String(p.slug).toLowerCase(), p.id]));

  const districts = await fetchJson(`${url}/rest/v1/districts_with_coords?select=id,province_id,slug,lat,lng`, { headers: { apikey: key, Authorization: `Bearer ${key}` } });
  const districtByProvSlug = new Map();
  const districtsByProvince = new Map();
  for (const d of districts) {
    districtByProvSlug.set(`${d.province_id}:${String(d.slug).toLowerCase()}`, d.id);
    const list = districtsByProvince.get(d.province_id) || [];
    list.push({
      id: d.id,
      lat: Number(d.lat),
      lng: Number(d.lng),
      slug: String(d.slug).toLowerCase(),
    });
    districtsByProvince.set(d.province_id, list);
  }

  const placeRowMap = new Map();
  const detailsRowMap = new Map();

  let districtFromGeoFixes = 0;
  let districtFromSlugMisses = 0;
  let districtUnresolved = 0;

  for (const r of filtered) {
    const provinceSlug = String(r.province_slug ?? '').toLowerCase();
    const provinceId = provinceBySlug.get(provinceSlug);
    if (!provinceId) continue;

    const districtSlug = String(r.district_slug ?? '').toLowerCase();
    const lat = Number(r.lat ?? NaN);
    const lng = Number(r.lng ?? NaN);
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) continue;

    let districtId = districtByProvSlug.get(`${provinceId}:${districtSlug}`) ?? null;
    const provinceDistricts = districtsByProvince.get(provinceId) || [];
    let nearestDistrict = null;
    let nearestDistance = Number.POSITIVE_INFINITY;
    for (const d of provinceDistricts) {
      if (!Number.isFinite(d.lat) || !Number.isFinite(d.lng)) continue;
      const dist = haversineMeters(lat, lng, d.lat, d.lng);
      if (dist < nearestDistance) {
        nearestDistance = dist;
        nearestDistrict = d;
      }
    }
    if (!districtId && nearestDistrict) {
      districtId = nearestDistrict.id;
      districtFromSlugMisses += 1;
    } else if (districtId && nearestDistrict && nearestDistance <= 60000 && districtId !== nearestDistrict.id) {
      districtId = nearestDistrict.id;
      districtFromGeoFixes += 1;
    }
    if (!districtId) districtUnresolved += 1;

    const shortSummary = String(r.short_summary ?? '').trim().slice(0, 160);
    if (!shortSummary) continue;

    const tags = toTags(r.tags);
    const category = String(r.category ?? 'activity').trim().toLowerCase();
    const row = {
      province_id: provinceId,
      district_id: districtId,
      name: String(r.name ?? '').trim(),
      slug: String(r.slug ?? '').trim(),
      category,
      category_key: mapCategoryKey(category, tags),
      geog: `SRID=4326;POINT(${lng} ${lat})`,
      short_summary: shortSummary,
      short_desc: shortSummary,
      best_time: inferBestTime(r.tags),
      duration_min: clampDuration(r.duration_min),
      tags,
      popularity_score: Number(r.popularity_score ?? 170) || 170,
      is_free: String(r.is_free ?? 'false').toLowerCase() === 'true',
      price_level: clampPrice(r.price_level),
      is_published: false,
      published_at: null,
      source_kind: 'curated',
      source_url: String(r.source_url ?? '').trim() || null,
      province: String(r.province ?? '').trim() || null,
      district: String(r.district ?? '').trim() || null,
      lat,
      lng,
      hap_history: String(r.history_tip ?? '').trim() || null,
      hap_eat: String(r.eat_tip ?? '').trim() || null,
      hap_tips: String(r.pro_tip ?? '').trim() || null,
    };
    if (!row.name || !row.slug) continue;

    const uniqueKey = `${provinceId}:${row.slug}`;
    placeRowMap.set(uniqueKey, row);
    detailsRowMap.set(uniqueKey, {
      province_id: provinceId,
      slug: row.slug,
      history_bullets: [String(r.history_tip ?? '').trim()].filter(Boolean).slice(0, 1),
      eat_drink_bullets: [String(r.eat_tip ?? '').trim()].filter(Boolean).slice(0, 1),
      tips_bullets: [String(r.pro_tip ?? '').trim()].filter(Boolean).slice(0, 1),
    });
  }

  const placeRows = [...placeRowMap.values()];
  const detailsRows = [...detailsRowMap.values()];

  console.log(`[curated->db] rows_filtered=${filtered.length} valid_places=${placeRows.length} provinces=${args.provinces.join(',') || 'ALL'}`);
  console.log(`[curated->db] district_geo_fixes=${districtFromGeoFixes} district_slug_miss_fallback=${districtFromSlugMisses} district_unresolved=${districtUnresolved}`);
  if (args.dryRun) return;

  let upserted = 0;
  for (const part of chunk(placeRows, args.batchSize)) {
    const data = await fetchJson(
      `${url}/rest/v1/places?on_conflict=province_id,slug`,
      { method: 'POST', headers: { ...headers, Prefer: 'resolution=merge-duplicates,return=representation' }, body: JSON.stringify(part) },
    );
    upserted += Array.isArray(data) ? data.length : 0;
  }

  const provinceIds = [...new Set(placeRows.map((p) => p.province_id))];
  const placeLookup = await fetchAll(
    `${url}/rest/v1/places?select=id,province_id,slug,source_kind&province_id=in.(${provinceIds.join(',')})&source_kind=eq.curated`,
    { apikey: key, Authorization: `Bearer ${key}` },
  );
  const placeIdByKey = new Map(placeLookup.map((p) => [`${p.province_id}:${p.slug}`, p.id]));

  const detailUpserts = detailsRows
    .map((d) => {
      const placeId = placeIdByKey.get(`${d.province_id}:${d.slug}`);
      if (!placeId) return null;
      return {
        place_id: placeId,
        history_bullets: d.history_bullets,
        eat_drink_bullets: d.eat_drink_bullets,
        tips_bullets: d.tips_bullets,
      };
    })
    .filter(Boolean);

  let detailsCount = 0;
  for (const part of chunk(detailUpserts, args.batchSize)) {
    const data = await fetchJson(
      `${url}/rest/v1/place_details?on_conflict=place_id`,
      { method: 'POST', headers: { ...headers, Prefer: 'resolution=merge-duplicates,return=representation' }, body: JSON.stringify(part) },
    );
    detailsCount += Array.isArray(data) ? data.length : 0;
  }

  const importedPlaceIds = [...new Set(
    placeRows
      .map((p) => placeIdByKey.get(`${p.province_id}:${p.slug}`))
      .filter(Boolean),
  )];
  const existingMedia = [];
  for (const part of chunk(importedPlaceIds, 200)) {
    if (part.length === 0) continue;
    const rows = await fetchJson(
      `${url}/rest/v1/place_media?select=place_id&place_id=in.(${part.join(',')})`,
      { headers: { apikey: key, Authorization: `Bearer ${key}` } },
    );
    if (Array.isArray(rows)) existingMedia.push(...rows);
  }
  const hasMedia = new Set((existingMedia || []).map((m) => m.place_id));
  const missingMediaIds = importedPlaceIds.filter((id) => !hasMedia.has(id));

  let mediaInserted = 0;
  const placeholderPath = 'curated/defaults/placeholder.jpg';
  for (const part of chunk(missingMediaIds, args.batchSize)) {
    const payload = part.map((placeId) => ({
      place_id: placeId,
      storage_path: placeholderPath,
      source_kind: 'curated',
      sort_order: 999,
      is_primary: false,
      attribution: 'Routevia curated placeholder',
    }));
    const data = await fetchJson(
      `${url}/rest/v1/place_media`,
      { method: 'POST', headers: { ...headers, Prefer: 'return=representation' }, body: JSON.stringify(payload) },
    );
    mediaInserted += Array.isArray(data) ? data.length : 0;
  }

  let published = 0;
  for (const part of chunk(importedPlaceIds, 120)) {
    const data = await fetchJson(
      `${url}/rest/v1/places?id=in.(${part.join(',')})`,
      {
        method: 'PATCH',
        headers: { ...headers, Prefer: 'return=representation' },
        body: JSON.stringify({ is_published: true, published_at: new Date().toISOString() }),
      },
    );
    published += Array.isArray(data) ? data.length : 0;
  }

  console.log(`[curated->db] places_upserted=${upserted} details_upserted=${detailsCount} media_inserted=${mediaInserted} published=${published}`);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
