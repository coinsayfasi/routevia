import { createSupabaseAdminClient } from "@/lib/supabase/server";

export interface PlaceRow {
  id: string;
  name: string;
  category: string;
  city: string | null;
  district: string | null;
  provenance_verified: boolean | null;
  created_at: string | null;
  is_featured?: boolean;
}

export async function listPlaces(input: {
  search?: string;
  category?: string;
  verified?: string;
  page?: number;
  pageSize?: number;
}): Promise<{ rows: PlaceRow[]; total: number }> {
  const supabase = await createSupabaseAdminClient();
  const pageSize = Math.min(Math.max(input.pageSize ?? 25, 1), 100);
  const page = Math.max(input.page ?? 1, 1);
  const offset = (page - 1) * pageSize;

  let query = supabase
    .from("pois")
    .select("id,name,category,city,district,provenance_verified,created_at", {
      count: "exact",
    })
    .order("created_at", { ascending: false });

  if (input.search?.trim()) {
    query = query.ilike("name", `%${input.search.trim()}%`);
  }
  if (input.category && input.category !== "all") {
    query = query.eq("category", input.category);
  }
  if (input.verified === "true") {
    query = query.eq("provenance_verified", true);
  } else if (input.verified === "false") {
    query = query.eq("provenance_verified", false);
  }

  const { data, error, count } = await query.range(offset, offset + pageSize - 1);
  if (error) throw error;

  // Get featured place IDs
  const ids = (data ?? []).map((r) => r.id as string);
  let featuredIds = new Set<string>();
  if (ids.length > 0) {
    const { data: fp } = await supabase
      .from("featured_places")
      .select("place_id")
      .in("place_id", ids);
    featuredIds = new Set((fp ?? []).map((r) => r.place_id as string));
  }

  const rows = (data ?? []).map((r) => ({
    ...(r as PlaceRow),
    is_featured: featuredIds.has(r.id as string),
  }));

  return { rows, total: count ?? 0 };
}

export async function listFeaturedPlaces(): Promise<PlaceRow[]> {
  const supabase = await createSupabaseAdminClient();
  const { data: fp, error: fpErr } = await supabase
    .from("featured_places")
    .select("place_id")
    .order("created_at", { ascending: false });
  if (fpErr) throw fpErr;
  if (!fp || fp.length === 0) return [];

  const ids = fp.map((r) => r.place_id as string);
  const { data, error } = await supabase
    .from("pois")
    .select("id,name,category,city,district,provenance_verified,created_at")
    .in("id", ids)
    .order("name", { ascending: true });
  if (error) throw error;
  return (data ?? []).map((r) => ({ ...(r as PlaceRow), is_featured: true }));
}
