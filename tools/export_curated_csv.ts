#!/usr/bin/env node
const fs = require('node:fs');
const path = require('node:path');

function loadEnv() {
  const envPath = path.resolve(process.cwd(), '.env');
  const out = {};
  if (!fs.existsSync(envPath)) return out;
  const content = fs.readFileSync(envPath, 'utf8');
  for (const line of content.split(/\r?\n/)) {
    const t = line.trim();
    if (!t || t.startsWith('#')) continue;
    const i = t.indexOf('=');
    if (i <= 0) continue;
    const k = t.slice(0, i).trim();
    const v = t.slice(i + 1).trim().replace(/^"|"$/g, '');
    out[k] = v;
  }
  return out;
}

function parseArgs(argv) {
  const args = { out: 'curated_places.csv' };
  for (let i = 2; i < argv.length; i += 1) {
    const a = argv[i];
    if (a === '--out') args.out = argv[++i] || args.out;
    if (a.startsWith('--out=')) args.out = a.slice('--out='.length);
  }
  return args;
}

function esc(v) {
  const s = String(v ?? '');
  if (s.includes(',') || s.includes('"') || s.includes('\n')) return `"${s.replaceAll('"', '""')}"`;
  return s;
}

async function main() {
  const args = parseArgs(process.argv);
  const fenv = loadEnv();
  const supabaseUrl = process.env.SUPABASE_URL || fenv.SUPABASE_URL;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || fenv.SUPABASE_SERVICE_ROLE_KEY;
  if (!supabaseUrl || !serviceKey) {
    throw new Error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY');
  }

  const res = await fetch(`${supabaseUrl}/rest/v1/rpc/export_curated_rows`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
    },
    body: '{}',
  });

  const text = await res.text();
  if (!res.ok) {
    throw new Error(`RPC failed (${res.status}): ${text}`);
  }

  const rows = text ? JSON.parse(text) : [];
  const header = [
    'name','province','district','category','lat','lng','price_level','duration_min','tags','short_desc','history_tip','eat_tip','pro_tip',
  ];

  const lines = [header.join(',')];
  for (const r of rows) {
    lines.push([
      esc(r.name),
      esc(r.province),
      esc(r.district),
      esc(r.category),
      esc(r.lat),
      esc(r.lng),
      esc(r.price_level),
      esc(r.duration_min),
      esc(r.tags),
      esc(r.short_desc),
      esc(r.history_tip),
      esc(r.eat_tip),
      esc(r.pro_tip),
    ].join(','));
  }

  const outPath = path.resolve(process.cwd(), args.out);
  fs.writeFileSync(outPath, `${lines.join('\n')}\n`, 'utf8');
  console.log(`Exported ${rows.length} rows -> ${outPath}`);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
