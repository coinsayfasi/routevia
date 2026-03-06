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
    threshold: 80,
    rawTable: 'places',
    batch: 1000,
    maxOffset: 80000,
    sleepMs: 80,
    provinces: [],
  };
  for (let i = 2; i < argv.length; i += 1) {
    const a = argv[i];
    if (a.startsWith('--threshold=')) args.threshold = Math.max(1, Number(a.slice(12)) || args.threshold);
    else if (a.startsWith('--raw-table=')) args.rawTable = a.slice(12);
    else if (a.startsWith('--batch=')) args.batch = Math.max(100, Math.min(5000, Number(a.slice(8)) || args.batch));
    else if (a.startsWith('--max-offset=')) args.maxOffset = Math.max(1000, Number(a.slice(13)) || args.maxOffset);
    else if (a.startsWith('--sleep-ms=')) args.sleepMs = Math.max(0, Number(a.slice(11)) || args.sleepMs);
    else if (a.startsWith('--provinces=')) args.provinces = a.slice(12).split(',').map((x) => x.trim()).filter(Boolean);
  }
  return args;
}

function wait(ms) { return new Promise((r) => setTimeout(r, ms)); }

async function fetchJson(url, options = {}) {
  const res = await fetch(url, options);
  const text = await res.text();
  let data = null;
  try { data = text ? JSON.parse(text) : null; } catch { data = { raw: text }; }
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${JSON.stringify(data)}`);
  return data;
}

async function countPlaces(url, key, provinceId) {
  const res = await fetch(`${url}/rest/v1/places_clean?select=id&province_id=eq.${provinceId}`, {
    method: 'HEAD',
    headers: { apikey: key, Authorization: `Bearer ${key}`, Prefer: 'count=exact' },
  });
  const range = res.headers.get('content-range') || '*/0';
  const total = Number((range.split('/')[1] || '0').trim()) || 0;
  return total;
}

async function main() {
  const env = { ...process.env, ...loadEnv() };
  const args = parseArgs(process.argv);

  const url = env.SUPABASE_URL;
  const anon = env.SUPABASE_ANON_KEY;
  const service = env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !anon || !service) throw new Error('SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY eksik');

  const provinces = await fetchJson(`${url}/rest/v1/provinces?select=id,name,slug&order=name.asc`, {
    headers: { apikey: service, Authorization: `Bearer ${service}` },
  });

  const target = [];
  for (const p of provinces) {
    if (args.provinces.length > 0 && !args.provinces.includes(p.slug)) continue;
    const count = await countPlaces(url, service, p.id);
    if (count < args.threshold) {
      target.push({ ...p, before: count });
    }
  }

  if (target.length === 0) {
    console.log(JSON.stringify({ ok: true, message: 'Zayıf il bulunamadı', threshold: args.threshold }));
    return;
  }

  const report = {
    started_at: new Date().toISOString(),
    threshold: args.threshold,
    raw_table: args.rawTable,
    batch: args.batch,
    target_count: target.length,
    provinces: [],
  };

  for (const p of target) {
    let inserted = 0;
    let linked = 0;
    let scanned = 0;
    let calls = 0;
    for (let offset = 0; offset <= args.maxOffset; offset += args.batch) {
      const data = await fetchJson(`${url}/functions/v1/admin_build_clean_dataset_from_raw`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          apikey: anon,
          'x-worker-secret': service,
        },
        body: JSON.stringify({
          raw_table: args.rawTable,
          province_slug: p.slug,
          province_name: p.name,
          limit: args.batch,
          offset,
        }),
      });
      calls += 1;
      const s = Number(data?.scanned ?? 0);
      const i = Number(data?.inserted ?? 0);
      const l = Number(data?.linked ?? 0);
      scanned += s;
      inserted += i;
      linked += l;
      if (s === 0) break;
      if (args.sleepMs > 0) await wait(args.sleepMs);
    }
    const after = await countPlaces(url, service, p.id);
    const row = {
      slug: p.slug,
      province: p.name,
      before: p.before,
      after,
      delta: after - p.before,
      scanned,
      inserted,
      linked,
      calls,
    };
    report.provinces.push(row);
    console.log(JSON.stringify(row));
  }

  report.finished_at = new Date().toISOString();
  const outDir = path.resolve(__dirname, '../../docs/reports');
  fs.mkdirSync(outDir, { recursive: true });
  const outPath = path.join(outDir, `weak_provinces_sync_${Date.now()}.json`);
  fs.writeFileSync(outPath, `${JSON.stringify(report, null, 2)}\n`);
  console.log(JSON.stringify({ ok: true, report: outPath, processed: report.provinces.length }));
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
