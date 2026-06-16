#!/usr/bin/env python3
"""Phase 1: apply province/district corrections to live DB via Management API.
  mode=pc    -> update places_clean.province_id/district_id (sync trigger -> pois)
  mode=poi   -> disable autofill trigger, update pois.city/district directly, re-enable
"""
import json, os, sys, time, urllib.request, urllib.error

REF = "xfswonqskciufcnsehfc"
PAT = os.environ["SUPA_PAT"]
URL = f"https://api.supabase.com/v1/projects/{REF}/database/query"

def run(sql):
    req = urllib.request.Request(URL, data=json.dumps({"query": sql}).encode(),
        headers={"Authorization": f"Bearer {PAT}", "Content-Type": "application/json", "User-Agent": "curl/8.4.0"})
    try:
        return json.loads(urllib.request.urlopen(req, timeout=120).read().decode())
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"HTTP {e.code}: {e.read().decode()[:300]}")

def batches(rows, n):
    for i in range(0, len(rows), n):
        yield rows[i:i+n]

def vals(rows):
    # rows: list of (id,pid,did) ; did may be None
    parts = []
    for rid, pid, did in rows:
        d = f"'{did}'::uuid" if did else "null::uuid"
        parts.append(f"('{rid}'::uuid,'{pid}'::uuid,{d})")
    return ",".join(parts)

mode = sys.argv[1]
res = json.load(open("poi_corrections.json"))
pc_ids = set(r["id"] for r in json.load(open("places_clean.json")))
wrong = [r for r in res if r["status"] in ("wrong_province", "wrong_district") and r["province_id"]]
pc = [(r["id"], r["province_id"], r["district_id"]) for r in wrong if r["id"] in pc_ids]
poi = [(r["id"], r["province_id"], r["district_id"]) for r in wrong if r["id"] not in pc_ids]

if mode == "pc":
    print(f"places_clean fixes: {len(pc)}")
    done = 0
    for b in batches(pc, 1000):
        sql = f"""update public.places_clean pc set province_id=v.pid, district_id=v.did
from (values {vals(b)}) v(id,pid,did) where pc.id=v.id;"""
        run(sql); done += len(b); print(f"  applied {done}/{len(pc)}"); time.sleep(0.2)
    print("places_clean done")

elif mode == "poi":
    print(f"pois (non-places_clean) fixes: {len(poi)}")
    run("alter table public.pois disable trigger trg_pois_autofill_city_and_district;")
    print("  trigger DISABLED")
    try:
        done = 0
        for b in batches(poi, 1000):
            sql = f"""update public.pois p set city=pr.name, district=d.name, updated_at=now()
from (values {vals(b)}) v(id,pid,did)
join public.provinces pr on pr.id=v.pid
left join public.districts d on d.id=v.did
where p.id=v.id;"""
            run(sql); done += len(b); print(f"  applied {done}/{len(poi)}"); time.sleep(0.2)
    finally:
        run("alter table public.pois enable trigger trg_pois_autofill_city_and_district;")
        print("  trigger RE-ENABLED")
    print("pois done")
