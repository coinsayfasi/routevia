"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import { createSupabaseAdminClient } from "@/lib/supabase/server";

export async function toggleVerified(placeId: string, current: boolean) {
  await requireAdmin();
  const supabase = await createSupabaseAdminClient();
  const { error } = await supabase
    .from("pois")
    .update({ provenance_verified: !current })
    .eq("id", placeId);
  if (error) throw error;
  revalidatePath("/places");
}

export async function toggleFeatured(placeId: string, isFeatured: boolean) {
  await requireAdmin();
  const supabase = await createSupabaseAdminClient();
  if (isFeatured) {
    await supabase.from("featured_places").delete().eq("place_id", placeId);
  } else {
    await supabase.from("featured_places").upsert({ place_id: placeId }, { onConflict: "place_id" });
  }
  revalidatePath("/places");
  revalidatePath("/editorial");
}
