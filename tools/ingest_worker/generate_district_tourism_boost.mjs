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
  const args = { province: 'mugla', district: 'fethiye', radiusM: 32000, maxRows: 120 };
  for (let i = 2; i < argv.length; i += 1) {
    const a = argv[i];
    if (a.startsWith('--province=')) args.province = a.slice(11);
    else if (a.startsWith('--district=')) args.district = a.slice(11);
    else if (a.startsWith('--radius-m=')) args.radiusM = Number(a.slice(11)) || args.radiusM;
    else if (a.startsWith('--max-rows=')) args.maxRows = Number(a.slice(11)) || args.maxRows;
  }
  return args;
}

function slugifyTr(value) {
  return String(value ?? '')
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
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
  if (t.has('beach')) return 'beach';
  if (t.has('natural_feature') || t.has('park') || t.has('waterfall') || t.has('canyon')) return 'nature';
  if (t.has('museum') || t.has('tourist_attraction') || t.has('historical_landmark')) return 'historical';
  if (t.has('view_point') || t.has('point_of_interest')) return 'viewpoint';
  if (t.has('restaurant')) return 'food';
  if (t.has('cafe')) return 'cafe';
  if (t.has('lodging') || t.has('hotel') || t.has('resort_hotel')) return 'lodging';
  return 'activity';
}

function tags(types, category) {
  const s = new Set([category]);
  for (const t of (types || []).slice(0, 6)) s.add(String(t).toLowerCase());
  if (category === 'beach') {
    s.add('swim');
    s.add('sunset');
  }
  return [...s].slice(0, 10).join(',');
}

async function fetchJson(url, init) {
  const res = await fetch(url, { ...init, signal: AbortSignal.timeout(25000) });
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${await res.text()}`);
  return res.json();
}

async function main() {
  const args = parseArgs(process.argv);
  const env = { ...process.env, ...loadEnv() };
  const supabaseUrl = env.SUPABASE_URL;
  const key = env.SUPABASE_ANON_KEY || env.SUPABASE_PUBLISHABLE_KEY;
  const googleKey = env.GOOGLE_MAPS_API_KEY || env.GOOGLE_PLACES_API_KEY;
  if (!supabaseUrl || !key || !googleKey) throw new Error('SUPABASE_URL/SUPABASE key/GOOGLE key missing');

  const pSlug = slugifyTr(args.province);
  const dSlug = slugifyTr(args.district);
  const pRows = await fetchJson(`${supabaseUrl}/rest/v1/provinces?select=id,name,slug&slug=eq.${pSlug}`, {
    headers: { apikey: key, Authorization: `Bearer ${key}` },
  });
  if (!Array.isArray(pRows) || pRows.length === 0) throw new Error('province not found');
  const p = pRows[0];
  const dRows = await fetchJson(`${supabaseUrl}/rest/v1/districts_with_coords?select=id,name,slug,lat,lng&province_id=eq.${p.id}&slug=eq.${dSlug}`, {
    headers: { apikey: key, Authorization: `Bearer ${key}` },
  });
  if (!Array.isArray(dRows) || dRows.length === 0) throw new Error('district not found');
  const d = dRows[0];
  const lat = Number(d.lat);
  const lng = Number(d.lng);

  const queries = [
    'beach', 'bay', 'cove', 'island', 'marina', 'boat tour', 'viewpoint', 'sunset point',
    'waterfall', 'canyon', 'hiking area', 'paragliding', 'historical places', 'museum',
    'restaurant', 'cafe', 'breakfast', 'hotel', 'bungalow',
  ];

  const collected = new Map();
  for (const q of queries) {
    const body = {
      textQuery: `${q} in ${d.name}, ${p.name}, Turkey`,
      languageCode: 'tr',
      pageSize: 20,
      locationBias: { circle: { center: { latitude: lat, longitude: lng }, radius: args.radiusM } },
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
      for (const x of (json.places || [])) {
        const id = String(x.id || '');
        if (id && !collected.has(id)) collected.set(id, x);
      }
    } catch {}
    await new Promise((r) => setTimeout(r, 120));
  }

  const rows = [...collected.values()]
    .sort((a, b) => Number(b.userRatingCount || 0) - Number(a.userRatingCount || 0))
    .slice(0, args.maxRows)
    .filter((x) => Number(x.rating || 0) >= 4.0 && Number(x.userRatingCount || 0) >= 25)
    .map((x) => {
      const name = String(x.displayName?.text || '').trim();
      const c = mapCategory(x.types || []);
      return {
        name,
        province: p.name,
        district: d.name,
        category: c,
        lat: Number(x.location?.latitude || 0).toFixed(6),
        lng: Number(x.location?.longitude || 0).toFixed(6),
        price_level: (typeof x.priceLevel === 'number') ? Math.max(0, Math.min(4, Math.floor(x.priceLevel))) : 1,
        duration_min: (c === 'food' || c === 'cafe') ? 75 : 120,
        tags: tags(x.types || [], c),
        short_desc: `${d.name} için öne çıkan premium durak.`,
        history_tip: 'Bölge turizm rotasında yüksek ilgi görür.',
        eat_tip: `${d.name} merkezde yerel lezzetleri dene.`,
        pro_tip: 'Erken saatlerde daha sakin deneyim sunar.',
      };
    })
    .filter((r) => r.name.length > 1);

  const outPath = path.resolve(__dirname, '../../data/seed/incoming_batch.csv');
  const header = 'name,province,district,category,lat,lng,price_level,duration_min,tags,short_desc,history_tip,eat_tip,pro_tip';
  const lines = [header, ...rows.map((r) => [
    esc(r.name), esc(r.province), esc(r.district), esc(r.category), esc(r.lat), esc(r.lng), esc(r.price_level),
    esc(r.duration_min), esc(r.tags), esc(r.short_desc), esc(r.history_tip), esc(r.eat_tip), esc(r.pro_tip),
  ].join(','))];
  fs.writeFileSync(outPath, `${lines.join('\n')}\n`, 'utf8');
  console.log(`Generated district boost rows=${rows.length} province=${pSlug} district=${dSlug}`);
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
