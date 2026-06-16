#!/usr/bin/env node
import { spawn } from 'node:child_process';

const DEFAULT_PROVINCES = [
  'istanbul',
  'antalya',
  'izmir',
  'mugla',
  'aydin',
  'nevsehir',
  'ankara',
  'bursa',
  'konya',
  'canakkale',
  'balikesir',
  'mersin',
  'adana',
  'trabzon',
  'rize',
];

function parseArgs(argv) {
  const args = {
    provinces: DEFAULT_PROVINCES,
    mode: 'force',
    radiusKm: 25,
    normalizeLimit: 600,
    concurrency: 1,
    withCurated: false,
    sleepMs: 1000,
  };
  for (let i = 2; i < argv.length; i += 1) {
    const a = argv[i];
    if (a.startsWith('--provinces=')) {
      args.provinces = a.slice('--provinces='.length).split(',').map((x) => x.trim()).filter(Boolean);
    } else if (a.startsWith('--mode=')) {
      args.mode = a.slice('--mode='.length);
    } else if (a.startsWith('--radius-km=')) {
      args.radiusKm = Math.max(5, Math.min(40, Number(a.slice('--radius-km='.length)) || args.radiusKm));
    } else if (a.startsWith('--normalize-limit=')) {
      args.normalizeLimit = Math.max(50, Math.min(2000, Number(a.slice('--normalize-limit='.length)) || args.normalizeLimit));
    } else if (a.startsWith('--concurrency=')) {
      args.concurrency = Math.max(1, Math.min(4, Number(a.slice('--concurrency='.length)) || args.concurrency));
    } else if (a === '--with-curated') {
      args.withCurated = true;
    } else if (a.startsWith('--sleep-ms=')) {
      args.sleepMs = Math.max(0, Number(a.slice('--sleep-ms='.length)) || args.sleepMs);
    }
  }
  return args;
}

function runNode(args, title) {
  return new Promise((resolve, reject) => {
    console.log(`\n=== ${title} ===`);
    const child = spawn('node', args, { stdio: 'inherit' });
    child.on('exit', (code) => {
      if (code === 0) resolve();
      else reject(new Error(`${title} failed with exit code ${code}`));
    });
  });
}

async function sleep(ms) {
  await new Promise((r) => setTimeout(r, ms));
}

async function run() {
  const args = parseArgs(process.argv);
  console.log(`[hot] provinces=${args.provinces.join(',')} mode=${args.mode} radius_km=${args.radiusKm} normalize_limit=${args.normalizeLimit} concurrency=${args.concurrency} curated_append=${args.withCurated}`);

  for (const province of args.provinces) {
    await runNode(
      [
        'tools/ingest_worker/run_province_full.mjs',
        `--province=${province}`,
        `--mode=${args.mode}`,
        `--radius-km=${args.radiusKm}`,
        `--normalize-limit=${args.normalizeLimit}`,
        `--concurrency=${args.concurrency}`,
      ],
      `province_full:${province}`,
    );

    if (args.withCurated) {
      await runNode(
        ['tools/ingest_worker/import_curated_batch.mjs'],
        `curated_import:${province}`,
      );
      await runNode(
        ['tools/ingest_worker/clean_curated_duplicates.mjs'],
        `curated_dedup:${province}`,
      );
    }

    await runNode(
      ['tools/ingest_worker/worker.mjs', '--report'],
      `report_after:${province}`,
    );
    if (args.sleepMs > 0) await sleep(args.sleepMs);
  }

  console.log('\n[hot] all provinces completed');
}

run().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
