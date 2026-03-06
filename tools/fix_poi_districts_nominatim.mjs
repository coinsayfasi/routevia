#!/usr/bin/env node

/*
 * POI district repair tool (Turkey-wide)
 * - Detects city/district mismatches
 * - Uses Nominatim reverse geocoding
 * - Updates public.pois.district via service role
 *
 * Usage:
 *   source .env
 *   node tools/fix_poi_districts_nominatim.mjs --max-updates=300 --delay-ms=1200
 */

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error("Missing SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY");
  process.exit(1);
}

const args = Object.fromEntries(
  process.argv.slice(2).map((a) => {
    const [k, v] = a.replace(/^--/, "").split("=");
    return [k, v ?? "true"];
  }),
);

const MAX_UPDATES = Number(args["max-updates"] ?? 150);
const DELAY_MS = Number(args["delay-ms"] ?? 1200);
const DRY_RUN = String(args["dry-run"] ?? "false") === "true";
const VERIFY_ALL = String(args["verify-all"] ?? "false") === "true";
const ONLY_CITY = (args["city"] ?? "").toString().trim();
const ALLOW_CITY_CORRECTION =
  String(args["allow-city-correction"] ?? "true") === "true";

function norm(v) {
  return (v ?? "")
    .toString()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/ı/g, "i")
    .replace(/[^a-z0-9]+/g, "");
}

async function sb(path, options = {}) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    ...options,
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
      ...options.headers,
    },
  });
  if (!res.ok) {
    const t = await res.text();
    throw new Error(`${path} => ${res.status} ${t}`);
  }
  const t = await res.text();
  if (!t) return {};
  return JSON.parse(t);
}

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function pickDistrictTokens(addr) {
  return [
    addr?.town,
    addr?.city_district,
    addr?.county,
    addr?.municipality,
    addr?.suburb,
    addr?.state_district,
  ]
    .filter(Boolean)
    .map((x) => x.toString());
}

function pickProvinceTokens(addr) {
  return [addr?.state, addr?.province, addr?.region]
    .filter(Boolean)
    .map((x) => x.toString());
}

function normalizeDistrictToken(raw) {
  return norm(raw)
    .replace(/ilcesimerkezi$|ilcemerkezi$/g, "")
    .replace(/ilcesi$|ilce$/g, "")
    .replace(/belediyesi$|mahallesi$|mahalle$/g, "");
}

function resolveDistrictFromTokens(tokens, districtMap, provinceName = "") {
  if (!districtMap || districtMap.size === 0) return null;
  if (!tokens || tokens.length === 0) return null;

  const provinceNorm = norm(provinceName);
  const districtNormKeys = [...districtMap.keys()].sort((a, b) => b.length - a.length);

  for (const rawToken of tokens) {
    const nRaw = norm(rawToken);
    const n = normalizeDistrictToken(rawToken);
    if (districtMap.has(nRaw)) return districtMap.get(nRaw);
    if (districtMap.has(n)) return districtMap.get(n);

    // "Karaman Merkez", "Merkez İlçe" style aliases.
    if ((nRaw.endsWith("merkez") || n.endsWith("merkez")) && districtMap.has("merkez")) {
      return districtMap.get("merkez");
    }
    if (
      provinceNorm &&
      nRaw.startsWith(provinceNorm) &&
      nRaw.endsWith("merkez") &&
      districtMap.has("merkez")
    ) {
      return districtMap.get("merkez");
    }

    // Fuzzy containment for patterns like "kadirliilcemerkezi" -> "kadirli".
    for (const dk of districtNormKeys) {
      if (dk.length < 4) continue;
      if (nRaw.includes(dk) || n.includes(dk) || dk.includes(n)) {
        return districtMap.get(dk);
      }
    }
  }
  return null;
}

async function reverseDistrict(lat, lng) {
  const u = `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lng}&format=jsonv2&accept-language=tr&zoom=10`;
  const res = await fetch(u, {
    headers: {
      "User-Agent": "routevia-poi-district-fix/1.0 (ops@routevia.app)",
    },
  });
  if (!res.ok) return null;
  const json = await res.json().catch(() => null);
  if (!json?.address) return null;
  return {
    districtTokens: pickDistrictTokens(json.address),
    provinceTokens: pickProvinceTokens(json.address),
    displayName: json.display_name ?? "",
  };
}

async function loadAllPois() {
  const out = [];
  const pageSize = 1000;
  let from = 0;
  for (;;) {
    const to = from + pageSize - 1;
    const rows = await sb(
      `pois?select=id,name,city,district,lat,lng,provenance_verified&provenance_verified=eq.true&order=id.asc`,
      {
        headers: {
          Range: `${from}-${to}`,
        },
      },
    );
    out.push(...rows);
    if (rows.length < pageSize) break;
    from += pageSize;
  }
  return out;
}

async function loadManualOverrides() {
  try {
    const rows = await sb(
      "poi_location_overrides?select=poi_id,city,district,is_active&is_active=eq.true",
    );
    const out = new Map();
    for (const r of rows) {
      out.set(r.poi_id, { city: r.city, district: r.district });
    }
    return out;
  } catch (e) {
    // Keep script backward-compatible before migration exists.
    console.warn(`[WARN] manual override table unavailable, skipping: ${e.message}`);
    return new Map();
  }
}

