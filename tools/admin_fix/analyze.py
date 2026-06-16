#!/usr/bin/env python3
"""v2: Authoritative province from province-polygon; district from province-consistent
district-polygon, else nearest DB district centroid within the correct province."""
import json, re, unicodedata, collections, math
from shapely.geometry import shape, Point
from shapely.strtree import STRtree
from shapely.prepared import prep

def norm(s):
    if not s: return ""
    repl = {"İ":"i","I":"i","ı":"i","Ş":"s","ş":"s","Ğ":"g","ğ":"g","Ü":"u","ü":"u","Ö":"o","ö":"o","Ç":"c","ç":"c"}
    s = "".join(repl.get(c,c) for c in s).lower()
    s = unicodedata.normalize("NFKD", s).encode("ascii","ignore").decode()
    return re.sub(r"[^a-z0-9]","",s)

# ---------- DB admin ----------
provinces = json.load(open("provinces.json"))
prov_by_norm = {norm(p["name"]): p for p in provinces}
dcoords = json.load(open("districts_coords.json"))
dist_lookup = {}                       # (province_id, norm name) -> district row
dists_by_prov = collections.defaultdict(list)
for d in dcoords:
    dist_lookup[(d["province_id"], norm(d["name"]))] = d
    dists_by_prov[d["province_id"]].append(d)

# ---------- province polygons (izzetkalic admin-4 + alpers Iğdır) ----------
il = json.load(open("tr_l4.geojson"))
prov_polys, prov_pid, prov_pnorm = [], [], []
covered = set()
for f in il["features"]:
    p = f["properties"]
    if p.get("network") != "TR-provinces": continue
    nm = re.sub(r"\s*İli$","", p.get("name:tr") or p.get("name"))
    dbp = prov_by_norm.get(norm(nm))
    if not dbp: continue
    prov_polys.append(shape(f["geometry"])); prov_pid.append(dbp["id"]); prov_pnorm.append(norm(nm))
    covered.add(norm(nm))
# fill missing provinces (e.g. Iğdır) from alpers
alp = json.load(open("alpers_il.geojson"))
for f in alp["features"]:
    nm = f["properties"]["name"]; n = norm(nm)
    if n in covered: continue
    dbp = prov_by_norm.get(n)
    if not dbp: continue
    prov_polys.append(shape(f["geometry"])); prov_pid.append(dbp["id"]); prov_pnorm.append(n)
    covered.add(n)
print("province polygons:", len(prov_polys), "| DB provinces covered:", len(covered), "/ 81")

# ---------- district polygons (izzetkalic admin-6) ----------
ilce = json.load(open("tr_l6.geojson"))
plate_prov = {}
for f in il["features"]:
    p = f["properties"]
    if p.get("network") != "TR-provinces": continue
    m = re.match(r"TR-(\d+)", p.get("ISO3166-2",""))
    if m: plate_prov[int(m.group(1))] = norm(re.sub(r"\s*İli$","", p.get("name:tr") or p.get("name")))
dist_polys, dist_dnorm, dist_pnorm = [], [], []
for f in ilce["features"]:
    p = f["properties"]; m = re.match(r"TR(\d+)-districts", p.get("network",""))
    if not m: continue
    pn = plate_prov.get(int(m.group(1)))
    if not pn: continue
    dist_polys.append(shape(f["geometry"])); dist_dnorm.append(norm(p.get("name"))); dist_pnorm.append(pn)
print("district polygons:", len(dist_polys))

prov_tree = STRtree(prov_polys); prov_prep = [prep(g) for g in prov_polys]
dist_tree = STRtree(dist_polys); dist_prep = [prep(g) for g in dist_polys]

def map_db_district(province_id, prov_norm, osm_dname):
    """OSM district name -> DB district id within province (merkez-aware)."""
    if "merkez" in osm_dname or osm_dname == prov_norm:
        d = dist_lookup.get((province_id, "merkez"))
        if d: return d
    d = dist_lookup.get((province_id, osm_dname))
    return d

def nearest_db_district(province_id, lat, lng):
    best, bd = None, 1e18
    for d in dists_by_prov.get(province_id, []):
        dd = (d["lat"]-lat)**2 + (d["lng"]-lng)**2
        if dd < bd: bd, best = dd, d
    return best

def locate(lat, lng):
    pt = Point(lng, lat)
    pid = pnorm = None
    for i in prov_tree.query(pt):
        if prov_prep[i].contains(pt):
            pid, pnorm = prov_pid[i], prov_pnorm[i]; break
    if pid is None:
        return None, None, "outside_tr"
    # district: province-consistent polygon
    did = None; src = "centroid"
    for i in dist_tree.query(pt):
        if dist_pnorm[i] == pnorm and dist_prep[i].contains(pt):
            d = map_db_district(pid, pnorm, dist_dnorm[i])
            if d: did, src = d["id"], "polygon"; break
    if did is None:
        d = nearest_db_district(pid, lat, lng)
        if d: did = d["id"]
    return pid, did, src

# ---------- analyze ----------
prov_name = {p["id"]: p["name"] for p in provinces}
dist_name = {d["id"]: d["name"] for d in dcoords}
pois = json.load(open("pois.json"))
results, stat = [], collections.Counter()
for r in pois:
    lat, lng = r.get("lat"), r.get("lng")
    if lat is None or lng is None: stat["no_coord"]+=1; continue
    pid, did, src = locate(lat, lng)
    if pid is None:
        stat["outside_tr"]+=1
        results.append({"id":r["id"],"name":r["name"],"lat":lat,"lng":lng,"cur_city":r.get("city"),
                        "cur_district":r.get("district"),"province_id":None,"district_id":None,
                        "true_prov":None,"true_dist":None,"status":"outside_tr","dsrc":src})
        continue
    np_, nd_ = prov_name[pid], dist_name.get(did)
    pw = norm(r.get("city")) != norm(np_)
    dw = nd_ is not None and norm(r.get("district")) != norm(nd_)
    status = "wrong_province" if pw else ("wrong_district" if dw else "ok")
    stat[status]+=1; stat[f"dsrc_{src}"]+=1
    results.append({"id":r["id"],"name":r["name"],"lat":lat,"lng":lng,"cur_city":r.get("city"),
                    "cur_district":r.get("district"),"province_id":pid,"district_id":did,
                    "true_prov":np_,"true_dist":nd_,"status":status,"dsrc":src})

json.dump(results, open("poi_corrections.json","w"), ensure_ascii=False)
print("\n=== STATUS ==="); [print(f"  {k:22s}{v}") for k,v in stat.most_common()]
leak = collections.Counter((r["cur_city"], r["true_prov"]) for r in results if r["status"]=="wrong_province")
print("\n=== CROSS-PROVINCE MOVES (cur -> true : n) ===")
for (a,b),c in leak.most_common(30): print(f"  {a} -> {b} : {c}")
