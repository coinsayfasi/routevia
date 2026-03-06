#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

function parseArgs(argv) {
  const args = { input: '', output: '', dryRun: false, maxDistanceKm: 250 };
  for (let i = 2; i < argv.length; i += 1) {
    const a = argv[i];
    if (a === '--dry-run') args.dryRun = true;
    else if (a.startsWith('--input=')) args.input = a.slice('--input='.length);
    else if (a === '--input') args.input = argv[++i] ?? '';
    else if (a.startsWith('--output=')) args.output = a.slice('--output='.length);
    else if (a === '--output') args.output = argv[++i] ?? '';
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
    .replaceAll('İ', 'i')
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

function haversineKm(lat1, lon1, lat2, lon2) {
  const toRad = (d) => (d * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a = Math.sin(dLat / 2) ** 2
    + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
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

function normalizeCategory(v) {
  const c = String(v ?? '').trim().toLowerCase();
  const allowed = new Set([
    'museum','historical','nature','beach','viewpoint','market','cafe','food','activity','lodging','tour','ski','waterfall','canyon',
  ]);
  if (allowed.has(c)) return c;
  if (c.includes('restaurant')) return 'food';
  if (c.includes('coffee')) return 'cafe';
  return 'activity';
}

function inferBestTime(tags) {
  const t = String(tags ?? '').toLowerCase();
  if (t.includes('sunset')) return 'sunset';
  if (t.includes('night')) return 'night';
  if (t.includes('morning') || t.includes('kahvalti') || t.includes('kahvalt')) return 'morning';
  return 'day';
}

function asBoolFromPrice(price) {
  const n = Number(price ?? 2);
  return Number.isFinite(n) && n <= 1 ? 'true' : 'false';
}

function mapInputRow(r) {
  const name = (r.name ?? '').trim();
  const province = (r.province ?? '').trim();
  const district = (r.district ?? '').trim();
  if (!name || !province || !district) return null;

  const provinceSlug = slugifyTr(province);
  const districtSlug = slugifyTr(district);
  const slug = `${slugifyTr(name)}-${districtSlug}`.slice(0, 120);
  const tags = String(r.tags ?? '').replaceAll('|', ',');
  const short = String(r.short_desc ?? r.short_summary ?? `${name} için curated öneri.`).slice(0, 160);
  const duration = Math.max(15, Math.min(240, Number(r.duration_min ?? 90) || 90));
  const priceLevel = Math.max(0, Math.min(4, Number(r.price_level ?? 1) || 1));

  return {
    province_slug: provinceSlug,
    district_slug: districtSlug,
    province,
    district,
    name,
    slug,
    category: normalizeCategory(r.category),
    lat: Number(r.lat ?? 0),
    lng: Number(r.lng ?? 0),
    price_level: priceLevel,
    duration_min: duration,
    tags,
    short_summary: short,
    history_tip: String(r.history_tip ?? '').slice(0, 160),
    eat_tip: String(r.eat_tip ?? '').slice(0, 160),
    pro_tip: String(r.pro_tip ?? '').slice(0, 160),
    is_free: asBoolFromPrice(priceLevel),
    popularity_score: 170,
    source_url: '',
    best_time: inferBestTime(tags),
  };
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
  const inputPath = path.resolve(process.cwd(), args.input || path.join('..', '..', 'data', 'seed', 'incoming_batch.csv'));
  const outputPath = path.resolve(process.cwd(), args.output || path.join('..', '..', 'data', 'seed', 'curated_places.csv'));
  const env = {
    ...process.env,
    ...loadEnv(path.join(repoRoot, '.env')),
  };

  if (!fs.existsSync(inputPath)) {
    console.error(`Input file not found: ${inputPath}`);
    process.exit(1);
  }
  if (!fs.existsSync(outputPath)) {
    console.error(`Target curated CSV not found: ${outputPath}`);
    process.exit(1);
  }

  const incoming = readCsv(inputPath).rows;
  const targetParsed = readCsv(outputPath);
  const targetHeaders = targetParsed.headers;
  const targetRows = targetParsed.rows;

  const keySet = new Set(
    targetRows.map((r) => `${r.province_slug || ''}:${r.slug || ''}`),
  );
  let centerByDistrict = null;
  const apiKey = env.SUPABASE_ANON_KEY || env.SUPABASE_PUBLISHABLE_KEY || env.SUPABASE_SERVICE_ROLE_KEY;
  if (env.SUPABASE_URL && apiKey) {
    try {
      centerByDistrict = await fetchDistrictCenters(env.SUPABASE_URL, apiKey);
    } catch (e) {
      console.warn(`Geofence disabled: ${String(e.message || e)}`);
    }
  } else {
    console.warn('Geofence disabled: SUPABASE_URL or API key missing');
  }

  const mapped = incoming
    .map(mapInputRow)
    .filter(Boolean)
    .filter((r) => Number.isFinite(r.lat) && Number.isFinite(r.lng));

  const deduped = [];
  let skippedGeo = 0;
  for (const r of mapped) {
    if (centerByDistrict) {
      const center = centerByDistrict.get(districtKey(r.province_slug || r.province, r.district_slug || r.district))
        || centerByDistrict.get(districtKey(r.province, r.district));
      if (center) {
        const km = haversineKm(center.lat, center.lng, r.lat, r.lng);
        if (km > args.maxDistanceKm) {
          skippedGeo += 1;
          continue;
        }
      }
    }
    const key = `${r.province_slug}:${r.slug}`;
    if (keySet.has(key)) continue;
    keySet.add(key);
    deduped.push(r);
  }

  const finalHeaders = targetHeaders.length > 0
    ? targetHeaders
    : [
      'province_slug','district_slug','province','district','name','slug','category','lat','lng','price_level','duration_min','tags','short_summary','history_tip','eat_tip','pro_tip','is_free','popularity_score','source_url',
    ];

  const lines = deduped.map((r) => finalHeaders.map((h) => escapeCsv(r[h] ?? '')).join(','));

  if (args.dryRun) {
    console.log(`Dry run: mapped=${mapped.length}, appended=${deduped.length}, skipped=${mapped.length - deduped.length}, skipped_geo=${skippedGeo}`);
    console.log(`Output target: ${outputPath}`);
    process.exit(0);
  }

  if (lines.length === 0) {
    console.log('No new rows to append (all duplicates or invalid).');
    process.exit(0);
  }

  fs.appendFileSync(outputPath, `\n${lines.join('\n')}\n`, 'utf8');
  console.log(`Appended ${lines.length} curated rows to ${path.relative(repoRoot, outputPath)} (mapped=${mapped.length}, skipped_geo=${skippedGeo}).`);
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
