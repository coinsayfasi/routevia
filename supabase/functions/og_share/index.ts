import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
);

serve(async (req: Request) => {
  const url = new URL(req.url);
  const token = url.searchParams.get('token');

  if (!token) {
    return htmlResponse(errorPage('Geçersiz bağlantı.'), 400);
  }

  // 1. Resolve share token
  const { data: share } = await supabase
    .from('trip_shares_clean')
    .select('trip_id')
    .eq('share_token', token)
    .maybeSingle();

  if (!share) {
    return htmlResponse(errorPage('Bu bağlantı artık geçerli değil veya bulunamadı.'), 404);
  }

  // 2. Fetch trip
  const { data: trip } = await supabase
    .from('trips_clean')
    .select('id, province_id, days, pref_pace, pref_persona')
    .eq('id', share.trip_id)
    .maybeSingle();

  if (!trip) {
    return htmlResponse(errorPage('Gezi bulunamadı.'), 404);
  }

  // 3. Fetch province
  const { data: province } = await supabase
    .from('provinces')
    .select('name')
    .eq('id', trip.province_id)
    .maybeSingle();

  const provinceName = province?.name ?? 'Türkiye';

  // 4. Fetch cover image — try both slug variants (Turkish chars transliterated vs. stripped)
  const slugify = (s: string) =>
    s.toLowerCase().trim().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '').slice(0, 80);
  const transliterateAndSlug = (s: string) =>
    s.replace(/[ğ]/gi, 'g').replace(/[üÜ]/g, 'u').replace(/[şŞ]/g, 's')
     .replace(/[ıİ]/g, 'i').replace(/[öÖ]/g, 'o').replace(/[çÇ]/g, 'c')
     .toLowerCase().trim().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '').slice(0, 80);
  const slug = transliterateAndSlug(provinceName);
  const slugAlt = slugify(provinceName);
  let cityImg: { image_url: string; photographer: string } | null = null;
  { const { data } = await supabase.from('city_images').select('image_url, photographer').eq('city_slug', slug).maybeSingle(); cityImg = data; }
  if (!cityImg && slugAlt !== slug) {
    const { data } = await supabase.from('city_images').select('image_url, photographer').eq('city_slug', slugAlt).maybeSingle();
    cityImg = data;
  }

  const coverUrl = cityImg?.image_url ?? '';
  const photographer = cityImg?.photographer ?? '';

  // 5. Build labels
  const days = trip.days ?? 1;
  const dayLabel = days === 1 ? '1 Günlük' : `${days} Günlük`;
  const paceMap: Record<string, string> = { slow: 'Sakin', fast: 'Hızlı', balanced: 'Dengeli' };
  const paceLabel = paceMap[trip.pref_pace ?? ''] ?? '';
  const personaMap: Record<string, string> = {
    nature: 'Doğa', history: 'Tarih', food: 'Gastronomi',
    adventure: 'Macera', culture: 'Kültür', relax: 'Dinlenme',
  };
  const personaLabel = personaMap[trip.pref_persona ?? ''] ?? '';

  const title = `${dayLabel} ${provinceName} Gezisi — Routevia`;
  const description = [paceLabel, personaLabel, provinceName].filter(Boolean).join(' · ') +
    ' rotası seni bekliyor. Routevia ile keşfet.';

  const deepLink = `routevia://share/${token}`;
  const appStoreUrl = 'https://apps.apple.com/app/routevia/id6761003117';
  const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.yunusgunes.routevia';
  const canonicalUrl = `${Deno.env.get('SUPABASE_URL')}/functions/v1/og_share?token=${token}`;

  const html = `<!DOCTYPE html>
<html lang="tr">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${escHtml(title)}</title>

  <!-- Open Graph -->
  <meta property="og:type" content="website" />
  <meta property="og:url" content="${escHtml(canonicalUrl)}" />
  <meta property="og:title" content="${escHtml(title)}" />
  <meta property="og:description" content="${escHtml(description)}" />
  ${coverUrl ? `<meta property="og:image" content="${escHtml(coverUrl)}" />
  <meta property="og:image:width" content="1200" />
  <meta property="og:image:height" content="630" />` : ''}
  <meta property="og:site_name" content="Routevia" />
  <meta property="og:locale" content="tr_TR" />

  <!-- Twitter Card -->
  <meta name="twitter:card" content="${coverUrl ? 'summary_large_image' : 'summary'}" />
  <meta name="twitter:title" content="${escHtml(title)}" />
  <meta name="twitter:description" content="${escHtml(description)}" />
  ${coverUrl ? `<meta name="twitter:image" content="${escHtml(coverUrl)}" />` : ''}

  <!-- App Links (iOS) -->
  <meta property="al:ios:url" content="${escHtml(deepLink)}" />
  <meta property="al:ios:app_store_id" content="6761003117" />
  <meta property="al:ios:app_name" content="Routevia" />

  <!-- App Links (Android) -->
  <meta property="al:android:url" content="${escHtml(deepLink)}" />
  <meta property="al:android:package" content="com.yunusgunes.routevia" />
  <meta property="al:android:app_name" content="Routevia" />

  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: #040d1a;
      color: #f0f4ff;
      min-height: 100dvh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 24px;
    }
    .card {
      background: linear-gradient(145deg, #0b1f3a, #061126);
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 20px;
      max-width: 420px;
      width: 100%;
      overflow: hidden;
      box-shadow: 0 24px 60px rgba(0,0,0,0.5);
    }
    .cover {
      width: 100%;
      height: 200px;
      object-fit: cover;
      display: block;
    }
    .cover-placeholder {
      width: 100%;
      height: 200px;
      background: linear-gradient(135deg, #0e4f8a, #0b3b68);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 64px;
    }
    .body { padding: 24px; }
    .badge {
      display: inline-block;
      background: rgba(20,184,166,0.2);
      color: #5eead4;
      border: 1px solid rgba(20,184,166,0.35);
      border-radius: 8px;
      font-size: 12px;
      font-weight: 600;
      padding: 4px 10px;
      margin-bottom: 12px;
      letter-spacing: 0.5px;
    }
    h1 { font-size: 22px; font-weight: 700; line-height: 1.3; margin-bottom: 8px; }
    .desc { color: rgba(240,244,255,0.65); font-size: 14px; line-height: 1.5; margin-bottom: 24px; }
    .photo-credit { color: rgba(240,244,255,0.35); font-size: 11px; margin-bottom: 20px; }
    .btn {
      display: block;
      width: 100%;
      padding: 15px;
      border-radius: 14px;
      font-size: 16px;
      font-weight: 700;
      text-align: center;
      text-decoration: none;
      cursor: pointer;
      border: none;
      transition: opacity 0.15s;
    }
    .btn:active { opacity: 0.8; }
    .btn-primary {
      background: linear-gradient(135deg, #14b8a6, #0e9488);
      color: #fff;
      margin-bottom: 12px;
    }
    .btn-secondary {
      background: rgba(255,255,255,0.08);
      color: rgba(240,244,255,0.8);
      border: 1px solid rgba(255,255,255,0.12);
    }
    .logo { text-align: center; margin-top: 28px; color: rgba(240,244,255,0.3); font-size: 13px; }
  </style>
</head>
<body>
  <div class="card">
    ${coverUrl
      ? `<img class="cover" src="${escHtml(coverUrl)}" alt="${escHtml(provinceName)}" />`
      : `<div class="cover-placeholder">🗺️</div>`}
    <div class="body">
      <div class="badge">Routevia Gezi Planı</div>
      <h1>${escHtml(provinceName)}'da ${escHtml(dayLabel)} Macera</h1>
      <p class="desc">${escHtml(description)}</p>
      ${photographer ? `<p class="photo-credit">Fotoğraf: ${escHtml(photographer)} / Pexels</p>` : ''}
      <a class="btn btn-primary" id="openBtn" href="${escHtml(deepLink)}">Uygulamada Aç</a>
      <a class="btn btn-secondary" id="storeBtn" href="${escHtml(appStoreUrl)}">Uygulamayı İndir</a>
    </div>
  </div>
  <p class="logo">Routevia — Akıllı Seyahat Asistanı</p>

  <script>
    // Auto deep-link on mobile after 150ms, fall back to store
    var deepLink = ${JSON.stringify(deepLink)};
    var appStoreUrl = ${JSON.stringify(appStoreUrl)};
    var playStoreUrl = ${JSON.stringify(playStoreUrl)};
    var ua = navigator.userAgent || '';
    var isAndroid = /Android/i.test(ua);
    var isIOS = /iPhone|iPad|iPod/i.test(ua);
    var storeUrl = isAndroid ? playStoreUrl : appStoreUrl;
    document.getElementById('storeBtn').href = storeUrl;

    if (isIOS || isAndroid) {
      setTimeout(function() {
        window.location.href = deepLink;
      }, 150);
      // If still here after 2s, show store button prominently
      setTimeout(function() {
        document.getElementById('storeBtn').textContent = 'Mağazadan İndir →';
      }, 2000);
    }
  </script>
</body>
</html>`;

  return htmlResponse(html, 200);
});

function escHtml(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

function htmlResponse(body: string, status: number): Response {
  return new Response(body, {
    status,
    headers: { 'Content-Type': 'text/html; charset=utf-8' },
  });
}

function errorPage(message: string): string {
  return `<!DOCTYPE html>
<html lang="tr">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Routevia</title>
  <style>
    body { font-family: -apple-system,sans-serif; background:#040d1a; color:#f0f4ff;
           display:flex; align-items:center; justify-content:center; min-height:100dvh;
           flex-direction:column; gap:16px; padding:24px; text-align:center; }
    p { color:rgba(240,244,255,0.6); }
    a { color:#5eead4; text-decoration:none; }
  </style>
</head>
<body>
  <div style="font-size:48px">🗺️</div>
  <h1 style="font-size:20px">Routevia</h1>
  <p>${escHtml(message)}</p>
  <a href="https://routevia.app">Ana Sayfaya Dön</a>
</body>
</html>`;
}
