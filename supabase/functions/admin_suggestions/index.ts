import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
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
        .select("id,user_id,suggested_name,suggested_category,suggested_tags,short_note,status,admin_note,created_at,reviewed_at,province_id,district_id,source_url,lat,lng")
        .order("created_at", { ascending: false })
        .limit(lim);

      if (body.status) q = q.eq("status", body.status);
      if (body.province_slug) {
        const { data: p } = await service.from("provinces").select("id").eq("slug", body.province_slug).maybeSingle();
        if (p?.id) q = q.eq("province_id", p.id as string);
      }

      const { data, error } = await q;
      if (error) return jsonResponse({ error: error.message }, 500);

      const rows = (data ?? []) as Array<Record<string, unknown>>;
      const provinceIds = [...new Set(rows.map((row) => String(row.province_id ?? "")).filter(Boolean))];
      const districtIds = [...new Set(rows.map((row) => String(row.district_id ?? "")).filter(Boolean))];
      const userIds = [...new Set(rows.map((row) => String(row.user_id ?? "")).filter(Boolean))];

      const [{ data: provinces }, { data: districts }, { data: profiles }] = await Promise.all([
        provinceIds.length
          ? service.from("provinces").select("id,name,slug").in("id", provinceIds)
          : Promise.resolve({ data: [] as Array<Record<string, unknown>> }),
        districtIds.length
          ? service.from("districts").select("id,name,slug").in("id", districtIds)
          : Promise.resolve({ data: [] as Array<Record<string, unknown>> }),
        userIds.length
          ? service.from("profiles").select("id,display_name").in("id", userIds)
          : Promise.resolve({ data: [] as Array<Record<string, unknown>> }),
      ]);

      const provinceById = new Map((provinces ?? []).map((row) => [String(row.id), row]));
      const districtById = new Map((districts ?? []).map((row) => [String(row.id), row]));
      const profileById = new Map((profiles ?? []).map((row) => [String(row.id), row]));

      const items = rows.map((row) => {
        const province = provinceById.get(String(row.province_id ?? ""));
        const district = districtById.get(String(row.district_id ?? ""));
        const profile = profileById.get(String(row.user_id ?? ""));
        return {
          ...row,
          province_name: province?.name ?? null,
          province_slug: province?.slug ?? null,
          district_name: district?.name ?? null,
          district_slug: district?.slug ?? null,
          submitter_name: profile?.display_name ?? null,
        };
      });

      return jsonResponse({ items });
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
    return errorResponse(error);
  }
});
