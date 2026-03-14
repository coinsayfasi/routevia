import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import { getServiceClient } from "../_shared/client.ts";

// ── Config ────────────────────────────────────────────────────────────────────

const TTL_MINUTES = 45; // Weather changes slowly; 45min gives high cache hit ratio

// ── WMO Weather Code Mapping ──────────────────────────────────────────────────
// Maps Open-Meteo WMO codes to Turkish condition text, emoji, and suggestion mode

interface Condition {
  text: string;
  emoji: string;
  mode: "outdoor" | "indoor" | "mixed" | "sunset";
}

const WMO: Record<number, Condition> = {
  0:  { text: "Açık Hava",          emoji: "☀️",  mode: "outdoor" },
  1:  { text: "Az Bulutlu",         emoji: "🌤️",  mode: "outdoor" },
  2:  { text: "Parçalı Bulutlu",    emoji: "⛅",  mode: "outdoor" },
  3:  { text: "Bulutlu",            emoji: "☁️",  mode: "mixed"   },
  45: { text: "Sisli",              emoji: "🌫️",  mode: "indoor"  },
  48: { text: "Yoğun Sis",          emoji: "🌫️",  mode: "indoor"  },
  51: { text: "Hafif Çiseleme",     emoji: "🌦️",  mode: "indoor"  },
  53: { text: "Çiseleme",           emoji: "🌦️",  mode: "indoor"  },
  55: { text: "Yoğun Çiseleme",     emoji: "🌧️",  mode: "indoor"  },
  61: { text: "Hafif Yağmur",       emoji: "🌧️",  mode: "indoor"  },
  63: { text: "Yağmurlu",           emoji: "🌧️",  mode: "indoor"  },
  65: { text: "Şiddetli Yağmur",    emoji: "🌧️",  mode: "indoor"  },
  71: { text: "Hafif Kar",          emoji: "🌨️",  mode: "indoor"  },
  73: { text: "Karlı",              emoji: "❄️",  mode: "indoor"  },
  75: { text: "Yoğun Kar",          emoji: "❄️",  mode: "indoor"  },
  77: { text: "Kar Taneleri",       emoji: "❄️",  mode: "indoor"  },
  80: { text: "Sağanak Yağış",      emoji: "🌧️",  mode: "indoor"  },
  81: { text: "Kuvvetli Sağanak",   emoji: "🌧️",  mode: "indoor"  },
  82: { text: "Çok Şiddetli Sağanak", emoji: "⛈️", mode: "indoor" },
  85: { text: "Kar Yağışı",         emoji: "🌨️",  mode: "indoor"  },
  86: { text: "Yoğun Kar Yağışı",   emoji: "❄️",  mode: "indoor"  },
  95: { text: "Fırtınalı",          emoji: "⛈️",  mode: "indoor"  },
  96: { text: "Dolulu Fırtına",     emoji: "⛈️",  mode: "indoor"  },
  99: { text: "Şiddetli Fırtına",   emoji: "⛈️",  mode: "indoor"  },
};

function resolveCondition(code: number): Condition {
  return WMO[code] ?? { text: "Bulutlu", emoji: "🌥️", mode: "mixed" };
}

// ── Suggestion Mode Derivation ────────────────────────────────────────────────
// Derives contextual suggestion mode from weather + time of day
// sunset: photography/viewpoint spots
// outdoor: parks, nature, viewpoints, lakes
// indoor: museums, cafes, covered markets
// mixed: city strolls, cafes + outdoor when temp moderate

function deriveSuggestionMode(
  code: number,
  temp: number,
  isDay: boolean,
  sunset: string | null,
): string {
  // Nighttime or approaching sunset (within 90 min): sunset mode
  if (!isDay) return "sunset";

  if (sunset) {
    try {
      const now = new Date();
      // sunset format from Open-Meteo: "2026-03-14T19:32"
      const sunsetDt = new Date(sunset);
      const diffMs = sunsetDt.getTime() - now.getTime();
      if (diffMs > 0 && diffMs < 90 * 60 * 1000) return "sunset";
    } catch (_) { /* ignore */ }
  }

  // Extreme cold → indoor
  if (temp < 5) return "indoor";
  // Very hot → mixed (shaded/evening activities)
  if (temp > 35) return "mixed";

  // Base from WMO condition
  return resolveCondition(code).mode;
}

