import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";

type Coord = { lat: number; lng: number; mode?: string };
type Stop = { transport_mode?: string; place?: { lat?: number; lng?: number } };
type Day = { stops?: Stop[] };
type Payload = {
  coords?: Coord[];
  days_plan?: Day[];
  transport_mode?: string;
};

const CO2_G_PER_KM: Record<string, number> = {
  walk: 0,
  bike: 5,
  transit: 45,
  car: 171,
};

function normalizeMode(mode?: string): keyof typeof CO2_G_PER_KM {
  const raw = String(mode ?? "car").toLowerCase();
  if (raw === "scooter") return "bike";
  if (raw in CO2_G_PER_KM) return raw as keyof typeof CO2_G_PER_KM;
  return "car";
}

function haversineKm(aLat: number, aLng: number, bLat: number, bLng: number): number {
  const r = 6371;
  const dLat = (bLat - aLat) * Math.PI / 180;
  const dLng = (bLng - aLng) * Math.PI / 180;
  const x = Math.sin(dLat / 2) ** 2
    + Math.cos(aLat * Math.PI / 180)
    * Math.cos(bLat * Math.PI / 180)
    * Math.sin(dLng / 2) ** 2;
  return 2 * r * Math.atan2(Math.sqrt(x), Math.sqrt(1 - x));
}

function coordsFromDays(days: Day[], fallbackMode?: string): Coord[] {
  const out: Coord[] = [];
  for (const day of days) {
    const stops = Array.isArray(day.stops) ? day.stops : [];
    for (const stop of stops) {
      const lat = Number(stop.place?.lat ?? NaN);
      const lng = Number(stop.place?.lng ?? NaN);
      if (!Number.isFinite(lat) || !Number.isFinite(lng) || lat < -90 || lat > 90 || lng < -180 || lng > 180) continue;
      out.push({ lat, lng, mode: stop.transport_mode ?? fallbackMode });
    }
  }
  return out;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "method_not_allowed" }, 405);

  try {
    const body = (await req.json()) as Payload;
    const coords = Array.isArray(body.coords) && body.coords.length > 1
      ? body.coords
      : coordsFromDays(Array.isArray(body.days_plan) ? body.days_plan : [], body.transport_mode);

    if (coords.length < 2) {
      return jsonResponse({
        score: 100,
        distance_km: 0,
        co2_kg: 0,
        mode_breakdown_km: {},
        mode_breakdown_co2_kg: {},
        grade: "A+",
        tips: ["En az 2 nokta secildiginde Eko skor hesaplanir."],
      });
    }

    let totalDistanceKm = 0;
    let totalCo2Kg = 0;
    const modeKm: Record<string, number> = {};
    const modeCo2Kg: Record<string, number> = {};

    for (let i = 1; i < coords.length; i += 1) {
      const prev = coords[i - 1];
      const cur = coords[i];
      const dKm = haversineKm(prev.lat, prev.lng, cur.lat, cur.lng);
      const mode = normalizeMode(cur.mode ?? prev.mode ?? body.transport_mode);
      const co2Kg = (dKm * CO2_G_PER_KM[mode]) / 1000;

      totalDistanceKm += dKm;
      totalCo2Kg += co2Kg;
      modeKm[mode] = (modeKm[mode] ?? 0) + dKm;
      modeCo2Kg[mode] = (modeCo2Kg[mode] ?? 0) + co2Kg;
    }

    const carBaselineKg = (totalDistanceKm * CO2_G_PER_KM.car) / 1000;
    const ratio = carBaselineKg <= 0 ? 0 : totalCo2Kg / carBaselineKg;
    const score = Math.max(0, Math.min(100, Math.round((1 - ratio) * 100)));

    const grade = score >= 85
      ? "A+"
      : score >= 70
      ? "A"
      : score >= 55
      ? "B"
      : score >= 40
      ? "C"
      : "D";

    const transitKm = modeKm.transit ?? 0;
    const walkBikeKm = (modeKm.walk ?? 0) + (modeKm.bike ?? 0);
    const tips: string[] = [];
    if (walkBikeKm < totalDistanceKm * 0.25) tips.push("Kisa etaplari yuruyus/bisiklet ile degistirerek skoru yukseltebilirsin.");
    if (transitKm < totalDistanceKm * 0.2) tips.push("Toplu tasima payini arttirmak karbon ayak izini belirgin dusurur.");
    if ((modeKm.car ?? 0) > totalDistanceKm * 0.6) tips.push("Arac kullanimini azaltmak icin duraklari bolge bazli grupla.");
    if (tips.length === 0) tips.push("Harika denge. Bu rota dusuk karbon profiline yakin.");

    return jsonResponse({
      score,
      grade,
      distance_km: Number(totalDistanceKm.toFixed(2)),
      co2_kg: Number(totalCo2Kg.toFixed(3)),
      car_baseline_kg: Number(carBaselineKg.toFixed(3)),
      saved_vs_car_kg: Number(Math.max(0, carBaselineKg - totalCo2Kg).toFixed(3)),
      mode_breakdown_km: Object.fromEntries(Object.entries(modeKm).map(([k, v]) => [k, Number(v.toFixed(2))])),
      mode_breakdown_co2_kg: Object.fromEntries(Object.entries(modeCo2Kg).map(([k, v]) => [k, Number(v.toFixed(3))])),
      tips,
    });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 400);
  }
});
