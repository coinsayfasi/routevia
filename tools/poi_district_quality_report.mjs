#!/usr/bin/env node

/*
 * District quality report for POIs.
 * Produces JSON with:
 * - total POIs
 * - missing district count
 * - invalid district count (district not found under matched province)
 * - top cities by invalid count
 * - sample invalid rows
 */

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error("Missing SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY");
  process.exit(1);
}

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

async function loadAllPois() {
  const out = [];
  const pageSize = 1000;
  let from = 0;
  for (;;) {
    const to = from + pageSize - 1;
    const rows = await sb(
      "pois?select=id,name,city,district,lat,lng,provenance_verified&provenance_verified=eq.true&order=id.asc",
      { headers: { Range: `${from}-${to}` } },
    );
    out.push(...rows);
    if (rows.length < pageSize) break;
    from += pageSize;
  }
  return out;
}

async function main() {
  const provinces = await sb("provinces?select=id,name,slug");
  const districts = await sb("districts?select=id,province_id,name,slug");
  const pois = await loadAllPois();

  const provinceByNorm = new Map();
  for (const p of provinces) {
    provinceByNorm.set(norm(p.name), p);
    provinceByNorm.set(norm(p.slug), p);
  }

  const districtsByProvince = new Map();
  for (const d of districts) {
    if (!districtsByProvince.has(d.province_id)) {
      districtsByProvince.set(d.province_id, new Set());
    }
    const s = districtsByProvince.get(d.province_id);
    s.add(norm(d.name));
    s.add(norm(d.slug));
  }

  let missingDistrict = 0;
  let invalidDistrict = 0;
  let unknownProvince = 0;
  const invalidSamples = [];
  const invalidByCity = new Map();

  for (const p of pois) {
    const cityNorm = norm(p.city);
    const province = provinceByNorm.get(cityNorm);
    if (!province) {
      unknownProvince += 1;
      continue;
    }

    const districtNorm = norm(p.district);
    if (!districtNorm) {
      missingDistrict += 1;
      continue;
    }

    const set = districtsByProvince.get(province.id);
    if (!set || !set.has(districtNorm)) {
      invalidDistrict += 1;
      const c = invalidByCity.get(p.city) ?? 0;
      invalidByCity.set(p.city, c + 1);
      if (invalidSamples.length < 80) {
        invalidSamples.push({
          id: p.id,
          name: p.name,
          city: p.city,
          district: p.district,
          lat: p.lat,
          lng: p.lng,
        });
      }
    }
  }

  const topCities = [...invalidByCity.entries()]
    .sort((a, b) => b[1] - a[1])
    .slice(0, 25)
    .map(([city, count]) => ({ city, count }));

  const out = {
    generated_at: new Date().toISOString(),
    total_verified_pois: pois.length,
    unknown_province_count: unknownProvince,
    missing_district_count: missingDistrict,
    invalid_district_count: invalidDistrict,
    issue_rate: Number(
      ((missingDistrict + invalidDistrict) / Math.max(1, pois.length)).toFixed(4),
    ),
    top_cities_by_invalid_district: topCities,
    sample_invalid_rows: invalidSamples,
  };

  console.log(JSON.stringify(out, null, 2));
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
