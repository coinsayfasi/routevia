#!/usr/bin/env python3
"""Create & load staging table _admin_fix with per-poi target province/district + dedup keys."""
import json, os, re, time, unicodedata, urllib.request, urllib.error

REF = "xfswonqskciufcnsehfc"; PAT = os.environ["SUPA_PAT"]
URL = f"https://api.supabase.com/v1/projects/{REF}/database/query"
def run(sql):
    req = urllib.request.Request(URL, data=json.dumps({"query": sql}).encode(),
        headers={"Authorization": f"Bearer {PAT}", "Content-Type": "application/json", "User-Agent": "curl/8.4.0"})
    try: return json.loads(urllib.request.urlopen(req, timeout=180).read().decode())
    except urllib.error.HTTPError as e: raise RuntimeError(f"HTTP {e.code}: {e.read().decode()[:400]}")

def norm(s):
    if not s: return ""
    repl = {"İ":"i","I":"i","ı":"i","Ş":"s","ş":"s","Ğ":"g","ğ":"g","Ü":"u","ü":"u","Ö":"o","ö":"o","Ç":"c","ç":"c"}
    s = "".join(repl.get(c,c) for c in s).lower()
    return re.sub(r"[^a-z0-9]","",unicodedata.normalize("NFKD", s).encode("ascii","ignore").decode())

res = json.load(open("poi_corrections.json"))
rows = [r for r in res if r["status"] != "outside_tr" and r["province_id"]]
print("in-TR rows to stage:", len(rows))

run("""drop table if exists public._admin_fix;
create table public._admin_fix(
  id uuid primary key, pid uuid, did uuid, namekey text,
  latr numeric, lngr numeric, slug citext, precious boolean default false, keep boolean default true);""")

def esc(s): return s.replace("'", "''")
done = 0
buf = []
for r in rows:
    nk = esc(norm(r["name"]))
    did = f"'{r['district_id']}'::uuid" if r["district_id"] else "null"
    buf.append(f"('{r['id']}'::uuid,'{r['province_id']}'::uuid,{did},'{nk}',{round(r['lat'],3)},{round(r['lng'],3)})")
    if len(buf) >= 1500:
        run("insert into public._admin_fix(id,pid,did,namekey,latr,lngr) values " + ",".join(buf) + ";")
        done += len(buf); print(f"  loaded {done}/{len(rows)}"); buf = []; time.sleep(0.15)
if buf:
    run("insert into public._admin_fix(id,pid,did,namekey,latr,lngr) values " + ",".join(buf) + ";")
    done += len(buf); print(f"  loaded {done}/{len(rows)}")
print(run("select count(*) n from public._admin_fix;"))
