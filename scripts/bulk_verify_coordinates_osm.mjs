#!/usr/bin/env node

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error("SUPABASE_URL ve SUPABASE_SERVICE_ROLE_KEY gerekli");
  process.exit(1);
}

const limit = Math.max(1, Math.min(Number(process.argv[2] || 25), 250));
const delayMs = Math.max(1000, Number(process.argv[3] || 1200));
const maxDistanceMeters = Math.max(25, Number(process.argv[4] || 250));

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function normalizeText(value) {
  return String(value || "")
    .toLocaleLowerCase("tr-TR")
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/['’`"]/g, "")
    .replace(/[^a-z0-9\u00c0-\u024f\s]/gi, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function unique(values) {
  return [...new Set(values.filter(Boolean))];
}

function tokenOverlapScore(a, b) {
  const aTokens = new Set(normalizeText(a).split(" ").filter((t) => t.length >= 3));
  const bTokens = new Set(normalizeText(b).split(" ").filter((t) => t.length >= 3));
  if (aTokens.size === 0 || bTokens.size === 0) return 0;
  let overlap = 0;
  for (const token of aTokens) {
    if (bTokens.has(token)) overlap += 1;
  }
  return overlap / Math.max(aTokens.size, bTokens.size);
}

function buildQueryVariants(name, provinceName) {
  const raw = String(name || "").trim();
  const cleaned = raw
    .replace(/\([^)]*\)/g, " ")
    .replace(/\bcore spot\b.*$/i, " ")
    .replace(/\b(otel|hotel|restaurant|restoran|beach|plaji|plajı)\b.*$/i, (match) => match)
    .replace(/[|/\\-]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
  const base = unique([
    raw,
    cleaned,
    normalizeText(cleaned)
      .replace(/\b(aktivitepaketleri com|aktivitepaketleri)\b/g, " ")
      .replace(/\s+/g, " ")
      .trim(),
  ]).filter((q) => q.length >= 3);

  return unique(
    base.flatMap((q) => [
      `${q}, ${provinceName}, Turkey`,
      `${q}, Turkey`,
    ]),
  );
}

function looksLikePlaceholder(name) {
  const normalized = normalizeText(name);
  return (
    normalized.includes("core spot") ||
    /^\w+\s+core spot\b/.test(normalized) ||
    normalized.length < 4
  );
}

function looksLikeLowSignal(name) {
  const normalized = normalizeText(name);
  return (
    looksLikePlaceholder(normalized) ||
    normalized.includes("aktivitepaketleri") ||
    normalized.includes("paragliding") ||
    normalized.includes("boat tour") ||
    normalized.includes("tekne turu") ||
    normalized.includes("hotel") ||
    normalized.includes("otel")
  );
}

function haversineMeters(lat1, lon1, lat2, lon2) {
  const r = 6371000;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  return 2 * r * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

async function supabaseGet(path) {
  const res = await fetch(`${SUPABASE_URL}${path}`, {
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
    },
  });
  if (!res.ok) {
    throw new Error(`Supabase GET failed: ${res.status} ${await res.text()}`);
  }
  return res.json();
}

async function supabasePost(path, body) {
  const res = await fetch(`${SUPABASE_URL}${path}`, {
    method: "POST",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    throw new Error(`Supabase POST failed: ${res.status} ${await res.text()}`);
  }
  return res.text();
}

async function fetchPendingQueue(rawLimit) {
  return supabaseGet(
    `/rest/v1/place_coordinate_verification_queue?select=place_id,status,created_at&status=eq.pending&order=created_at.asc&limit=${rawLimit}`,
  );
}

async function fetchPlaces(placeIds) {
  const encodedIds = placeIds.map((id) => `"${id}"`).join(",");
  return supabaseGet(
    `/rest/v1/places_clean_with_coords?select=id,name,lat,lng,province_id&id=in.(${encodedIds})`,
  );
}

async function fetchProvinces(provinceIds) {
  if (provinceIds.length === 0) return [];
  const encodedIds = provinceIds.map((id) => `"${id}"`).join(",");
  return supabaseGet(
    `/rest/v1/provinces?select=id,name,slug&id=in.(${encodedIds})`,
  );
}

async function nominatimSearch(query) {
  const q = encodeURIComponent(query);
  const url = `https://nominatim.openstreetmap.org/search?q=${q}&format=jsonv2&limit=5&countrycodes=tr`;
  const res = await fetch(url, {
    headers: {
      "User-Agent": "RouteviaCoordinateVerifier/1.0 (ops@routevia.app)",
      Accept: "application/json",
    },
  });
  if (!res.ok) {
    if (res.status === 429) {
      const retryAfter = Number(res.headers.get("retry-after") || 15);
      const err = new Error(`Nominatim failed: 429`);
      err.retryAfterSeconds = Number.isFinite(retryAfter) ? retryAfter : 15;
      throw err;
    }
    throw new Error(`Nominatim failed: ${res.status}`);
  }
  return res.json();
}

function pickBestResult(place, results) {
  const lat = Number(place.lat);
  const lng = Number(place.lng);
  const ranked = (results || [])
    .map((result) => {
      const rLat = Number(result.lat);
      const rLng = Number(result.lon);
      if (!Number.isFinite(rLat) || !Number.isFinite(rLng)) return null;
      const distance = haversineMeters(lat, lng, rLat, rLng);
      const overlap = tokenOverlapScore(
        place.name,
        `${result.name || ""} ${result.display_name || ""}`,
      );
      const importance = Number(result.importance || 0);
      const score =
        overlap * 1000 -
        Math.min(distance, 5000) / 10 +
        importance * 100;
      return { result, distance, overlap, score };
    })
    .filter(Boolean)
    .sort((a, b) => b.score - a.score);
  return ranked[0] || null;
}

async function recodeFromOsm(placeId, lat, lng, note) {
  return supabasePost(`/rest/v1/rpc/recode_place_coordinate_from_osm`, {
    p_place_id: placeId,
    p_lat: lat,
    p_lng: lng,
    p_verified_by: "auto_osm_batch",
    p_note: note,
  });
}

async function main() {
  const rawQueue = await fetchPendingQueue(Math.min(limit * 8, 1000));
  const placeIds = rawQueue.map((item) => item.place_id).filter(Boolean);
  if (placeIds.length === 0) {
    console.log("Pending queue bos.");
    return;
  }

  const places = await fetchPlaces(placeIds);
  const placeById = new Map(places.map((place) => [place.id, place]));
  const queue = rawQueue
    .map((item) => ({ item, place: placeById.get(item.place_id) }))
    .filter((entry) => entry.place)
    .sort((a, b) => {
      const aLowSignal = looksLikeLowSignal(a.place.name) ? 1 : 0;
      const bLowSignal = looksLikeLowSignal(b.place.name) ? 1 : 0;
      if (aLowSignal !== bLowSignal) return aLowSignal - bLowSignal;
      const aPlaceholder = looksLikePlaceholder(a.place.name) ? 1 : 0;
      const bPlaceholder = looksLikePlaceholder(b.place.name) ? 1 : 0;
      if (aPlaceholder !== bPlaceholder) return aPlaceholder - bPlaceholder;
      return 0;
    })
    .slice(0, limit)
    .map((entry) => entry.item);
  const provinceIds = [
    ...new Set(
      places.map((place) => place.province_id).filter(Boolean),
    ),
  ];
  const provinces = await fetchProvinces(provinceIds);
  const provinceById = new Map(
    provinces.map((province) => [province.id, province]),
  );

  let verified = 0;
  let skipped = 0;

  for (const item of queue) {
    const place = placeById.get(item.place_id);
    if (!place) {
      skipped += 1;
      continue;
    }

    const provinceName = provinceById.get(place.province_id)?.name || "";
    const lat = Number(place.lat);
    const lng = Number(place.lng);
    if (!provinceName || !Number.isFinite(lat) || !Number.isFinite(lng)) {
      skipped += 1;
      continue;
    }

    try {
      const queries = buildQueryVariants(place.name, provinceName);
      let best = null;
      for (const query of queries) {
        const results = await nominatimSearch(query);
        const candidate = pickBestResult(place, results);
        if (!candidate) continue;
        if (
          !best ||
          candidate.score > best.score ||
          (candidate.score === best.score && candidate.distance < best.distance)
        ) {
          best = candidate;
        }
        if (candidate.distance <= maxDistanceMeters && candidate.overlap >= 0.55) {
          break;
        }
        await sleep(Math.max(250, Math.floor(delayMs / 3)));
      }

      if (best && best.distance <= maxDistanceMeters && best.overlap >= 0.4) {
        const osmLat = Number(best.result.lat);
        const osmLng = Number(best.result.lon);
        await recodeFromOsm(
          place.id,
          osmLat,
          osmLng,
          `auto_osm_batch distance=${Math.round(best.distance)}m overlap=${best.overlap.toFixed(2)} display_name=${String(best.result.display_name || "").slice(0, 180)}`,
        );
        verified += 1;
        console.log(
          `VERIFIED ${place.name} (${Math.round(best.distance)}m overlap=${best.overlap.toFixed(2)})`,
        );
      } else {
        skipped += 1;
        console.log(`SKIP ${place.name}`);
      }
    } catch (error) {
      skipped += 1;
      console.log(`ERROR ${place.name}: ${error.message}`);
      if (String(error.message || "").includes("429")) {
        const retryAfterMs = Math.max(
          delayMs * 5,
          Number(error.retryAfterSeconds || 15) * 1000,
        );
        console.log(`BACKOFF ${Math.round(retryAfterMs / 1000)}s`);
        await sleep(retryAfterMs);
      }
    }

    await sleep(delayMs);
  }

  console.log(
    JSON.stringify(
      {
        scanned: queue.length,
        fetched_pending_pool: rawQueue.length,
        verified,
        skipped,
      },
      null,
      2,
    ),
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
