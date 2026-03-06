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

  Future<void> signInWithOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email.trim(),
      shouldCreateUser: true,
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
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('profiles').upsert({
      'id': user.id,
      'display_name': user.email,
      'onboarding_completed': false,
    });
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
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
    if (cityName != null && cityName.trim().isNotEmpty) {
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
    return generateDemoTripPlan(
      provinceSlug: provinceSlug,
      days: days,
      transportMode: transportMode,
      pace: pace,
      personaMode: personaMode,
      preferences: preferences,
    );
  }

  Future<TripPlan> generateDemoTripPlan({
    required String provinceSlug,
    required int days,
    required String transportMode,
    required String pace,
    required String personaMode,
    required List<String> preferences,
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

    final placesRes = await _client
        .from('pois')
        .select('id,name,category,lat,lng,city,district,tags,source')
        .eq('provenance_verified', true)
        .ilike('city', province.name)
        .limit(260);

    final places = (placesRes as List)
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
        .where((p) => p.lat != null && p.lng != null)
        .toList();

    if (places.isEmpty) {
      throw Exception(
        'Bu ilde su an yeterli gezi verisi yok. Nearby/plan icin seed gerekiyor.',
      );
    }

    final perDay = _stopsPerDayForPace(pace);
    final needed = (days * perDay).clamp(1, places.length);
    final byDistrict = <String, List<PlaceModel>>{};
    for (final p in places) {
      final districtKey =
          ((placesRes as List)
              .cast<Map>()
              .firstWhere((r) => r['id'] == p.id, orElse: () => const {})
              .cast<String, dynamic>()['district']
              ?.toString()) ??
          'none';
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

      for (int i = 0; i < composed.length && i < perDay; i++) {
        final p = composed[i];
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

    await _cache.saveLastTrip(trip.toMap());
    return trip;
  }

  Future<TripPlan?> readCachedTrip() async {
    final map = await _cache.readLastTrip();
    if (map == null) return null;
    return TripPlan.fromMap(map);
  }

  Future<String> createShareToken(String tripId) async {
    final result = await _client.functions.invoke(
      'share_trip',
      body: {'trip_id': tripId},
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
    final user = _client.auth.currentUser;
    if (user == null) return const [];

    final response = await _client
        .from('trips_clean')
        .select(
          'id,days,transport_mode,pace,persona_mode,created_at,provinces(name,slug)',
        )
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
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
      'media': const [],
      'source_kind': row['source'] ?? 'osm',
      'is_free': true,
      'app_score': 0,
      'app_rating': 0,
      'rating_count': 0,
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
    String? category,
    List<String> categories = const [],
    List<String> tags = const [],
    bool freeOnly = false,
  }) async {
    final categoryList = categories.isNotEmpty
        ? categories
        : (category == null ? const <String>[] : <String>[category]);
    final cacheKey =
        '${lat.toStringAsFixed(4)}:${lng.toStringAsFixed(4)}:$radiusKm:${provinceId ?? ''}:${provinceSlug ?? ''}:${districtId ?? ''}:${districtSlug ?? ''}:${categoryList.join('|')}:${tags.join(',')}:$freeOnly';
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
    final rpc = await _client.rpc(
      'get_poi_stats',
      params: {'p_poi_id': placeId},
    );
    final map = Map<String, dynamic>.from((rpc as Map?) ?? const {});
    if (map.isEmpty) {
      return PlaceStats.fromMap({
        'place_id': placeId,
        'avg_rating': 0,
        'review_count': 0,
        'crowded_count': 0,
        'family_count': 0,
        'photo_spot_count': 0,
        'sunset_worthy_count': 0,
        'recent_reviews': const [],
      });
    }
    return PlaceStats.fromMap({...map, 'place_id': map['place_id'] ?? placeId});
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
    final result = await _client.functions.invoke(
      'submit_review',
      body: {
        'place_id': placeId,
        'rating': rating,
        'flags': flags,
        'comment_short': commentShort,
      },
    );
    final data = Map<String, dynamic>.from(result.data as Map);
    return PlaceStats.fromMap(Map<String, dynamic>.from(data['stats'] as Map));
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
  }) async {
    Map<String, dynamic>? province = await _client
        .from('provinces')
        .select('name,slug')
        .eq('slug', provinceSlug)
        .maybeSingle();
    if (province == null) return const [];
    final cityName = (province['name'] as String?) ?? '';
    final rows = await _client
        .from('pois')
        .select('id,name,category,lat,lng,city,district,tags,source')
        .eq('provenance_verified', true)
        .ilike('city', cityName)
        .limit(1000);
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
    int limit = 24,
  }) async {
    final province = await _client
        .from('provinces')
        .select('name,slug')
        .eq('slug', provinceSlug)
        .maybeSingle();
    if (province != null) {
      final cityName = province['name'] as String;
      final localRows = await _client
          .from('pois')
          .select('id,name,category,lat,lng,city,district,tags,source')
          .eq('provenance_verified', true)
          .ilike('city', cityName)
          .limit(limit);

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

    final result = await _client.functions.invoke(
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

    await _cache.saveLastTrip(updated.toMap());
    return {
      'plan': updated,
      'premium_used':
          ((data['meta'] as Map?)?['premium_used'] as bool?) ?? premium,
      'reason': ((data['meta'] as Map?)?['reason'] as String?) ?? 'optimized',
    };
  }

  Future<List<Map<String, dynamic>>> getSmartSeasonSuggestions({
    String? provinceSlug,
    int limit = 10,
  }) async {
    final result = await _client.functions.invoke(
      'smart_season_suggestions',
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

  Future<List<Map<String, dynamic>>> getTrendMapItems({
    String? provinceSlug,
    int limit = 120,
  }) async {
    final result = await _client.functions.invoke(
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
    final result = await _client.functions.invoke(
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
    final result = await _client.functions.invoke(
      'admin_place_query',
      body: {
        'mode': mode,
        ...?provinceSlug == null ? null : {'province_slug': provinceSlug},
        ...?provinceId == null ? null : {'province_id': provinceId},
        ...?query == null ? null : {'query': query},
        'include_unpublished': includeUnpublished,
        'limit': limit,
      },
    );
    final data = Map<String, dynamic>.from(result.data as Map);
    return ((data['items'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<String> adminUpsertPlace(Map<String, dynamic> payload) async {
    final result = await _client.functions.invoke(
      'admin_place_upsert',
      body: payload,
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
    final result = await _client.functions.invoke(
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
    );
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<String> createReferralCode() async {
    final result = await _client.functions.invoke('create_referral_code');
    final data = Map<String, dynamic>.from(result.data as Map);
    return data['code'] as String;
  }

  Future<Map<String, dynamic>> redeemReferral(String code) async {
    final result = await _client.functions.invoke(
      'redeem_referral',
      body: {'code': code},
    );
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<List<Map<String, dynamic>>> getEntitlements() async {
    final result = await _client.functions.invoke('get_entitlements');
    final data = Map<String, dynamic>.from(result.data as Map);
    return ((data['items'] as List?) ?? const [])
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
    await _client.functions.invoke(
      'submit_feedback',
      body: {'message': message, 'rating': rating},
    );
  }

  Future<Map<String, dynamic>> submitUserSignal({
    required String placeId,
    required String type,
    double? rating,
  }) async {
    final result = await _client.functions.invoke(
      'submit_user_signal',
      body: {'place_id': placeId, 'type': type, 'rating': rating},
    );
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<void> logAppEvent(
    String eventName, {
    Map<String, dynamic> payload = const {},
  }) async {
    await _client.functions.invoke(
      'log_app_event',
      body: {'event_name': eventName, 'payload': payload},
    );
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
}

class _NearbyCacheEntry {
  const _NearbyCacheEntry({required this.items, required this.createdAt});

  final List<PlaceModel> items;
  final DateTime createdAt;
}
