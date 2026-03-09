import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, jsonResponse, errorResponse } from "../_shared/http.ts";

const PEXELS_API_KEY = Deno.env.get("PEXELS_API_KEY") ?? "";

function slugify(str: string): string {
  return str
    .toLowerCase()
    .trim()
    .replace(/\s+/g, "-")
    .replace(/[^a-z0-9-]/g, "")
    .slice(0, 80);
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const body = await req.json().catch(() => ({}));
    const rawCity = ((body?.city as string) ?? "").trim().slice(0, 100);
    if (!rawCity) return jsonResponse({ error: "city is required" }, 400);

    const citySlug = slugify(rawCity);

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Check cache first
    const { data: cached } = await supabase
      .from("city_images")
      .select("image_url,photographer,city_slug")
      .eq("city_slug", citySlug)
      .maybeSingle();

    if (cached) {
      return jsonResponse({
        source: "cache",
        city: rawCity,
        city_slug: citySlug,
        image_url: cached.image_url,
        photographer: cached.photographer,
      });
    }

    if (!PEXELS_API_KEY) {
      return jsonResponse({ error: "Pexels API key not configured" }, 503);
    }

    // Try progressively broader queries — city/urban focus
    const queries = [
      `${rawCity} city aerial`,
      `${rawCity} cityscape`,
      `${rawCity} city`,
      `${rawCity} travel`,
    ];

    let bestPhoto: { url: string; photographer: string } | null = null;

    for (const q of queries) {
      const pexelsRes = await fetch(
        `https://api.pexels.com/v1/search?query=${encodeURIComponent(q)}&per_page=15&orientation=landscape`,
        { headers: { Authorization: PEXELS_API_KEY } },
      );

      if (!pexelsRes.ok) continue;

      const data = await pexelsRes.json();
      const photos = (data.photos ?? []) as Array<{
        src: { large2x: string; large: string; original: string };
        width: number;
        height: number;
        photographer: string;
      }>;

      if (photos.length === 0) continue;

      // Sort by widest aspect ratio (best landscape cover)
      photos.sort((a, b) => b.width / b.height - a.width / a.height);
      const photo = photos[0];
      bestPhoto = {
        url: photo.src.large2x ?? photo.src.large ?? photo.src.original,
        photographer: photo.photographer,
      };
      break;
    }

    if (!bestPhoto) {
      return jsonResponse({ error: "No image found for this city" }, 404);
    }

    // Cache result (non-fatal if it fails)
    try {
      await supabase.from("city_images").upsert(
        {
          city_name: rawCity,
          city_slug: citySlug,
          image_url: bestPhoto.url,
          photographer: bestPhoto.photographer,
          source: "pexels",
          updated_at: new Date().toISOString(),
        },
        { onConflict: "city_slug" },
      );
    } catch (_) {}

    return jsonResponse({
      source: "pexels",
      city: rawCity,
      city_slug: citySlug,
      image_url: bestPhoto.url,
      photographer: bestPhoto.photographer,
    });
  } catch (e) {
    return errorResponse(e);
  }
});
