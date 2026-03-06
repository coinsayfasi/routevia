#!/usr/bin/env node

const url = process.env.SUPABASE_URL;
const anon = process.env.SUPABASE_ANON_KEY;
const service = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!url || !anon || !service) {
  console.error('Missing SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

const args = new Map(
  process.argv.slice(2)
    .filter((a) => a.startsWith('--'))
    .map((a) => {
      const [k, v] = a.replace(/^--/, '').split('=');
      return [k, v ?? 'true'];
    }),
);

const rawTable = args.get('raw-table') ?? 'places';
const limit = Math.max(10, Math.min(1000, Number(args.get('limit') ?? 200)));
const start = Math.max(0, Number(args.get('start') ?? 0));
const end = Math.max(start, Number(args.get('end') ?? 10000));
const sleepMs = Math.max(0, Number(args.get('sleep-ms') ?? 300));
const stopOnZero = (args.get('stop-on-zero') ?? 'true') === 'true';

async function callBatch(offset) {
  const res = await fetch(`${url}/functions/v1/admin_build_clean_dataset_from_raw`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      apikey: anon,
      'x-worker-secret': service,
    },
    body: JSON.stringify({
      raw_table: rawTable,
      limit,
      offset,
    }),
  });

  const text = await res.text();
  let data = null;
  try {
    data = JSON.parse(text);
  } catch {
    data = { raw: text };
  }

  if (!res.ok) {
    throw new Error(`HTTP ${res.status} ${JSON.stringify(data)}`);
  }
  return data;
}

function wait(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

let totalInserted = 0;
let totalLinked = 0;
let batches = 0;

for (let offset = start; offset <= end; offset += limit) {
  const started = Date.now();
  const res = await callBatch(offset);
  const inserted = Number(res?.inserted ?? 0);
  const linked = Number(res?.linked ?? 0);
  const scanned = Number(res?.scanned ?? 0);
  totalInserted += inserted;
  totalLinked += linked;
  batches += 1;

  const took = Date.now() - started;
  console.log(
    JSON.stringify({
      offset,
      scanned,
      inserted,
      linked,
      took_ms: took,
      total_inserted: totalInserted,
      total_linked: totalLinked,
      batches,
    }),
  );

  if (stopOnZero && scanned === 0) {
    console.log(JSON.stringify({ stop: 'scanned_zero', offset }));
    break;
  }

  if (stopOnZero && scanned > 0 && inserted === 0 && linked === 0 && offset > start + limit * 5) {
    console.log(JSON.stringify({ stop: 'no_progress', offset }));
    break;
  }

  if (sleepMs > 0) await wait(sleepMs);
}

console.log(JSON.stringify({ done: true, total_inserted: totalInserted, total_linked: totalLinked, batches }));
