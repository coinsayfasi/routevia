"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

import { requireAdmin } from "@/lib/auth";
import { createSupabaseAdminClient } from "@/lib/supabase/server";

function slugify(value: string) {
  return value
    .trim()
    .toLowerCase()
    .replaceAll("ç", "c")
    .replaceAll("ğ", "g")
    .replaceAll("ı", "i")
    .replaceAll("ö", "o")
    .replaceAll("ş", "s")
    .replaceAll("ü", "u")
    .replaceAll(/[^a-z0-9]+/g, "-")
    .replaceAll(/^-+|-+$/g, "");
}

export async function createEventAction(formData: FormData) {
  await requireAdmin();

  const provinceId = String(formData.get("province_id") ?? "").trim();
  const district = String(formData.get("district") ?? "").trim();
  const name = String(formData.get("name") ?? "").trim();
  const slugInput = String(formData.get("slug") ?? "").trim();
  const description = String(formData.get("description") ?? "").trim();
  const monthStart = Number.parseInt(String(formData.get("month_start") ?? ""), 10);
  const monthEnd = Number.parseInt(String(formData.get("month_end") ?? ""), 10);
  const category = String(formData.get("category") ?? "festival").trim();
  const tags = String(formData.get("tags") ?? "")
    .split(",")
    .map((tag) => tag.trim())
    .filter(Boolean);
  const latRaw = String(formData.get("lat") ?? "").trim();
  const lngRaw = String(formData.get("lng") ?? "").trim();
  const imageUrl = String(formData.get("image_url") ?? "").trim();
  const sourceUrl = String(formData.get("source_url") ?? "").trim();

  if (!provinceId || !name || !Number.isFinite(monthStart) || !Number.isFinite(monthEnd)) {
    redirect("/events?error=missing_fields");
  }

  const supabase = await createSupabaseAdminClient();
  const { data: province, error: provinceError } = await supabase
    .from("provinces")
    .select("id,name")
    .eq("id", provinceId)
    .maybeSingle();

  if (provinceError || !province) {
    redirect("/events?error=province_not_found");
  }

  const { error } = await supabase.from("events").insert({
    province_id: province.id,
    province_name: province.name,
    district: district || null,
    name,
    slug: slugInput || slugify(name),
    description: description || null,
    month_start: monthStart,
    month_end: monthEnd,
    category,
    tags,
    lat: latRaw ? Number.parseFloat(latRaw) : null,
    lng: lngRaw ? Number.parseFloat(lngRaw) : null,
    image_url: imageUrl || null,
    source_url: sourceUrl || null,
    is_active: true,
  });

  if (error) {
    redirect(`/events?error=${encodeURIComponent(error.message)}`);
  }

  revalidatePath("/events");
  redirect("/events?created=1");
}
