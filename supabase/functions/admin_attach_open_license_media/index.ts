import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireAdminOrWorker } from "../_shared/client.ts";

type Item = {
  place_id: string;
  storage_path: string;
  sort_order?: number;
  license: string;
  attribution?: string;
  url_original?: string;
};

type Payload = {
  items: Item[];
};

function validStoragePath(path: string): boolean {
  if (!path || !path.includes("/")) return false;
  if (path.includes("..") || path.startsWith("/")) return false;
  return path.startsWith("public-media/open-license/") || path.startsWith("public-media/curated/");
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "method_not_allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrWorker(authHeader, req.headers.get("x-worker-secret"));

    const body = (await req.json()) as Payload;
    const items = body.items ?? [];
    if (items.length === 0) return jsonResponse({ error: "items_required" }, 400);

    const service = getServiceClient();
    let attached = 0;

    for (const it of items.slice(0, 500)) {
      if (!it.place_id || !it.storage_path || !it.license) continue;
      if (!validStoragePath(it.storage_path)) continue;

      const upsert = await service
        .from("place_media_clean")
        .upsert({
          place_id: it.place_id,
          storage_path: it.storage_path,
          source: "open_license",
          sort_order: Number.isFinite(it.sort_order) ? Number(it.sort_order) : 0,
        }, { onConflict: "place_id,storage_path" })
        .select("id")
        .single();
      if (upsert.error || !upsert.data?.id) continue;

      const meta = await service
        .from("place_media_open_license_meta")
        .upsert({
          media_id: upsert.data.id,
          license: it.license,
          attribution: it.attribution ?? null,
          url_original: it.url_original ?? null,
        }, { onConflict: "media_id" });
      if (meta.error) continue;
      attached += 1;
    }

    return jsonResponse({ attached });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 500);
  }
});
