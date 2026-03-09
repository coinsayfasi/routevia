import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/trip_models.dart';
import 'fallback_provinces.dart';
import 'local_cache.dart';

class RouteviaRepository {
  RouteviaRepository(this._client, this._cache);

  final SupabaseClient _client;
  final LocalCache _cache;
  final Map<String, _NearbyCacheEntry> _nearbyCache = {};

  Future<void> _safeLogEvent(
    String eventName, {
    Map<String, dynamic> payload = const {},
  }) async {
    try {
      await logAppEvent(eventName, payload: payload);
    } catch (_) {}
  }

  SupabaseClient get client => _client;

  String _normalizeTransportMode(String mode) {
    if (mode == 'scooter') return 'bike';
    return mode;
  }

  int _stopsPerDayForPace(String pace) {
    switch (pace) {
      case 'slow':
        return 6;
      case 'fast':
        return 8;
      default:
        return 7;
    }
  }

  Future<void> _persistTripArtifacts(TripPlan trip) async {
    await _cache.saveLastTrip(trip.toMap());
    await _cache.saveTripHistoryEntry(trip.toMap());
  }

  Future<TripPlan> _saveTripRemote(TripPlan trip) async {
    final user = _client.auth.currentUser;
    if (user == null) return trip;

    final tripInsert = await _client
        .from('trips_clean')
        .insert({
          'user_id': user.id,
          'province_id': trip.province.id,
          'days': trip.days,
          'transport_mode': trip.transportMode,
          'pace': trip.pace,
          'persona_mode': trip.personaMode,
          'preferences': trip.preferences,
        })
        .select('id')
        .single();

    final tripId = (tripInsert['id'] as String?) ?? trip.tripId;

    try {
      final dayPayload = trip.daysPlan
          .map((day) => {'trip_id': tripId, 'day_number': day.dayNumber})
          .toList();
      final insertedDays = await _client
          .from('trip_days_clean')
          .insert(dayPayload)
          .select('id,day_number');

      final dayIdByNumber = {
        for (final raw in (insertedDays as List))
          (raw['day_number'] as num).toInt(): raw['id'] as String,
      };

      final stopPayload = <Map<String, dynamic>>[];
      for (final day in trip.daysPlan) {
        final tripDayId = dayIdByNumber[day.dayNumber];
        if (tripDayId == null) continue;
        for (final stop in day.stops) {
          stopPayload.add({
            'trip_day_id': tripDayId,
            'place_id': stop.place.id,
            'order_index': stop.orderIndex,
            'arrival_time': stop.arrivalTime,
            'duration_min': stop.durationMin,
            'transport_mode': stop.transportMode,
          });
        }
      }

      if (stopPayload.isNotEmpty) {
        await _client.from('trip_stops_clean').insert(stopPayload);
      }

      return TripPlan(
        tripId: tripId,
        days: trip.days,
        transportMode: trip.transportMode,
        pace: trip.pace,
        personaMode: trip.personaMode,
        preferences: trip.preferences,
        province: trip.province,
        daysPlan: trip.daysPlan,
        startLat: trip.startLat,
        startLng: trip.startLng,
        radiusUsedKm: trip.radiusUsedKm,
        districtStrict: trip.districtStrict,
      );
    } catch (_) {
      await _client.from('trips_clean').delete().eq('id', tripId);
      rethrow;
    }
  }

  Future<void> _ensureFreshSession() async {
    final session = _client.auth.currentSession;
    if (session == null) return;
    final expiresAt = session.expiresAt;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (expiresAt == null || (expiresAt - now) <= 180) {
      try {
        await _client.auth.refreshSession();
      } catch (e) {
        // Only sign out if the refresh token is definitively invalid/expired.
        // Transient network errors must NOT force sign-out — that causes the
        // "oturum süreniz dolmuş" loop on poor connections.
        final msg = e.toString().toLowerCase();
        final isTokenInvalid =
            msg.contains('invalid refresh token') ||
            msg.contains('refresh_token_not_found') ||
            msg.contains('token has expired') ||
            msg.contains('user not found') ||
            msg.contains('invalid_grant');
        if (isTokenInvalid) {
          try {
            await _client.auth.signOut();
          } catch (_) {}
        }
      }
    }
  }

