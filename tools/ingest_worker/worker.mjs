import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const envPath = path.resolve(__dirname, '../../.env');
const fileEnv = {};
if (fs.existsSync(envPath)) {
  const content = fs.readFileSync(envPath, 'utf8');
  for (const line of content.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const idx = trimmed.indexOf('=');
    if (idx <= 0) continue;
    const key = trimmed.slice(0, idx).trim();
    const raw = trimmed.slice(idx + 1).trim();
    const value = raw.replace(/^"|"$/g, '');
    fileEnv[key] = value;
  }
}

const argv = process.argv.slice(2);
const hasFlag = (f) => argv.includes(f);
const flagValue = (prefix) => {
  const item = argv.find((a) => a.startsWith(`${prefix}=`));
  return item ? item.slice(prefix.length + 1) : undefined;
};

const mode = hasFlag('--dry-run')
  ? 'dry-run'
  : hasFlag('--report')
  ? 'report'
  : hasFlag('--once')
  ? 'once'
  : 'live';
const resume = hasFlag('--resume');
const untilDone = hasFlag('--until-done');

const env = {
  SUPABASE_URL: fileEnv.SUPABASE_URL || process.env.SUPABASE_URL,
  SUPABASE_ANON_KEY: fileEnv.SUPABASE_ANON_KEY || process.env.SUPABASE_ANON_KEY,
  SUPABASE_PUBLISHABLE_KEY: fileEnv.SUPABASE_PUBLISHABLE_KEY || process.env.SUPABASE_PUBLISHABLE_KEY,
  SUPABASE_SERVICE_ROLE_KEY: fileEnv.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY,
  INGEST_BATCH_LIMIT: Math.max(1, Math.min(10, Number(flagValue('--batch') || fileEnv.INGEST_BATCH_LIMIT || process.env.INGEST_BATCH_LIMIT || '10'))),
  INGEST_SLEEP_MS: Number(flagValue('--sleep') || fileEnv.INGEST_SLEEP_MS || process.env.INGEST_SLEEP_MS || '3000'),
  INGEST_MAX_RUNTIME_MIN: Number(flagValue('--minutes') || fileEnv.INGEST_MAX_RUNTIME_MIN || process.env.INGEST_MAX_RUNTIME_MIN || '0'),
  INGEST_LOG_EVERY: Number(fileEnv.INGEST_LOG_EVERY || process.env.INGEST_LOG_EVERY || '1'),
  INGEST_MAX_ERRORS: Number(flagValue('--max-errors') || fileEnv.INGEST_MAX_ERRORS || process.env.INGEST_MAX_ERRORS || '50'),
  INGEST_HTTP_TIMEOUT_MS: Math.max(10_000, Math.min(120_000, Number(flagValue('--http-timeout-ms') || fileEnv.INGEST_HTTP_TIMEOUT_MS || process.env.INGEST_HTTP_TIMEOUT_MS || '90000'))),
  RETRO_CLEANUP_ON_START: (fileEnv.RETRO_CLEANUP_ON_START || process.env.RETRO_CLEANUP_ON_START || 'true') === 'true',
  RETRO_CLEANUP_ACTION: (fileEnv.RETRO_CLEANUP_ACTION || process.env.RETRO_CLEANUP_ACTION || 'unpublish'),
  RETRO_CLEANUP_LIMIT: Number(fileEnv.RETRO_CLEANUP_LIMIT || process.env.RETRO_CLEANUP_LIMIT || '5000'),
  FORCE_COVERAGE_ON_START: (fileEnv.FORCE_COVERAGE_ON_START || process.env.FORCE_COVERAGE_ON_START || 'true') === 'true',
  FORCE_COVERAGE_LIMIT: Number(fileEnv.FORCE_COVERAGE_LIMIT || process.env.FORCE_COVERAGE_LIMIT || '300'),
  FORCE_COVERAGE_MAX_PLACES: Number(fileEnv.FORCE_COVERAGE_MAX_PLACES || process.env.FORCE_COVERAGE_MAX_PLACES || '20'),
  FORCE_COVERAGE_MERKEZ_ONLY: (fileEnv.FORCE_COVERAGE_MERKEZ_ONLY || process.env.FORCE_COVERAGE_MERKEZ_ONLY || 'true') === 'true',
  FORCE_COVERAGE_EVERY_BATCH: Number(fileEnv.FORCE_COVERAGE_EVERY_BATCH || process.env.FORCE_COVERAGE_EVERY_BATCH || '20'),
  MERKEZ_BOOST_ON_START: (fileEnv.MERKEZ_BOOST_ON_START || process.env.MERKEZ_BOOST_ON_START || 'true') === 'true',
  MERKEZ_BOOST_EVERY_BATCH: Number(fileEnv.MERKEZ_BOOST_EVERY_BATCH || process.env.MERKEZ_BOOST_EVERY_BATCH || '5'),
  STUCK_REQUEUE_EVERY_BATCH: Number(fileEnv.STUCK_REQUEUE_EVERY_BATCH || process.env.STUCK_REQUEUE_EVERY_BATCH || '5'),
  STUCK_REQUEUE_MINUTES: Number(fileEnv.STUCK_REQUEUE_MINUTES || process.env.STUCK_REQUEUE_MINUTES || '10'),
  NORMALIZE_AFTER_BATCH: (fileEnv.NORMALIZE_AFTER_BATCH || process.env.NORMALIZE_AFTER_BATCH || 'true') === 'true',
  NORMALIZE_LIMIT: Number(fileEnv.NORMALIZE_LIMIT || process.env.NORMALIZE_LIMIT || '300'),
  AUTO_APPROVE_SAFE: (fileEnv.AUTO_APPROVE_SAFE || process.env.AUTO_APPROVE_SAFE || 'true') === 'true',
};

