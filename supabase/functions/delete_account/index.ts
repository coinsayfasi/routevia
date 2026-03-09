import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const userId = user.id;
    const service = getServiceClient();

    // Delete user-generated content and data in dependency order.
    const tables: { table: string; column: string }[] = [
      { table: "place_reviews", column: "user_id" },
      { table: "photo_reports", column: "user_id" },
      { table: "place_checkins", column: "user_id" },
      { table: "user_trust", column: "user_id" },
      { table: "poi_signals", column: "user_id" },
      { table: "trips_clean", column: "user_id" },
      { table: "user_entitlements", column: "user_id" },
    ];

    for (const { table, column } of tables) {
      const { error } = await service.from(table).delete().eq(column, userId);
      if (error) {
        console.error(`delete_account: failed to delete from ${table}:`, error.message);
      }
    }

    // Delete user photos from storage then from the table.
    const { data: photos } = await service
      .from("place_photos")
      .select("id,storage_path")
      .eq("user_id", userId);

    if (photos && photos.length > 0) {
      const paths = photos
        .map((p: { storage_path?: string }) => p.storage_path)
        .filter((p?: string): p is string => !!p);
      if (paths.length > 0) {
        const { error: storageError } = await service.storage
          .from("place-photos")
          .remove(paths);
        if (storageError) {
          console.error("delete_account: storage remove error:", storageError.message);
        }
      }
      const { error: photosError } = await service
        .from("place_photos")
        .delete()
        .eq("user_id", userId);
      if (photosError) {
        console.error("delete_account: place_photos delete error:", photosError.message);
      }
    }

    // Delete profile row.
    const { error: profileError } = await service
      .from("profiles")
      .delete()
      .eq("id", userId);
    if (profileError) {
      console.error("delete_account: profiles delete error:", profileError.message);
    }

    // Delete the auth user.
    const { error: authError } = await service.auth.admin.deleteUser(userId);
    if (authError) {
      return jsonResponse({ error: "Auth deletion failed: " + authError.message }, 500);
    }

    return jsonResponse({ ok: true });
  } catch (error) {
    return errorResponse(error);
  }
});
