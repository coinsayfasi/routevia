import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import {
  countDailyRows,
  decodePhotoPayload,
  ensurePlaceExists,
  getUtcDayStartIso,
  uploadPhotoObject,
  validatePhotoBytes,
} from "../_shared/community.ts";

type UploadPhotoPayload = {
  place_id?: string;
  file_name?: string;
  content_type?: string;
  file_base64?: string;
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const body = (await req.json()) as UploadPhotoPayload;
    const placeId = String(body.place_id ?? "").trim();
    const fileName = String(body.file_name ?? "upload.jpg").trim();
    const contentType = String(body.content_type ?? "image/jpeg").trim().toLowerCase();
    const fileBase64 = String(body.file_base64 ?? "").trim();

    if (!placeId) return jsonResponse({ error: "place_id is required" }, 400);
    if (!fileBase64) return jsonResponse({ error: "file_base64 is required" }, 400);
    if (!["image/jpeg", "image/png"].includes(contentType)) {
      return jsonResponse({ error: "Only JPEG and PNG are supported" }, 400);
    }

    await ensurePlaceExists(placeId);
    const uploadedToday = await countDailyRows("place_photos", user.id, getUtcDayStartIso());
    if (uploadedToday >= 5) {
      return jsonResponse({
        error: "daily_photo_limit_exceeded",
        message: "Günlük fotoğraf yükleme sınırına ulaştın. Bugün en fazla 5 fotoğraf ekleyebilirsin.",
      }, 429);
    }

    const bytes = decodePhotoPayload(fileBase64);
    const meta = validatePhotoBytes(bytes);
    const service = getServiceClient();
    const fileExt = contentType === "image/png" ? "png" : "jpg";
    const uploaded = await uploadPhotoObject({
      userId: user.id,
      placeId,
      fileExt,
      contentType,
      bytes,
    });

    const { data: inserted, error: insertError } = await service
      .from("place_photos")
      .insert({
        place_id: placeId,
        user_id: user.id,
        image_url: uploaded.imageUrl,
        storage_path: uploaded.storagePath,
        status: "pending",
        likes_count: 0,
        reports_count: 0,
        width_px: meta.width,
        height_px: meta.height,
        file_size_bytes: bytes.byteLength,
        moderation_note: `awaiting_review:${fileName}`,
      })
      .select("id,place_id,user_id,image_url,storage_path,status,likes_count,reports_count,created_at,updated_at")
      .maybeSingle();

    if (insertError) {
      // Clean up the storage object so it doesn't become an orphan
      try {
        await service.storage.from("place-photos").remove([uploaded.storagePath]);
      } catch (_) { /* best effort */ }
      return jsonResponse({ error: insertError.message }, 500);
    }

    const { data: state } = await service
      .from("place_community_state")
      .select("place_id,routevia_score,avg_rating,review_count,checkins_count,photo_count,cover_photo")
      .eq("place_id", placeId)
      .maybeSingle();

    return jsonResponse({ ok: true, photo: inserted, community: state ?? {} });
  } catch (error) {
    return errorResponse(error);
  }
});