if (!env.SUPABASE_URL || !env.SUPABASE_SERVICE_ROLE_KEY) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

const startedAt = Date.now();
let batchNo = 0;
let stopping = false;
let consecutiveErrors = 0;

process.on('SIGINT', () => {
  stopping = true;
});
process.on('SIGTERM', () => {
  stopping = true;
});

function fnUrl(name) {
  return `${env.SUPABASE_URL}/functions/v1/${name}`;
}

async function invoke(name, body = {}, method = 'POST') {
  const apiKey = env.SUPABASE_PUBLISHABLE_KEY || env.SUPABASE_ANON_KEY || '';
  const res = await fetch(fnUrl(name), {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(apiKey ? { apikey: apiKey } : {}),
      Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,
      'x-worker-secret': env.SUPABASE_SERVICE_ROLE_KEY,
    },
    signal: AbortSignal.timeout(env.INGEST_HTTP_TIMEOUT_MS),
    body: method === 'POST' ? JSON.stringify(body) : undefined,
  });

  const text = await res.text();
  let data = {};
  try {
    data = text ? JSON.parse(text) : {};
  } catch {
    data = { raw: text };
  }

  if (!res.ok) {
    throw new Error(`${name} failed (${res.status}): ${JSON.stringify(data)}`);
  }

  return data;
}

async function invokeWithRetry(name, body = {}, method = 'POST', attempts = 3) {
  let lastError;
  for (let i = 0; i < attempts; i += 1) {
    try {
      return await invoke(name, body, method);
    } catch (err) {
      lastError = err;
      const waitMs = 800 * (2 ** i);
      if (i < attempts - 1) {
        await sleep(waitMs);
      }
    }
  }
  throw lastError;
}

function shouldStop() {
  if (stopping) return true;
  if (env.INGEST_MAX_RUNTIME_MIN <= 0) return false;
  const elapsedMin = (Date.now() - startedAt) / 60000;
  return elapsedMin >= env.INGEST_MAX_RUNTIME_MIN;
}

async function sleep(ms) {
  await new Promise((resolve) => setTimeout(resolve, ms));
}

async function getProgress() {
  return invokeWithRetry('get_ingest_progress', {}, 'POST', 2);
}

async function printProgress(prefix = 'progress') {
  const p = await getProgress();
  const totalPlaces = Object.values(p.places_by_source || {}).reduce((a, b) => a + Number(b || 0), 0);
  console.log(`[${prefix}] districts=${p.total_districts} queued=${p.jobs?.queued ?? 0} running=${p.jobs?.running ?? 0} done=${p.jobs?.done ?? 0} failed=${p.jobs?.failed ?? 0} places_total=${totalPlaces}`);
  const failed = p.recent_failed_jobs || [];
  if (failed.length > 0) {
    console.log(`[${prefix}] recent_failed_jobs=${failed.length} top_error=${failed[0]?.last_error ?? ''}`);
  }
}

