"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import { createSupabaseAdminClient } from "@/lib/supabase/server";

export async function togglePublished(placeId: string, current: boolean) {
  await requireAdmin();
  const supabase = await createSupabaseAdminClient();
  const { error } = await supabase
    .from("pois")
    .update({ is_published: !current })
    .eq("id", placeId);
  if (error) throw error;
  revalidatePath("/places");
}

export async function toggleFeatured(placeId: string, current: boolean) {
  await requireAdmin();
  const supabase = await createSupabaseAdminClient();
  const { error } = await supabase
    .from("pois")
    .update({ is_featured: !current })
    .eq("id", placeId);
  if (error) throw error;
  revalidatePath("/places");
  revalidatePath("/editorial");
}
