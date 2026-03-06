#!/usr/bin/env node

/*
 * Backend production smoke check for Routevia.
 *
 * Required env:
 * - SUPABASE_URL
 * - SUPABASE_SERVICE_ROLE_KEY
 *
 * Optional thresholds:
 * - MIN_PROVINCES (default: 81)
 * - MAX_MISSING_DISTRICT (default: 0)
 * - MAX_INVALID_DISTRICT (default: 0)
 * - MAX_ISSUE_RATE (default: 0)
 */

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error("Missing SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY");
  process.exit(1);
}

const MIN_PROVINCES = Number(process.env.MIN_PROVINCES ?? 81);
const MAX_MISSING_DISTRICT = Number(process.env.MAX_MISSING_DISTRICT ?? 0);
const MAX_INVALID_DISTRICT = Number(process.env.MAX_INVALID_DISTRICT ?? 0);
const MAX_ISSUE_RATE = Number(process.env.MAX_ISSUE_RATE ?? 0);

function nowIso() {
  return new Date().toISOString();
}

async function rest(path, options = {}) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    ...options,
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
      ...options.headers,
    },
  });
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`REST ${path} => ${res.status} ${text}`);
  }
  return text ? JSON.parse(text) : null;
}

async function rpc(name, body = {}) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${name}`, {
    method: "POST",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`RPC ${name} => ${res.status} ${text}`);
  }
  try {
    return JSON.parse(text);
  } catch (_) {
    return text;
  }
}

async function edge(functionName, body = {}) {
  const res = await fetch(`${SUPABASE_URL}/functions/v1/${functionName}`, {
    method: "POST",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`EDGE ${functionName} => ${res.status} ${text}`);
  }
  return text ? JSON.parse(text) : null;
}

function buildCheck(name, ok, details = {}) {
  return { name, ok, details };
}

async function main() {
  const startedAt = nowIso();
  const checks = [];

  const provinces = await rest("provinces?select=id&limit=1000");
  checks.push(
    buildCheck("provinces_count", provinces.length >= MIN_PROVINCES, {
      found: provinces.length,
      min_expected: MIN_PROVINCES,
    }),
  );

  const applyOverridesResult = await rpc("apply_poi_location_overrides", {});
  checks.push(
    buildCheck("apply_poi_location_overrides_rpc", true, {
      result: applyOverridesResult,
    }),
  );

  const verifiedPoiIds = await rest(
    "pois?select=id&provenance_verified=eq.true&limit=5",
  );
  const ids = verifiedPoiIds.map((r) => r.id);
  const live = await edge("get_live_status", { place_ids: ids, hours: 6 });
  checks.push(
    buildCheck("get_live_status_edge", Array.isArray(live?.items), {
      requested_ids: ids.length,
      returned_items: Array.isArray(live?.items) ? live.items.length : 0,
    }),
  );

  const quality = await import("node:child_process").then(({ execSync }) => {
    const out = execSync(
      "node tools/poi_district_quality_report.mjs",
      { encoding: "utf8" },
    );
    return JSON.parse(out);
  });

  checks.push(
    buildCheck(
      "district_quality_thresholds",
      quality.missing_district_count <= MAX_MISSING_DISTRICT &&
        quality.invalid_district_count <= MAX_INVALID_DISTRICT &&
        Number(quality.issue_rate) <= MAX_ISSUE_RATE,
      {
        missing_district_count: quality.missing_district_count,
        invalid_district_count: quality.invalid_district_count,
        issue_rate: quality.issue_rate,
        thresholds: {
          max_missing_district: MAX_MISSING_DISTRICT,
          max_invalid_district: MAX_INVALID_DISTRICT,
          max_issue_rate: MAX_ISSUE_RATE,
        },
      },
    ),
  );

  const passed = checks.every((c) => c.ok);
  const report = {
    started_at: startedAt,
    finished_at: nowIso(),
    passed,
    checks,
  };

  console.log(JSON.stringify(report, null, 2));

  if (!passed) {
    process.exit(1);
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