async function ensureBootstrapped() {
  console.log('1) Verifying/Seeding Turkey admin boundaries...');
  const seedCheck = await invoke('seed_turkey_admin');
  if (!seedCheck.ok) {
    throw new Error(`Boundary seed not loaded: provinces=${seedCheck.provinces} districts=${seedCheck.districts}.`);
  }

  console.log('2) Enqueue district jobs (idempotent)...');
  const enq = await invoke('enqueue_all_district_jobs');
  console.log(`[enqueue] inserted=${enq.inserted ?? 0} skipped_existing=${enq.skipped_existing ?? 0}`);

  if (env.RETRO_CLEANUP_ON_START) {
    const clean = await invoke('retro_quality_cleanup', {
      action: env.RETRO_CLEANUP_ACTION === 'unpublish' ? 'unpublish' : 'demote',
      limit: env.RETRO_CLEANUP_LIMIT,
    });
    console.log(`[retro_cleanup] action=${clean?.result?.action ?? 'demote'} affected=${clean?.result?.affected ?? 0}`);
  }

  if (env.FORCE_COVERAGE_ON_START) {
    const forced = await invoke('force_coverage_jobs', {
      limit: env.FORCE_COVERAGE_LIMIT,
      max_places: env.FORCE_COVERAGE_MAX_PLACES,
      merkez_only: env.FORCE_COVERAGE_MERKEZ_ONLY,
      preview_limit: 10,
    });
    console.log(
      `[force_coverage] targeted=${forced?.forced?.targeted ?? 0} updated=${forced?.forced?.updated ?? 0} running_skipped=${forced?.forced?.running_skipped ?? 0}`,
    );
  }

  if (env.MERKEZ_BOOST_ON_START) {
    const boosted = await invoke('boost_merkez_jobs', {
      limit: env.FORCE_COVERAGE_LIMIT,
      min_priority: 120,
      max_place_count: env.FORCE_COVERAGE_MAX_PLACES,
      include_done: false,
    });
    console.log(
      `[merkez_boost] targeted=${boosted?.result?.targeted ?? 0} updated=${boosted?.result?.updated ?? 0} skipped_running=${boosted?.result?.skipped_running ?? 0}`,
    );
  }
}

async function runOnceBatch() {
  const result = await invokeWithRetry('run_ingest_batch', { limit: env.INGEST_BATCH_LIMIT }, 'POST', 2);
  const claimed = Number(result.claimed ?? 0);
  const failed = ((result.results || []).filter((r) => r.status === 'failed')).length;
  console.log(`[once] claimed=${claimed} failed=${failed}`);
  await printProgress('once-after');
}

