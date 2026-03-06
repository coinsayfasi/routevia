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

function argsMap(argv) {
  const m = new Map();
  for (const a of argv.slice(2)) {
    if (!a.startsWith('--')) continue;
    const [k, v] = a.replace(/^--/, '').split('=');
    m.set(k, v ?? 'true');
  }
  return m;
}

function sleep(ms) { return new Promise((r) => setTimeout(r, ms)); }

async function fetchJson(url, options = {}) {
  const res = await fetch(url, options);
  const text = await res.text();
  let data = null;
  try { data = text ? JSON.parse(text) : null; } catch { data = { raw: text }; }
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${JSON.stringify(data)}`);
  return data;
}

async function headCount(url, key, table, filters = []) {
  const qs = filters.length ? `&${filters.join('&')}` : '';
  const res = await fetch(`${url}/rest/v1/${table}?select=id${qs}`, {
    method: 'HEAD',
    headers: { apikey: key, Authorization: `Bearer ${key}`, Prefer: 'count=exact' },
  });
  const range = res.headers.get('content-range') || '*/0';
  return Number((range.split('/')[1] || '0').trim()) || 0;
}

async function nearbyCount(url, anonKey, lat, lng, provinceSlug, districtSlug = null, radiusM = 10000) {
  const body = {
    lat,
    lng,
    radius_m: radiusM,
    province_slug: provinceSlug,
    ...(districtSlug ? { district_slug: districtSlug } : {}),
  };
  const data = await fetchJson(`${url}/functions/v1/nearby_places`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', apikey: anonKey },
    body: JSON.stringify(body),
  });
  return Number(Array.isArray(data?.items) ? data.items.length : 0);
}

async function runProvinceSync({ url, anonKey, serviceKey, province, batch, maxOffset, sleepMs }) {
  let scanned = 0;
  let inserted = 0;
  let linked = 0;
  let calls = 0;

  for (let offset = 0; offset <= maxOffset; offset += batch) {
    const data = await fetchJson(`${url}/functions/v1/admin_build_clean_dataset_from_raw`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        apikey: anonKey,
        'x-worker-secret': serviceKey,
      },
      body: JSON.stringify({
        raw_table: 'places',
        province_slug: province.slug,
        province_name: province.name,
        limit: batch,
        offset,
      }),
    });

    const s = Number(data?.scanned ?? 0);
    const i = Number(data?.inserted ?? 0);
    const l = Number(data?.linked ?? 0);
    calls += 1;
    scanned += s;
    inserted += i;
    linked += l;
    if (s === 0) break;
    if (sleepMs > 0) await sleep(sleepMs);
  }

  return { scanned, inserted, linked, calls };
}

async function main() {
  const env = { ...process.env, ...loadEnv() };
  const args = argsMap(process.argv);
  const url = env.SUPABASE_URL;
  const anonKey = env.SUPABASE_ANON_KEY;
  const serviceKey = env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !anonKey || !serviceKey) throw new Error('SUPABASE_URL/SUPABASE_ANON_KEY/SUPABASE_SERVICE_ROLE_KEY eksik');

  const provincesArg = (args.get('provinces') || '').trim();
  const provinceSlugs = provincesArg
    ? provincesArg.split(',').map((s) => s.trim()).filter(Boolean)
    : ['istanbul', 'antalya', 'mugla', 'izmir', 'ankara', 'trabzon', 'konya', 'aydin', 'denizli', 'bursa', 'canakkale', 'edirne', 'nevsehir'];

  const threshold = Math.max(1, Number(args.get('threshold') || 120));
  const batch = Math.max(100, Math.min(5000, Number(args.get('batch') || 1000)));
  const maxOffset = Math.max(1000, Number(args.get('max-offset') || 50000));
  const sleepMs = Math.max(0, Number(args.get('sleep-ms') || 100));

  let allProvinces = [];
  try {
    allProvinces = await fetchJson(
      `${url}/rest/v1/provinces_with_coords?select=id,name,slug,lat,lng&order=name.asc`,
      { headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` } },
    );
  } catch (_) {
    allProvinces = await fetchJson(
      `${url}/rest/v1/provinces?select=id,name,slug&order=name.asc`,
      { headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` } },
    );
  }

  const target = allProvinces.filter((p) => provinceSlugs.includes(p.slug));
  if (target.length === 0) throw new Error('Hedef il bulunamadı');

  const report = {
    started_at: new Date().toISOString(),
    threshold,
    provinces: [],
  };

  for (const p of target) {
    const beforeDb = await headCount(url, serviceKey, 'places_clean', [`province_id=eq.${p.id}`]);
    const beforeNearby = (p.lat != null && p.lng != null)
      ? await nearbyCount(url, anonKey, Number(p.lat), Number(p.lng), p.slug)
      : 0;

    const sync = beforeDb < threshold
      ? await runProvinceSync({ url, anonKey, serviceKey, province: p, batch, maxOffset, sleepMs })
      : { scanned: 0, inserted: 0, linked: 0, calls: 0 };

    const afterDb = await headCount(url, serviceKey, 'places_clean', [`province_id=eq.${p.id}`]);
    const afterNearby = (p.lat != null && p.lng != null)
      ? await nearbyCount(url, anonKey, Number(p.lat), Number(p.lng), p.slug)
      : 0;

    const row = {
      slug: p.slug,
      province: p.name,
      before_db_count: beforeDb,
      after_db_count: afterDb,
      db_delta: afterDb - beforeDb,
      before_marker_count: beforeNearby,
      after_marker_count: afterNearby,
      marker_delta: afterNearby - beforeNearby,
      ...sync,
    };
    report.provinces.push(row);
    console.log(JSON.stringify(row));
  }

  report.finished_at = new Date().toISOString();
  const outDir = path.resolve(__dirname, '../../docs/reports');
  fs.mkdirSync(outDir, { recursive: true });
  const outPath = path.join(outDir, `coverage_wave_${Date.now()}.json`);
  fs.writeFileSync(outPath, `${JSON.stringify(report, null, 2)}\n`);
  console.log(JSON.stringify({ ok: true, report: outPath, total: report.provinces.length }));
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