  Future<String> _requireAccessToken() async {
    await _ensureFreshSession();
    final token = _client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Oturum bulunamadi. Lutfen tekrar giris yap.');
    }
    return token;
  }

  bool _isAuthError(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('functionexception(status: 401') ||
        msg.contains('missing authorization header') ||
        msg.contains('unauthorized') ||
        msg.contains('invalid jwt') ||
        (msg.contains('session') && msg.contains('expired'));
  }

  Future<dynamic> _invokeFunction(
    String name, {
    Object? body,
    bool requireAuth = false,
  }) async {
    Future<dynamic> run() async {
      await _ensureFreshSession();
      final headers = <String, String>{};
      if (requireAuth) {
        headers['Authorization'] = 'Bearer ${await _requireAccessToken()}';
      }
      return _client.functions.invoke(name, body: body, headers: headers);
    }

    try {
      return await run();
    } catch (e) {
      if (!requireAuth || !_isAuthError(e)) rethrow;
      await _client.auth.refreshSession();
      return run();
    }
  }

  Future<void> signInWithOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email.trim(),
      shouldCreateUser: true,
      emailRedirectTo: 'routevia://auth-callback',
    );
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: 'routevia://auth-callback',
    );
  }

  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: 'https://legal.routevia.tabserve.com.tr/auth-callback',
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    await _client.auth.verifyOTP(
      type: OtpType.email,
      email: email.trim(),
      token: code.trim(),
    );
  }

  Future<void> ensureProfile() async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('profiles').upsert({
      'id': user.id,
      'display_name': user.email,
      'onboarding_completed': false,
    });
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('profiles')
        .select(
          'id,display_name,role,onboarding_completed,pref_tags,pref_pace,allow_location,allow_notifications,referral_code',
        )
        .eq('id', user.id)
        .maybeSingle();
    if (row == null) return null;
    return Map<String, dynamic>.from(row as Map);
  }

  Future<void> completeOnboarding({
    required List<String> prefTags,
    required String prefPace,
    required bool allowLocation,
    required bool allowNotifications,
  }) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('profiles').upsert({
      'id': user.id,
      'onboarding_completed': true,
      'pref_tags': prefTags,
      'pref_pace': prefPace,
      'allow_location': allowLocation,
      'allow_notifications': allowNotifications,
    });
    await logAppEvent(
      'onboarding_completed',
      payload: {
        'pref_tags': prefTags,
        'pref_pace': prefPace,
        'allow_location': allowLocation,
        'allow_notifications': allowNotifications,
      },
    );
  }

  Future<bool> isCurrentUserAdmin() async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) return false;
    try {
      final row = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      final role = (row as Map?)?['role']?.toString();
      return role == 'admin';
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> listProvinces() async {
    try {
      final response = await _client
          .from('provinces_with_coords')
          .select('id,name,slug,lat,lng')
          .order('plate_no');
      final items = (response as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      if (items.isNotEmpty) return items;
    } catch (_) {
      // fall through to secondary query
    }

    try {
      final fallback = await _client
          .from('provinces')
          .select('id,name,slug')
          .order('plate_no');
      final items = (fallback as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      if (items.isNotEmpty) return items;
    } catch (_) {
      // fall through to local fallback
    }

    return kFallbackProvinces;
  }

  Future<List<Map<String, dynamic>>> listDistrictsByProvinceSlug(
    String provinceSlug,
  ) async {
    try {
      final province = await _client
          .from('provinces')
          .select('id')
          .eq('slug', provinceSlug)
          .maybeSingle();
      if (province == null) return const [];
      final rows = await _client
          .from('districts_with_coords')
          .select('id,name,slug,lat,lng')
          .eq('province_id', province['id'] as String)
          .order('name');
      return (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<PlaceModel>> fetchPoisByViewport({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
    List<String> categories = const [],
    String? searchQuery,
    int limit = 1000,
    String? cityName,
    String? districtName,
  }) async {
    final safeLimit = limit.clamp(1, 1000);
    dynamic query = _client
        .from('pois')
        .select('id,name,category,lat,lng,city,district,tags,source')
        .eq('provenance_verified', true)
        .gte('lat', minLat)
        .lte('lat', maxLat)
        .gte('lng', minLng)
        .lte('lng', maxLng);

    if (categories.isNotEmpty) {
      query = query.inFilter('category', categories);
    }
    if (districtName != null && districtName.trim().isNotEmpty) {
      query = query.ilike('district', districtName.trim());
    } else if (cityName != null && cityName.trim().isNotEmpty) {
      query = query.ilike('city', cityName.trim());
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query = query.ilike('name', '%${searchQuery.trim()}%');
    }

    final rows = await query.limit(safeLimit);
    return (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map(
          (row) => PlaceModel.fromMap({
            'id': row['id'],
            'name': row['name'],
            'slug': row['id'],
            'category': row['category'],
            'short_summary':
                '${row['district'] ?? row['city'] ?? 'Keşif noktası'}',
            'best_time': 'day',
            'duration_min': 60,
            'lat': row['lat'],
            'lng': row['lng'],
            'tags': ((row['tags'] as List?) ?? const []).cast<String>(),
            'source_kind': row['source'],
            'is_free': true,
            'app_score': 0,
            'app_rating': 0,
            'rating_count': 0,
            'media': const [],
          }),
        )
        .toList();
  }

  static double _distanceKmRepo(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLng = (lng2 - lng1) * math.pi / 180.0;
    final a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            (math.sin(dLng / 2) * math.sin(dLng / 2));
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  // ── Tourist quality filter ───────────────────────────────────────────────

  // Generic OSM names that are NOT tourist-worthy (exact, lowercase-trimmed)
  static const _poisBlacklistExact = {
    'park',
    'çocuk parkı',
    'çocuk oyun parkı',
    'otopark',
    'park yeri',
    'eczane',
    'banka',
    'atm',
    'ptt',
    'ptt şubesi',
    'okul',
    'lise',
    'ilkokul',
    'ortaokul',
    'kreş',
    'anaokulu',
    'yurt',
    'hastane',
    'klinik',
    'sağlık ocağı',
    'aile sağlığı merkezi',
    'benzin',
    'akaryakıt',
    'akaryakıt istasyonu',
    'benzin istasyonu',
    'market',
    'süpermarket',
    'migros',
    'bim',
    'a101',
    'şok',
    'carrefour',
    'otobüs durağı',
    'durak',
    'metro istasyonu',
    'tren istasyonu',
    'vergi dairesi',
    'belediye',
    'muhtarlık',
    'karakol',
    'emniyet',
    'trafo',
    'su deposu',
    'elektrik',
    'çöp',
  };

  // Keywords anywhere in name that disqualify a POI
  static const _poisBlacklistKeywords = [
    'otopark',
    'akaryakıt',
    'benzin istasyonu',
    'benzin pump',
    'trafo',
    'transformatör',
    'elektrik tesisi',
    'su deposu',
    'çöp kutusu',
    'oyun alanı',
    'belediyesi',
    'muhtarlığı',
    'kaymakamlık',
  ];

  static bool _isTouristWorthy(PlaceModel p) {
    if (p.lat == null || p.lng == null) return false;
    final name = p.name.toLowerCase().trim();
    if (name.length < 4) return false;
    if (_poisBlacklistExact.contains(name)) return false;
    for (final kw in _poisBlacklistKeywords) {
      if (name.contains(kw)) return false;
    }
    if (p.category == 'lodging') return false;
    return true;
  }

  static List<PlaceModel> _sortByProximity(
    List<PlaceModel> places, {
    double? originLat,
    double? originLng,
  }) {
    if (places.length <= 1) return places;
    final withCoords = places
        .where((p) => p.lat != null && p.lng != null)
        .toList();
    final withoutCoords = places
        .where((p) => p.lat == null || p.lng == null)
        .toList();
    if (withCoords.isEmpty) return places;

    final remaining = List<PlaceModel>.from(withCoords);
    final sorted = <PlaceModel>[];
    double curLat = originLat ?? remaining.first.lat!;
    double curLng = originLng ?? remaining.first.lng!;

    while (remaining.isNotEmpty) {
      int bestIdx = 0;
      double bestDist = double.infinity;
      for (int i = 0; i < remaining.length; i++) {
        final d = _distanceKmRepo(
          curLat,
          curLng,
          remaining[i].lat!,
          remaining[i].lng!,
        );
        if (d < bestDist) {
          bestDist = d;
          bestIdx = i;
        }
      }
      final best = remaining.removeAt(bestIdx);
      sorted.add(best);
      curLat = best.lat!;
      curLng = best.lng!;
    }
    return [...sorted, ...withoutCoords];
  }

  Future<TripPlan> generateTripPlan({
    required String provinceSlug,
    required int days,
    required String transportMode,
    required String pace,
    required String personaMode,
    required List<String> preferences,
    String? districtId,
    int? maxRadiusKm,
    bool? allowOutsideDistrict,
    double? startLat,
    double? startLng,
    List<String> mustIncludePlaceIds = const [],
  }) async {
    // Compliance mode: generate trip only from compliant POIs dataset.
    final generated = await generateDemoTripPlan(
      provinceSlug: provinceSlug,
      days: days,
      transportMode: transportMode,
      pace: pace,
      personaMode: personaMode,
      preferences: preferences,
      districtId: districtId,
      allowOutsideDistrict: allowOutsideDistrict ?? false,
      startLat: startLat,
      startLng: startLng,
    );
    final persisted = await _saveTripRemote(generated);
    await _persistTripArtifacts(persisted);
    return persisted;
  }

  Future<TripPlan> generateDemoTripPlan({
    required String provinceSlug,
    required int days,
    required String transportMode,
    required String pace,
    required String personaMode,
    required List<String> preferences,
    String? districtId,
    bool allowOutsideDistrict = false,
    double? startLat,
    double? startLng,
  }) async {
    final provinceRes = await _client
        .from('provinces')
        .select('id,name,slug')
        .eq('slug', provinceSlug)
        .maybeSingle();
    if (provinceRes == null) {
      throw Exception('Secilen il bulunamadi: $provinceSlug');
    }

    final province = ProvinceModel.fromMap(
      Map<String, dynamic>.from(provinceRes as Map),
    );

    String? districtName;
    if (districtId != null && districtId.isNotEmpty) {
      final districtRes = await _client
          .from('districts')
          .select('name,province_id')
          .eq('id', districtId)
          .maybeSingle();
      if (districtRes != null &&
          districtRes['province_id']?.toString() == province.id) {
        districtName = districtRes['name']?.toString();
      }
    }

    // ── Fetch & filter places ─────────────────────────────────────────────
    // OSM city field is unreliable — try three progressively broader queries.

    final minNeeded = _stopsPerDayForPace(pace) * days;

    Future<List<PlaceModel>> fetchFiltered(dynamic q) async {
      final raw = (await (q as dynamic).limit(500)) as List;
      return raw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(
            (row) => PlaceModel.fromMap({
              'id': row['id'],
              'name': row['name'],
              'slug': row['id'],
              'category': row['category'],
              'short_summary':
                  '${row['district'] ?? row['city'] ?? 'Keşif noktası'}',
              'best_time': 'day',
              'duration_min': 60,
              'lat': row['lat'],
              'lng': row['lng'],
              'tags': ((row['tags'] as List?) ?? const []).cast<String>(),
              'source_kind': row['source'],
              'is_free': true,
              'media': const [],
              'app_score': 0,
              'app_rating': 0,
              'rating_count': 0,
            }),
          )
          .where(_isTouristWorthy)
          .toList();
    }

    // Try 1: exact province name match
    var q1 = _client
        .from('pois')
        .select('id,name,category,lat,lng,city,district,tags,source')
        .eq('provenance_verified', true)
        .ilike('city', province.name);
    if (!allowOutsideDistrict &&
        districtName != null &&
        districtName.trim().isNotEmpty) {
      q1 = (q1 as dynamic).ilike('district', districtName.trim());
    }
    var places = await fetchFiltered(q1);

    // Try 2: city contains province name (handles sub-district city values)
    if (places.length < minNeeded) {
      final q2 = _client
          .from('pois')
          .select('id,name,category,lat,lng,city,district,tags,source')
          .eq('provenance_verified', true)
          .ilike('city', '%${province.name}%');
      final extra = await fetchFiltered(q2);
      final seen1 = places.map((p) => p.id).toSet();
      places = [...places, ...extra.where((p) => !seen1.contains(p.id))];
    }

    // Try 3: no city filter, but restrict by distance to province center
    if (places.length < minNeeded) {
      final coordRow = await _client
          .from('provinces')
          .select('lat,lng')
          .eq('slug', provinceSlug)
          .maybeSingle();
      final pLat = (coordRow?['lat'] as num?)?.toDouble();
      final pLng = (coordRow?['lng'] as num?)?.toDouble();

      final q3 = _client
          .from('pois')
          .select('id,name,category,lat,lng,city,district,tags,source')
          .eq('provenance_verified', true);
      final all3 = await fetchFiltered(q3);
      final seen2 = places.map((p) => p.id).toSet();
      var extras = all3.where((p) => !seen2.contains(p.id)).toList();

      if (pLat != null && pLng != null) {
        extras.sort((a, b) {
          final da = _distanceKmRepo(pLat, pLng, a.lat ?? 0, a.lng ?? 0);
          final db = _distanceKmRepo(pLat, pLng, b.lat ?? 0, b.lng ?? 0);
          return da.compareTo(db);
        });
        extras = extras
            .where((p) => _distanceKmRepo(pLat, pLng, p.lat!, p.lng!) <= 80)
            .toList();
      }
      places = [...places, ...extras.take(200)];
    }

    // Final dedup
    final seenIds = <String>{};
    places = places.where((p) => seenIds.add(p.id)).toList();

    if (places.isEmpty) {
      throw Exception(
        districtName != null && !allowOutsideDistrict
            ? 'Seçilen ilçede şu an yeterli gezi verisi yok.'
            : 'Bu ilde şu an yeterli gezi verisi bulunamadı.',
      );
    }

    final perDay = _stopsPerDayForPace(pace);
    final needed = (days * perDay).clamp(1, places.length);
    // Use shortSummary as district key (it's set to district ?? city name)
    final byDistrict = <String, List<PlaceModel>>{};
    for (final p in places) {
      final districtKey = p.shortSummary.isNotEmpty ? p.shortSummary : 'other';
      byDistrict.putIfAbsent(districtKey, () => <PlaceModel>[]).add(p);
    }
    final districtPools = byDistrict.values.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final interleaved = <PlaceModel>[];
    var ptr = 0;
    while (interleaved.length < places.length) {
      var advanced = false;
      for (final pool in districtPools) {
        if (ptr < pool.length) {
          interleaved.add(pool[ptr]);
          advanced = true;
        }
      }
      if (!advanced) break;
      ptr += 1;
    }
    final selected = interleaved.take(needed).toList();

    int minute = 10 * 60;
    final dayPlans = <TripDay>[];
    int idx = 0;

    for (int d = 1; d <= days; d++) {
      final stops = <TripStop>[];
      final dayPool = <PlaceModel>[];
      while (idx < selected.length && dayPool.length < perDay * 2) {
        dayPool.add(selected[idx++]);
      }
      var foodLike = 0;
      final mustScenic = dayPool.where((p) {
        const scenic = {
          'nature',
          'historical',
          'viewpoint',
          'beach',
          'waterfall',
          'canyon',
          'tour',
          'museum',
        };
        return scenic.contains(p.category);
      }).toList();
      final composed = <PlaceModel>[];
      if (mustScenic.isNotEmpty) composed.add(mustScenic.first);
      for (final p in dayPool) {
        if (composed.length >= perDay) break;
        final isFood = {'food', 'cafe', 'lodging'}.contains(p.category);
        if (isFood && foodLike >= 2) continue;
        if (composed.any((x) => x.id == p.id)) continue;
        composed.add(p);
        if (isFood) foodLike += 1;
      }
      while (composed.length < perDay && idx < selected.length) {
        final p = selected[idx++];
        if (composed.any((x) => x.id == p.id)) continue;
        composed.add(p);
      }

      // Sort stops within this day by nearest-neighbor for a logical route
      final composedSorted = _sortByProximity(
        composed,
        originLat: d == 1 ? startLat : null,
        originLng: d == 1 ? startLng : null,
      );

      for (int i = 0; i < composedSorted.length && i < perDay; i++) {
        final p = composedSorted[i];
        final hh = (minute ~/ 60).toString().padLeft(2, '0');
        final mm = (minute % 60).toString().padLeft(2, '0');
        stops.add(
          TripStop(
            orderIndex: i + 1,
            arrivalTime: '$hh:$mm:00',
            durationMin: p.durationMin,
            transportMode: _normalizeTransportMode(transportMode),
            place: p,
          ),
        );
        minute += p.durationMin + 25;
      }
      if (stops.isNotEmpty) {
        dayPlans.add(TripDay(dayNumber: d, stops: stops));
      }
      minute = 10 * 60;
    }

    final trip = TripPlan(
      tripId: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      days: dayPlans.length,
      transportMode: _normalizeTransportMode(transportMode),
      pace: pace,
      personaMode: personaMode,
      preferences: preferences,
      province: province,
      daysPlan: dayPlans,
    );

    await _persistTripArtifacts(trip);
    return trip;
  }

  Future<TripPlan?> readCachedTrip() async {
    final map = await _cache.readLastTrip();
    if (map == null) return null;
    return TripPlan.fromMap(map);
  }

  Future<List<TripPlan>> readTripHistory() async {
    final items = await _cache.readTripHistory();
    return items.map(TripPlan.fromMap).toList();
  }

  Future<TripPlan?> getMyTripPlan(String tripId) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final tripRow = await _client
        .from('trips_clean')
        .select(
          'id,province:provinces(id,name,slug),days,transport_mode,pace,persona_mode,preferences,created_at',
        )
        .eq('id', tripId)
        .eq('user_id', user.id)
        .maybeSingle();
    if (tripRow == null) return null;

    final dayRows = await _client
        .from('trip_days_clean')
        .select('id,day_number')
        .eq('trip_id', tripId)
        .order('day_number');

    final days = (dayRows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    if (days.isEmpty) return null;

    final dayIds = days.map((e) => e['id'] as String).toList();
    final stopRows = await _client
        .from('trip_stops_clean')
        .select(
          'trip_day_id,order_index,arrival_time,duration_min,transport_mode,place_id',
        )
        .inFilter('trip_day_id', dayIds)
        .order('order_index');

    final stops = (stopRows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final placeIds = stops.map((e) => e['place_id'] as String).toSet().toList();
    final placeMap = <String, PlaceModel>{};
    if (placeIds.isNotEmpty) {
      final pois = await _client
          .from('pois')
          .select('id,name,category,lat,lng,city,district,tags,source')
          .inFilter('id', placeIds);
      for (final raw in (pois as List)) {
        final row = Map<String, dynamic>.from(raw as Map);
        placeMap[row['id'] as String] = PlaceModel.fromMap({
          'id': row['id'],
          'name': row['name'],
          'slug': row['id'],
          'category': row['category'],
          'short_summary':
              '${row['district'] ?? row['city'] ?? 'Kesif noktasi'}',
          'best_time': 'day',
          'duration_min': 60,
          'lat': row['lat'],
          'lng': row['lng'],
          'tags': ((row['tags'] as List?) ?? const []).cast<String>(),
          'source_kind': row['source'],
          'is_free': true,
          'media': const [],
          'app_score': 0,
          'app_rating': 0,
          'rating_count': 0,
        });
      }
    }

    final daysPlan = days.map((day) {
      final tripDayId = day['id'] as String;
      final dayStops = stops
          .where((stop) => stop['trip_day_id'] == tripDayId)
          .map((stop) {
            final placeId = stop['place_id'] as String;
            final place = placeMap[placeId];
            if (place == null) return null;
            return TripStop(
              orderIndex: (stop['order_index'] as num).toInt(),
              arrivalTime: stop['arrival_time'] as String,
              durationMin: (stop['duration_min'] as num).toInt(),
              transportMode: stop['transport_mode'] as String,
              place: place,
            );
          })
          .whereType<TripStop>()
          .toList();
      return TripDay(
        dayNumber: (day['day_number'] as num).toInt(),
        stops: dayStops,
      );
    }).toList();

    return TripPlan(
      tripId: tripId,
      days: (tripRow['days'] as num).toInt(),
      transportMode: tripRow['transport_mode'] as String,
      pace: tripRow['pace'] as String,
      personaMode: tripRow['persona_mode'] as String,
      preferences: ((tripRow['preferences'] as List?) ?? const [])
          .cast<String>(),
      province: ProvinceModel.fromMap(
        Map<String, dynamic>.from(tripRow['province'] as Map),
      ),
      daysPlan: daysPlan,
    );
  }

  Future<String> createShareToken(String tripId) async {
    final result = await _invokeFunction(
      'share_trip',
      body: {'trip_id': tripId},
      requireAuth: true,
    );
    final data = Map<String, dynamic>.from(result.data as Map);
    return data['token'] as String;
  }

  Future<TripPlan> getSharedTrip(String token) async {
    final result = await _client.functions.invoke(
      'get_shared_trip',
      body: {'token': token},
    );
    if (result.data == null) {
      throw Exception('No shared trip found');
    }
    final map = Map<String, dynamic>.from(result.data as Map);
    map['trip_id'] ??= 'shared';
    return TripPlan.fromMap(map);
  }

  Future<List<Map<String, dynamic>>> listMyTrips() async {
    final local = (await readTripHistory())
        .map(
          (trip) => {
            'id': trip.tripId,
            'days': trip.days,
            'transport_mode': trip.transportMode,
            'pace': trip.pace,
            'persona_mode': trip.personaMode,
            'created_at': null,
            'province': {
              'id': trip.province.id,
              'name': trip.province.name,
              'slug': trip.province.slug,
            },
            'source': 'local',
            'plan': trip.toMap(),
          },
        )
        .toList();

    final user = _client.auth.currentUser;
    if (user == null) return local;

    try {
      final response = await _client
          .from('trips_clean')
          .select(
            'id,days,transport_mode,pace,persona_mode,preferences,created_at,province:provinces(id,name,slug)',
          )
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final remote = (response as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map((row) => {...row, 'source': 'remote'})
          .toList();
      final merged = <String, Map<String, dynamic>>{
        for (final item in local) item['id'] as String: item,
      };
      for (final item in remote) {
        merged[item['id'] as String] = item;
      }
      return merged.values.toList()..sort((a, b) {
        final aDate = DateTime.tryParse((a['created_at'] as String?) ?? '');
        final bDate = DateTime.tryParse((b['created_at'] as String?) ?? '');
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    } catch (_) {
      return local;
    }
  }

  Future<PlaceModel> fetchPlaceDetail(String placeId) async {
    final poi = await _client
        .from('pois')
        .select('id,name,category,lat,lng,city,district,tags,source')
        .eq('provenance_verified', true)
        .eq('id', placeId)
        .maybeSingle();
    if (poi == null) {
      throw Exception('Place not found');
    }
    final row = Map<String, dynamic>.from(poi as Map);
    Map<String, dynamic>? communityState;
    List<MediaModel> media = const [];

    try {
      final state = await _client
          .from('place_community_state')
          .select(
            'place_id,cover_photo,routevia_score,avg_rating,review_count,checkins_count,photo_count',
          )
          .eq('place_id', placeId)
          .maybeSingle();
      if (state != null) {
        communityState = Map<String, dynamic>.from(state as Map);
      }
    } catch (_) {}

    try {
      final photos = await getPlacePhotos(placeId);
      media = photos
          .where((photo) => photo.isApproved)
          .map(
            (photo) => MediaModel(
              storagePath: photo.storagePath,
              publicUrl: photo.imageUrl,
              sortOrder: 0,
            ),
          )
          .toList();
    } catch (_) {}

    return PlaceModel.fromMap({
      'id': row['id'],
      'name': row['name'],
      'slug': row['id'],
      'category': row['category'],
      'short_summary': '${row['district'] ?? row['city'] ?? 'Keşif noktası'}',
      'best_time': 'day',
      'duration_min': 60,
      'lat': row['lat'],
      'lng': row['lng'],
      'tags': ((row['tags'] as List?) ?? const []).cast<String>(),
      'media': media,
      'source_kind': row['source'] ?? 'osm',
      'is_free': true,
      'app_score': communityState?['routevia_score'] ?? 0,
      'app_rating': communityState?['avg_rating'] ?? 0,
      'rating_count': communityState?['review_count'] ?? 0,
    });
  }

  Future<List<PlaceModel>> nearbyPlaces({
    required double lat,
    required double lng,
    required int radiusKm,
    String? provinceId,
    String? provinceSlug,
    String? category,
    List<String> categories = const [],
    List<String> tags = const [],
    bool freeOnly = false,
  }) async {
    final bundle = await nearbyPlacesBundle(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      provinceId: provinceId,
      provinceSlug: provinceSlug,
      category: category,
      categories: categories,
      tags: tags,
      freeOnly: freeOnly,
    );
    return bundle['items'] as List<PlaceModel>;
  }

  Future<Map<String, Object>> nearbyPlacesBundle({
    required double lat,
    required double lng,
    required int radiusKm,
    String? provinceId,
    String? provinceSlug,
    String? districtId,
    String? districtSlug,
    String? districtName,
    String? category,
    List<String> categories = const [],
    List<String> tags = const [],
    bool freeOnly = false,
  }) async {
    final categoryList = categories.isNotEmpty
        ? categories
        : (category == null ? const <String>[] : <String>[category]);
    final cacheKey =
        '${lat.toStringAsFixed(4)}:${lng.toStringAsFixed(4)}:$radiusKm:${provinceId ?? ''}:${provinceSlug ?? ''}:${districtId ?? ''}:${districtSlug ?? ''}:${districtName ?? ''}:${categoryList.join('|')}:${tags.join(',')}:$freeOnly';
    final cached = _nearbyCache[cacheKey];
    final now = DateTime.now();
    if (cached != null &&
        now.difference(cached.createdAt).inSeconds <= 15 &&
        cached.items.isNotEmpty) {
      return {
        'items': cached.items,
        'top_picks': cached.items.take(10).toList(),
        'top_picks_overall': cached.items.take(10).toList(),
        'meta': const <String, dynamic>{},
      };
    }

    try {
      String? cityName;
      if (provinceSlug != null && provinceSlug.isNotEmpty) {
        final p = await _client
            .from('provinces')
            .select('name')
            .eq('slug', provinceSlug)
            .maybeSingle();
        cityName = (p as Map?)?['name']?.toString();
      }

      final deltaLat = radiusKm / 111.0;
      final latCos = math.cos(lat * math.pi / 180.0).abs().clamp(0.2, 1.0);
      final deltaLng = radiusKm / (111.0 * latCos);
      final minLat = lat - deltaLat;
      final maxLat = lat + deltaLat;
      final minLng = lng - deltaLng;
      final maxLng = lng + deltaLng;

      final places = await fetchPoisByViewport(
        minLat: minLat,
        maxLat: maxLat,
        minLng: minLng,
        maxLng: maxLng,
        categories: categoryList,
        cityName: cityName,
        districtName: districtName,
        limit: 1000,
      );
      final effectiveTopPicks = places.take(10).toList();
      if (effectiveTopPicks.isEmpty) {
        await _safeLogEvent(
          'top_picks_empty',
          payload: {
            'province_slug': provinceSlug,
            'radius_km': radiusKm,
            'items_count': places.length,
            'reason': 'insufficient_coverage',
          },
        );
      }
      _nearbyCache[cacheKey] = _NearbyCacheEntry(items: places, createdAt: now);
      return {
        'items': places,
        'top_picks': effectiveTopPicks,
        'top_picks_overall': effectiveTopPicks,
        'top_picks_by_category': const <String, dynamic>{},
        'meta': <String, dynamic>{
          'reason': places.isEmpty ? 'insufficient_coverage' : null,
          'radius_km': radiusKm,
          'compliant_source': 'pois',
        },
      };
    } catch (e) {
      await _safeLogEvent(
        'nearby_error',
        payload: {
          'province_slug': provinceSlug,
          'radius_km': radiusKm,
          'error': e.toString(),
        },
      );
      return const {
        'items': <PlaceModel>[],
        'top_picks': <PlaceModel>[],
        'top_picks_overall': <PlaceModel>[],
        'top_picks_by_category': <String, dynamic>{},
        'meta': <String, dynamic>{},
      };
    }
  }

  Future<Map<String, dynamic>> aiSuggestNow({
    required double lat,
    required double lng,
    String? districtId,
    String? provinceId,
    int radiusKm = 10,
  }) async {
    final bundle = await nearbyPlacesBundle(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
    );
    final items = (bundle['items'] as List<PlaceModel>?) ?? const [];
    return {
      'suggestions': items
          .take(3)
          .map(
            (p) => {
              'id': p.id,
              'name': p.name,
              'category': p.category,
              'lat': p.lat,
              'lng': p.lng,
              'score': p.routeviaScore,
              'distance_m': p.metersFromUser,
              'reason': 'Skor + mesafe dengesi',
            },
          )
          .toList(),
      'meta': {'mode': 'compliant_pois', 'total_candidates': items.length},
    };
  }

  Future<PlaceStats> getPlaceStats(String placeId) async {
    Map<String, dynamic> state = const {};
    try {
      final row = await _client
          .from('place_community_state')
          .select(
            'place_id,routevia_score,avg_rating,review_count,checkins_count,photo_count',
          )
          .eq('place_id', placeId)
          .maybeSingle();
      if (row != null) {
        state = Map<String, dynamic>.from(row as Map);
      }
    } catch (_) {}

    Map<String, dynamic> reviews = const {};
    if (_client.auth.currentSession != null) {
      try {
        final result = await _invokeFunction(
          'get_place_reviews',
          body: {'place_id': placeId, 'limit': 20},
          requireAuth: true,
        );
        reviews = Map<String, dynamic>.from((result.data as Map?) ?? const {});
      } catch (_) {}
    }

    return PlaceStats.fromMap({
      'place_id': placeId,
      'avg_rating': reviews['avg_rating'] ?? state['avg_rating'] ?? 0,
      'review_count': reviews['review_count'] ?? state['review_count'] ?? 0,
      'routevia_score': state['routevia_score'] ?? 0,
      'checkins_count': state['checkins_count'] ?? 0,
      'photo_count': state['photo_count'] ?? 0,
      'crowded_count': 0,
      'family_count': 0,
      'photo_spot_count': 0,
      'sunset_worthy_count': 0,
      'recent_reviews': reviews['reviews'] ?? const [],
    });
  }

  Future<Map<String, PlaceStats>> getPlaceStatsBatch(
    List<String> placeIds,
  ) async {
    if (placeIds.isEmpty) return const {};
    final rows = await _client
        .from('poi_stats')
        .select(
          'place_id,avg_rating,review_count,crowded_count,family_count,photo_spot_count,sunset_worthy_count',
        )
        .inFilter('place_id', placeIds);
    final map = <String, PlaceStats>{};
    for (final raw in (rows as List)) {
      final row = Map<String, dynamic>.from(raw as Map);
      final stats = PlaceStats.fromMap({...row, 'recent_reviews': const []});
      map[stats.placeId] = stats;
    }
    return map;
  }

  Future<PlaceStats> submitPlaceReview({
    required String placeId,
    required int rating,
    required List<String> flags,
    required String commentShort,
  }) async {
    final result = await _invokeFunction(
      'add_review',
      body: {
        'place_id': placeId,
        'rating': rating,
        'flags': flags,
        'comment': commentShort,
      },
      requireAuth: true,
    );
    final data = Map<String, dynamic>.from(result.data as Map);
    final reviews = Map<String, dynamic>.from(data['reviews'] as Map);
    final state = await _client
        .from('place_community_state')
        .select(
          'place_id,routevia_score,avg_rating,review_count,checkins_count,photo_count',
        )
        .eq('place_id', placeId)
        .maybeSingle();
    final merged = {
      ...Map<String, dynamic>.from((state as Map?) ?? const {}),
      ...reviews,
      'place_id': placeId,
      'recent_reviews': reviews['reviews'] ?? const [],
      'crowded_count': 0,
      'family_count': 0,
      'photo_spot_count': 0,
      'sunset_worthy_count': 0,
    };
    return PlaceStats.fromMap(merged);
  }

  Future<List<PlacePhotoModel>> getPlacePhotos(
    String placeId, {
    int limit = 24,
  }) async {
    if (_client.auth.currentSession == null) return const [];
    final result = await _invokeFunction(
      'get_place_photos',
      body: {'place_id': placeId, 'limit': limit},
      requireAuth: true,
    );
    final data = Map<String, dynamic>.from((result.data as Map?) ?? const {});
    return ((data['photos'] as List?) ?? const [])
        .map(
          (e) => PlacePhotoModel.fromMap(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  Future<PlacePhotoModel> uploadPlacePhoto({
    required String placeId,
    required File file,
  }) async {
    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last.toLowerCase();
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
    final result = await _invokeFunction(
      'upload_photo',
      body: {
        'place_id': placeId,
        'file_name': file.uri.pathSegments.isEmpty
            ? 'upload.$ext'
            : file.uri.pathSegments.last,
        'content_type': contentType,
        'file_base64': base64Encode(bytes),
      },
      requireAuth: true,
    );
    final data = Map<String, dynamic>.from(result.data as Map);
    return PlacePhotoModel.fromMap(
      Map<String, dynamic>.from(data['photo'] as Map),
    );
  }

  Future<void> addPlaceCheckin(String placeId) async {
    await _invokeFunction(
      'add_checkin',
      body: {'place_id': placeId},
      requireAuth: true,
    );
  }

  Future<Map<String, dynamic>?> getProvinceBySlug(String provinceSlug) async {
    final row = await _client
        .from('provinces_with_coords')
        .select('id,name,slug,lat,lng')
        .eq('slug', provinceSlug)
        .maybeSingle();
    if (row == null) return null;
    return Map<String, dynamic>.from(row as Map);
  }

  Future<List<PlaceModel>> listProvinceHubPlaces({
    required String provinceSlug,
    String personaMode = 'relax',
    List<String> preferences = const [],
    String? districtName,
  }) async {
    Map<String, dynamic>? province = await _client
        .from('provinces')
        .select('name,slug')
        .eq('slug', provinceSlug)
        .maybeSingle();
    if (province == null) return const [];
    final cityName = (province['name'] as String?) ?? '';
    dynamic query = _client
        .from('pois')
        .select('id,name,category,lat,lng,city,district,tags,source')
        .eq('provenance_verified', true)
        .ilike('city', cityName);
    if (districtName != null && districtName.trim().isNotEmpty) {
      query = query.ilike('district', districtName.trim());
    }
    final rows = await query.limit(1000);
    return (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map(
          (row) => PlaceModel.fromMap({
            'id': row['id'],
            'name': row['name'],
            'slug': row['id'],
            'category': row['category'],
            'short_summary':
                '${row['district'] ?? row['city'] ?? 'Keşif noktası'}',
            'best_time': 'day',
            'duration_min': 60,
            'lat': row['lat'],
            'lng': row['lng'],
            'tags': ((row['tags'] as List?) ?? const []).cast<String>(),
            'source_kind': row['source'],
            'is_free': true,
            'media': const [],
            'app_score': 0,
            'app_rating': 0,
            'rating_count': 0,
          }),
        )
        .toList();
  }

  Future<List<PlaceModel>> listProvinceOrNationalTopPicks({
    required String provinceSlug,
    String? districtName,
    int limit = 24,
  }) async {
    final province = await _client
        .from('provinces')
        .select('name,slug')
        .eq('slug', provinceSlug)
        .maybeSingle();
    if (province != null) {
      final cityName = province['name'] as String;
      dynamic query = _client
          .from('pois')
          .select('id,name,category,lat,lng,city,district,tags,source')
          .eq('provenance_verified', true)
          .ilike('city', cityName);
      if (districtName != null && districtName.trim().isNotEmpty) {
        query = query.ilike('district', districtName.trim());
      }
      final localRows = await query.limit(limit);

      final local = (localRows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(
            (row) => PlaceModel.fromMap({
              'id': row['id'],
              'name': row['name'],
              'slug': row['id'],
              'category': row['category'],
              'short_summary':
                  '${row['district'] ?? row['city'] ?? 'Keşif noktası'}',
              'best_time': 'day',
              'duration_min': 60,
              'lat': row['lat'],
              'lng': row['lng'],
              'tags': ((row['tags'] as List?) ?? const []).cast<String>(),
              'source_kind': row['source'],
              'is_free': true,
              'media': const [],
              'app_score': 0,
              'app_rating': 0,
              'rating_count': 0,
            }),
          )
          .where((p) => p.name.trim().isNotEmpty)
          .toList();
      if (local.isNotEmpty) return local;
    }

    final nationalRows = await _client
        .from('pois')
        .select('id,name,category,lat,lng,city,district,tags,source')
        .eq('provenance_verified', true)
        .limit(limit);

    return (nationalRows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map(
          (row) => PlaceModel.fromMap({
            'id': row['id'],
            'name': row['name'],
            'slug': row['id'],
            'category': row['category'],
            'short_summary':
                '${row['district'] ?? row['city'] ?? 'Keşif noktası'}',
            'best_time': 'day',
            'duration_min': 60,
            'lat': row['lat'],
            'lng': row['lng'],
            'tags': ((row['tags'] as List?) ?? const []).cast<String>(),
            'source_kind': row['source'],
            'is_free': true,
            'media': const [],
            'app_score': 0,
            'app_rating': 0,
            'rating_count': 0,
          }),
        )
        .where((p) => p.name.trim().isNotEmpty)
        .toList();
  }

  Future<List<PlaceModel>> listFethiyeHubPlaces({
    String personaMode = 'relax',
    List<String> preferences = const [],
  }) {
    return listProvinceHubPlaces(
      provinceSlug: 'mugla',
      personaMode: personaMode,
      preferences: preferences,
    );
  }

  Future<Map<String, dynamic>> sunsetNow({
    required double lat,
    required double lng,
    required int radiusKm,
    String? provinceId,
    String? provinceSlug,
    bool debugForce = false,
  }) async {
    final bundle = await nearbyPlacesBundle(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      provinceSlug: provinceSlug,
      categories: const ['viewpoint', 'beach', 'nature'],
    );
    final items = (bundle['items'] as List<PlaceModel>?) ?? const [];
    final picked = items
        .take(5)
        .map(
          (p) => {
            'id': p.id,
            'name': p.name,
            'category': p.category,
            'lat': p.lat,
            'lng': p.lng,
            'media': p.media
                .map(
                  (m) => {
                    'storage_path': m.storagePath,
                    'public_url': m.publicUrl,
                    'sort_order': m.sortOrder,
                  },
                )
                .toList(),
          },
        )
        .toList();
    return {
      'suggestions': picked,
      'meta': {
        'radius_km': radiusKm,
        'compliant_source': 'pois',
        'debug_force': debugForce,
      },
    };
  }

  Future<Map<String, dynamic>> getEcoScore({TripPlan? trip}) async {
    final sourceTrip = trip ?? await readCachedTrip();
    if (sourceTrip == null) {
      return const {
        'score': 100,
        'grade': 'A+',
        'distance_km': 0.0,
        'co2_kg': 0.0,
        'saved_vs_car_kg': 0.0,
        'tips': ['Son rota bulunamadi. Once rota olustur.'],
      };
    }

    final body = {
      'transport_mode': sourceTrip.transportMode,
      'days_plan': sourceTrip.daysPlan
          .map(
            (d) => {
              'stops': d.stops
                  .map(
                    (s) => {
                      'transport_mode': s.transportMode,
                      'place': {'lat': s.place.lat, 'lng': s.place.lng},
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };

    final result = await _client.functions.invoke('eco_score', body: body);
    final data = Map<String, dynamic>.from((result.data as Map?) ?? const {});
    if (data.isEmpty) {
      return const {
        'score': 100,
        'grade': 'A+',
        'distance_km': 0.0,
        'co2_kg': 0.0,
        'saved_vs_car_kg': 0.0,
        'tips': ['Eko skor su an hesaplanamadi.'],
      };
    }
    return data;
  }

  Future<Map<String, dynamic>?> getPlaceTrustMetrics(String placeId) async {
    final row = await _client
        .from('poi_trust_metrics')
        .select(
          'poi_id,trust_score,weighted_rating,review_count,signal_quality,media_quality,freshness_score,spam_risk,updated_at',
        )
        .eq('poi_id', placeId)
        .maybeSingle();
    if (row == null) return null;
    return Map<String, dynamic>.from(row as Map);
  }

  Future<Map<String, Map<String, dynamic>>> getLiveStatusForPlaces(
    List<String> placeIds, {
    int hours = 6,
  }) async {
    final ids = placeIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (ids.isEmpty) return const {};

    final result = await _client.functions.invoke(
      'get_live_status',
      body: {'place_ids': ids, 'hours': hours, 'limit': ids.length},
    );
    final data = Map<String, dynamic>.from((result.data as Map?) ?? const {});
    final items = ((data['items'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return {for (final it in items) (it['place_id'] as String): it};
  }

  Future<Map<String, dynamic>> optimizeTripPlanV2({
    required TripPlan plan,
  }) async {
    var premium = false;
    try {
      final entitlements = await getEntitlements();
      premium = entitlements.any(
        (e) =>
            (e['entitlement_key'] as String?) == 'pro_preview_7d' &&
            DateTime.tryParse(
                  (e['expires_at'] as String?) ?? '',
                )?.isAfter(DateTime.now().toUtc()) ==
                true,
      );
    } catch (_) {
      premium = false;
    }

    final result = await _invokeFunction(
      'optimize_trip_v2',
      body: {
        'days_plan': plan.toMap()['days_plan'],
        'pace': plan.pace,
        'persona_mode': plan.personaMode,
        'preferences': plan.preferences,
        'premium': premium,
      },
    );

    final data = Map<String, dynamic>.from((result.data as Map?) ?? const {});
    final daysRaw = ((data['days_plan'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    if (daysRaw.isEmpty) return {'plan': plan, 'premium_used': premium};

    final updated = TripPlan(
      tripId: plan.tripId,
      days: plan.days,
      transportMode: plan.transportMode,
      pace: plan.pace,
      personaMode: plan.personaMode,
      preferences: plan.preferences,
      province: plan.province,
      daysPlan: daysRaw.map(TripDay.fromMap).toList(),
      startLat: plan.startLat,
      startLng: plan.startLng,
      radiusUsedKm: plan.radiusUsedKm,
      districtStrict: plan.districtStrict,
    );

    await _persistTripArtifacts(updated);
    return {
      'plan': updated,
      'premium_used':
          ((data['meta'] as Map?)?['premium_used'] as bool?) ?? premium,
      'reason': ((data['meta'] as Map?)?['reason'] as String?) ?? 'optimized',
    };
  }

  Future<List<Map<String, dynamic>>> getSmartSeasonSuggestions({
    String? provinceSlug,
    String? districtName,
    int limit = 10,
  }) async {
    final result = await _invokeFunction(
      'smart_season_suggestions',
      body: {
        if (provinceSlug != null && provinceSlug.isNotEmpty)
          'province_slug': provinceSlug,
        if (districtName != null && districtName.isNotEmpty)
          'district_name': districtName,
        'limit': limit,
      },
    );
    final data = Map<String, dynamic>.from((result.data as Map?) ?? const {});
    return ((data['items'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getTrendMapItems({
    String? provinceSlug,
    int limit = 120,
  }) async {
    final result = await _invokeFunction(
      'trend_map',
      body: {
        if (provinceSlug != null && provinceSlug.isNotEmpty)
          'province_slug': provinceSlug,
        'limit': limit,
      },
    );
    final data = Map<String, dynamic>.from((result.data as Map?) ?? const {});
    return ((data['items'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> downloadOfflineCityPack(String provinceSlug) async {
    final places = await listProvinceHubPlaces(provinceSlug: provinceSlug);
    final placeIds = places.map((p) => p.id).toList();
    final mediaByPlace = <String, List<Map<String, dynamic>>>{};

    if (placeIds.isNotEmpty) {
      try {
        final mediaRows = await _client
            .from('place_media_clean')
            .select('place_id,storage_path,sort_order')
            .inFilter('place_id', placeIds)
            .limit(3000);

        for (final raw in (mediaRows as List)) {
          final row = Map<String, dynamic>.from(raw as Map);
          final placeId = row['place_id']?.toString() ?? '';
          final storagePath = row['storage_path']?.toString() ?? '';
          if (placeId.isEmpty || storagePath.isEmpty) continue;
          final publicUrl = _client.storage
              .from('public-media')
              .getPublicUrl(storagePath);
          mediaByPlace
              .putIfAbsent(placeId, () => <Map<String, dynamic>>[])
              .add({
                'storage_path': storagePath,
                'public_url': publicUrl,
                'sort_order': (row['sort_order'] as num?)?.toInt() ?? 0,
              });
        }

        for (final list in mediaByPlace.values) {
          list.sort(
            (a, b) => ((a['sort_order'] as num?)?.toInt() ?? 0).compareTo(
              (b['sort_order'] as num?)?.toInt() ?? 0,
            ),
          );
        }
      } catch (_) {}
    }

    final payload = places
        .map(
          (p) => {
            'id': p.id,
            'name': p.name,
            'slug': p.slug,
            'category': p.category,
            'short_summary': p.shortSummary,
            'best_time': p.bestTime,
            'duration_min': p.durationMin,
            'lat': p.lat,
            'lng': p.lng,
            'tags': p.tags,
            'source_kind': p.sourceKind,
            'is_free': p.isFree,
            'app_score': p.appScore,
            'app_rating': p.appRating,
            'rating_count': p.ratingCount,
            'media':
                mediaByPlace[p.id] ??
                p.media
                    .map(
                      (m) => {
                        'storage_path': m.storagePath,
                        'public_url': m.publicUrl,
                        'sort_order': m.sortOrder,
                      },
                    )
                    .toList(),
          },
        )
        .toList();
    await _cache.saveOfflineCityPack(provinceSlug, payload);
    await _prefetchOfflineThumbnails(payload);
  }

  Future<void> _prefetchOfflineThumbnails(
    List<Map<String, dynamic>> payload,
  ) async {
    const maxThumbs = 80;
    final urls = <String>{};

    for (final place in payload) {
      final media = ((place['media'] as List?) ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      if (media.isEmpty) continue;

      final first = media.first;
      final url = first['public_url']?.toString();
      if (url == null || url.isEmpty || !url.startsWith('http')) continue;
      urls.add(url);
      if (urls.length >= maxThumbs) break;
    }

    final cache = DefaultCacheManager();
    for (final url in urls) {
      try {
        await cache.downloadFile(url, key: url);
      } catch (_) {}
    }
  }

  Future<List<PlaceModel>> readOfflineCityPack(String provinceSlug) async {
    final pack = await _cache.readOfflineCityPack(provinceSlug);
    final places = ((pack?['places'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map(PlaceModel.fromMap)
        .toList();
    return places;
  }

  Future<Map<String, String>> listOfflineCityPacks() {
    return _cache.listOfflineCityPacks();
  }

  Future<void> removeOfflineCityPack(String provinceSlug) {
    return _cache.removeOfflineCityPack(provinceSlug);
  }

  Future<List<Map<String, dynamic>>> resolveSavedItems({
    required String provinceId,
    required List<String> items,
    double? lat,
    double? lng,
  }) async {
    final result = await _invokeFunction(
      'resolve_saved_items',
      body: {
        'province_id': provinceId,
        'items': items.map((e) => {'text_or_url': e}).toList(),
        ...?lat == null ? null : {'lat': lat},
        ...?lng == null ? null : {'lng': lng},
      },
    );
    final data = Map<String, dynamic>.from(result.data as Map);
    return ((data['results'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<List<Map<String, dynamic>>> adminQuery({
    required String mode,
    String? provinceSlug,
    String? provinceId,
    String? query,
    bool includeUnpublished = true,
    int limit = 200,
  }) async {
    final result = await _invokeFunction(
      'admin_place_query',
      body: {
        'mode': mode,
        ...?provinceSlug == null ? null : {'province_slug': provinceSlug},
        ...?provinceId == null ? null : {'province_id': provinceId},
        ...?query == null ? null : {'query': query},
        'include_unpublished': includeUnpublished,
        'limit': limit,
      },
      requireAuth: true,
    );
    final data = Map<String, dynamic>.from(result.data as Map);
    return ((data['items'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<String> adminUpsertPlace(Map<String, dynamic> payload) async {
    final result = await _invokeFunction(
      'admin_place_upsert',
      body: payload,
      requireAuth: true,
    );
    final data = Map<String, dynamic>.from(result.data as Map);
    return data['place_id'] as String;
  }

  Future<Map<String, dynamic>> adminReferralReport({
    int days = 30,
    int limit = 300,
  }) async {
    final since = DateTime.now()
        .toUtc()
        .subtract(Duration(days: days))
        .toIso8601String();

    final referralsRes = await _client
        .from('referrals')
        .select('id,referrer_user_id,referee_user_id,code,created_at')
        .gte('created_at', since)
        .order('created_at', ascending: false)
        .limit(limit);

    final referrals = (referralsRes as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final userIds = <String>{
      ...referrals
          .map((r) => r['referrer_user_id'] as String?)
          .whereType<String>(),
      ...referrals
          .map((r) => r['referee_user_id'] as String?)
          .whereType<String>(),
    }.toList();

    final profiles = userIds.isEmpty
        ? <Map<String, dynamic>>[]
        : ((await _client
                      .from('profiles')
                      .select('id,display_name,referral_code')
                      .inFilter('id', userIds))
                  as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

    final profileById = <String, Map<String, dynamic>>{
      for (final p in profiles) p['id'] as String: p,
    };

    final entitlementsRes = await _client
        .from('user_entitlements')
        .select('user_id,entitlement_key,expires_at,created_at')
        .eq('entitlement_key', 'pro_preview_7d')
        .gte('created_at', since)
        .order('created_at', ascending: false)
        .limit(limit * 2);
    final entitlements = (entitlementsRes as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final eventsRes = await _client
        .from('app_events')
        .select('event_name,created_at,payload,user_id')
        .gte('created_at', since)
        .inFilter('event_name', const ['referral_shared', 'referral_redeemed'])
        .order('created_at', ascending: false)
        .limit(limit * 3);
    final events = (eventsRes as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final codeCounts = <String, int>{};
    final codeByDay = <String, Set<String>>{};
    for (final r in referrals) {
      final code = (r['code'] as String?) ?? '-';
      codeCounts[code] = (codeCounts[code] ?? 0) + 1;
      final day = ((r['created_at'] as String?) ?? '').substring(0, 10);
      final key = '$code::$day';
      codeByDay.putIfAbsent(key, () => <String>{});
      codeByDay[key]!.add(r['referee_user_id'] as String? ?? '');
    }

    final suspicious =
        codeByDay.entries.where((e) => e.value.length >= 5).map((e) {
          final split = e.key.split('::');
          return {
            'code': split.first,
            'day': split.last,
            'redeem_count': e.value.length,
          };
        }).toList()..sort(
          (a, b) =>
              (b['redeem_count'] as int).compareTo(a['redeem_count'] as int),
        );

    final enrichedReferrals = referrals.map((r) {
      final referrer = profileById[r['referrer_user_id']];
      final referee = profileById[r['referee_user_id']];
      return {
        ...r,
        'referrer_name': referrer?['display_name'],
        'referee_name': referee?['display_name'],
      };
    }).toList();

    return {
      'summary': {
        'days': days,
        'referrals_count': referrals.length,
        'unique_codes': codeCounts.length,
        'entitlements_count': entitlements.length,
        'events_count': events.length,
      },
      'top_codes':
          codeCounts.entries
              .map((e) => {'code': e.key, 'count': e.value})
              .toList()
            ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int)),
      'suspicious': suspicious,
      'referrals': enrichedReferrals,
      'entitlements': entitlements,
      'events': events,
    };
  }

  Future<List<Map<String, dynamic>>> adminSuggestions({
    String status = 'pending',
    String? provinceSlug,
    int limit = 100,
  }) async {
    final result = await _invokeFunction(
      'admin_suggestions',
      body: {
        'mode': 'list',
        'status': status,
        ...?provinceSlug == null ? null : {'province_slug': provinceSlug},
        'limit': limit,
      },
      requireAuth: true,
    );
    final data = Map<String, dynamic>.from(result.data as Map);
    return ((data['items'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> adminReviewSuggestion({
    required String suggestionId,
    required String decision,
    String? adminNote,
  }) async {
    await _invokeFunction(
      'admin_suggestions',
      body: {
        'mode': 'review',
        'suggestion_id': suggestionId,
        'decision': decision,
        ...?adminNote == null || adminNote.trim().isEmpty
            ? null
            : {'admin_note': adminNote.trim()},
      },
      requireAuth: true,
    );
  }

  Future<Map<String, dynamic>> submitPlaceSuggestion({
    required String provinceSlug,
    String? districtSlug,
    required String suggestedName,
    required String suggestedCategory,
    required String shortNote,
    List<String> suggestedTags = const [],
    double? lat,
    double? lng,
    String? sourceUrl,
  }) async {
    final result = await _invokeFunction(
      'submit_place_suggestion',
      body: {
        'province_slug': provinceSlug,
        ...?districtSlug == null ? null : {'district_slug': districtSlug},
        'suggested_name': suggestedName,
        'suggested_category': suggestedCategory,
        'suggested_tags': suggestedTags,
        'short_note': shortNote,
        ...?lat == null ? null : {'lat': lat},
        ...?lng == null ? null : {'lng': lng},
        ...?sourceUrl == null ? null : {'source_url': sourceUrl},
      },
      requireAuth: true,
    );
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<String> createReferralCode() async {
    final result = await _invokeFunction(
      'create_referral_code',
      requireAuth: true,
    );
    final data = Map<String, dynamic>.from(result.data as Map);
    return data['code'] as String;
  }

  Future<Map<String, dynamic>> redeemReferral(String code) async {
    final result = await _invokeFunction(
      'redeem_referral',
      body: {'code': code},
      requireAuth: true,
    );
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<List<Map<String, dynamic>>> getEntitlements() async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) return const [];
    final rows = await _client
        .from('user_entitlements')
        .select('entitlement_key,expires_at,created_at')
        .eq('user_id', user.id)
        .gte('expires_at', DateTime.now().toUtc().toIso8601String())
        .order('expires_at', ascending: false);
    return (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getPremiumFeatures() async {
    final rows = await _client
        .from('premium_features')
        .select('feature_key,enabled,premium_only,rollout_percent,description')
        .order('feature_key');
    return (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> submitFeedback({required String message, double? rating}) async {
    await _invokeFunction(
      'submit_feedback',
      body: {'message': message, 'rating': rating},
      requireAuth: true,
    );
  }

  Future<Map<String, dynamic>> submitUserSignal({
    required String placeId,
    required String type,
    double? rating,
  }) async {
    final result = await _invokeFunction(
      'submit_user_signal',
      body: {'place_id': placeId, 'type': type, 'rating': rating},
      requireAuth: true,
    );
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<void> logAppEvent(
    String eventName, {
    Map<String, dynamic> payload = const {},
  }) async {
    final consent = await _cache.getConsentPreferences();
    if (consent['analytics_enabled'] != true) return;
    await _invokeFunction(
      'log_app_event',
      body: {'event_name': eventName, 'payload': payload},
    );
  }

  Future<Map<String, dynamic>> getUserStats() async {
    final result = await _invokeFunction('get_user_stats', requireAuth: true);
    return Map<String, dynamic>.from((result.data as Map?) ?? const {});
  }

  Future<void> deleteAccount() async {
    await _invokeFunction('delete_account', requireAuth: true);
  }

  Future<Map<String, dynamic>?> getTripById(String tripId) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('trips_clean')
        .select(
          'id,days,transport_mode,pace,persona_mode,preferences,created_at,province_id',
        )
        .eq('id', tripId)
        .eq('user_id', user.id)
        .maybeSingle();
    if (row == null) return null;
    return Map<String, dynamic>.from(row as Map);
  }

  // ── Admin: Photo Moderation ───────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> adminGetPendingPhotos({
    int limit = 50,
  }) async {
    final rows = await _client
        .from('place_photos')
        .select(
          'id,place_id,user_id,image_url,storage_path,status,moderation_note,created_at,'
          'pois(name)',
        )
        .eq('status', 'pending')
        .order('created_at', ascending: true)
        .limit(limit);
    return (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> adminReviewPhoto(
    String photoId, {
    required String status, // 'approved' | 'rejected' | 'hidden'
    String? note,
    bool setCover = false, // If true, set as place cover image
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _client
        .from('place_photos')
        .update({
          'status': status,
          'moderation_note': note,
          'updated_at': now,
        })
        .eq('id', photoId);

    // If approved and setCover, update the place's main media
    if (status == 'approved' && setCover) {
      final rows = await _client
          .from('place_photos')
          .select('place_id, image_url')
          .eq('id', photoId)
          .maybeSingle();
      if (rows != null) {
        final placeId = rows['place_id'] as String?;
        final imageUrl = rows['image_url'] as String?;
        if (placeId != null && imageUrl != null) {
          // Update place's first media slot or community state cover
          await _client
              .from('place_community_state')
              .upsert({
                'place_id': placeId,
                'cover_photo': imageUrl,
              }, onConflict: 'place_id');
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> adminGetPendingReviews({
    int limit = 50,
  }) async {
    final rows = await _client
        .from('place_reviews')
        .select('id,place_id,user_id,rating,comment,flags,status,created_at,pois(name)')
        .eq('status', 'pending')
        .order('created_at', ascending: true)
        .limit(limit);
    return (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> adminReviewReview(
    String reviewId, {
    required String status, // 'approved' | 'hidden'
  }) async {
    await _client
        .from('place_reviews')
        .update({
          'status': status,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', reviewId);
  }

  /// Fetches a Pexels cover image for a city/province via the Edge Function proxy.
  /// Returns null on any error (non-fatal — UI falls back gracefully).
  Future<Map<String, dynamic>?> getDestinationImage(String cityName) async {
    try {
      final result = await _invokeFunction(
        'get_destination_image',
        body: {'city': cityName},
      );
      final data = result.data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    } catch (_) {
      return null;
    }
  }
}

class _NearbyCacheEntry {
  const _NearbyCacheEntry({required this.items, required this.createdAt});

  final List<PlaceModel> items;
  final DateTime createdAt;
}
