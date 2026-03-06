#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

function parseArgs(argv) {
  const args = { input: '', maxDistanceKm: 250, dryRun: false };
  for (let i = 2; i < argv.length; i += 1) {
    const a = argv[i];
    if (a === '--dry-run') args.dryRun = true;
    else if (a.startsWith('--input=')) args.input = a.slice('--input='.length);
    else if (a === '--input') args.input = argv[++i] ?? '';
    else if (a.startsWith('--max-distance-km=')) args.maxDistanceKm = Number(a.slice('--max-distance-km='.length)) || args.maxDistanceKm;
    else if (a === '--max-distance-km') args.maxDistanceKm = Number(argv[++i] ?? args.maxDistanceKm) || args.maxDistanceKm;
  }
  return args;
}

function loadEnv(envPath) {
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

function districtKey(province, district) {
  return `${slugifyTr(province)}:${slugifyTr(district)}`;
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

function escapeCsv(v) {
  const s = String(v ?? '');
  if (s.includes(',') || s.includes('"') || s.includes('\n')) {
    return `"${s.replaceAll('"', '""')}"`;
  }
  return s;
}

function readCsv(filePath) {
  const raw = fs.readFileSync(filePath, 'utf8');
  const lines = raw.split(/\r?\n/).filter((l) => l.trim().length > 0);
  if (lines.length < 2) return { headers: [], rows: [] };
  const headers = parseCsvLine(lines[0]).map((h) => h.trim());
  const rows = lines.slice(1).map((line) => {
    const cols = parseCsvLine(line);
    const row = {};
    headers.forEach((h, idx) => {
      row[h] = cols[idx] ?? '';
    });
    return row;
  });
  return { headers, rows };
}

function haversineKm(lat1, lon1, lat2, lon2) {
  const toRad = (d) => (d * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a = Math.sin(dLat / 2) ** 2
    + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
}

async function fetchDistrictCenters(supabaseUrl, apiKey) {
  const headers = { apikey: apiKey, Authorization: `Bearer ${apiKey}` };
  const pRes = await fetch(`${supabaseUrl}/rest/v1/provinces?select=id,slug`, { headers });
  if (!pRes.ok) throw new Error(`provinces fetch failed: ${pRes.status}`);
  const provinces = await pRes.json();
  const provinceSlugById = new Map(provinces.map((p) => [String(p.id), String(p.slug)]));

  const dRes = await fetch(`${supabaseUrl}/rest/v1/districts_with_coords?select=province_id,name,slug,lat,lng`, { headers });
  if (!dRes.ok) throw new Error(`districts_with_coords fetch failed: ${dRes.status}`);
  const districts = await dRes.json();
  const out = new Map();
  for (const d of districts) {
    const provinceSlug = provinceSlugById.get(String(d.province_id));
    const districtSlug = String(d.slug ?? '');
    const districtName = String(d.name ?? '');
    const lat = Number(d.lat ?? NaN);
    const lng = Number(d.lng ?? NaN);
    if (!provinceSlug || !districtSlug || !Number.isFinite(lat) || !Number.isFinite(lng)) continue;
    out.set(districtKey(provinceSlug, districtSlug), { lat, lng });
    out.set(districtKey(provinceSlug, districtName), { lat, lng });
  }
  return out;
}

async function main() {
  const args = parseArgs(process.argv);
  const repoRoot = path.resolve(process.cwd(), '..', '..');
  const inputPath = path.resolve(process.cwd(), args.input || path.join('..', '..', 'data', 'seed', 'curated_places.csv'));
  const env = { ...process.env, ...loadEnv(path.join(repoRoot, '.env')) };
  const apiKey = env.SUPABASE_ANON_KEY || env.SUPABASE_PUBLISHABLE_KEY || env.SUPABASE_SERVICE_ROLE_KEY;
  if (!env.SUPABASE_URL || !apiKey) {
    throw new Error('SUPABASE_URL and API key required for geofence cleanup');
  }

  const centers = await fetchDistrictCenters(env.SUPABASE_URL, apiKey);
  const parsed = readCsv(inputPath);
  const { headers, rows } = parsed;

  const keep = [];
  const removed = [];
  for (const r of rows) {
    const key = districtKey(r.province_slug || r.province, r.district_slug || r.district);
    const center = centers.get(key) || centers.get(districtKey(r.province, r.district));
    const lat = Number(r.lat ?? NaN);
    const lng = Number(r.lng ?? NaN);
    if (!center || !Number.isFinite(lat) || !Number.isFinite(lng)) {
      keep.push(r);
      continue;
    }
    const km = haversineKm(center.lat, center.lng, lat, lng);
    if (km > args.maxDistanceKm) {
      removed.push({ key, name: r.name, km: km.toFixed(1) });
    } else {
      keep.push(r);
    }
  }

  if (args.dryRun) {
    console.log(`Dry run remove=${removed.length} keep=${keep.length}`);
    console.log(removed.slice(0, 30));
    return;
  }

  const backupPath = `${inputPath}.bak`;
  fs.copyFileSync(inputPath, backupPath);
  const lines = [
    headers.join(','),
    ...keep.map((r) => headers.map((h) => escapeCsv(r[h] ?? '')).join(',')),
  ];
  fs.writeFileSync(inputPath, `${lines.join('\n')}\n`, 'utf8');
  console.log(`Cleaned curated CSV. removed=${removed.length} keep=${keep.length} backup=${backupPath}`);
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
