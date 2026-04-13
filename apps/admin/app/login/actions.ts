"use server";

import { redirect } from "next/navigation";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { headers } from "next/headers";

export async function sendMagicLink(formData: FormData) {
  const email = (formData.get("email") as string | null)?.trim().toLowerCase();

  const allowedEmail = process.env.ADMIN_ALLOWED_EMAIL?.trim().toLowerCase();

  if (!email) {
    redirect("/login?error=email_required");
  }

  // Email whitelist — sadece yetkili admin girebilir
  if (allowedEmail && email !== allowedEmail) {
    // Gerçek hata vermiyoruz, kaba kuvvet saldırısına bilgi vermemek için
    redirect("/login?sent=1");
  }

  const supabase = await createSupabaseServerClient();
  const headerStore = await headers();
  const origin = headerStore.get("origin") ?? "";

  const { error } = await supabase.auth.signInWithOtp({
    email,
    options: {
      emailRedirectTo: `${origin}/auth/callback`,
      shouldCreateUser: false, // Sadece mevcut kullanıcılar
    },
  });

  if (error) {
    redirect("/login?error=send_failed");
  }

  redirect("/login?sent=1");
}