async function runLoop() {
  console.log(`3) Starting ingest loop... Ctrl+C to stop.${untilDone ? ' (until done)' : ''}`);
  while (!shouldStop()) {
    batchNo += 1;
    let result;
    try {
      console.log(`[batch=${batchNo}] run_ingest_batch start limit=${env.INGEST_BATCH_LIMIT}`);
      result = await invokeWithRetry('run_ingest_batch', { limit: env.INGEST_BATCH_LIMIT }, 'POST', 2);
      console.log(`[batch=${batchNo}] run_ingest_batch end claimed=${Number(result?.claimed ?? 0)}`);
      consecutiveErrors = 0;
    } catch (err) {
      consecutiveErrors += 1;
      console.error(`[batch=${batchNo}] run_ingest_batch error: ${err.message}`);
      if (consecutiveErrors % 3 === 0) {
        try {
          await invoke('reset_stuck_running_jobs', { stale_minutes: 5 });
          console.log('[recover] reset_stuck_running_jobs called');
        } catch (_) {}
      }
      if (consecutiveErrors >= env.INGEST_MAX_ERRORS) {
        throw new Error(`too_many_consecutive_errors=${consecutiveErrors}`);
      }
      await sleep(Math.max(env.INGEST_SLEEP_MS, 4000));
      continue;
    }

    if (env.NORMALIZE_AFTER_BATCH) {
      const doneDistrictIds = (result.results || [])
        .filter((r) => r.status === 'done' && r.district_id)
        .map((r) => r.district_id);
      for (const districtId of doneDistrictIds) {
        try {
          const norm = await invokeWithRetry('normalize_raw_places', {
            district_id: districtId,
            limit: env.NORMALIZE_LIMIT,
            auto_approve_safe: env.AUTO_APPROVE_SAFE,
          }, 'POST', 2);
          console.log(
            `[normalize] district=${districtId} drafts=${norm.drafts ?? 0} approved=${norm.approved ?? 0} merged=${norm.merged ?? 0} skipped=${norm.skipped ?? 0}`,
          );
        } catch (err) {
          console.error(`[normalize] district=${districtId} error: ${err.message}`);
        }
      }
    }

    let stats;
    if (batchNo % env.INGEST_LOG_EVERY === 0) {
      stats = await getProgress();
      const totalPlaces = Object.values(stats.places_by_source || {}).reduce((a, b) => a + Number(b || 0), 0);
      console.log(`[batch=${batchNo}] claimed=${result.claimed ?? 0} done=${stats.jobs?.done ?? '-'} queued=${stats.jobs?.queued ?? '-'} failed=${stats.jobs?.failed ?? '-'} places=${totalPlaces}`);
    }

    if (env.FORCE_COVERAGE_EVERY_BATCH > 0 && batchNo % env.FORCE_COVERAGE_EVERY_BATCH === 0) {
      try {
        const forced = await invoke('force_coverage_jobs', {
          limit: env.FORCE_COVERAGE_LIMIT,
          max_places: env.FORCE_COVERAGE_MAX_PLACES,
          merkez_only: env.FORCE_COVERAGE_MERKEZ_ONLY,
          preview_limit: 5,
        });
        console.log(
          `[force_coverage@batch=${batchNo}] targeted=${forced?.forced?.targeted ?? 0} updated=${forced?.forced?.updated ?? 0}`,
        );
      } catch (err) {
        console.error(`[force_coverage@batch=${batchNo}] error: ${err.message}`);
      }
    }

    if (env.MERKEZ_BOOST_EVERY_BATCH > 0 && batchNo % env.MERKEZ_BOOST_EVERY_BATCH === 0) {
      try {
        const boosted = await invoke('boost_merkez_jobs', {
          limit: env.FORCE_COVERAGE_LIMIT,
          min_priority: 120,
          max_place_count: env.FORCE_COVERAGE_MAX_PLACES,
          include_done: false,
        });
        console.log(
          `[merkez_boost@batch=${batchNo}] targeted=${boosted?.result?.targeted ?? 0} updated=${boosted?.result?.updated ?? 0}`,
        );
      } catch (err) {
        console.error(`[merkez_boost@batch=${batchNo}] error: ${err.message}`);
      }
    }

    if (env.STUCK_REQUEUE_EVERY_BATCH > 0 && batchNo % env.STUCK_REQUEUE_EVERY_BATCH === 0) {
      try {
        const reset = await invoke('reset_stuck_running_jobs', { stale_minutes: env.STUCK_REQUEUE_MINUTES });
        if (Number(reset?.requeued ?? 0) > 0) {
          console.log(`[stuck_requeue@batch=${batchNo}] requeued=${reset.requeued}`);
        }
      } catch (err) {
        console.error(`[stuck_requeue@batch=${batchNo}] error: ${err.message}`);
      }
    }

    if (untilDone) {
      stats = stats || await getProgress();
      const queued = Number(stats.jobs?.queued ?? 0);
      const running = Number(stats.jobs?.running ?? 0);
      const failed = Number(stats.jobs?.failed ?? 0);
      if (failed > 0) {
        try {
          const rq = await invoke('requeue_failed_jobs', { max_attempts: 8 });
          console.log(`[recover] requeue_failed_jobs requeued=${rq.requeued ?? 0}`);
        } catch (err) {
          console.error(`[recover] requeue_failed_jobs error: ${err.message}`);
        }
      }
      if (queued === 0 && running === 0) {
        console.log('[done] queue drained to zero');
        break;
      }
    }

    if (shouldStop()) break;
    await sleep(env.INGEST_SLEEP_MS);
  }

  console.log('Stopping ingest loop.');
  await printProgress('final');
}

async function main() {
  console.log(`Mode: ${mode}${resume ? ' (resume)' : ''}${untilDone ? ' --until-done' : ''}`);

  if (mode === 'dry-run') {
    console.log('Dry-run: verify seed -> enqueue -> run_ingest_batch loop');
    process.exit(0);
  }

  if (mode === 'report') {
    await printProgress('report');
    process.exit(0);
  }

  if (!resume) {
    await ensureBootstrapped();
  } else {
    console.log('Resume mode: skipping seed/enqueue.');
  }

  if (mode === 'once') {
    await runOnceBatch();
    process.exit(0);
  }

  await runLoop();
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