// ── Main Handler ──────────────────────────────────────────────────────────────

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const body = await req.json().catch(() => ({}));
    const { city_slug, city_name, lat, lng, district_slug, district_name } = body as {
      city_slug: string;
      city_name: string;
      lat: number;
      lng: number;
      district_slug?: string;
      district_name?: string;
    };

    if (!city_slug || lat == null || lng == null) {
      return jsonResponse({ error: "city_slug, lat, lng are required" }, 400);
    }

    const cacheKey = district_slug
      ? `${city_slug}:${district_slug}`
      : city_slug;

    const service = getServiceClient();
    const now = new Date();

    // ── Cache hit check ───────────────────────────────────────────────────────
    // Single row lookup by unique cache_key; returns immediately if fresh.
    // Many concurrent users requesting same city all hit this cache → 1 provider call per TTL.
    const { data: cached } = await service
      .from("weather_cache")
      .select("payload")
      .eq("cache_key", cacheKey)
      .gt("expires_at", now.toISOString())
      .maybeSingle();

    if (cached?.payload) {
      return jsonResponse({ ...(cached.payload as object), from_cache: true });
    }

    // ── Fetch from Open-Meteo ─────────────────────────────────────────────────
    // Minimal field selection: only what Routevia needs.
    // Free, no API key, GDPR-safe (no user data sent).
    const url =
      `https://api.open-meteo.com/v1/forecast` +
      `?latitude=${lat}&longitude=${lng}` +
      `&current=temperature_2m,apparent_temperature,relative_humidity_2m,` +
      `precipitation_probability,weather_code,wind_speed_10m,is_day` +
      `&daily=sunrise,sunset` +
      `&timezone=auto&forecast_days=1`;

    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 8000);

    let omData: {
      current: {
        temperature_2m: number;
        apparent_temperature: number;
        relative_humidity_2m: number;
        precipitation_probability: number;
        weather_code: number;
        wind_speed_10m: number;
        is_day: number;
      };
      daily: { sunrise: string[]; sunset: string[] };
    };

    try {
      const resp = await fetch(url, { signal: controller.signal });
      clearTimeout(timer);
      if (!resp.ok) throw new Error(`Open-Meteo HTTP ${resp.status}`);
      omData = await resp.json();
    } catch (fetchErr) {
      clearTimeout(timer);
      // ── Stale cache fallback ──────────────────────────────────────────────
      // If provider is down, return expired cache rather than an error.
      // Better UX: slightly stale weather beats a broken UI.
      const { data: stale } = await service
        .from("weather_cache")
        .select("payload")
        .eq("cache_key", cacheKey)
        .order("fetched_at", { ascending: false })
        .limit(1)
        .maybeSingle();

      if (stale?.payload) {
        return jsonResponse({ ...(stale.payload as object), from_cache: true, stale: true });
      }
      throw fetchErr;
    }

    // ── Normalize provider response ───────────────────────────────────────────
    const cur = omData.current;
    const daily = omData.daily;

    const code: number = cur.weather_code ?? 0;
    const temp: number = Math.round((cur.temperature_2m ?? 0) * 10) / 10;
    const isDay: boolean = cur.is_day === 1;
    const sunset: string | null = daily?.sunset?.[0] ?? null;

    const condition = resolveCondition(code);
    const suggestionMode = deriveSuggestionMode(code, temp, isDay, sunset);

    const expiresAt = new Date(now.getTime() + TTL_MINUTES * 60 * 1000);

    const payload = {
      cache_key: cacheKey,
      city_slug,
      city_name: city_name ?? city_slug,
      district_slug: district_slug ?? null,
      district_name: district_name ?? null,
      temperature: temp,
      apparent_temperature: Math.round((cur.apparent_temperature ?? temp) * 10) / 10,
      weather_code: code,
      condition_text: condition.text,
      condition_emoji: condition.emoji,
      is_day: isDay,
      precipitation_probability: cur.precipitation_probability ?? 0,
      wind_speed: Math.round((cur.wind_speed_10m ?? 0) * 10) / 10,
      humidity: cur.relative_humidity_2m ?? 0,
      sunrise: daily?.sunrise?.[0] ?? null,
      sunset,
      suggestion_mode: suggestionMode,
      provider: "open-meteo",
      fetched_at: now.toISOString(),
      expires_at: expiresAt.toISOString(),
    };

    // ── Cache upsert ──────────────────────────────────────────────────────────
    // ON CONFLICT (cache_key) DO UPDATE prevents duplicate rows.
    // Multiple simultaneous users requesting same city may both trigger this path
    // (cache stampede), but Postgres upsert is idempotent so worst case is 2
    // identical Open-Meteo calls per TTL window — acceptable tradeoff.
    await service.from("weather_cache").upsert(
      {
        cache_key: cacheKey,
        city_slug,
        city_name: payload.city_name,
        district_slug: district_slug ?? null,
        district_name: district_name ?? null,
        lat,
        lng,
        temperature: payload.temperature,
        apparent_temperature: payload.apparent_temperature,
        weather_code: code,
        condition_text: payload.condition_text,
        condition_emoji: payload.condition_emoji,
        is_day: isDay,
        precipitation_probability: payload.precipitation_probability,
        wind_speed: payload.wind_speed,
        humidity: payload.humidity,
        sunrise: payload.sunrise,
        sunset: payload.sunset,
        suggestion_mode: suggestionMode,
        provider: "open-meteo",
        payload,
        fetched_at: payload.fetched_at,
        expires_at: payload.expires_at,
      },
      { onConflict: "cache_key" },
    );

    return jsonResponse({ ...payload, from_cache: false });
  } catch (error) {
    return errorResponse(error);
  }
});
