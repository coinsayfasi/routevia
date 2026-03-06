import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireAdmin, requireUser } from "../_shared/client.ts";

type Payload =
  | { mode: "list"; status?: "pending" | "approved" | "rejected"; province_slug?: string; limit?: number }
  | { mode: "review"; suggestion_id: string; decision: "approved" | "rejected"; admin_note?: string };

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    await requireAdmin(user.id);

    const body = (await req.json()) as Payload;
    const service = getServiceClient();

    if (body.mode === "list") {
      const lim = Math.max(1, Math.min(body.limit ?? 100, 500));
      let q = service
        .from("place_suggestions")
        .select("id,suggested_name,suggested_category,suggested_tags,short_note,status,created_at,province_id,district_id,source_url,lat,lng")
        .order("created_at", { ascending: false })
        .limit(lim);

      if (body.status) q = q.eq("status", body.status);
      if (body.province_slug) {
        const { data: p } = await service.from("provinces").select("id").eq("slug", body.province_slug).maybeSingle();
        if (p?.id) q = q.eq("province_id", p.id as string);
      }

      const { data, error } = await q;
      if (error) return jsonResponse({ error: error.message }, 500);
      return jsonResponse({ items: data ?? [] });
    }

    const { error } = await service
      .from("place_suggestions")
      .update({
        status: body.decision,
        admin_note: body.admin_note ?? null,
        reviewed_by: user.id,
        reviewed_at: new Date().toISOString(),
      })
      .eq("id", body.suggestion_id)
      .eq("status", "pending");

    if (error) return jsonResponse({ error: error.message }, 500);
    return jsonResponse({ ok: true });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
