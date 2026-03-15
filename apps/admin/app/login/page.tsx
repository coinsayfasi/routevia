export default function LoginPage() {
  return (
    <div className="mx-auto flex min-h-screen max-w-lg items-center px-6">
      <div className="panel w-full rounded-3xl p-8 shadow-sm">
        <p className="text-sm uppercase tracking-[0.18em] text-slate-500">
          Routevia Admin
        </p>
        <h1 className="mt-3 text-3xl font-semibold tracking-tight text-slate-950">
          Giriş entegrasyonu gerekli
        </h1>
        <p className="mt-3 text-sm text-slate-600">
          Bu iskelet Supabase auth + admin role doğrulaması ile çalışacak şekilde hazırlandı.
          Gerçek sign-in UI ve callback route’u ürün kararına göre eklenmeli.
        </p>
      </div>
    </div>
  );
}
