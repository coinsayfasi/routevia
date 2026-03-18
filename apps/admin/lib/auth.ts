import { redirect } from "next/navigation";
import { createSupabaseAdminClient, createSupabaseServerClient } from "@/lib/supabase/server";

export async function requireAdmin() {
  if (
    process.env.NODE_ENV !== "production" &&
    process.env.ROUTEVIA_ADMIN_BYPASS === "true"
  ) {
    return {
      user: {
        id: "local-admin-bypass",
      },
      profile: {
        role: "admin",
        display_name: "Local Admin",
      },
    };
  }

  const supabase = await createSupabaseServerClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login");
  }

  const admin = await createSupabaseAdminClient();
  const { data, error } = await admin
    .from("profiles")
    .select("role,display_name")
    .eq("id", user.id)
    .single();

  if (error || data?.role !== "admin") {
    redirect("/login");
  }

  return {
    user,
    profile: data,
  };
}
