#!/usr/bin/env python3
"""
Routevia · must-see kapak görseli çözücü (idempotent, reproduce edilebilir).

Ne yapar:
  Pinli (featured_places.is_active) olup hiç kapak görseli OLMAYAN POI'ler için
  TR Wikipedia'dan gerçek görsel çözer ve place_community_state.cover_photo'ya yazar.
  (Kart görsel önceliği: place_community_state.cover_photo → place_images → place_photos
   → runtime Wikidata/Wikipedia/Pexels edge function.)

Doğruluk (ultra özen):
  - TR Wikipedia REST summary EXACT başlık (en isabetli) → başlık-son-kelime atılmış hâli
    → şehir-farkında katı arama (place'in ayırt edici token'ları makale başlığında olmalı).
  - Eşleşmeyen POI atlanır (yanlış görsel YERİNE runtime fallback).
  - İşletme isimleri (otel/kafe/restoran...) atlanır.

Kullanım:
  python3 scripts/resolve_mustsee_covers.py            # çöz + DB'ye yaz
  python3 scripts/resolve_mustsee_covers.py --dry-run  # sadece çöz, yazma

DB erişimi tools/admin_fix/runsql.sh üzerinden (Supabase Management API, Keychain token).
"""
import json, re, sys, time, subprocess, urllib.request, urllib.parse, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RUNSQL = os.path.join(ROOT, "tools/admin_fix/runsql.sh")
UA = {"User-Agent": "Routevia/1.0 (routevia@tabserve.com.tr)"}
DRY = "--dry-run" in sys.argv

GEN = set("antik kenti kent oren ören yeri yer milli millî parki parkı park tabiat aniti anıti "
          "selalesi şelalesi selaleleri şelaleleri kalesi muzesi müzesi camii cami vadisi golu gölü "
          "gol göl dagi dağı dag dağ magarasi mağarası kanyonu plaji plajı koprusu köprüsü turbesi "
          "türbesi medresesi kulliyesi külliyesi kervansarayi kervansarayı yaylasi yaylası adasi adası "
          "kaplicalari kaplıcaları baraji barajı goleti göleti obruklari obrukları hoyugu höyüğü "
          "tapinagi tapınağı sarayi sarayı bogazi boğazı koyu köyü harabeleri harabeler".split())
BIZ = re.compile(r'\b(otel|hotel|restoran|restaurant|cafe|kafe|lokanta|pension|pansiyon|büfe|bufe|'
                 r'suit|apart|konaklama)\b|[&|]', re.I)


def runsql(sql):
    p = subprocess.run(["bash", RUNSQL, "/dev/stdin"], input=sql, text=True,
                       capture_output=True)
    return p.stdout.strip()


def runsql_file(sql):
    import tempfile
    with tempfile.NamedTemporaryFile("w", suffix=".sql", delete=False) as f:
        f.write(sql); path = f.name
    out = subprocess.run(["bash", RUNSQL, path], text=True, capture_output=True).stdout.strip()
    os.unlink(path)
    return out


def norm(s):
    s = (s or "").lower()
    for a, b in [('ç','c'),('ğ','g'),('ı','i'),('ö','o'),('ş','s'),('ü','u'),('â','a'),('î','i'),('û','u')]:
        s = s.replace(a, b)
    return re.sub(r'[^a-z0-9]+', ' ', s).strip()


GENN = {norm(g) for g in GEN}
def toks(s): return set(t for t in norm(s).split() if len(t) > 2)
def distinctive(name, city): return set(t for t in toks(name) if t not in GENN and t not in set(norm(city).split()))


def get(url): return json.load(urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=12))


def summary(title):
    try:
        t = urllib.parse.quote(title.replace(" ", "_"))
        d = get(f"https://tr.wikipedia.org/api/rest_v1/page/summary/{t}")
        if d.get("type") == "disambiguation":
            return None, None
        return (d.get("originalimage") or d.get("thumbnail") or {}).get("source"), d.get("title")
    except Exception:
        return None, None


def search(name, dist):
    p = urllib.parse.urlencode({"action": "query", "list": "search", "srsearch": name,
                                "format": "json", "srlimit": "4", "formatversion": "2"})
    try:
        for r in get(f"https://tr.wikipedia.org/w/api.php?{p}").get("query", {}).get("search", []):
            if not dist or not dist.issubset(toks(r["title"])):
                continue
            img, t = summary(r["title"])
            if img:
                return img, t
    except Exception:
        pass
    return None, None


def resolve(name, city):
    dist = distinctive(name, city)
    img, t = summary(name)
    if img:
        return img, t, "exact"
    parts = name.split()
    if len(parts) > 1:
        img, t = summary(" ".join(parts[:-1]))
        if img and dist.issubset(toks(t)):
            return img, t, "short"
    if dist:
        img, t = search(name, dist)
        if img:
            return img, t, "search"
    return None, None, "none"


def main():
    rows = json.loads(runsql_file(
        "select coalesce(json_agg(json_build_object('id',p.id,'name',p.name,'city',p.city)),'[]') j "
        "from pois p join featured_places f on f.place_id=p.id and f.is_active "
        "where not exists (select 1 from place_community_state s where s.place_id=p.id and coalesce(s.cover_photo,'')<>'') "
        "and not exists (select 1 from place_images i where i.place_id=p.id and i.is_published and i.is_active) "
        "and not exists (select 1 from place_photos ph where ph.place_id=p.id and ph.status='approved');"))[0]["j"]

    print(f"kapaksız pinli POI: {len(rows)}")
    out = {}
    for i, p in enumerate(rows):
        if BIZ.search(p["name"]):
            continue
        u, t, src = resolve(p["name"], p["city"])
        if u:
            out[p["id"]] = u
        if (i + 1) % 40 == 0:
            print(f"  ...{i+1}/{len(rows)} (çözülen {len(out)})", flush=True)
        time.sleep(0.04)
    print(f"çözülen: {len(out)}/{len(rows)}")

    if DRY or not out:
        return
    vals = ",\n".join(f"('{pid}','{u.replace(chr(39), chr(39)*2)}')" for pid, u in out.items())
    runsql_file(f"""
      insert into place_community_state (place_id,cover_photo,routevia_score,avg_rating,review_count,checkins_count,photo_count,updated_at)
      select x.pid::uuid,x.url,0,0,0,0,0,now() from (values {vals}) as x(pid,url)
      on conflict (place_id) do update set cover_photo=excluded.cover_photo, updated_at=now()
      where coalesce(place_community_state.cover_photo,'')='';
    """)
    print(f"yazıldı: {len(out)} cover")


if __name__ == "__main__":
    main()
