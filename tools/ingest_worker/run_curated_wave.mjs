#!/usr/bin/env node
import { spawn } from 'node:child_process';

function parseArgs(argv) {
  const args = {
    provinces: [],
    maxPerDistrict: 22,
    radiusM: 28000,
    dbBatch: 120,
    sleepMs: 1200,
  };
  for (let i = 2; i < argv.length; i += 1) {
    const a = argv[i];
    if (a.startsWith('--provinces=')) args.provinces = a.slice('--provinces='.length).split(',').map((x) => x.trim()).filter(Boolean);
    else if (a.startsWith('--max-per-district=')) args.maxPerDistrict = Math.max(8, Number(a.slice('--max-per-district='.length)) || args.maxPerDistrict);
    else if (a.startsWith('--radius-m=')) args.radiusM = Math.max(10000, Number(a.slice('--radius-m='.length)) || args.radiusM);
    else if (a.startsWith('--db-batch=')) args.dbBatch = Math.max(50, Number(a.slice('--db-batch='.length)) || args.dbBatch);
    else if (a.startsWith('--sleep-ms=')) args.sleepMs = Math.max(0, Number(a.slice('--sleep-ms='.length)) || args.sleepMs);
  }
  return args;
}

async function sleep(ms) {
  await new Promise((r) => setTimeout(r, ms));
}

function runNode(args, title) {
  return new Promise((resolve, reject) => {
    console.log(`\n=== ${title} ===`);
    const p = spawn('node', args, { stdio: 'inherit' });
    p.on('exit', (code) => {
      if (code === 0) resolve();
      else reject(new Error(`${title} failed (${code})`));
    });
  });
}

async function main() {
  const args = parseArgs(process.argv);
  if (!args.provinces.length) throw new Error('Use --provinces=slug1,slug2,...');

  for (const province of args.provinces) {
    await runNode(
      [
        'tools/ingest_worker/import_curated_batch.mjs',
        '--input=data/seed/incoming_batch.csv',
        '--output=data/seed/curated_places.csv',
      ],
      `curated_csv_append:${province}`,
    );

    await runNode(
      [
        'tools/ingest_worker/import_curated_to_db.mjs',
        `--provinces=${province}`,
        `--batch=${args.dbBatch}`,
      ],
      `curated_db_push:${province}`,
    );

    await sleep(args.sleepMs);
  }

  await runNode(
    ['tools/ingest_worker/clean_curated_duplicates.mjs', '--input=data/seed/curated_places.csv'],
    'curated_dedup_final',
  );

  console.log('\n[curated-wave] completed');
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
