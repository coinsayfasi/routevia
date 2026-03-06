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
    provinces: ['istanbul', 'antalya', 'nevsehir', 'denizli', 'izmir', 'bursa', 'trabzon', 'ankara'],
    priority: 9000,
    radiusKm: 25,
    forceMode: true,
    onlyLowCoverage: false,
    lowCoverageMaxPlaces: 80,
  };
  for (let i = 2; i < argv.length; i += 1) {
    const a = argv[i];
    if (a.startsWith('--provinces=')) args.provinces = a.slice('--provinces='.length).split(',').map((x) => x.trim()).filter(Boolean);
    else if (a.startsWith('--priority=')) args.priority = Math.max(1000, Number(a.slice('--priority='.length)) || args.priority);
    else if (a.startsWith('--radius-km=')) args.radiusKm = Math.max(10, Math.min(40, Number(a.slice('--radius-km='.length)) || args.radiusKm));
    else if (a === '--no-force-mode') args.forceMode = false;
    else if (a === '--only-low-coverage') args.onlyLowCoverage = true;
    else if (a.startsWith('--low-max=')) args.lowCoverageMaxPlaces = Math.max(0, Number(a.slice('--low-max='.length)) || args.lowCoverageMaxPlaces);
  }
  return args;
}

async function fetchJson(url, options) {
  const res = await fetch(url, options);
  const text = await res.text();
  const json = text ? JSON.parse(text) : {};
  if (!res.ok) {
    throw new Error(`HTTP ${res.status}: ${JSON.stringify(json)}`);
  }
  return json;
}

async function main() {
  const args = parseArgs(process.argv);
  const env = { ...process.env, ...loadEnv() };
  const url = env.SUPABASE_URL;
  const key = env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !key) throw new Error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY');

  const headers = {
    apikey: key,
    Authorization: `Bearer ${key}`,
    'Content-Type': 'application/json',
    Prefer: 'return=representation',
  };

  const provinceFilter = args.provinces.map((s) => `slug.eq.${encodeURIComponent(s)}`).join(',');
  const provinces = await fetchJson(
    `${url}/rest/v1/provinces?select=id,name,slug&or=(${provinceFilter})`,
    { headers: { apikey: key, Authorization: `Bearer ${key}` } },
  );
  if (!Array.isArray(provinces) || provinces.length === 0) throw new Error('No matching provinces found');
  const provinceIds = provinces.map((p) => p.id);

  const districts = await fetchJson(
    `${url}/rest/v1/districts?select=id,name,province_id&province_id=in.(${provinceIds.join(',')})`,
    { headers: { apikey: key, Authorization: `Bearer ${key}` } },
  );
  const districtIds = districts.map((d) => d.id);
  if (districtIds.length === 0) throw new Error('No districts found for selected provinces');

  const updateBody = {
    priority_score: args.priority,
    next_run_at: new Date().toISOString(),
    status: 'queued',
    ...(args.forceMode ? { mode: 'force', radius_km: args.radiusKm } : {}),
  };

  let targetIds = districtIds;
  if (args.onlyLowCoverage) {
    const counts = await fetchJson(
      `${url}/rest/v1/places?select=district_id,count:id&is_published=eq.true&district_id=in.(${districtIds.join(',')})`,
      { headers: { apikey: key, Authorization: `Bearer ${key}`, Prefer: 'count=exact' } },
    );
    const countMap = new Map();
    for (const row of counts) {
      countMap.set(row.district_id, Number(row.count ?? 0));
    }
    targetIds = districtIds.filter((id) => (countMap.get(id) ?? 0) <= args.lowCoverageMaxPlaces);
  }

  if (targetIds.length === 0) {
    console.log('No target districts after filter.');
    return;
  }

  const chunkSize = 150;
  let updated = 0;
  for (let i = 0; i < targetIds.length; i += chunkSize) {
    const chunk = targetIds.slice(i, i + chunkSize);
    const data = await fetchJson(
      `${url}/rest/v1/district_ingest_jobs?district_id=in.(${chunk.join(',')})`,
      { method: 'PATCH', headers, body: JSON.stringify(updateBody) },
    );
    updated += Array.isArray(data) ? data.length : 0;
  }

  const provinceNames = provinces.map((p) => p.name).join(', ');
  console.log(`Prioritized provinces: ${provinceNames}`);
  console.log(`Target districts: ${targetIds.length}, updated jobs: ${updated}, priority=${args.priority}, mode=${args.forceMode ? 'force' : 'normal'}, radius_km=${args.radiusKm}`);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
