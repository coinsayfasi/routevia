#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

function loadEnv() {
  const envPath = path.resolve(__dirname, '../../.env');
  const out = {};
  if (!fs.existsSync(envPath)) return out;
  const content = fs.readFileSync(envPath, 'utf8');
  for (const line of content.split(/\r?\n/)) {
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
    province: 'antalya',
    mode: 'force',
    radiusKm: 25,
    normalizeLimit: 500,
    autoApproveSafe: true,
    withIngestDistrict: true,
    concurrency: 1,
    districtLimit: 0,
  };
  for (let i = 2; i < argv.length; i += 1) {
    const a = argv[i];
    if (a.startsWith('--province=')) args.province = a.slice(11);
    else if (a === '--province') args.province = argv[++i] || args.province;
    else if (a.startsWith('--mode=')) args.mode = a.slice(7);
    else if (a.startsWith('--radius-km=')) args.radiusKm = Number(a.slice(12));
    else if (a.startsWith('--normalize-limit=')) args.normalizeLimit = Number(a.slice(18));
    else if (a === '--no-auto-approve') args.autoApproveSafe = false;
    else if (a === '--no-ingest-district') args.withIngestDistrict = false;
    else if (a.startsWith('--concurrency=')) args.concurrency = Math.max(1, Number(a.slice(14)) || 1);
    else if (a.startsWith('--district-limit=')) args.districtLimit = Math.max(0, Number(a.slice(17)) || 0);
  }
  return args;
}

async function fnInvoke(base, anonOrPublishable, workerSecret, name, body) {
  const authToken = anonOrPublishable || workerSecret;
  const res = await fetch(`${base}/functions/v1/${name}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(anonOrPublishable ? { apikey: anonOrPublishable } : {}),
      ...(authToken ? { Authorization: `Bearer ${authToken}` } : {}),
      'x-worker-secret': workerSecret,
    },
    signal: AbortSignal.timeout(120000),
    body: JSON.stringify(body),
  });
  const text = await res.text();
  const json = text ? JSON.parse(text) : {};
  if (!res.ok) throw new Error(`${name} ${res.status}: ${JSON.stringify(json)}`);
  return json;
}

async function sleep(ms) {
  await new Promise((r) => setTimeout(r, ms));
}

async function run() {
  const env = { ...process.env, ...loadEnv() };
  const args = parseArgs(process.argv);

  const supabaseUrl = env.SUPABASE_URL;
  const serviceKey = env.SUPABASE_SERVICE_ROLE_KEY;
  const anon = env.SUPABASE_ANON_KEY || env.SUPABASE_PUBLISHABLE_KEY || '';
  if (!supabaseUrl || !serviceKey) {
    throw new Error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY');
  }

  const provincesRes = await fnInvoke(supabaseUrl, anon, serviceKey, 'admin_place_query', {
    mode: 'provinces',
  });
  const provinces = provincesRes.items ?? [];
  const province = provinces.find((p) => String(p.slug) === String(args.province));
  if (!province) throw new Error(`province_not_found:${args.province}`);
  const districtsRes = await fnInvoke(supabaseUrl, anon, serviceKey, 'admin_place_query', {
    mode: 'districts',
    province_id: province.id,
  });
  let districts = districtsRes.items ?? [];
  if (args.districtLimit > 0) districts = districts.slice(0, args.districtLimit);

  console.log(`Province=${province.name} (${province.slug}) districts=${districts.length}`);

  const summary = {
    districts: districts.length,
    ingestDistrictDone: 0,
    ingestDistrictFailed: 0,
    googleFetched: 0,
    googleInserted: 0,
    googleUpdated: 0,
    drafts: 0,
    approved: 0,
    merged: 0,
    skipped: 0,
    failures: [],
  };

  const queue = [...districts];
  const workers = Array.from({ length: args.concurrency }, async () => {
    while (queue.length > 0) {
      const d = queue.shift();
      if (!d) break;
      try {
        console.log(`[start] ${d.name}`);
        if (args.withIngestDistrict) {
          const ingest = await fnInvoke(supabaseUrl, anon, serviceKey, 'ingest_district', {
            district_id: d.id,
          });
          if (ingest?.ok) summary.ingestDistrictDone += 1;
        }

        const g = await fnInvoke(supabaseUrl, anon, serviceKey, 'ingest_google_district', {
          district_id: d.id,
          mode: args.mode,
          radius_km: args.radiusKm,
        });
        summary.googleFetched += Number(g.fetched || 0);
        summary.googleInserted += Number(g.inserted || 0);
        summary.googleUpdated += Number(g.updated || 0);

        const n = await fnInvoke(supabaseUrl, anon, serviceKey, 'normalize_raw_places', {
          district_id: d.id,
          limit: args.normalizeLimit,
          auto_approve_safe: args.autoApproveSafe,
        });
        summary.drafts += Number(n.drafts || 0);
        summary.approved += Number(n.approved || 0);
        summary.merged += Number(n.merged || 0);
        summary.skipped += Number(n.skipped || 0);

        console.log(`[ok] ${d.name} fetched=${g.fetched || 0} inserted=${g.inserted || 0} updated=${g.updated || 0} drafts=${n.drafts || 0} approved=${n.approved || 0}`);
      } catch (e) {
        const msg = String(e.message || e);
        if (msg.includes('ingest_district')) summary.ingestDistrictFailed += 1;
        summary.failures.push({ district: d.name, error: msg });
        console.log(`[fail] ${d.name} -> ${msg}`);
      }
      await sleep(250);
    }
  });

  await Promise.all(workers);

  console.log('--- SUMMARY ---');
  console.log(JSON.stringify(summary, null, 2));
}

run().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
