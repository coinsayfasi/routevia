import { decodeBase64 } from "https://deno.land/std@0.224.0/encoding/base64.ts";
import { getServiceClient } from "./client.ts";

const minPhotoBytes = 50 * 1024;
const minPhotoPixels = 300;

type ImageMeta = {
  width: number;
  height: number;
};

function parsePngMeta(bytes: Uint8Array): ImageMeta | null {
  if (bytes.length < 24) return null;
  const pngSig = [137, 80, 78, 71, 13, 10, 26, 10];
  for (let i = 0; i < pngSig.length; i += 1) {
    if (bytes[i] !== pngSig[i]) return null;
  }
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const width = view.getUint32(16);
  const height = view.getUint32(20);
  if (!width || !height) return null;
  return { width, height };
}

function parseJpegMeta(bytes: Uint8Array): ImageMeta | null {
  if (bytes.length < 4 || bytes[0] !== 0xff || bytes[1] !== 0xd8) return null;
  let offset = 2;
  while (offset + 9 < bytes.length) {
    if (bytes[offset] !== 0xff) {
      offset += 1;
      continue;
    }
    const marker = bytes[offset + 1];
    offset += 2;
    if (marker === 0xd8 || marker === 0xd9) continue;
    if (offset + 2 > bytes.length) break;
    const length = (bytes[offset] << 8) | bytes[offset + 1];
    if (length < 2 || offset + length > bytes.length) break;
    const isSof =
      (marker >= 0xc0 && marker <= 0xc3) ||
      (marker >= 0xc5 && marker <= 0xc7) ||
      (marker >= 0xc9 && marker <= 0xcb) ||
      (marker >= 0xcd && marker <= 0xcf);
    if (isSof && offset + 7 < bytes.length) {
      const height = (bytes[offset + 3] << 8) | bytes[offset + 4];
      const width = (bytes[offset + 5] << 8) | bytes[offset + 6];
      if (!width || !height) return null;
      return { width, height };
    }
    offset += length;
  }
  return null;
}

export function extractImageMeta(bytes: Uint8Array): ImageMeta | null {
  return parsePngMeta(bytes) ?? parseJpegMeta(bytes);
}

export function isLikelyBlankImage(bytes: Uint8Array): boolean {
  if (bytes.length < 2048) return true;
  const sampleWindow = Math.min(bytes.length, 24 * 1024);
  const sampleStride = Math.max(1, Math.floor(sampleWindow / 1024));
  const seen = new Set<number>();
  let sum = 0;
  let count = 0;
  for (let i = 0; i < sampleWindow; i += sampleStride) {
    const value = bytes[i];
    seen.add(value);
    sum += value;
    count += 1;
  }
  if (count == 0) return true;
  const mean = sum / count;
  let variance = 0;
  for (let i = 0; i < sampleWindow; i += sampleStride) {
    const delta = bytes[i] - mean;
    variance += delta * delta;
  }
  variance = variance / count;
  return seen.size < 12 || variance < 8;
}

export function decodePhotoPayload(base64Data: string): Uint8Array {
  const trimmed = base64Data.replace(/^data:image\/[a-zA-Z0-9.+-]+;base64,/, "").trim();
  return decodeBase64(trimmed);
}

export function validatePhotoBytes(bytes: Uint8Array) {
  if (bytes.byteLength <= minPhotoBytes) {
    throw new Error("Fotoğraf en az 50 KB olmalı.");
  }
  const meta = extractImageMeta(bytes);
  if (!meta || meta.width < minPhotoPixels || meta.height < minPhotoPixels) {
    throw new Error("Fotoğraf çözünürlüğü en az 300x300 olmalı.");
  }
  if (isLikelyBlankImage(bytes)) {
    throw new Error("Boş veya tek renk görsel kabul edilmiyor.");
  }
  return meta;
}

export function getUtcDayStartIso(now = new Date()): string {
  return new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate())).toISOString();
}

export async function ensurePlaceExists(placeId: string) {
  const service = getServiceClient();
  const { data, error } = await service
    .from("pois")
    .select("id")
    .eq("provenance_verified", true)
    .eq("id", placeId)
    .maybeSingle();

  if (error || !data) {
    throw new Error("Place not found");
  }
}

export async function countDailyRows(table: string, userId: string, sinceIso: string): Promise<number> {
  const service = getServiceClient();
  const { count, error } = await service
    .from(table)
    .select("id", { count: "exact", head: true })
    .eq("user_id", userId)
    .gte("created_at", sinceIso);

  if (error) {
    throw new Error(error.message);
  }
  return count ?? 0;
}

export async function uploadPhotoObject(params: {
  userId: string;
  placeId: string;
  fileExt: string;
  contentType: string;
  bytes: Uint8Array;
}) {
  const service = getServiceClient();
  const fileName = `${crypto.randomUUID()}.${params.fileExt}`;
  const storagePath = `${params.userId}/${params.placeId}/${fileName}`;
  const { error } = await service.storage
    .from("place-photos")
    .upload(storagePath, params.bytes, {
      cacheControl: "3600",
      contentType: params.contentType,
      upsert: false,
    });

  if (error) {
    throw new Error(error.message);
  }

  const { data } = service.storage.from("place-photos").getPublicUrl(storagePath);
  return {
    storagePath,
    imageUrl: data.publicUrl,
  };
}