async function main() {
  console.log("Loading provinces/districts...");
  const [provinces, districts] = await Promise.all([
    sb("provinces?select=id,name,slug"),
    sb("districts?select=id,province_id,name,slug"),
  ]);

  const provinceByNormName = new Map();
  for (const p of provinces) {
    provinceByNormName.set(norm(p.name), p);
    provinceByNormName.set(norm(p.slug), p);
  }

  const districtMapByProvince = new Map();
  for (const d of districts) {
    if (!districtMapByProvince.has(d.province_id)) {
      districtMapByProvince.set(d.province_id, new Map());
    }
    const m = districtMapByProvince.get(d.province_id);
    m.set(norm(d.name), d.name);
    m.set(norm(d.slug), d.name);
  }

  console.log("Loading POIs...");
  const pois = await loadAllPois();
  console.log(`POI loaded: ${pois.length}`);
  const manualOverrides = await loadManualOverrides();
  console.log(`Manual overrides loaded: ${manualOverrides.size}`);

  const candidates = [];
  for (const p of pois) {
    if (ONLY_CITY && norm(p.city) !== norm(ONLY_CITY)) continue;
    const province = provinceByNormName.get(norm(p.city));
    if (!province) continue;
    const dm = districtMapByProvince.get(province.id);
    if (!dm) continue;
    const currentNorm = norm(p.district);
    if (VERIFY_ALL) {
      candidates.push(p);
    } else if (!currentNorm || !dm.has(currentNorm)) {
      candidates.push(p);
    }
  }

  console.log(`Mismatch candidates: ${candidates.length}`);
  let updated = 0;
  let checked = 0;

  for (const p of candidates) {
    if (updated >= MAX_UPDATES) break;
    checked += 1;

    const manual = manualOverrides.get(p.id);
    if (manual) {
      const districtUnchanged = norm(p.district) === norm(manual.district);
      const cityUnchanged = norm(p.city) === norm(manual.city);
      if (!districtUnchanged || !cityUnchanged) {
        const payload = { district: manual.district };
        if (!cityUnchanged) payload.city = manual.city;
        if (!DRY_RUN) {
          await sb(`pois?id=eq.${p.id}`, {
            method: "PATCH",
            body: JSON.stringify(payload),
            headers: { Prefer: "return=minimal" },
          });
        }
        updated += 1;
        const cityChangePart = cityUnchanged
          ? ""
          : ` | city: ${p.city} -> ${manual.city}`;
        console.log(
          `[${updated}] ${p.name} | district: ${p.district ?? "-"} -> ${manual.district}${cityChangePart} [manual]`,
        );
      }
      continue;
    }

    if (p.lat == null || p.lng == null) continue;
    const province = provinceByNormName.get(norm(p.city));
    const dm = districtMapByProvince.get(province.id);
    if (!dm) continue;

    const reverse = await reverseDistrict(p.lat, p.lng);
    await sleep(DELAY_MS);
    if (!reverse) continue;

    const tokens = [...reverse.districtTokens];
    if (reverse.displayName) {
      tokens.push(...reverse.displayName.split(",").map((s) => s.trim()));
    }

    let resolved = resolveDistrictFromTokens(tokens, dm, province.name);
    let nextCity = p.city;

    // Fallback: if city was wrong, safely switch city+district together using reverse province.
    if (!resolved && ALLOW_CITY_CORRECTION) {
      for (const pt of reverse.provinceTokens) {
        const reverseProvince = provinceByNormName.get(norm(pt.replace(/\s+ili$/i, "")));
        if (!reverseProvince) continue;
        const reverseDistrictMap = districtMapByProvince.get(reverseProvince.id);
        const reverseResolved = resolveDistrictFromTokens(
          tokens,
          reverseDistrictMap,
          reverseProvince.name,
        );
        if (reverseResolved) {
          resolved = reverseResolved;
          nextCity = reverseProvince.name;
          break;
        }
      }
    }

    if (!resolved) continue;
    const districtUnchanged = norm(p.district) === norm(resolved);
    const cityUnchanged = norm(p.city) === norm(nextCity);
    if (districtUnchanged && cityUnchanged) continue;

    const payload = { district: resolved };
    if (!cityUnchanged) payload.city = nextCity;

    if (!DRY_RUN) {
      await sb(`pois?id=eq.${p.id}`, {
        method: "PATCH",
        body: JSON.stringify(payload),
        headers: { Prefer: "return=minimal" },
      });
    }
    updated += 1;
    const cityChangePart = cityUnchanged ? "" : ` | city: ${p.city} -> ${nextCity}`;
    console.log(
      `[${updated}] ${p.name} | district: ${p.district ?? "-"} -> ${resolved}${cityChangePart}`,
    );
  }

  console.log(
    `Done. checked=${checked}, updated=${updated}, dry_run=${DRY_RUN}, max_updates=${MAX_UPDATES}`,
  );
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
