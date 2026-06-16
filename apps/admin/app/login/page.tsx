import { sendMagicLink } from "./actions";

interface Props {
  searchParams: Promise<{ sent?: string; error?: string }>;
}

export default async function LoginPage({ searchParams }: Props) {
  const { sent, error } = await searchParams;

  return (
    <div className="mx-auto flex min-h-screen max-w-lg items-center px-6">
      <div className="panel w-full rounded-3xl p-8 shadow-sm">
        <p className="text-sm uppercase tracking-[0.18em] text-slate-500">
          Routevia
        </p>
        <h1 className="mt-3 text-3xl font-semibold tracking-tight text-slate-950">
          Admin Girişi
        </h1>
        <p className="mt-2 text-sm text-slate-500">
          Email adresinize giriş bağlantısı gönderilecek.
        </p>

        {sent ? (
          <div className="mt-6 rounded-2xl bg-teal-50 px-4 py-4">
            <p className="text-sm font-medium text-teal-800">
              Bağlantı gönderildi
            </p>
            <p className="mt-1 text-sm text-teal-700">
              Email kutunuzu kontrol edin ve gelen bağlantıya tıklayın.
            </p>
          </div>
        ) : (
          <form action={sendMagicLink} className="mt-6 space-y-4">
            <div>
              <label
                htmlFor="email"
                className="block text-sm font-medium text-slate-700"
              >
                Email
              </label>
              <input
                id="email"
                name="email"
                type="email"
                required
                autoComplete="email"
                className="mt-1 w-full rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm text-slate-900 outline-none transition focus:border-teal-500 focus:ring-2 focus:ring-teal-100"
                placeholder="admin@example.com"
              />
            </div>

            {error && (
              <p className="text-sm text-red-600">
                {error === "email_required"
                  ? "Email adresi gerekli."
                  : "Bir hata oluştu, tekrar deneyin."}
              </p>
            )}

            <button
              type="submit"
              className="w-full rounded-xl bg-slate-900 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-slate-700 active:scale-[0.98]"
            >
              Giriş Bağlantısı Gönder
            </button>
          </form>
        )}
      </div>
    </div>
  );
}
