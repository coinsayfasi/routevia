ROUTEVIA 81 IL GOLD CONTENT SPRINT

1) Il Bazli Minimum Kalite Bari (publish oncesi zorunlu)
- Her il: minimum 120 published POI
- Her ilce: minimum 8 published POI (buyuk ilcelerde 15+)
- Kategori kapsama (her il): museum, historical, nature, beach/shore (uygunsa), viewpoint, market, mall, cafe, food, activity, lodging
- Her POI icin:
  - 1+ medya path (public-media/...)
  - short_summary <= 160
  - history_bullets <= 3
  - eat_drink_bullets <= 3
  - tips_bullets <= 4
  - tags min 3 (sunset/sunrise/family/budget/instagrammable/hidden_gem/walkable/free/rainy_day)
  - lat/lng zorunlu
  - duration_min 15..240
- Harita ve Explore kalite:
  - province center + district center + nearby response verification
  - en az 30 nearby sonucu olan 5 hotspot nokta (il basi)

2) Il Bazli Checklist
- A) Core POI seti
- B) Medya baglama (placeholder ya da gercek)
- C) Hap bilgi zenginlestirme
- D) category/tag kalite audit
- E) Nearby smoke test (1/3/10km)
- F) generate_trip_plan smoke test (relax/photo/family/budget/foodie)
- G) share token + read-only view test

3) Kabul Kriteri (Done)
- il bazli coverage >= 95% (districts_with_places / district_total)
- crash-free analyze + local run
- nearby sonuçları il disina kacmiyor
- published olmayan icerik publicte gorunmuyor

4) Operasyon Modeli
- User suggestions -> pending
- Admin review -> approved/rejected + note
- Approved item -> admin_place_upsert -> publish quality guard -> live
