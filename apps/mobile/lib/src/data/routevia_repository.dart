import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants.dart';
import '../core/geo_utils.dart';
import '../models/community_post_models.dart';
import '../models/event_models.dart';
import '../models/trip_models.dart';
import '../models/weather_models.dart';
import 'fallback_provinces.dart';
import 'local_cache.dart';
import 'must_see_places.dart';

class RouteviaRepository {
  RouteviaRepository(this._client, this._cache);

  final SupabaseClient _client;
  final LocalCache _cache;
  final Map<String, _NearbyCacheEntry> _nearbyCache = {};
  final Map<String, _SignedUrlCacheEntry> _signedUrlCache = {};
  DateTime? _lastSessionValidationAt;
  // Mutex: prevents concurrent refreshSession() calls that corrupt session state.
  Future<void>? _refreshLock;

  bool _isDefinitiveRefreshTokenFailure(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('invalid refresh token') ||
        msg.contains('refresh_token_not_found') ||
        msg.contains('token has expired') ||
        msg.contains('user not found') ||
        msg.contains('invalid_grant');
  }

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

  bool _isLodgingCategory(String? category) {
    final normalized = (category ?? '').trim().toLowerCase();
    return normalized == 'lodging' ||
        normalized == 'accommodation' ||
        normalized == 'hotel' ||
        normalized == 'konaklama';
  }

  String _normalizeLookupText(String value) {
    return value
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  bool _hasLodgingSignal({
    required String name,
    required String category,
    required Iterable<dynamic> tags,
  }) {
    const needles = <String>[
      'lodging',
      'hotel',
      'bungalow',
      'bungalov',
      'villa',
      'resort',
      'glamping',
      'campingcabin',
      'extendedstayhotel',
      'boutiquehotel',
      'butikotel',
      'thermalhotel',
      'spahotel',
      'suitehotel',
      'suitotel',
      'konaklama',
    ];
    final values = <String>[
      _normalizeLookupText(name),
      _normalizeLookupText(category),
      ...tags.map((tag) => _normalizeLookupText(tag?.toString() ?? '')),
    ];
    return values.any((value) => needles.any(value.contains));
  }

  bool _isLodgingLikePlace(PlaceModel place) {
    return _isLodgingCategory(place.category) ||
        _hasLodgingSignal(
          name: place.name,
          category: place.category,
          tags: place.tags,
        );
  }

  bool _hasSuppressedRetailSignal({
    required String name,
    required String category,
    required Iterable<dynamic> tags,
  }) {
    const brandNeedles = <String>['lcwaikiki', 'lcw', 'waikiki'];
    final values = <String>[
      _normalizeLookupText(name),
      _normalizeLookupText(category),
      ...tags.map((tag) => _normalizeLookupText(tag?.toString() ?? '')),
    ];
    final hasRetailTag = values.any(
      (value) =>
          value.contains('clothingstore') ||
          value.contains('giyim') ||
          value.contains('apparel') ||
          value.contains('fashionstore'),
    );
    final matchesBrand = values.any(
      (value) => brandNeedles.any((needle) => value.contains(needle)),
    );
    return matchesBrand || hasRetailTag;
  }

  bool _hasSuppressedVenueSignal({
    required String name,
    required String category,
    required Iterable<dynamic> tags,
  }) {
    final values = <String>[
      _normalizeLookupText(name),
      _normalizeLookupText(category),
      ...tags.map((tag) => _normalizeLookupText(tag?.toString() ?? '')),
    ];
    const venueNeedles = <String>[
      'ifperformancehall',
      'performancehall',
      'concerthall',
      'livemusicvenue',
      'eventvenue',
      'nightclub',
      'auditorium',
      'bar',
      'clubiq',
      'loungebar',
    ];
    return values.any((value) => venueNeedles.any(value.contains));
  }

  bool _isSuppressedPlace(PlaceModel place) {
    return _hasSuppressedRetailSignal(
          name: place.name,
          category: place.category,
          tags: place.tags,
        ) ||
        _hasSuppressedVenueSignal(
          name: place.name,
          category: place.category,
          tags: place.tags,
        );
  }

  bool _isSuppressedMapItem(Map<String, dynamic> item) {
    return _hasSuppressedRetailSignal(
          name: item['name']?.toString() ?? '',
          category: item['category']?.toString() ?? '',
          tags: ((item['tags'] as List?) ?? const []),
        ) ||
        _hasSuppressedVenueSignal(
          name: item['name']?.toString() ?? '',
          category: item['category']?.toString() ?? '',
          tags: ((item['tags'] as List?) ?? const []),
        );
  }

  List<Map<String, dynamic>> _dedupeMapItemsByNameAndCoords(
    List<Map<String, dynamic>> items,
  ) {
    final deduped = <String, Map<String, dynamic>>{};
    for (final item in items) {
      final key =
          '${_normalizeLookupText(item['name']?.toString() ?? '')}:'
          '${((item['lat'] as num?)?.toDouble() ?? 0).toStringAsFixed(3)}:'
          '${((item['lng'] as num?)?.toDouble() ?? 0).toStringAsFixed(3)}';
      deduped.putIfAbsent(key, () => item);
    }
    return deduped.values.toList(growable: false);
  }

  List<PlaceModel> _dedupePlacesByNameAndCoords(List<PlaceModel> items) {
    final deduped = <String, PlaceModel>{};
    for (final item in items) {
      final lat = item.lat ?? 0;
      final lng = item.lng ?? 0;
      final key =
          '${_normalizeLookupText(item.name)}:'
          '${lat.toStringAsFixed(3)}:'
          '${lng.toStringAsFixed(3)}';
      final existing = deduped[key];
      if (existing == null) {
        deduped[key] = item;
        continue;
      }

      final existingHasMedia = existing.media.isNotEmpty;
      final candidateHasMedia = item.media.isNotEmpty;
      if (candidateHasMedia && !existingHasMedia) {
        deduped[key] = item;
        continue;
      }
      if (existingHasMedia && !candidateHasMedia) {
        continue;
      }

      final existingScore =
          existing.routeviaScore + (existing.effectiveRating * 10);
      final candidateScore = item.routeviaScore + (item.effectiveRating * 10);
      if (candidateScore > existingScore) {
        deduped[key] = item;
      }
    }
    return deduped.values.toList(growable: false);
  }

  int _mustSeeBoostForPlace({
    required String provinceSlug,
    required String placeName,
    String? districtName,
  }) {
    final keywords = kMustSeePlaceKeywordsByProvince[provinceSlug];
    final name = _normalizeLookupText(placeName);
    final district = _normalizeLookupText(districtName ?? '');
    var best = 0;
    if (keywords != null && keywords.isNotEmpty) {
      for (final keyword in keywords) {
        final normalizedKeyword = _normalizeLookupText(keyword);
        if (normalizedKeyword.isEmpty) continue;
        if (name == normalizedKeyword) {
          best = math.max(best, 240);
        } else if (name.contains(normalizedKeyword) ||
            normalizedKeyword.contains(name)) {
          best = math.max(best, 180);
        }
      }
    }
    final districtRules = kMustSeePlaceKeywordsByDistrict[provinceSlug];
    if (districtRules != null && district.isNotEmpty) {
      for (final entry in districtRules.entries) {
        final districtKeyword = _normalizeLookupText(entry.key);
        if (!district.contains(districtKeyword) &&
            !districtKeyword.contains(district)) {
          continue;
        }
        for (final keyword in entry.value) {
          final normalizedKeyword = _normalizeLookupText(keyword);
          if (normalizedKeyword.isEmpty) continue;
          if (name == normalizedKeyword) {
            best = math.max(best, 320);
          } else if (name.contains(normalizedKeyword) ||
              normalizedKeyword.contains(name)) {
            best = math.max(best, 260);
          }
        }
      }
    }
    return best;
  }

  List<PlaceModel> _applyMustSeeOrdering(
    String provinceSlug,
    List<PlaceModel> places,
  ) {
    final ranked = places.toList(growable: false)
      ..sort((a, b) {
        final boostB = _mustSeeBoostForPlace(
          provinceSlug: provinceSlug,
          placeName: b.name,
        );
        final boostA = _mustSeeBoostForPlace(
          provinceSlug: provinceSlug,
          placeName: a.name,
        );
        if (boostA != boostB) return boostB.compareTo(boostA);
        final scoreA = a.routeviaScore + (a.effectiveRating * 8);
        final scoreB = b.routeviaScore + (b.effectiveRating * 8);
        if (scoreA != scoreB) return scoreB.compareTo(scoreA);
        return a.name.compareTo(b.name);
      });
    return _dedupePlacesByNameAndCoords(ranked);
  }

  List<Map<String, dynamic>> _applyMustSeeOrderingToMapItems(
    String provinceSlug,
    List<Map<String, dynamic>> items,
  ) {
    final ranked = items.toList(growable: false)
      ..sort((a, b) {
        final boostA = _mustSeeBoostForPlace(
          provinceSlug: provinceSlug,
          placeName: a['name']?.toString() ?? '',
          districtName: a['district']?.toString(),
        );
        final boostB = _mustSeeBoostForPlace(
          provinceSlug: provinceSlug,
          placeName: b['name']?.toString() ?? '',
          districtName: b['district']?.toString(),
        );
        if (boostA != boostB) return boostB.compareTo(boostA);
        final scoreA =
            ((a['trust_score'] as num?)?.toDouble() ?? 0) +
            (((a['season_score'] as num?)?.toDouble() ?? 0) * 0.5) +
            (((a['trend_score'] as num?)?.toDouble() ?? 0) * 0.25);
        final scoreB =
            ((b['trust_score'] as num?)?.toDouble() ?? 0) +
            (((b['season_score'] as num?)?.toDouble() ?? 0) * 0.5) +
            (((b['trend_score'] as num?)?.toDouble() ?? 0) * 0.25);
        if (scoreA != scoreB) return scoreB.compareTo(scoreA);
        return (a['name']?.toString() ?? '').compareTo(
          b['name']?.toString() ?? '',
        );
      });
    return _dedupeMapItemsByNameAndCoords(
      ranked,
    ).where((item) => !_isSuppressedMapItem(item)).toList(growable: false);
  }

  /// Returns place IDs that an admin has marked as "featured" (Öne Çıkan).
  /// Used in home screen to boost those places to the top and show the badge.
  Future<Set<String>> getFeaturedPlaceIds() async {
    try {
      final rows = await _client
          .from('featured_places')
          .select('place_id')
          .eq('is_active', true);
      return {for (final r in (rows as List)) r['place_id'] as String};
    } catch (_) {
      return {};
    }
  }

  Future<String?> _signedCommunityPostUrl(
    String? storagePath, {
    int width = 900,
    int quality = 80,
  }) async {
    final path = storagePath?.trim() ?? '';
    if (path.isEmpty) return null;
    final cacheKey = '$path:$width:$quality';
    final cached = _signedUrlCache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.cachedAt).inSeconds < 518400) {
      return cached.url;
    }
    try {
      final url = await _runAuthed(
        () => _client.storage
            .from('community-posts')
            .createSignedUrl(
              path,
              60 * 60 * 24 * 7,
              transform: TransformOptions(width: width, quality: quality),
            ),
      );
      _signedUrlCache[cacheKey] = _SignedUrlCacheEntry(url: url, cachedAt: DateTime.now());
      return url;
    } catch (_) {
      try {
        final url = await _runAuthed(
          () => _client.storage
              .from('community-posts')
              .createSignedUrl(path, 60 * 60 * 24 * 7),
        );
        _signedUrlCache[cacheKey] = _SignedUrlCacheEntry(url: url, cachedAt: DateTime.now());
        return url;
      } catch (_) {
        return null;
      }
    }
  }

  Future<List<CommunityPostModel>> _hydrateCommunityPosts(
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return const [];

    final userIds = rows
        .map((row) => row['user_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final routeIds = rows
        .map((row) => row['related_route_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final postIds = rows
        .map((row) => row['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    final profiles = userIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : ((await _runAuthed(
                    () => _client
                        .from('profiles')
                        .select('id,display_name')
                        .inFilter('id', userIds),
                  ))
                  as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(growable: false);
    final routes = routeIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : ((await _runAuthed(
                    () => _client
                        .from('trips_clean')
                        .select('id,days,province:provinces(name)')
                        .inFilter('id', routeIds),
                  ))
                  as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(growable: false);
    final galleryRows = postIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : ((await _runAuthed(
                    () => _client
                        .from('community_post_gallery')
                        .select('id,post_id,storage_path,sort_order,created_at')
                        .inFilter('post_id', postIds)
                        .order('sort_order')
                        .order('created_at'),
                  ))
                  as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(growable: false);

    final profileById = {
      for (final item in profiles) item['id']?.toString() ?? '': item,
    };
    final routeTitleById = <String, String>{};
    for (final item in routes) {
      final province = item['province'] as Map?;
      final provinceName = province?['name']?.toString().trim();
      final days = (item['days'] as num?)?.toInt();
      final label = provinceName == null || provinceName.isEmpty
          ? null
          : days == null
          ? provinceName
          : '$provinceName • $days ${days == 1 ? 'gün' : 'gün'}';
      if (label != null) {
        routeTitleById[item['id']?.toString() ?? ''] = label;
      }
    }

    // Fetch all gallery + cover signed URLs in parallel instead of sequentially.
    // Gallery images are served at card size; covers at detail size.
    final galleryUrlFutures = galleryRows
        .map(
          (row) => _signedCommunityPostUrl(
            row['storage_path']?.toString(),
            width: 400,
            quality: 72,
          ),
        )
        .toList();
    final coverUrlFutures = rows
        .map(
          (row) => _signedCommunityPostUrl(
            row['cover_storage_path']?.toString(),
            width: 900,
            quality: 80,
          ),
        )
        .toList();
    final allUrls = await Future.wait([
      ...galleryUrlFutures,
      ...coverUrlFutures,
    ]);
    final galleryUrls = allUrls.sublist(0, galleryRows.length);
    final coverUrls = allUrls.sublist(galleryRows.length);

    final galleryByPostId = <String, List<Map<String, dynamic>>>{};
    for (var i = 0; i < galleryRows.length; i++) {
      final row = galleryRows[i];
      final postId = row['post_id']?.toString() ?? '';
      if (postId.isEmpty) continue;
      galleryByPostId.putIfAbsent(postId, () => <Map<String, dynamic>>[]).add({
        ...row,
        'image_url': galleryUrls[i],
      });
    }

    final items = <CommunityPostModel>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final userId = row['user_id']?.toString() ?? '';
      final routeId = row['related_route_id']?.toString();
      items.add(
        CommunityPostModel.fromMap({
          ...row,
          'cover_image_url': coverUrls[i],
          'submitter_name':
              profileById[userId]?['display_name']?.toString() ??
              'Routevia gezgini',
          'related_route_title': routeId == null
              ? null
              : routeTitleById[routeId],
          'gallery': galleryByPostId[row['id']?.toString() ?? ''] ?? const [],
        }),
      );
    }
    return items;
  }

  Future<void> _persistTripArtifacts(TripPlan trip) async {
    final map = trip.toMap();
    await Future.wait([
      _cache.saveLastTrip(map),
      _cache.saveTripHistoryEntry(map),
    ]);
  }

  Future<TripPlan> _saveTripRemote(TripPlan trip) async {
    final user = _client.auth.currentUser;
    if (user == null) return trip;

    final tripInsert = await _runAuthed(
      () => _client
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
          .maybeSingle(),
    );

    final tripId = (tripInsert?['id'] as String?) ?? trip.tripId;

    try {
      final dayPayload = trip.daysPlan
          .map((day) => {'trip_id': tripId, 'day_number': day.dayNumber})
          .toList();
      final insertedDays = await _runAuthed(
        () => _client
            .from('trip_days_clean')
            .insert(dayPayload)
            .select('id,day_number'),
      );

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
        await _runAuthed(
          () => _client.from('trip_stops_clean').insert(stopPayload),
        );
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
      await _runAuthed(
        () => _client.from('trips_clean').delete().eq('id', tripId),
      );
      rethrow;
    }
  }

  Future<void> _ensureFreshSession() async {
    // If a refresh is already in flight, piggyback on it instead of firing a
    // concurrent refreshSession() which can corrupt the token pair.
    if (_refreshLock != null) {
      try {
        await _refreshLock;
      } catch (_) {}
      return;
    }
    _refreshLock = _doEnsureFreshSession();
    try {
      await _refreshLock;
    } finally {
      _refreshLock = null;
    }
  }

  Future<void> _doEnsureFreshSession() async {
    final session = _client.auth.currentSession;
    if (session == null) return;
    final expiresAt = session.expiresAt;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var refreshed = false;
    if (expiresAt == null || (expiresAt - now) <= 180) {
      try {
        await _client.auth.refreshSession();
        refreshed = true;
      } catch (e) {
        // Only sign out if the refresh token is definitively invalid/expired.
        // Transient network errors must NOT force sign-out — that causes the
        // "oturum süreniz dolmuş" loop on poor connections.
        if (_isDefinitiveRefreshTokenFailure(e)) {
          try {
            await _client.auth.signOut();
          } catch (_) {}
          rethrow;
        }
        return;
      }
    }

    final shouldValidateWithServer =
        refreshed ||
        _lastSessionValidationAt == null ||
        DateTime.now().difference(_lastSessionValidationAt!) >
            const Duration(seconds: 75);

    if (!shouldValidateWithServer) return;

    try {
      await _client.auth.getUser();
      _lastSessionValidationAt = DateTime.now();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final isAuthProblem =
          msg.contains('jwt') ||
          msg.contains('unauthorized') ||
          msg.contains('auth session missing') ||
          (msg.contains('session') && msg.contains('expired'));
      if (!isAuthProblem) return;
      try {
        await _client.auth.refreshSession();
        await _client.auth.getUser();
        _lastSessionValidationAt = DateTime.now();
      } catch (refreshError) {
        if (_isDefinitiveRefreshTokenFailure(refreshError)) {
          try {
            await _client.auth.signOut();
          } catch (_) {}
        }
      }
    }
  }

  Future<String> _requireAccessToken() async {
    await _ensureFreshSession();
    final session = _client.auth.currentSession;
    if (session == null) {
      throw Exception('jwt expired');
    }
    final token = session.accessToken;
    if (token.isEmpty) {
      throw Exception('jwt expired');
    }
    // If token is still expired after refresh attempt (network failure etc.), inform user
    final expiresAt = session.expiresAt;
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (expiresAt != null && expiresAt < nowSec) {
      try {
        await _client.auth.refreshSession();
      } catch (e) {
        if (_isDefinitiveRefreshTokenFailure(e)) {
          try {
            await _client.auth.signOut();
          } catch (_) {}
          throw Exception('jwt expired');
        }
        rethrow;
      }
      final refreshedSession = _client.auth.currentSession;
      final refreshedToken = refreshedSession?.accessToken ?? '';
      final refreshedExpiresAt = refreshedSession?.expiresAt;
      if (refreshedSession == null ||
          refreshedToken.isEmpty ||
          (refreshedExpiresAt != null && refreshedExpiresAt < nowSec)) {
        throw Exception('jwt expired');
      }
      return refreshedToken;
    }
    return token;
  }

  bool _isAuthError(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('functionexception(status: 401') ||
        msg.contains('missing authorization header') ||
        msg.contains('unauthorized') ||
        msg.contains('invalid jwt') ||
        msg.contains('jwt expired') ||
        msg.contains('expired jwt') ||
        msg.contains('auth session missing') ||
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
      return _client.functions
          .invoke(name, body: body, headers: headers)
          .timeout(const Duration(seconds: 30));
    }

    try {
      return await run();
    } catch (e) {
      if (!requireAuth || !_isAuthError(e)) rethrow;
      try {
        await _client.auth.refreshSession();
        return run();
      } catch (refreshError) {
        if (_isDefinitiveRefreshTokenFailure(refreshError)) {
          try {
            await _client.auth.signOut();
          } catch (_) {}
          rethrow;
        }
        rethrow;
      }
    }
  }

  Future<T> _runAuthed<T>(Future<T> Function() action) async {
    Future<T> run() async {
      await _ensureFreshSession();
      return action();
    }

    try {
      return await run();
    } catch (e) {
      if (!_isAuthError(e)) rethrow;
      try {
        await _client.auth.refreshSession();
        return run();
      } catch (refreshError) {
        if (_isDefinitiveRefreshTokenFailure(refreshError)) {
          try {
            await _client.auth.signOut();
          } catch (_) {}
          rethrow;
        }
        rethrow;
      }
    }
  }

  Future<void> signInWithOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email.trim(),
      shouldCreateUser: true,
      emailRedirectTo: AppConstants.authCallbackUrl,
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
      emailRedirectTo: AppConstants.authCallbackUrl,
    );
  }

  Future<void> resendSignupConfirmation(String email) async {
    await _client.auth.resend(
      email: email.trim(),
      type: OtpType.signup,
      emailRedirectTo: AppConstants.authCallbackUrl,
    );
  }

  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: AppConstants.authCallbackUrl,
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    // Signup confirmation codes must be verified with OtpType.signup (verified
    // end-to-end: generate_link signup OTP -> verifyOTP signup -> session).
    await _client.auth.verifyOTP(
      type: OtpType.signup,
      email: email.trim(),
      token: code.trim(),
    );
  }

  Future<void> ensureProfile() async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) return;
    // ignoreDuplicates: true → sadece profil yoksa oluştur, varsa dokunma.
    // Bu sayede concurrent çağrılar onboarding_completed gibi alanları sıfırlamaz.
    await _runAuthed(
      () => _client.from('profiles').upsert({
        'id': user.id,
        'display_name': user.email,
        'onboarding_completed': false,
      }, ignoreDuplicates: true),
    );
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _runAuthed(
      () => _client
          .from('profiles')
          .select(
            'id,display_name,role,onboarding_completed,pref_tags,pref_pace,allow_location,allow_notifications',
          )
          .eq('id', user.id)
          .maybeSingle(),
    );
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
    if (user == null) {
      throw Exception('jwt expired');
    }
    await ensureProfile();
    await _runAuthed(
      () => _client.from('profiles').upsert({
        'id': user.id,
        'onboarding_completed': true,
        'pref_tags': prefTags,
        'pref_pace': prefPace,
        'allow_location': allowLocation,
        'allow_notifications': allowNotifications,
      }),
    );
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

  Future<void> updateProfilePreferences({
    String? prefPace,
    List<String>? prefTags,
    bool? allowLocation,
    bool? allowNotifications,
  }) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) return;

    final payload = <String, dynamic>{'id': user.id};
    if (prefPace != null) payload['pref_pace'] = prefPace;
    if (prefTags != null) payload['pref_tags'] = prefTags;
    if (allowLocation != null) payload['allow_location'] = allowLocation;
    if (allowNotifications != null) {
      payload['allow_notifications'] = allowNotifications;
    }

    await _runAuthed(() => _client.from('profiles').upsert(payload));
  }

  Future<bool> isCurrentUserAdmin() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;
    final allowedEmails = AppConstants.normalizedAdminAllowedEmails;
    if (allowedEmails.isNotEmpty) {
      final email = user.email?.trim().toLowerCase() ?? '';
      if (!allowedEmails.contains(email)) return false;
    }
    try {
      final row = await _runAuthed(
        () => _client
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle(),
      );
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
          .order('name');
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
          .order('name');
      final items = (fallback as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      if (items.isNotEmpty) return items;
    } catch (_) {
      // fall through to local fallback
    }

    return [...kFallbackProvinces]
      ..sort((a, b) => (a['slug'] as String).compareTo(b['slug'] as String));
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

  Future<List<EventModel>> listProvinceEvents(
    String provinceSlug, {
    int limit = 24,
  }) async {
    final viaFunction = await getEvents(
      provinceSlug: provinceSlug,
      limit: limit,
    );
    if (viaFunction.isNotEmpty) return viaFunction;
    try {
      final province = await _client
          .from('provinces')
          .select('id')
          .eq('slug', provinceSlug)
          .maybeSingle();
      final provinceId = province?['id']?.toString();
      if (provinceId == null || provinceId.isEmpty) return const [];

      final rows = await _client
          .from('events')
          .select(
            'id,province_id,province_name,district,name,slug,description,month_start,month_end,category,is_recurring,tags,lat,lng,source_url,is_active',
          )
          .eq('province_id', provinceId)
          .eq('is_active', true)
          .order('month_start')
          .order('name')
          .limit(limit);

      return (rows as List)
          .map((e) => EventModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<EventModel>> getEvents({
    String? provinceSlug,
    String? provinceName,
    int? month,
    int limit = 24,
  }) async {
    try {
      final payload =
          <String, dynamic>{
            'province_slug': provinceSlug?.trim(),
            'province': provinceName?.trim(),
            'month': month,
            'limit': limit,
          }..removeWhere(
            (key, value) => value == null || (value is String && value.isEmpty),
          );
      final result = await _invokeFunction('get_events', body: payload);
      final data = result.data;
      if (data is List) {
        return data
            .map((e) => EventModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .map((e) => EventModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {}

    try {
      dynamic query = _client
          .from('events')
          .select(
            'id,province_id,province_name,district,name,slug,description,month_start,month_end,category,is_recurring,tags,lat,lng,source_url,is_active',
          )
          .eq('is_active', true)
          .order('month_start')
          .order('name')
          .limit(limit);
      if (provinceSlug != null && provinceSlug.trim().isNotEmpty) {
        final province = await _client
            .from('provinces')
            .select('id')
            .eq('slug', provinceSlug.trim())
            .maybeSingle();
        final provinceId = province?['id']?.toString();
        if (provinceId == null || provinceId.isEmpty) return const [];
        query = query.eq('province_id', provinceId);
      } else if (provinceName != null && provinceName.trim().isNotEmpty) {
        query = query.ilike('province_name', provinceName.trim());
      }
      final rows = await query;
      var items = (rows as List)
          .map((e) => EventModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      if (month != null) {
        items = items.where((event) => event.isActiveInMonth(month)).toList();
      }
      return items;
    } catch (_) {
      return const [];
    }
  }

  Future<Map<String, EventReminderSetting>> listMyEventReminders() async {
    final user = _client.auth.currentUser;
    if (user == null) return const <String, EventReminderSetting>{};
    try {
      await _ensureFreshSession();
      final rows = await _runAuthed(
        () => _client
            .from('user_event_reminders')
            .select('event_id')
            .eq('user_id', user.id),
      );
      final items = (rows as List)
          .map(
            (e) => EventReminderSetting.fromMap(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .where((item) => item.eventId.isNotEmpty);
      return {for (final item in items) item.eventId: item};
    } catch (_) {
      return const <String, EventReminderSetting>{};
    }
  }

  Future<void> setEventReminder({
    required String eventId,
    required bool enabled,
  }) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('auth session missing');
    if (enabled) {
      await _runAuthed(
        () => _client.from('user_event_reminders').upsert(
          {'user_id': user.id, 'event_id': eventId},
          onConflict: 'user_id,event_id',
        ),
      );
    } else {
      await _runAuthed(
        () => _client
            .from('user_event_reminders')
            .delete()
            .eq('user_id', user.id)
            .eq('event_id', eventId),
      );
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
    final trimmedSearch = searchQuery?.trim() ?? '';
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    final viewportRadiusKm = math.min(
      _distanceKmRepo(centerLat, centerLng, maxLat, centerLng),
      _distanceKmRepo(centerLat, centerLng, centerLat, maxLng),
    );

    PlaceModel mapPoiRow(Map<String, dynamic> row) {
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
        'source_kind': row['source'],
        'is_free': true,
        'app_score': 0,
        'app_rating': 0,
        'rating_count': 0,
        'media': const [],
      });
    }

    double distanceToCenterKm(Map<String, dynamic> row) {
      final lat = (row['lat'] as num?)?.toDouble();
      final lng = (row['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return double.infinity;
      return GeoUtils.distanceKm(centerLat, centerLng, lat, lng);
    }

    dynamic applyLocationScope(dynamic q) {
      if (districtName != null &&
          districtName.trim().isNotEmpty &&
          cityName == null) {
        return q.ilike('district', districtName.trim());
      } else if (cityName != null && cityName.trim().isNotEmpty) {
        return q.ilike('city', cityName.trim());
      }
      return q;
    }

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
    query = applyLocationScope(query);
    if (trimmedSearch.isNotEmpty) {
      final q = trimmedSearch.replaceAll(',', ' ').trim();
      query = query.or(
        ['name.ilike.%$q%', 'district.ilike.%$q%', 'city.ilike.%$q%'].join(','),
      );
    }

    final rows = ((await query.limit(safeLimit)) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final exactViewportRows = rows
        .where((row) => !_isSuppressedMapItem(row))
        .where((row) => distanceToCenterKm(row) <= viewportRadiusKm)
        .toList();

    if (trimmedSearch.isEmpty || exactViewportRows.length >= safeLimit) {
      final places = exactViewportRows
          .map(mapPoiRow)
          .where((place) => !_isLodgingLikePlace(place))
          .toList();
      return _attachCommunityCoverMedia(_dedupePlacesByNameAndCoords(places));
    }

    dynamic broaderQuery = _client
        .from('pois')
        .select('id,name,category,lat,lng,city,district,tags,source')
        .eq('provenance_verified', true);
    if (categories.isNotEmpty) {
      broaderQuery = broaderQuery.inFilter('category', categories);
    }
    broaderQuery = applyLocationScope(broaderQuery);
    broaderQuery = broaderQuery.or(
      [
        'name.ilike.%$trimmedSearch%',
        'district.ilike.%$trimmedSearch%',
        'city.ilike.%$trimmedSearch%',
      ].join(','),
    );

    final broaderRows = ((await broaderQuery.limit(safeLimit * 3)) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((row) => !_isSuppressedMapItem(row))
        .toList();
    final merged = <String, Map<String, dynamic>>{
      for (final row in exactViewportRows) row['id'].toString(): row,
      for (final row in broaderRows) row['id'].toString(): row,
    };
    final sorted = merged.values.toList()
      ..removeWhere((row) => distanceToCenterKm(row) > viewportRadiusKm)
      ..sort((a, b) {
        final nameA = (a['name'] as String? ?? '').toLowerCase();
        final nameB = (b['name'] as String? ?? '').toLowerCase();
        final q = trimmedSearch.toLowerCase();
        final exactA = nameA == q ? 0 : 1;
        final exactB = nameB == q ? 0 : 1;
        if (exactA != exactB) return exactA.compareTo(exactB);
        final startsA = nameA.startsWith(q) ? 0 : 1;
        final startsB = nameB.startsWith(q) ? 0 : 1;
        if (startsA != startsB) return startsA.compareTo(startsB);
        final containsA = nameA.contains(q) ? 0 : 1;
        final containsB = nameB.contains(q) ? 0 : 1;
        if (containsA != containsB) return containsA.compareTo(containsB);
        return distanceToCenterKm(a).compareTo(distanceToCenterKm(b));
      });
    final places = sorted
        .take(safeLimit)
        .map(mapPoiRow)
        .where((place) => !_isLodgingLikePlace(place))
        .toList();
    return _attachCommunityCoverMedia(_dedupePlacesByNameAndCoords(places));
  }

  static double _distanceKmRepo(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) => GeoUtils.distanceKm(lat1, lng1, lat2, lng2);

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

  bool _isTouristWorthy(PlaceModel p) {
    if (p.lat == null || p.lng == null) return false;
    final name = p.name.toLowerCase().trim();
    if (name.length < 4) return false;
    if (_poisBlacklistExact.contains(name)) return false;
    for (final kw in _poisBlacklistKeywords) {
      if (name.contains(kw)) return false;
    }
    if (_isLodgingLikePlace(p)) return false;
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
    int startHour = 9,
    List<String> mustIncludePlaceIds = const [],
  }) async {
    final generated = await generateDemoTripPlan(
      provinceSlug: provinceSlug,
      days: days,
      transportMode: transportMode,
      pace: pace,
      personaMode: personaMode,
      preferences: preferences,
      districtId: districtId,
      maxRadiusKm: maxRadiusKm,
      allowOutsideDistrict: allowOutsideDistrict ?? false,
      startLat: startLat,
      startLng: startLng,
      startHour: startHour,
    );
    // AI enrichment — fire-and-forget, never block the user
    if (AppConstants.useLlm) {
      unawaited(_enrichTripWithAi(generated));
    }
    try {
      final persisted = await _saveTripRemote(generated);
      await _persistTripArtifacts(persisted);
      return persisted;
    } catch (_) {
      await _persistTripArtifacts(generated);
      return generated;
    }
  }

  Future<void> _enrichTripWithAi(TripPlan plan) async {
    try {
      final daysPayload = plan.daysPlan.map((d) => {
        'day': d.dayNumber,
        'stops': d.stops.map((s) => {
          'name': s.place.name,
          'category': s.place.category,
        }).toList(),
      }).toList();
      await _invokeFunction(
        'generate_trip_plan_v2',
        body: {
          'province_name': plan.province.name,
          'days': daysPayload,
          'transport_mode': plan.transportMode,
          'pace': plan.pace,
        },
        requireAuth: true,
      );
    } catch (_) {
      // Enrichment is best-effort — never propagate errors
    }
  }

  Future<TripPlan> generateDemoTripPlan({
    required String provinceSlug,
    required int days,
    required String transportMode,
    required String pace,
    required String personaMode,
    required List<String> preferences,
    String? districtId,
    int? maxRadiusKm,
    bool allowOutsideDistrict = false,
    double? startLat,
    double? startLng,
    int startHour = 9,
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

    final useStrictDistrictFilter =
        startLat == null ||
        startLng == null ||
        maxRadiusKm == null ||
        maxRadiusKm > 40;

    // ── Fetch & filter places ─────────────────────────────────────────────
    // OSM city field is unreliable — try three progressively broader queries.

    final minNeeded = _stopsPerDayForPace(pace) * days;

    // Category-based realistic visit durations (minutes)
    int categoryDuration(String? cat) => switch (cat) {
      'museum' => 90,
      'historical' => 75,
      'nature' => 90,
      'beach' => 90,
      'waterfall' => 60,
      'canyon' => 75,
      'viewpoint' => 35,
      'tour' => 90,
      'activity' => 75,
      'market' => 45,
      'food' => 60,
      'cafe' => 45,
      _ => 60,
    };

    Future<List<PlaceModel>> fetchFiltered(dynamic q) async {
      final raw = (await (q as dynamic).limit(500)) as List;
      return raw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map((row) {
            final cat = row['category'] as String? ?? '';
            return PlaceModel.fromMap({
              'id': row['id'],
              'name': row['name'],
              'slug': row['id'],
              'category': cat,
              'short_summary':
                  '${row['district'] ?? row['city'] ?? 'Keşif noktası'}',
              'best_time': 'day',
              'duration_min': categoryDuration(cat),
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
          })
          .where(_isTouristWorthy)
          .toList();
    }

    // Try 1: exact province name match
    var q1 = _client
        .from('pois')
        .select('id,name,category,lat,lng,city,district,tags,source')
        .eq('provenance_verified', true)
        .ilike('city', province.name);
    if (useStrictDistrictFilter &&
        !allowOutsideDistrict &&
        districtName != null &&
        districtName.trim().isNotEmpty) {
      q1 = (q1 as dynamic).ilike('district', districtName.trim());
    }
    var places = await fetchFiltered(q1);

    // Try 2: city contains province name (handles sub-district city values)
    if (places.length < minNeeded) {
      var q2 = _client
          .from('pois')
          .select('id,name,category,lat,lng,city,district,tags,source')
          .eq('provenance_verified', true)
          .ilike('city', '%${province.name}%');
      if (useStrictDistrictFilter &&
          !allowOutsideDistrict &&
          districtName != null &&
          districtName.trim().isNotEmpty) {
        q2 = (q2 as dynamic).ilike('district', districtName.trim());
      }
      final extra = await fetchFiltered(q2);
      final seen1 = places.map((p) => p.id).toSet();
      places = [...places, ...extra.where((p) => !seen1.contains(p.id))];
    }

    // Try 3: no city filter, but restrict by distance to province center
    if (places.length < minNeeded) {
      final coordRow = await _client
          .from('provinces_with_coords')
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

      if (useStrictDistrictFilter &&
          !allowOutsideDistrict &&
          districtName != null &&
          districtName.trim().isNotEmpty) {
        final strictDistrictName = districtName.trim();
        extras = extras
            .where((p) => p.shortSummary == strictDistrictName)
            .toList();
      }

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

    // Final dedup by ID
    final seenIds = <String>{};
    places = places.where((p) => seenIds.add(p.id)).toList();

    // Also dedup by normalized name — catches same physical place with different DB IDs
    // (e.g., duplicated OSM imports, place_clean vs pois overlap)
    final seenNormNames = <String>{};
    places = places.where((p) {
      final norm = p.name
          .toLowerCase()
          .replaceAll('ç', 'c')
          .replaceAll('ğ', 'g')
          .replaceAll('ı', 'i')
          .replaceAll('ö', 'o')
          .replaceAll('ş', 's')
          .replaceAll('ü', 'u')
          .replaceAll(RegExp(r'[^a-z0-9]'), '');
      return seenNormNames.add(norm);
    }).toList();

    // ── Must-see boosting: push province-level must-see places to the front ──
    // This ensures must-see landmarks (Ayasofya, Efes, Pamukkale etc.) are
    // always included in generated routes when they're in the pool.
    final mustSeeKeywords =
        kMustSeePlaceKeywordsByProvince[provinceSlug] ?? const [];
    if (mustSeeKeywords.isNotEmpty) {
      String normMustSee(String s) => s
          .toLowerCase()
          .replaceAll('ç', 'c')
          .replaceAll('ğ', 'g')
          .replaceAll('ı', 'i')
          .replaceAll('ö', 'o')
          .replaceAll('ş', 's')
          .replaceAll('ü', 'u')
          .replaceAll(RegExp(r'[^a-z0-9]'), '');
      final normalizedKeywords = mustSeeKeywords.map(normMustSee).toSet();
      bool isMustSee(PlaceModel p) {
        final norm = normMustSee(p.name);
        return normalizedKeywords.any(
          (kw) => norm.contains(kw) || kw.contains(norm),
        );
      }

      final mustSees = places.where(isMustSee).toList();
      final rest = places.where((p) => !isMustSee(p)).toList();
      places = [...mustSees, ...rest];
    }

    if (startLat != null && startLng != null && maxRadiusKm != null) {
      final inRadius = places.where((p) {
        final lat = p.lat;
        final lng = p.lng;
        if (lat == null || lng == null) return false;
        return _distanceKmRepo(startLat, startLng, lat, lng) <= maxRadiusKm;
      }).toList();
      if (inRadius.isNotEmpty) {
        places = inRadius;
      }
    }

    if (places.isEmpty) {
      throw Exception(
        districtName != null && !allowOutsideDistrict
            ? 'Seçilen ilçede şu an yeterli gezi verisi yok.'
            : 'Bu ilde şu an yeterli gezi verisi bulunamadı.',
      );
    }

    final perDay = _stopsPerDayForPace(pace);

    // ── Sort all available places by proximity to user ─────────────────────
    final sortedByProx = List<PlaceModel>.from(places);
    if (startLat != null && startLng != null) {
      sortedByProx.sort((a, b) {
        final da = _distanceKmRepo(startLat, startLng, a.lat ?? 0, a.lng ?? 0);
        final db = _distanceKmRepo(startLat, startLng, b.lat ?? 0, b.lng ?? 0);
        return da.compareTo(db);
      });
    }

    // ── Category buckets (already proximity-ordered) ───────────────────────
    const catCultural = {'museum', 'historical', 'tour'};
    const catOutdoor = {'nature', 'beach', 'waterfall', 'canyon', 'viewpoint'};
    const catActive = {'activity', 'market'};
    const catDining = {'food', 'cafe'};

    final bucketCultural = sortedByProx
        .where((p) => catCultural.contains(p.category))
        .toList();
    final bucketOutdoor = sortedByProx
        .where((p) => catOutdoor.contains(p.category))
        .toList();
    final bucketActive = sortedByProx
        .where((p) => catActive.contains(p.category))
        .toList();
    final bucketDining = sortedByProx
        .where((p) => catDining.contains(p.category))
        .toList();

    // Global used-ID set — no place repeated across days
    final usedIds = <String>{};

    // Must-see keyword set for this province (for bucket priority)
    final mustSeeKeywordsForBucket =
        (kMustSeePlaceKeywordsByProvince[provinceSlug] ?? const [])
            .map(
              (s) => s
                  .toLowerCase()
                  .replaceAll('ç', 'c')
                  .replaceAll('ğ', 'g')
                  .replaceAll('ı', 'i')
                  .replaceAll('ö', 'o')
                  .replaceAll('ş', 's')
                  .replaceAll('ü', 'u')
                  .replaceAll(RegExp(r'[^a-z0-9]'), ''),
            )
            .toSet();

    bool isMustSeePlace(PlaceModel p) {
      if (mustSeeKeywordsForBucket.isEmpty) return false;
      final norm = p.name
          .toLowerCase()
          .replaceAll('ç', 'c')
          .replaceAll('ğ', 'g')
          .replaceAll('ı', 'i')
          .replaceAll('ö', 'o')
          .replaceAll('ş', 's')
          .replaceAll('ü', 'u')
          .replaceAll(RegExp(r'[^a-z0-9]'), '');
      return mustSeeKeywordsForBucket.any(
        (kw) => norm.contains(kw) || kw.contains(norm),
      );
    }

    // Pick from a bucket skipping used IDs. Must-see places always win;
    // otherwise shuffles top-K candidates for variety across runs.
    PlaceModel? pickFrom(List<PlaceModel> bucket, {int topK = 6}) {
      final unused = bucket.where((p) => !usedIds.contains(p.id)).toList();
      if (unused.isEmpty) return null;
      // Must-see places always win over regular picks — pick one if available
      final mustSeeCandidate = unused.where(isMustSeePlace).firstOrNull;
      if (mustSeeCandidate != null) return mustSeeCandidate;
      // Otherwise shuffle top-K for variety
      final candidates = unused.take(topK).toList()..shuffle();
      return candidates.first;
    }

    // Pick any unused place ordered by proximity (fallback filler)
    PlaceModel? pickAny() {
      for (final p in sortedByProx) {
        if (!usedIds.contains(p.id)) return p;
      }
      return null;
    }

    void use(PlaceModel p) => usedIds.add(p.id);

    // ── Day composition ────────────────────────────────────────────────────
    int minute = startHour.clamp(6, 14) * 60;
    final dayPlans = <TripDay>[];

    for (int d = 1; d <= days; d++) {
      final composed = <PlaceModel>[];

      // Slot: Cultural (museum / historical / tour)
      final c1 = pickFrom(bucketCultural);
      if (c1 != null) {
        composed.add(c1);
        use(c1);
      }

      // Slot: Outdoor (nature / beach / viewpoint / waterfall / canyon)
      final o1 = pickFrom(bucketOutdoor);
      if (o1 != null) {
        composed.add(o1);
        use(o1);
      }

      // Slot: Activity / market — or a second outdoor / cultural if unavailable
      final a1 =
          pickFrom(bucketActive) ??
          pickFrom(bucketOutdoor) ??
          pickFrom(bucketCultural);
      if (a1 != null) {
        composed.add(a1);
        use(a1);
      }

      // Slot: Dining (max 1 food/cafe per day)
      final d1 = pickFrom(bucketDining);
      if (d1 != null) {
        composed.add(d1);
        use(d1);
      }

      // Slot: Second cultural or outdoor if pace calls for more stops
      if (composed.length < perDay) {
        final c2 = pickFrom(bucketCultural) ?? pickFrom(bucketOutdoor);
        if (c2 != null) {
          composed.add(c2);
          use(c2);
        }
      }

      // Fill any remaining slots with nearest unused place
      while (composed.length < perDay) {
        final p = pickAny();
        if (p == null) break;
        use(p);
        composed.add(p);
      }

      if (composed.isEmpty) break;

      // Sort this day's stops by nearest-neighbor greedy (logical walking route)
      final composedSorted = _sortByProximity(
        composed,
        originLat: d == 1 ? startLat : null,
        originLng: d == 1 ? startLng : null,
      );

      final stops = <TripStop>[];
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
      minute = startHour.clamp(6, 14) * 60;
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
    await _cache.recordVisitedProvince(province.slug, province.name);
    return trip;
  }

  Future<TripPlan?> readCachedTrip() async {
    final map = await _cache.readLastTrip();
    if (map == null) return null;
    return TripPlan.fromMap(map);
  }

  Future<List<TripPlan>> readTripHistory() async {
    List<Map<String, dynamic>> items;
    try {
      items = await _cache.readTripHistory();
    } catch (_) {
      return const [];
    }
    return items
        .map((m) {
          try {
            return TripPlan.fromMap(m);
          } catch (_) {
            return null;
          }
        })
        .whereType<TripPlan>()
        .toList();
  }

  Future<void> deleteTrip({
    required String tripId,
    required bool isLocal,
  }) async {
    await _cache.deleteTripHistoryEntry(tripId);
    if (isLocal) return;

    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }

    await _runAuthed(
      () => _client
          .from('trips_clean')
          .delete()
          .eq('id', tripId)
          .eq('user_id', user.id),
    );
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
    try {
      final result = await _invokeFunction(
        'share_trip',
        body: {'trip_id': tripId},
        requireAuth: true,
      );
      final data = Map<String, dynamic>.from(result.data as Map);
      return data['token'] as String;
    } catch (_) {
      final existing = await _findExistingShareToken(tripId);
      if (existing != null && existing.isNotEmpty) return existing;

      final token = _generateShareToken();
      final payload = {
        'trip_id': tripId,
        'share_token': token,
        'is_active': true,
      };

      try {
        await _runAuthed(
          () => _client.from('trip_shares_clean').insert(payload),
        );
        return token;
      } catch (_) {
        await _runAuthed(() => _client.from('trip_shares').insert(payload));
        return token;
      }
    }
  }

  Future<String?> _findExistingShareToken(String tripId) async {
    try {
      final row = await _runAuthed(
        () => _client
            .from('trip_shares_clean')
            .select('share_token')
            .eq('trip_id', tripId)
            .eq('is_active', true)
            .maybeSingle(),
      );
      return row == null ? null : row['share_token'] as String?;
    } catch (_) {
      try {
        final row = await _runAuthed(
          () => _client
              .from('trip_shares')
              .select('share_token')
              .eq('trip_id', tripId)
              .eq('is_active', true)
              .maybeSingle(),
        );
        return row == null ? null : row['share_token'] as String?;
      } catch (_) {
        return null;
      }
    }
  }

  String _generateShareToken() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = math.Random.secure();
    return List.generate(10, (_) => chars[random.nextInt(chars.length)]).join();
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
      final response = await _runAuthed(
        () => _client
            .from('trips_clean')
            .select(
              'id,days,transport_mode,pace,persona_mode,preferences,created_at,province:provinces(id,name,slug)',
            )
            .eq('user_id', user.id)
            .order('created_at', ascending: false),
      );

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

  Future<List<CommunityPostModel>> listMyCommunityPosts({
    int limit = 80,
  }) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) return const [];

    final rows = await _runAuthed(
      () => _client
          .from('community_posts')
          .select(
            'id,user_id,related_route_id,title,summary,city,country,post_type,'
            'cover_storage_path,content_body,tags,status,admin_note,submitted_at,'
            'published_at,reviewed_at,created_at,updated_at,estimated_read_minutes',
          )
          .eq('user_id', user.id)
          .order('updated_at', ascending: false)
          .limit(limit),
    );
    return _hydrateCommunityPosts(
      (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false),
    );
  }

  Future<List<CommunityPostModel>> listCommunityFeed({
    int limit = 10,
    int offset = 0,
  }) async {
    final blockedUserIds = await getBlockedUserIds();
    final rows = await _runAuthed(
      () => _client
          .from('community_posts')
          .select(
            'id,user_id,related_route_id,title,summary,city,country,post_type,'
            'cover_storage_path,tags,status,published_at,created_at,updated_at,'
            'estimated_read_minutes',
          )
          .eq('status', 'approved')
          .order('published_at', ascending: false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1),
    );
    final filtered = (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where(
          (row) => !blockedUserIds.contains(row['user_id']?.toString() ?? ''),
        )
        .toList(growable: false);
    return _hydrateCommunityPosts(filtered);
  }

  Future<CommunityPostModel?> getCommunityPostById(String postId) async {
    final row = await _runAuthed(
      () => _client
          .from('community_posts')
          .select(
            'id,user_id,related_route_id,title,summary,city,country,post_type,'
            'cover_storage_path,content_body,tags,status,admin_note,submitted_at,'
            'published_at,reviewed_at,created_at,updated_at,estimated_read_minutes',
          )
          .eq('id', postId)
          .maybeSingle(),
    );
    if (row == null) return null;
    final items = await _hydrateCommunityPosts([
      Map<String, dynamic>.from(row as Map),
    ]);
    return items.firstOrNull;
  }

  Future<CommunityPostModel> saveCommunityPostDraft({
    String? postId,
    required String title,
    required String summary,
    required String city,
    required String country,
    required String postType,
    required String contentBody,
    List<String> tags = const [],
    String? relatedRouteId,
  }) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    final payload = <String, dynamic>{
      'user_id': user.id,
      'title': title.trim(),
      'summary': summary.trim(),
      'city': city.trim(),
      'country': country.trim(),
      'post_type': postType,
      'content_body': contentBody.trim(),
      'tags': tags
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toSet()
          .toList(growable: false),
      'related_route_id':
          relatedRouteId == null || relatedRouteId.trim().isEmpty
          ? null
          : relatedRouteId.trim(),
      'status': 'draft',
      'admin_note': null,
    };

    Map<String, dynamic> row;
    if (postId == null || postId.trim().isEmpty) {
      final inserted = await _runAuthed(
        () => _client
            .from('community_posts')
            .insert(payload)
            .select(
              'id,user_id,related_route_id,title,summary,city,country,post_type,'
              'cover_storage_path,content_body,tags,status,admin_note,submitted_at,'
              'published_at,reviewed_at,created_at,updated_at,estimated_read_minutes',
            )
            .maybeSingle(),
      );
      if (inserted == null) throw Exception('Gönderi kaydedilemedi.');
      row = Map<String, dynamic>.from(inserted as Map);
    } else {
      final updated = await _runAuthed(
        () => _client
            .from('community_posts')
            .update(payload)
            .eq('id', postId.trim())
            .eq('user_id', user.id)
            .select(
              'id,user_id,related_route_id,title,summary,city,country,post_type,'
              'cover_storage_path,content_body,tags,status,admin_note,submitted_at,'
              'published_at,reviewed_at,created_at,updated_at,estimated_read_minutes',
            )
            .maybeSingle(),
      );
      if (updated == null) throw Exception('Gönderi güncellenemedi.');
      row = Map<String, dynamic>.from(updated as Map);
    }

    final items = await _hydrateCommunityPosts([row]);
    return items.first;
  }

  Future<void> submitCommunityPostForReview(String postId) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    final row = await _runAuthed(
      () => _client
          .from('community_posts')
          .select(
            'id,title,summary,city,country,post_type,content_body,cover_storage_path,status',
          )
          .eq('id', postId)
          .eq('user_id', user.id)
          .maybeSingle(),
    );
    if (row == null) {
      throw Exception('İçerik bulunamadı.');
    }
    final map = Map<String, dynamic>.from(row as Map);
    final title = map['title']?.toString().trim() ?? '';
    final summary = map['summary']?.toString().trim() ?? '';
    final city = map['city']?.toString().trim() ?? '';
    final country = map['country']?.toString().trim() ?? '';
    final body = map['content_body']?.toString().trim() ?? '';
    final cover = map['cover_storage_path']?.toString().trim() ?? '';
    if (title.length < 8) {
      throw Exception('Başlık en az 8 karakter olmalı.');
    }
    if (summary.length < 24) {
      throw Exception('Özet en az 24 karakter olmalı.');
    }
    if (city.isEmpty || country.isEmpty) {
      throw Exception('Şehir ve ülke alanı zorunlu.');
    }
    if (body.length < 180) {
      throw Exception('İçerik gövdesi en az 180 karakter olmalı.');
    }
    if (cover.isEmpty) {
      throw Exception('Kapak görseli yüklenmeden incelemeye gönderilemez.');
    }
    await _runAuthed(
      () => _client
          .from('community_posts')
          .update({
            'status': 'pending',
            'submitted_at': DateTime.now().toUtc().toIso8601String(),
            'admin_note': null,
          })
          .eq('id', postId)
          .eq('user_id', user.id),
    );
  }

  Future<void> uploadCommunityPostCover({
    required String postId,
    required File file,
  }) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    final current = await _runAuthed(
      () => _client
          .from('community_posts')
          .select('cover_storage_path')
          .eq('id', postId)
          .eq('user_id', user.id)
          .maybeSingle(),
    );
    final ext = file.path.split('.').last.toLowerCase();
    final safeExt = ext == 'png' ? 'png' : 'jpg';
    final contentType = safeExt == 'png' ? 'image/png' : 'image/jpeg';
    final objectPath =
        '${user.id}/$postId/cover_${DateTime.now().millisecondsSinceEpoch}.$safeExt';
    final bytes = await file.readAsBytes();
    await _runAuthed(
      () => _client.storage
          .from('community-posts')
          .uploadBinary(
            objectPath,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: false),
          ),
    );
    await _runAuthed(
      () => _client
          .from('community_posts')
          .update({'cover_storage_path': objectPath})
          .eq('id', postId)
          .eq('user_id', user.id),
    );
    final previous = (current as Map?)?['cover_storage_path']?.toString() ?? '';
    if (previous.isNotEmpty && previous != objectPath) {
      try {
        await _runAuthed(
          () => _client.storage.from('community-posts').remove([previous]),
        );
      } catch (_) {}
    }
  }

  Future<void> uploadCommunityPostGallery({
    required String postId,
    required List<File> files,
  }) async {
    if (files.isEmpty) return;
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    final existing = await _runAuthed(
      () => _client
          .from('community_post_gallery')
          .select('sort_order')
          .eq('post_id', postId)
          .order('sort_order', ascending: false)
          .limit(1),
    );
    var nextSort = (existing as List).isEmpty
        ? 0
        : ((existing.first['sort_order'] as num?)?.toInt() ?? 0) + 1;

    for (final file in files) {
      final ext = file.path.split('.').last.toLowerCase();
      final safeExt = ext == 'png' ? 'png' : 'jpg';
      final contentType = safeExt == 'png' ? 'image/png' : 'image/jpeg';
      final objectPath =
          '${user.id}/$postId/gallery_${DateTime.now().millisecondsSinceEpoch}_$nextSort.$safeExt';
      final bytes = await file.readAsBytes();
      await _runAuthed(
        () => _client.storage
            .from('community-posts')
            .uploadBinary(
              objectPath,
              bytes,
              fileOptions: FileOptions(contentType: contentType, upsert: false),
            ),
      );
      await _runAuthed(
        () => _client.from('community_post_gallery').insert({
          'post_id': postId,
          'user_id': user.id,
          'storage_path': objectPath,
          'sort_order': nextSort,
        }),
      );
      nextSort += 1;
    }
  }

  Future<void> deleteCommunityPost(String postId) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    final post = await _runAuthed(
      () => _client
          .from('community_posts')
          .select('cover_storage_path')
          .eq('id', postId)
          .eq('user_id', user.id)
          .maybeSingle(),
    );
    if (post == null) return;
    final gallery = await _runAuthed(
      () => _client
          .from('community_post_gallery')
          .select('storage_path')
          .eq('post_id', postId),
    );
    await _runAuthed(
      () => _client
          .from('community_posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', user.id),
    );
    final paths = <String>[
      (post as Map)['cover_storage_path']?.toString() ?? '',
      for (final row in (gallery as List))
        row['storage_path']?.toString() ?? '',
    ].where((path) => path.isNotEmpty).toList(growable: false);
    if (paths.isNotEmpty) {
      try {
        await _runAuthed(
          () => _client.storage.from('community-posts').remove(paths),
        );
      } catch (_) {}
    }
  }

  Future<void> deleteCommunityPostImage(String imageId) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    final row = await _runAuthed(
      () => _client
          .from('community_post_gallery')
          .select('storage_path')
          .eq('id', imageId)
          .eq('user_id', user.id)
          .maybeSingle(),
    );
    if (row == null) return;
    final storagePath = (row as Map)['storage_path']?.toString() ?? '';
    await _runAuthed(
      () => _client
          .from('community_post_gallery')
          .delete()
          .eq('id', imageId)
          .eq('user_id', user.id),
    );
    if (storagePath.isNotEmpty) {
      try {
        await _runAuthed(
          () => _client.storage.from('community-posts').remove([storagePath]),
        );
      } catch (_) {}
    }
  }

  Future<bool> hasAcceptedUgcPolicy() async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) return false;
    final row = await _runAuthed(
      () => _client
          .from('ugc_policy_acceptances')
          .select('user_id')
          .eq('user_id', user.id)
          .maybeSingle(),
    );
    return row != null;
  }

  Future<void> acceptUgcPolicy({String version = '2026-03-12'}) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    await _runAuthed(
      () => _client.from('ugc_policy_acceptances').upsert({
        'user_id': user.id,
        'version': version,
        'accepted_at': DateTime.now().toUtc().toIso8601String(),
      }),
    );
  }

  Future<void> reportCommunityPost({
    required String postId,
    required String reason,
    String? details,
  }) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    await _runAuthed(
      () => _client.from('community_post_reports').upsert({
        'post_id': postId,
        'reporter_user_id': user.id,
        'reason': reason.trim(),
        'details': details?.trim().isEmpty ?? true ? null : details!.trim(),
        'status': 'pending',
      }),
    );
  }

  Future<Set<String>> getBlockedUserIds() async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) return <String>{};
    final rows = await _runAuthed(
      () => _client
          .from('user_blocks')
          .select('blocked_user_id')
          .eq('user_id', user.id),
    );
    return (rows as List)
        .map((row) => row['blocked_user_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<bool> isUserBlocked(String blockedUserId) async {
    final ids = await getBlockedUserIds();
    return ids.contains(blockedUserId);
  }

  Future<bool> toggleUserBlock(String blockedUserId) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    final rows = await _runAuthed(
      () => _client
          .from('user_blocks')
          .select('id')
          .eq('user_id', user.id)
          .eq('blocked_user_id', blockedUserId)
          .limit(1),
    );
    if ((rows as List).isNotEmpty) {
      await _runAuthed(
        () => _client
            .from('user_blocks')
            .delete()
            .eq('user_id', user.id)
            .eq('blocked_user_id', blockedUserId),
      );
      return false;
    }
    await _runAuthed(
      () => _client.from('user_blocks').insert({
        'user_id': user.id,
        'blocked_user_id': blockedUserId,
      }),
    );
    return true;
  }

  Future<void> submitPlaceStoryContribution({
    required String placeId,
    required String title,
    required String storyText,
    required String factType,
  }) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    final trimmedTitle = title.trim();
    final trimmedStory = storyText.trim();
    if (trimmedStory.length < 40) {
      throw Exception('Yer hikayesi en az 40 karakter olmalı.');
    }
    if (trimmedStory.length > 2000) {
      throw Exception('Yer hikayesi 2000 karakteri aşamaz.');
    }
    if (trimmedTitle.length > 140) {
      throw Exception('Kısa başlık 140 karakteri aşamaz.');
    }
    final inserted = await _runAuthed(
      () => _client
          .from('user_story_submissions')
          .insert({
            'place_id': placeId,
            'user_id': user.id,
            'title': trimmedTitle,
            'story_text': trimmedStory,
            'story_kind': factType,
            'status': 'pending',
          })
          .select('id,status,submitted_at')
          .maybeSingle(),
    );
    if (inserted == null) throw Exception('Moderasyon kaydı oluşturulamadı.');
    final status = inserted['status']?.toString() ?? '';
    if (status != 'pending') {
      throw Exception('Moderasyon kaydı oluşturulamadı.');
    }
  }

  Future<List<Map<String, dynamic>>> getApprovedPlaceStories(
    String placeId, {
    int limit = 8,
  }) async {
    final rows = await _runAuthed(
      () => _client
          .from('place_stories')
          .select(
            'id,place_id,author_user_id,title,story_text,story_kind,published_at,created_at',
          )
          .eq('place_id', placeId)
          .eq('is_published', true)
          .order('published_at', ascending: false)
          .order('created_at', ascending: false)
          .limit(limit),
    );
    final items = (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map(
          (row) => {
            ...row,
            'user_id': row['author_user_id'],
            'fact_type': row['story_kind'],
            'status': 'approved',
          },
        )
        .toList(growable: false);
    final userIds = items
        .map((row) => row['user_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (userIds.isEmpty) return items;
    final profiles = await _runAuthed(
      () => _client
          .from('profiles')
          .select('id,display_name')
          .inFilter('id', userIds),
    );
    final profileById = {
      for (final row in (profiles as List))
        row['id']?.toString() ?? '': row['display_name']?.toString(),
    };
    return items
        .map((row) {
          final rawName = profileById[row['user_id']?.toString() ?? ''] ?? '';
          // Mask emails and empty names for privacy — never show email addresses
          final displayName = (rawName.isEmpty || rawName.contains('@'))
              ? 'Elit routevia kullanıcısı'
              : rawName;
          return {...row, 'submitter_name': displayName};
        })
        .toList(growable: false);
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

    final coverPhoto = communityState?['cover_photo'] as String?;
    if ((media.isEmpty || media.every((m) => m.publicUrl != coverPhoto)) &&
        coverPhoto != null &&
        coverPhoto.isNotEmpty) {
      media = [
        MediaModel(
          storagePath: coverPhoto,
          publicUrl: coverPhoto,
          sortOrder: -1,
        ),
        ...media,
      ];
    }

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
      'province_name': row['city'],
      'district_name': row['district'],
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
        now.difference(cached.createdAt).inSeconds <= 120 &&
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
    try {
      final result = await _client.rpc(
        'get_poi_stats',
        params: {'p_poi_id': placeId},
      );
      reviews = Map<String, dynamic>.from((result as Map?) ?? const {});
    } catch (_) {}

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
      'recent_reviews': reviews['recent_reviews'] ?? const [],
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
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    if (rating < 1 || rating > 5) {
      throw Exception('Geçersiz puan');
    }

    await _runAuthed(
      () => _client.from('poi_reviews').upsert({
        'poi_id': placeId,
        'user_id': user.id,
        'rating': rating,
        'flags': flags,
        'comment_short': commentShort,
        'status': 'pending',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id,poi_id'),
    );

    final reviewsRaw = await _runAuthed(
      () => _client.rpc('get_poi_stats', params: {'p_poi_id': placeId}),
    );
    final reviews = Map<String, dynamic>.from(
      (reviewsRaw as Map?) ?? const <String, dynamic>{},
    );
    final state = await _runAuthed(
      () => _client
          .from('place_community_state')
          .select(
            'place_id,routevia_score,avg_rating,review_count,checkins_count,photo_count',
          )
          .eq('place_id', placeId)
          .maybeSingle(),
    );
    final merged = {
      ...Map<String, dynamic>.from((state as Map?) ?? const {}),
      ...reviews,
      'place_id': placeId,
      'recent_reviews': reviews['recent_reviews'] ?? const [],
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
    final rows = await _client
        .from('place_photos')
        .select(
          'id,place_id,user_id,image_url,storage_path,status,likes_count,reports_count,created_at,updated_at',
        )
        .eq('place_id', placeId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map(
          (e) => PlacePhotoModel.fromMap(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  Future<PlacePhotoModel> uploadPlacePhoto({
    required String placeId,
    required File file,
  }) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last.toLowerCase();
    final safeExt = switch (ext) {
      'png' => 'png',
      'jpg' => 'jpg',
      'jpeg' => 'jpeg',
      'webp' => 'webp',
      'heic' => 'heic',
      'heif' => 'heif',
      _ => 'jpg',
    };
    final contentType = switch (safeExt) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      'jpeg' => 'image/jpeg',
      _ => 'image/jpeg',
    };
    final objectPath =
        '${user.id}/$placeId/${DateTime.now().millisecondsSinceEpoch}.$safeExt';

    try {
      await _runAuthed(
        () => _client.storage
            .from('place-photos')
            .uploadBinary(
              objectPath,
              bytes,
              fileOptions: FileOptions(contentType: contentType, upsert: false),
            ),
      );
    } catch (_) {
      await _runAuthed(
        () => _client.storage
            .from('place-photos')
            .uploadBinary(
              objectPath,
              bytes,
              fileOptions: const FileOptions(
                contentType: 'application/octet-stream',
                upsert: false,
              ),
            ),
      );
    }

    final imageUrl = _client.storage
        .from('place-photos')
        .getPublicUrl(objectPath);
    late final Map<String, dynamic> inserted;
    try {
      final result = await _runAuthed(
        () => _client
            .from('place_photos')
            .insert({
              'place_id': placeId,
              'user_id': user.id,
              'image_url': imageUrl,
              'storage_path': objectPath,
              'status': 'pending',
              'likes_count': 0,
              'reports_count': 0,
            })
            .select(
              'id,place_id,user_id,image_url,storage_path,status,likes_count,reports_count,created_at,updated_at',
            )
            .maybeSingle(),
      );
      if (result == null) throw Exception('Fotoğraf DB kaydı oluşturulamadı.');
      inserted = Map<String, dynamic>.from(result as Map);
    } catch (e) {
      try {
        await _runAuthed(
          () => _client.storage.from('place-photos').remove([objectPath]),
        );
      } catch (_) {}
      rethrow;
    }

    // Mirror into user_photo_submissions so the unified admin moderation queue
    // picks it up. This is a best-effort insert; failures don't block the upload.
    try {
      await _runAuthed(
        () => _client.from('user_photo_submissions').insert({
          'place_id': placeId,
          'user_id': user.id,
          'bucket': 'place-photos',
          'object_path': objectPath,
          'caption': '',
          'status': 'pending',
          'submitted_at': DateTime.now().toUtc().toIso8601String(),
        }),
      );
    } catch (_) {}

    return PlacePhotoModel.fromMap(inserted);
  }

  Future<void> addPlaceCheckin(String placeId) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    try {
      await _runAuthed(
        () => _client.from('place_checkins').insert({
          'place_id': placeId,
          'user_id': user.id,
        }),
      );
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final isDuplicate =
          msg.contains('duplicate key') ||
          msg.contains('23505') ||
          msg.contains('place_checkins_user_place_day_uidx');
      if (!isDuplicate) rethrow;
    }
  }

  Future<Map<String, bool>> getPlaceSavedState(String placeId) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      return const {'favorite': false, 'checkin': false};
    }
    final results = await Future.wait([
      _runAuthed(
        () => _client
            .from('poi_signals')
            .select('id')
            .eq('user_id', user.id)
            .eq('poi_id', placeId)
            .eq('type', 'favorite')
            .limit(1),
      ),
      _runAuthed(
        () => _client
            .from('place_checkins')
            .select('id')
            .eq('user_id', user.id)
            .eq('place_id', placeId)
            .limit(1),
      ),
    ]);
    return {
      'favorite': (results[0] as List).isNotEmpty,
      'checkin': (results[1] as List).isNotEmpty,
    };
  }

  Future<bool> toggleFavorite(String placeId) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    final existing = await _runAuthed(
      () => _client
          .from('poi_signals')
          .select('id')
          .eq('user_id', user.id)
          .eq('poi_id', placeId)
          .eq('type', 'favorite')
          .limit(1),
    );
    if ((existing as List).isNotEmpty) {
      await _runAuthed(
        () => _client
            .from('poi_signals')
            .delete()
            .eq('user_id', user.id)
            .eq('poi_id', placeId)
            .eq('type', 'favorite'),
      );
      return false;
    }
    await submitUserSignal(placeId: placeId, type: 'favorite');
    return true;
  }

  Future<bool> toggleCheckin(String placeId) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    final existing = await _runAuthed(
      () => _client
          .from('place_checkins')
          .select('id')
          .eq('user_id', user.id)
          .eq('place_id', placeId)
          .limit(1),
    );
    if ((existing as List).isNotEmpty) {
      await _runAuthed(
        () => _client
            .from('place_checkins')
            .delete()
            .eq('user_id', user.id)
            .eq('place_id', placeId),
      );
      return false;
    }
    await addPlaceCheckin(placeId);
    return true;
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
    // Try provinces_with_coords view first (has lat/lng), fallback to table.
    Map<String, dynamic>? province = await _client
        .from('provinces_with_coords')
        .select('name,slug')
        .eq('slug', provinceSlug)
        .maybeSingle();
    province ??= await _client
        .from('provinces')
        .select('name,slug')
        .eq('slug', provinceSlug)
        .maybeSingle();
    // If still null, derive city name from fallback list.
    if (province == null) {
      final fallback = kFallbackProvinces.firstWhere(
        (p) => p['slug'] == provinceSlug,
        orElse: () => const <String, dynamic>{},
      );
      if (fallback.isEmpty) return const [];
      province = fallback;
    }
    final cityName = (province['name'] as String?) ?? '';
    if (cityName.isEmpty) return const [];

    // District-level scoping: when a district is selected we filter POIs to that
    // district; when only a province is selected we return the whole province.
    // (POI city/district are now boundary-accurate after the admin re-sync.)
    final districtFilter = (districtName ?? '').trim();
    final scopeToDistrict = districtFilter.isNotEmpty;

    var rawRows = await () {
      var q = _client
          .from('pois')
          .select('id,name,category,lat,lng,city,district,tags,source')
          .eq('provenance_verified', true)
          .eq('city', cityName);
      if (scopeToDistrict) q = q.ilike('district', districtFilter);
      return q.limit(1000);
    }();

    // Fallback: case-insensitive match in case of encoding mismatch.
    if ((rawRows as List).isEmpty) {
      rawRows = await () {
        var q = _client
            .from('pois')
            .select('id,name,category,lat,lng,city,district,tags,source')
            .ilike('city', cityName);
        if (scopeToDistrict) q = q.ilike('district', districtFilter);
        return q.limit(1000);
      }();
    }

    PlaceModel mapRow(Map<String, dynamic> row) {
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
        'source_kind': row['source'],
        'is_free': true,
        'media': const <Map<String, dynamic>>[],
        'app_score': 0,
        'app_rating': 0,
        'rating_count': 0,
      });
    }

    final places = (rawRows as List)
        .map((e) => mapRow(Map<String, dynamic>.from(e as Map)))
        .where((p) => !_isLodgingCategory(p.category))
        .where((p) => !_isSuppressedPlace(p))
        .toList();

    return _dedupePlacesByNameAndCoords(
      await _attachCommunityCoverMedia(
        _applyMustSeeOrdering(provinceSlug, places),
      ),
    );
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
      // Fetch all province POIs; district filtering is unreliable server-side
      final localRows = await _client
          .from('pois')
          .select('id,name,category,lat,lng,city,district,tags,source')
          .eq('provenance_verified', true)
          .eq('city', cityName)
          .limit(limit);

      final local = (localRows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map((row) {
            return PlaceModel.fromMap({
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
              'media': const <Map<String, dynamic>>[],
              'app_score': 0,
              'app_rating': 0,
              'rating_count': 0,
            });
          })
          .where((p) => !_isLodgingCategory(p.category))
          .where((p) => p.name.trim().isNotEmpty)
          .toList();
      final filteredLocal = local
          .where((p) => !_isSuppressedPlace(p))
          .toList(growable: false);
      if (filteredLocal.isNotEmpty) {
        return _dedupePlacesByNameAndCoords(
          await _attachCommunityCoverMedia(
            _applyMustSeeOrdering(provinceSlug, filteredLocal),
          ),
        );
      }
    }

    // National fallback: no province filter, no provenance_verified filter so
    // we always show something even if pois migration is incomplete.
    final nationalRows = await _client
        .from('pois')
        .select('id,name,category,lat,lng,city,district,tags,source')
        .limit(limit);

    final national = (nationalRows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map((row) {
          return PlaceModel.fromMap({
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
            'media': const <Map<String, dynamic>>[],
            'app_score': 0,
            'app_rating': 0,
            'rating_count': 0,
          });
        })
        .where((p) => !_isLodgingCategory(p.category))
        .where((p) => p.name.trim().isNotEmpty)
        .toList();
    return _dedupePlacesByNameAndCoords(
      await _attachCommunityCoverMedia(
        national.where((p) => !_isSuppressedPlace(p)).toList(growable: false),
      ),
    );
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

    final coords = <Map<String, dynamic>>[];
    for (final day in sourceTrip.daysPlan) {
      for (final stop in day.stops) {
        final lat = stop.place.lat;
        final lng = stop.place.lng;
        if (lat == null || lng == null) continue;
        coords.add({
          'lat': lat,
          'lng': lng,
          'mode': _normalizeTransportMode(
            stop.transportMode.isEmpty
                ? sourceTrip.transportMode
                : stop.transportMode,
          ),
        });
      }
    }

    if (coords.length < 2) {
      return const {
        'score': 100,
        'grade': 'A+',
        'distance_km': 0.0,
        'co2_kg': 0.0,
        'saved_vs_car_kg': 0.0,
        'tips': ['Eko skor su an hesaplanamadi.'],
      };
    }

    const co2GPerKm = <String, double>{
      'walk': 0,
      'bike': 5,
      'transit': 45,
      'car': 171,
    };

    var totalDistanceKm = 0.0;
    var totalCo2Kg = 0.0;
    final modeBreakdownKm = <String, double>{};
    final modeBreakdownCo2Kg = <String, double>{};

    for (var i = 1; i < coords.length; i++) {
      final prev = coords[i - 1];
      final cur = coords[i];
      final distanceKm = _distanceKmRepo(
        prev['lat'] as double,
        prev['lng'] as double,
        cur['lat'] as double,
        cur['lng'] as double,
      );
      final mode = (cur['mode'] as String?) ?? 'car';
      final gramsPerKm = co2GPerKm[mode] ?? co2GPerKm['car']!;
      final co2Kg = distanceKm * gramsPerKm / 1000;

      totalDistanceKm += distanceKm;
      totalCo2Kg += co2Kg;
      modeBreakdownKm[mode] = (modeBreakdownKm[mode] ?? 0) + distanceKm;
      modeBreakdownCo2Kg[mode] = (modeBreakdownCo2Kg[mode] ?? 0) + co2Kg;
    }

    final carBaselineKg = totalDistanceKm * (co2GPerKm['car']! / 1000);
    final ratio = carBaselineKg <= 0 ? 0 : totalCo2Kg / carBaselineKg;
    final score = ((1 - ratio) * 100).round().clamp(0, 100);
    final grade = score >= 85
        ? 'A+'
        : score >= 70
        ? 'A'
        : score >= 55
        ? 'B'
        : score >= 40
        ? 'C'
        : 'D';

    final transitKm = modeBreakdownKm['transit'] ?? 0;
    final walkBikeKm =
        (modeBreakdownKm['walk'] ?? 0) + (modeBreakdownKm['bike'] ?? 0);
    final tips = <String>[];
    if (walkBikeKm < totalDistanceKm * 0.25) {
      tips.add(
        'Kisa etaplari yuruyus veya bisiklet ile degistirerek skoru yukseltebilirsin.',
      );
    }
    if (transitKm < totalDistanceKm * 0.2) {
      tips.add(
        'Toplu tasima payini arttirmak karbon ayak izini belirgin dusurur.',
      );
    }
    if ((modeBreakdownKm['car'] ?? 0) > totalDistanceKm * 0.6) {
      tips.add('Arac kullanimini azaltmak icin duraklari bolge bazli grupla.');
    }
    if (tips.isEmpty) {
      tips.add('Harika denge. Bu rota dusuk karbon profiline yakin.');
    }

    return {
      'score': score,
      'grade': grade,
      'distance_km': double.parse(totalDistanceKm.toStringAsFixed(2)),
      'co2_kg': double.parse(totalCo2Kg.toStringAsFixed(3)),
      'car_baseline_kg': double.parse(carBaselineKg.toStringAsFixed(3)),
      'saved_vs_car_kg': double.parse(
        math.max(0, carBaselineKg - totalCo2Kg).toStringAsFixed(3),
      ),
      'mode_breakdown_km': modeBreakdownKm.map(
        (key, value) => MapEntry(key, double.parse(value.toStringAsFixed(2))),
      ),
      'mode_breakdown_co2_kg': modeBreakdownCo2Kg.map(
        (key, value) => MapEntry(key, double.parse(value.toStringAsFixed(3))),
      ),
      'tips': tips,
    };
  }

  Future<Map<String, String>> _getCommunityCoverPhotos(
    List<String> placeIds,
  ) async {
    final normalizedIds = placeIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalizedIds.isEmpty) return const {};

    final covers = <String, String>{};
    try {
      final stateRows = await _client
          .from('place_community_state')
          .select('place_id,cover_photo')
          .inFilter('place_id', normalizedIds);
      for (final raw in (stateRows as List)) {
        final row = Map<String, dynamic>.from(raw as Map);
        final placeId = row['place_id']?.toString() ?? '';
        final cover = row['cover_photo']?.toString() ?? '';
        if (placeId.isNotEmpty && cover.isNotEmpty) {
          covers[placeId] = cover;
        }
      }
    } catch (_) {}

    final missingIds = normalizedIds
        .where((id) => !covers.containsKey(id))
        .toList(growable: false);
    if (missingIds.isEmpty) return covers;

    // Check place_images (new unified schema — populated when admin approves via RPC)
    try {
      final imageRows = await _client
          .from('place_images')
          .select('place_id,bucket,object_path,created_at')
          .inFilter('place_id', missingIds)
          .eq('is_published', true)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(missingIds.length * 4);
      for (final raw in (imageRows as List)) {
        final row = Map<String, dynamic>.from(raw as Map);
        final placeId = row['place_id']?.toString() ?? '';
        if (placeId.isEmpty || covers.containsKey(placeId)) continue;
        final bucket = row['bucket']?.toString() ?? 'community-photos';
        final objPath = row['object_path']?.toString() ?? '';
        if (objPath.isEmpty) continue;
        final publicUrl = _client.storage.from(bucket).getPublicUrl(objPath);
        if (publicUrl.isNotEmpty) covers[placeId] = publicUrl;
      }
    } catch (_) {}

    // Fallback: check legacy place_photos table (pre-unified schema)
    final stillMissing = missingIds
        .where((id) => !covers.containsKey(id))
        .toList(growable: false);
    if (stillMissing.isNotEmpty) {
      try {
        final photoRows = await _client
            .from('place_photos')
            .select('place_id,image_url,created_at,status')
            .inFilter('place_id', stillMissing)
            .eq('status', 'approved')
            .order('created_at', ascending: false)
            .limit(stillMissing.length * 4);
        for (final raw in (photoRows as List)) {
          final row = Map<String, dynamic>.from(raw as Map);
          final placeId = row['place_id']?.toString() ?? '';
          final imageUrl = row['image_url']?.toString() ?? '';
          if (placeId.isEmpty ||
              imageUrl.isEmpty ||
              covers.containsKey(placeId)) {
            continue;
          }
          covers[placeId] = imageUrl;
        }
      } catch (_) {}
    }

    return covers;
  }

  Future<List<PlaceModel>> _attachCommunityCoverMedia(
    List<PlaceModel> places,
  ) async {
    if (places.isEmpty) return places;
    final coverById = await _getCommunityCoverPhotos(
      places.map((place) => place.id).toList(growable: false),
    );
    if (coverById.isEmpty) return places;
    return places
        .map((place) {
          final cover = coverById[place.id];
          if (cover == null || cover.isEmpty) return place;
          final alreadyIncluded = place.media.any(
            (media) => media.publicUrl == cover,
          );
          if (alreadyIncluded && place.media.isNotEmpty) return place;
          return place.copyWith(
            media: [
              MediaModel(storagePath: cover, publicUrl: cover, sortOrder: -1),
              ...place.media,
            ],
          );
        })
        .toList(growable: false);
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

    final rows = await _client
        .from('poi_live_status')
        .select(
          'poi_id,crowded_score,family_score,sunset_score,quiet_score,tags,confidence,last_event_at,updated_at',
        )
        .inFilter('poi_id', ids)
        .order('updated_at', ascending: false)
        .limit(ids.length);
    final items = (rows as List).map((raw) {
      final row = Map<String, dynamic>.from(raw as Map);
      final rawTags = ((row['tags'] as List?) ?? const [])
          .map((v) => v.toString())
          .where((v) => v.isNotEmpty)
          .toList();
      final crowdedScore = (row['crowded_score'] as num?)?.toDouble() ?? 0;
      final familyScore = (row['family_score'] as num?)?.toDouble() ?? 0;
      final sunsetScore = (row['sunset_score'] as num?)?.toDouble() ?? 0;
      final quietScore = (row['quiet_score'] as num?)?.toDouble() ?? 0;
      final confidence = (row['confidence'] as num?)?.toDouble() ?? 0;

      var tags = <String>[];
      if (confidence >= 35) {
        if (crowdedScore >= 45) tags.add('kalabalik');
        if (familyScore >= 40) tags.add('aile_uygun');
        if (sunsetScore >= 40) tags.add('gun_batimi');
        if (quietScore >= 45) tags.add('sessiz');
        if (tags.isEmpty) tags = rawTags;
      }
      if (confidence < 55 && tags.length > 2) {
        tags = tags.take(2).toList();
      }

      final tagLabels = tags
          .map(
            (t) => t == 'kalabalik'
                ? 'kalabalık'
                : t == 'aile_uygun'
                ? 'aile uygun'
                : t == 'gun_batimi'
                ? 'gün batımı'
                : t == 'sessiz'
                ? 'sessiz'
                : t,
          )
          .toList();

      return {
        'place_id': row['poi_id'] as String? ?? '',
        'tags': tags,
        'tag_labels': tagLabels,
        'crowded_score': crowdedScore,
        'family_score': familyScore,
        'sunset_score': sunsetScore,
        'quiet_score': quietScore,
        'confidence': confidence,
        'last_event_at': row['last_event_at'],
      };
    }).toList();
    return {for (final it in items) (it['place_id'] as String): it};
  }

  Future<Map<String, dynamic>> optimizeTripPlanV2({
    required TripPlan plan,
  }) async {
    var premium = false;
    try {
      final entitlements = await getEntitlements();
      final now = DateTime.now().toUtc();
      premium = entitlements.any((e) {
        final key = e['entitlement_key'] as String?;
        if (key != 'routevia_pro') return false;
        final ex = DateTime.tryParse((e['expires_at'] as String?) ?? '');
        return ex != null && ex.isAfter(now);
      });
    } catch (_) {
      premium = false;
    }

    try {
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
    } catch (_) {
      return {'plan': plan, 'premium_used': false, 'reason': 'fallback'};
    }
  }

  Future<List<Map<String, dynamic>>> getSmartSeasonSuggestions({
    String? provinceSlug,
    String? districtName,
    int limit = 10,
  }) async {
    try {
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
      final items = ((data['items'] as List?) ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final coverById = await _getCommunityCoverPhotos(
        items
            .map((item) => item['id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toList(),
      );
      final filtered = items
          .where(
            (item) => !_hasLodgingSignal(
              name: item['name']?.toString() ?? '',
              category: item['category']?.toString() ?? '',
              tags: ((item['tags'] as List?) ?? const []),
            ),
          )
          .toList();
      return _applyMustSeeOrderingToMapItems(
            provinceSlug ?? '',
            _dedupeMapItemsByNameAndCoords(filtered),
          )
          .map(
            (item) => {
              ...item,
              'cover_photo': coverById[item['id']?.toString() ?? ''],
            },
          )
          .toList();
    } catch (_) {
      final month = DateTime.now().month;
      final seasonalCategoryByMonth = <int, List<String>>{
        1: ['museum', 'historical', 'cafe'],
        2: ['museum', 'historical', 'cafe'],
        3: ['nature', 'historical', 'viewpoint'],
        4: ['nature', 'viewpoint', 'beach'],
        5: ['beach', 'nature', 'viewpoint'],
        6: ['beach', 'nature', 'activity'],
        7: ['beach', 'nature', 'waterfall'],
        8: ['beach', 'nature', 'waterfall'],
        9: ['nature', 'historical', 'viewpoint'],
        10: ['historical', 'museum', 'nature'],
        11: ['museum', 'historical', 'cafe'],
        12: ['museum', 'historical', 'cafe'],
      };
      final seasonalCats =
          seasonalCategoryByMonth[month] ?? ['nature', 'historical', 'cafe'];

      String? cityName;
      if (provinceSlug != null && provinceSlug.isNotEmpty) {
        final province = await _client
            .from('provinces')
            .select('name')
            .eq('slug', provinceSlug)
            .maybeSingle();
        cityName = (province as Map?)?['name']?.toString();
      }

      dynamic poiQuery = _client
          .from('pois')
          .select('id,name,category,city,district,lat,lng,tags')
          .eq('provenance_verified', true)
          .inFilter('category', seasonalCats)
          .limit(300);
      if (cityName != null && cityName.isNotEmpty) {
        poiQuery = poiQuery.ilike('city', cityName);
      }
      if (districtName != null && districtName.isNotEmpty) {
        poiQuery = poiQuery.ilike('district', districtName);
      }

      final pois = ((await poiQuery) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final ids = pois
          .map((p) => p['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      final trustRows = ids.isEmpty
          ? const <Map<String, dynamic>>[]
          : ((await _client
                        .from('poi_trust_metrics')
                        .select('poi_id,trust_score')
                        .inFilter('poi_id', ids))
                    as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
      final liveRows = ids.isEmpty
          ? const <Map<String, dynamic>>[]
          : ((await _client
                        .from('poi_live_status')
                        .select(
                          'poi_id,sunset_score,crowded_score,quiet_score,tags,confidence',
                        )
                        .inFilter('poi_id', ids))
                    as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
      final trustById = {
        for (final row in trustRows)
          row['poi_id']?.toString() ?? '':
              (row['trust_score'] as num?)?.toDouble() ?? 0,
      };
      final liveById = {
        for (final row in liveRows) row['poi_id']?.toString() ?? '': row,
      };
      final coverById = await _getCommunityCoverPhotos(ids);

      final items = pois
          .map((poi) {
            final id = poi['id']?.toString() ?? '';
            final trust = trustById[id] ?? 0;
            final live = liveById[id] ?? const <String, dynamic>{};
            final sunset = (live['sunset_score'] as num?)?.toDouble() ?? 0;
            final quiet = (live['quiet_score'] as num?)?.toDouble() ?? 0;
            final crowded = (live['crowded_score'] as num?)?.toDouble() ?? 0;
            final confidence = (live['confidence'] as num?)?.toDouble() ?? 0;
            final score =
                trust * 0.60 +
                sunset * 0.16 +
                quiet * 0.10 -
                crowded * 0.06 +
                confidence * 0.10 +
                12;
            return {
              'id': id,
              'name': poi['name']?.toString() ?? '',
              'category': poi['category']?.toString() ?? 'activity',
              'city': poi['city']?.toString() ?? '',
              'district': poi['district']?.toString() ?? '',
              'lat': (poi['lat'] as num?)?.toDouble(),
              'lng': (poi['lng'] as num?)?.toDouble(),
              'tags': ((poi['tags'] as List?) ?? const []).cast<dynamic>(),
              'season_score': double.parse(score.toStringAsFixed(2)),
              'trust_score': double.parse(trust.toStringAsFixed(2)),
              'event_score': 0,
              'weather_score': 70,
              'live_tags': ((live['tags'] as List?) ?? const [])
                  .cast<dynamic>(),
              'cover_photo': coverById[id],
              'why': 'Mevsim + trust + canli sinyal',
            };
          })
          .where(
            (item) => !_hasLodgingSignal(
              name: item['name']?.toString() ?? '',
              category: item['category']?.toString() ?? '',
              tags: ((item['tags'] as List?) ?? const []),
            ),
          )
          .where((item) => item['lat'] != null && item['lng'] != null)
          .toList();
      return _applyMustSeeOrderingToMapItems(
        provinceSlug ?? '',
        _dedupeMapItemsByNameAndCoords(items),
      ).take(limit).toList();
    }
  }

  Future<List<Map<String, dynamic>>> getTrendMapItems({
    String? provinceSlug,
    int limit = 120,
  }) async {
    String? cityName;
    if (provinceSlug != null && provinceSlug.isNotEmpty) {
      try {
        final province = await _client
            .from('provinces')
            .select('name')
            .eq('slug', provinceSlug)
            .maybeSingle();
        cityName = (province as Map?)?['name']?.toString();
      } catch (_) {
        cityName = null;
      }
    }

    dynamic poiQuery = _client
        .from('pois')
        .select('id,name,category,city,district,lat,lng,tags')
        .eq('provenance_verified', true)
        .limit(limit.clamp(10, 300));
    if (cityName != null && cityName.isNotEmpty) {
      poiQuery = poiQuery.ilike('city', cityName);
    }

    final pois = ((await poiQuery) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final ids = pois
        .map((p) => p['id']?.toString() ?? '')
        .where((v) => v.isNotEmpty)
        .toList();
    List<Map<String, dynamic>> trustRows = const <Map<String, dynamic>>[];
    if (ids.isNotEmpty) {
      try {
        trustRows =
            ((await _client
                        .from('poi_trust_metrics')
                        .select('poi_id,trust_score')
                        .inFilter('poi_id', ids))
                    as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
      } catch (_) {
        trustRows = const <Map<String, dynamic>>[];
      }
    }
    List<Map<String, dynamic>> liveRows = const <Map<String, dynamic>>[];
    if (ids.isNotEmpty) {
      try {
        liveRows =
            ((await _client
                        .from('poi_live_status')
                        .select(
                          'poi_id,crowded_score,sunset_score,family_score,quiet_score,confidence',
                        )
                        .inFilter('poi_id', ids))
                    as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
      } catch (_) {
        liveRows = const <Map<String, dynamic>>[];
      }
    }

    final trustById = {
      for (final row in trustRows)
        row['poi_id']?.toString() ?? '':
            (row['trust_score'] as num?)?.toDouble() ?? 0,
    };
    final liveById = {
      for (final row in liveRows) row['poi_id']?.toString() ?? '': row,
    };

    final items = pois
        .where(
          (poi) => !_hasLodgingSignal(
            name: poi['name']?.toString() ?? '',
            category: poi['category']?.toString() ?? '',
            tags: ((poi['tags'] as List?) ?? const []),
          ),
        )
        .where((poi) => !_isSuppressedMapItem(poi))
        .map((poi) {
          final id = poi['id']?.toString() ?? '';
          final trust = trustById[id] ?? 0;
          final live = liveById[id] ?? const <String, dynamic>{};
          final crowded = (live['crowded_score'] as num?)?.toDouble() ?? 0;
          final sunset = (live['sunset_score'] as num?)?.toDouble() ?? 0;
          final family = (live['family_score'] as num?)?.toDouble() ?? 0;
          final quiet = (live['quiet_score'] as num?)?.toDouble() ?? 0;
          final confidence = (live['confidence'] as num?)?.toDouble() ?? 0;
          final trendScore =
              trust * 0.55 +
              crowded * 0.15 +
              sunset * 0.10 +
              family * 0.10 +
              quiet * 0.05 +
              confidence * 0.05;

          return {
            'id': id,
            'name': poi['name']?.toString() ?? '',
            'category': poi['category']?.toString() ?? 'activity',
            'city': poi['city']?.toString() ?? '',
            'district': poi['district']?.toString() ?? '',
            'lat': (poi['lat'] as num?)?.toDouble(),
            'lng': (poi['lng'] as num?)?.toDouble(),
            'trend_score': double.parse(trendScore.toStringAsFixed(2)),
            'trust_score': double.parse(trust.toStringAsFixed(2)),
          };
        })
        .where((item) => item['lat'] != null && item['lng'] != null)
        .toList();

    return _applyMustSeeOrderingToMapItems(
      provinceSlug ?? '',
      _dedupeMapItemsByNameAndCoords(items),
    );
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
        .where((place) => !_isSuppressedPlace(place))
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
    if (mode == 'provinces') {
      final rows = await _runAuthed(
        () => _client
            .from('provinces')
            .select('id,name,slug,plate_no')
            .order('plate_no'),
      );
      return (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    if (mode == 'districts') {
      String? resolvedProvinceId = provinceId;
      if (resolvedProvinceId == null && provinceSlug != null) {
        final province = await _runAuthed(
          () => _client
              .from('provinces')
              .select('id')
              .eq('slug', provinceSlug)
              .maybeSingle(),
        );
        resolvedProvinceId = province?['id'] as String?;
      }
      if (resolvedProvinceId == null) return const [];
      final rows = await _runAuthed(
        () => _client
            .from('districts')
            .select('id,name,slug,province_id')
            .eq('province_id', resolvedProvinceId!)
            .order('name'),
      );
      return (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    String? resolvedProvinceId = provinceId;
    if (resolvedProvinceId == null && provinceSlug != null) {
      try {
        final province = await _runAuthed(
          () => _client
              .from('provinces')
              .select('id')
              .eq('slug', provinceSlug)
              .maybeSingle(),
        );
        resolvedProvinceId = province?['id'] as String?;
      } catch (_) {
        resolvedProvinceId = null;
      }
    }

    final safeLimit = limit.clamp(1, 500);

    Future<List<Map<String, dynamic>>> loadFromPlacesCleanWithCoords() async {
      dynamic q = _client
          .from('places_clean_with_coords')
          .select(
            'id,province_id,district_id,name,slug,category,short_summary,best_time,duration_min,tags,popularity_score,lat,lng,app_rating,rating_count',
          )
          .order('popularity_score', ascending: false)
          .limit(safeLimit);

      if (resolvedProvinceId != null) {
        q = q.eq('province_id', resolvedProvinceId);
      }
      if (query != null && query.trim().isNotEmpty) {
        final s = query.trim();
        q = q.or('name.ilike.%$s%,slug.ilike.%$s%');
      }

      final rows = await _runAuthed(() => q);
      return (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    Future<List<Map<String, dynamic>>> loadFromPoisFallback() async {
      String? provinceName;
      if (resolvedProvinceId != null) {
        try {
          final province = await _runAuthed(
            () => _client
                .from('provinces')
                .select('name,slug')
                .eq('id', resolvedProvinceId!)
                .maybeSingle(),
          );
          provinceName = province?['name'] as String?;
        } catch (_) {
          provinceName = null;
        }
      }

      dynamic q = _client
          .from('pois')
          .select('id,name,category,city,district,lat,lng,tags,updated_at')
          .order('updated_at', ascending: false)
          .limit(safeLimit);

      if (provinceName != null && provinceName.trim().isNotEmpty) {
        q = q.ilike('city', provinceName.trim());
      }
      if (query != null && query.trim().isNotEmpty) {
        final s = query.trim();
        q = q.or('name.ilike.%$s%,category.ilike.%$s%,district.ilike.%$s%');
      }

      final rows = await _runAuthed(() => q);
      return (rows as List)
          .map((raw) => Map<String, dynamic>.from(raw as Map))
          .map(
            (row) => {
              'id': row['id'],
              'province_id': resolvedProvinceId,
              'district_id': null,
              'province_slug': provinceSlug,
              'district_slug': null,
              'name': row['name'],
              'slug': row['id'],
              'category': row['category'],
              'short_summary': row['district'] ?? row['city'] ?? '',
              'best_time': 'day',
              'duration_min': 60,
              'tags': row['tags'] ?? const [],
              'popularity_score': 0,
              'lat': row['lat'],
              'lng': row['lng'],
              'app_rating': null,
              'rating_count': null,
              'district_name': row['district'],
              'is_published': true,
            },
          )
          .toList(growable: false);
    }

    try {
      return await loadFromPlacesCleanWithCoords();
    } catch (_) {
      try {
        return await loadFromPoisFallback();
      } catch (_) {
        return const [];
      }
    }
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

  Future<List<Map<String, dynamic>>> adminSuggestions({
    String status = 'pending',
    String? provinceSlug,
    int limit = 100,
  }) async {
    String? provinceId;
    if (provinceSlug != null) {
      final province = await _runAuthed(
        () => _client
            .from('provinces')
            .select('id')
            .eq('slug', provinceSlug)
            .maybeSingle(),
      );
      provinceId = province?['id'] as String?;
    }

    // ── Query new unified table ────────────────────────────────────────
    List<Map<String, dynamic>> rows = [];
    try {
      dynamic q = _client
          .from('user_place_submissions')
          .select(
            'id,user_id,city_id,legacy_province_id,legacy_district_id,place_name,category_key,tag_slugs,short_note,description,source_url,lat,lng,cover_bucket,cover_object_path,status,admin_note,rejection_reason,approved_place_id,submitted_at,reviewed_at,created_at',
          )
          .order('submitted_at', ascending: false)
          .order('created_at', ascending: false)
          .limit(limit.clamp(1, 500));
      if (status != 'all') q = q.eq('status', status);
      if (provinceId != null) q = q.eq('legacy_province_id', provinceId);
      rows = ((await _runAuthed(() => q)) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      // new table may not exist yet — fall through to legacy table
    }

    // ── Query legacy table and merge (deduplicating by id) ────────────
    try {
      dynamic legacyQ = _client
          .from('place_suggestions')
          .select(
            'id,user_id,province_id,district_id,suggested_name,suggested_category,suggested_tags,short_note,status,admin_note,lat,lng,source_url,created_at,reviewed_at',
          )
          .order('created_at', ascending: false)
          .limit(limit.clamp(1, 500));
      if (status != 'all') legacyQ = legacyQ.eq('status', status);
      if (provinceId != null) legacyQ = legacyQ.eq('province_id', provinceId);
      final legacyRaw = ((await _runAuthed(() => legacyQ)) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      // Normalise legacy rows to match new schema shape
      final existingIds = rows.map((r) => r['id'] as String?).toSet();
      for (final r in legacyRaw) {
        final id = r['id'] as String?;
        if (id == null || existingIds.contains(id)) continue;
        rows.add({
          ...r,
          'place_name': r['suggested_name'],
          'category_key': r['suggested_category'],
          'tag_slugs': r['suggested_tags'],
          'legacy_province_id': r['province_id'],
          'legacy_district_id': r['district_id'],
          '_source': 'legacy',
        });
      }
    } catch (_) {
      // legacy table may have been dropped — ignore
    }

    if (rows.isEmpty) return const [];

    // ── Enrich with province / district / profile names ───────────────
    final provinceIds = rows
        .map(
          (row) => (row['legacy_province_id'] ?? row['province_id']) as String?,
        )
        .whereType<String>()
        .toSet()
        .toList();
    final districtIds = rows
        .map(
          (row) => (row['legacy_district_id'] ?? row['district_id']) as String?,
        )
        .whereType<String>()
        .toSet()
        .toList();
    final userIds = rows
        .map((row) => row['user_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    final provinces = provinceIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : ((await _runAuthed(
                    () => _client
                        .from('provinces')
                        .select('id,name,slug')
                        .inFilter('id', provinceIds),
                  ))
                  as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
    final districts = districtIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : ((await _runAuthed(
                    () => _client
                        .from('districts')
                        .select('id,name,slug')
                        .inFilter('id', districtIds),
                  ))
                  as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
    final profiles = userIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : ((await _runAuthed(
                    () => _client
                        .from('profiles')
                        .select('id,display_name')
                        .inFilter('id', userIds),
                  ))
                  as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

    final provinceById = {for (final p in provinces) p['id'] as String: p};
    final districtById = {for (final d in districts) d['id'] as String: d};
    final profileById = {for (final p in profiles) p['id'] as String: p};

    return rows.map((row) {
      final provinceIdKey =
          (row['legacy_province_id'] ?? row['province_id']) as String?;
      final districtIdKey =
          (row['legacy_district_id'] ?? row['district_id']) as String?;
      final province = provinceIdKey != null
          ? provinceById[provinceIdKey]
          : null;
      final district = districtIdKey != null
          ? districtById[districtIdKey]
          : null;
      final profile = profileById[row['user_id'] as String? ?? ''];
      return {
        ...row,
        'suggested_name': row['place_name'] ?? row['suggested_name'],
        'suggested_category': row['category_key'] ?? row['suggested_category'],
        'suggested_tags': row['tag_slugs'] ?? row['suggested_tags'] ?? const [],
        'province_name': province?['name'],
        'province_slug': province?['slug'],
        'district_name': district?['name'],
        'district_slug': district?['slug'],
        'submitter_name': profile?['display_name'],
      };
    }).toList();
  }

  Future<void> adminReviewSuggestion({
    required String suggestionId,
    required String decision,
    String? adminNote,
  }) async {
    // Try unified RPC first (new schema, requires moderation_queue row).
    bool rpcSucceeded = false;
    try {
      await _runAuthed(
        () => _client.rpc(
          'admin_moderate_submission',
          params: {
            'p_submission_type': 'place_submission',
            'p_submission_id': suggestionId,
            'p_decision': decision,
            'p_admin_note': adminNote?.trim().isEmpty ?? true
                ? null
                : adminNote!.trim(),
            'p_rejection_reason': decision == 'rejected'
                ? (adminNote?.trim().isEmpty ?? true
                      ? 'Rejected by admin'
                      : adminNote!.trim())
                : null,
            'p_publish': decision == 'approved',
            'p_set_cover': false,
          },
        ),
      );
      rpcSucceeded = true;
    } catch (_) {}
    if (rpcSucceeded) return;

    // Fallback 1: direct update on user_place_submissions (new table, no moderation_queue).
    bool directNewSucceeded = false;
    try {
      await _runAuthed(
        () => _client
            .from('user_place_submissions')
            .update({
              'status': decision,
              'admin_note': adminNote?.trim().isEmpty ?? true
                  ? null
                  : adminNote!.trim(),
              'rejection_reason': decision == 'rejected'
                  ? (adminNote?.trim().isEmpty ?? true
                        ? 'Rejected by admin'
                        : adminNote!.trim())
                  : null,
              'reviewed_at': DateTime.now().toUtc().toIso8601String(),
              'reviewed_by': _client.auth.currentUser?.id,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', suggestionId),
      );
      directNewSucceeded = true;
    } catch (_) {}
    if (directNewSucceeded) return;

    // Fallback 2: legacy place_suggestions table (old submissions).
    await _runAuthed(
      () => _client
          .from('place_suggestions')
          .update({
            'status': decision,
            'admin_note': adminNote?.trim().isEmpty ?? true
                ? null
                : adminNote!.trim(),
            'reviewed_by': _client.auth.currentUser?.id,
            'reviewed_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', suggestionId),
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
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    final province = await _runAuthed(
      () => _client
          .from('provinces')
          .select('id')
          .eq('slug', provinceSlug)
          .maybeSingle(),
    );
    if (province == null) throw Exception('İl bulunamadı: $provinceSlug');
    String? districtId;
    if (districtSlug != null && districtSlug.trim().isNotEmpty) {
      final district = await _runAuthed(
        () => _client
            .from('districts')
            .select('id')
            .eq('province_id', province['id'] as String)
            .eq('slug', districtSlug)
            .maybeSingle(),
      );
      districtId = district?['id'] as String?;
    }
    final inserted = await _runAuthed(
      () => _client
          .from('place_suggestions')
          .insert({
            'user_id': user.id,
            'province_id': province['id'] as String,
            'district_id': districtId,
            'suggested_name': suggestedName.trim(),
            'suggested_category': suggestedCategory,
            'suggested_tags': suggestedTags,
            'short_note': shortNote.trim(),
            'lat': lat,
            'lng': lng,
            'source_url': sourceUrl?.trim().isEmpty ?? true
                ? null
                : sourceUrl!.trim(),
            'status': 'pending',
          })
          .select('id,status,created_at')
          .maybeSingle(),
    );
    if (inserted == null) throw Exception('Öneri gönderilemedi.');
    return Map<String, dynamic>.from(inserted as Map);
  }

  Future<String> uploadSuggestionImage(File file) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    return _runAuthed(() async {
      final ext = file.path.split('.').last.toLowerCase();
      final safeExt = ext == 'png' ? 'png' : 'jpg';
      final contentType = safeExt == 'png' ? 'image/png' : 'image/jpeg';
      final objectPath =
          '${user.id}/suggestions/${DateTime.now().millisecondsSinceEpoch}.$safeExt';
      final bytes = await file.readAsBytes();
      await _client.storage
          .from('place-photos')
          .uploadBinary(
            objectPath,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: false),
          );
      return _client.storage.from('place-photos').getPublicUrl(objectPath);
    });
  }

  Future<List<Map<String, dynamic>>> adminGetCoordinateQueue({
    String status = 'pending',
    int limit = 100,
    String? provinceSlug,
  }) async {
    List<Map<String, dynamic>> queue;
    List<Map<String, dynamic>> places;
    if (provinceSlug != null && provinceSlug.trim().isNotEmpty) {
      final province = await _runAuthed(
        () => _client
            .from('provinces')
            .select('id,name,slug')
            .eq('slug', provinceSlug.trim())
            .maybeSingle(),
      );
      if (province == null) return const [];
      final provinceId = province['id'] as String;
      final placeRows = await _runAuthed(
        () => _client
            .from('places_clean_with_coords')
            .select(
              'id,name,slug,category,short_summary,lat,lng,coordinate_source,coordinate_verified_at,coordinate_verified_by,province_id',
            )
            .eq('province_id', provinceId)
            .limit(1500),
      );
      places = (placeRows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final placeIds = places
          .map((item) => item['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      if (placeIds.isEmpty) return const [];
      final queueRows = await _runAuthed(
        () => _client
            .from('place_coordinate_verification_queue')
            .select(
              'place_id,status,reason,source_snapshot,note,created_at,updated_at,reviewed_at,reviewed_by',
            )
            .eq('status', status)
            .inFilter('place_id', placeIds)
            .order('created_at', ascending: false)
            .limit(limit),
      );
      queue = (queueRows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else {
      final queueRows = await _runAuthed(
        () => _client
            .from('place_coordinate_verification_queue')
            .select(
              'place_id,status,reason,source_snapshot,note,created_at,updated_at,reviewed_at,reviewed_by',
            )
            .eq('status', status)
            .order('created_at', ascending: false)
            .limit(limit),
      );
      queue = (queueRows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final placeIds = queue
          .map((item) => item['place_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      if (placeIds.isEmpty) return queue;
      final placeRows = await _runAuthed(
        () => _client
            .from('places_clean_with_coords')
            .select(
              'id,name,slug,category,short_summary,lat,lng,coordinate_source,coordinate_verified_at,coordinate_verified_by,province_id',
            )
            .inFilter('id', placeIds),
      );
      places = (placeRows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    final placeIds = queue
        .map((item) => item['place_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    if (placeIds.isEmpty) return queue;
    final placeRows = places
        .where((row) => placeIds.contains(row['id']?.toString() ?? ''))
        .toList(growable: false);
    final provinceIds = (placeRows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map((row) => row['province_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    final provinceRows = provinceIds.isEmpty
        ? const []
        : await _runAuthed(
            () => _client
                .from('provinces')
                .select('id,name,slug')
                .inFilter('id', provinceIds),
          );

    final placeById = {
      for (final raw in (placeRows as List))
        raw['id'].toString(): Map<String, dynamic>.from(raw as Map),
    };
    final provinceById = {
      for (final raw in provinceRows)
        raw['id'].toString(): Map<String, dynamic>.from(raw as Map),
    };

    return queue
        .map((item) {
          final place =
              placeById[item['place_id']?.toString() ?? ''] ?? const {};
          final province =
              provinceById[place['province_id']?.toString() ?? ''] ?? const {};
          return {
            ...item,
            'place_name': place['name'],
            'place_slug': place['slug'],
            'place_category': place['category'],
            'place_summary': place['short_summary'],
            'lat': place['lat'],
            'lng': place['lng'],
            'coordinate_source': place['coordinate_source'],
            'coordinate_verified_at': place['coordinate_verified_at'],
            'coordinate_verified_by': place['coordinate_verified_by'],
            'province_name': province['name'],
            'province_slug': province['slug'],
          };
        })
        .toList(growable: false);
  }

  Future<void> adminMarkCoordinateVerified({
    required String placeId,
    required String coordinateSource,
    String? note,
  }) async {
    await _runAuthed(
      () => _client.rpc(
        'mark_place_coordinate_verified',
        params: {
          'p_place_id': placeId,
          'p_coordinate_source': coordinateSource,
          'p_verified_by': _client.auth.currentUser?.id ?? 'admin',
          'p_note': note?.trim().isEmpty == true ? null : note?.trim(),
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getEntitlements() async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) return const [];
    final rows = await _runAuthed(
      () => _client
          .from('user_entitlements')
          .select('entitlement_key,expires_at,created_at')
          .eq('user_id', user.id)
          .gte('expires_at', DateTime.now().toUtc().toIso8601String())
          .order('expires_at', ascending: false),
    );
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
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    final trimmed = message.trim();
    if (trimmed.length < 4) {
      throw Exception('Mesaj çok kısa');
    }
    if (trimmed.length > 1200) {
      throw Exception('Mesaj çok uzun');
    }
    if (rating != null && (rating < 1 || rating > 5)) {
      throw Exception('Puan 1-5 olmalı');
    }
    await _runAuthed(
      () => _client.from('feedback').insert({
        'user_id': user.id,
        'message': trimmed,
        'rating': rating,
      }),
    );
    await _safeLogEvent('rating_submitted', payload: {'rating': rating});
  }

  Future<Map<String, dynamic>> submitUserSignal({
    required String placeId,
    required String type,
    double? rating,
  }) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    if (type == 'favorite' || type == 'checkin') {
      try {
        await _runAuthed(
          () => _client.from('poi_signals').insert({
            'user_id': user.id,
            'poi_id': placeId,
            'type': type,
            'rating': null,
          }),
        );
      } catch (e) {
        final msg = e.toString().toLowerCase();
        final isDuplicate =
            msg.contains('duplicate key') ||
            msg.contains('23505') ||
            msg.contains('already exists') ||
            msg.contains('poi_signals_user_poi_once_uidx');
        if (!isDuplicate) rethrow;
      }
    } else {
      await _runAuthed(
        () => _client.from('poi_signals').insert({
          'user_id': user.id,
          'poi_id': placeId,
          'type': type,
          'rating': rating,
        }),
      );
    }

    final stats = await _runAuthed(
      () => _client.rpc('get_poi_stats', params: {'p_poi_id': placeId}),
    );
    return {
      'ok': true,
      'stats': Map<String, dynamic>.from((stats as Map?) ?? const {}),
    };
  }

  Future<void> logAppEvent(
    String eventName, {
    Map<String, dynamic> payload = const {},
  }) async {
    final consent = await _cache.getConsentPreferences();
    if (consent['analytics_enabled'] != true) return;
    try {
      final user = _client.auth.currentUser;
      if (user != null) {
        await _runAuthed(
          () => _client.from('app_events').insert({
            'user_id': user.id,
            'event_name': eventName,
            'payload': payload,
          }),
        );
        return;
      }
      await _invokeFunction(
        'log_app_event',
        body: {'event_name': eventName, 'payload': payload},
      );
    } catch (_) {}
  }

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final result = await _invokeFunction('get_user_stats', requireAuth: true);
      return Map<String, dynamic>.from((result.data as Map?) ?? const {});
    } catch (_) {
      await _ensureFreshSession();
      final user = _client.auth.currentUser;
      if (user == null) return const {};

      final favorites = await _runAuthed(
        () => _client
            .from('poi_signals')
            .select('id')
            .eq('user_id', user.id)
            .eq('type', 'favorite'),
      );
      final reviews = await _runAuthed(
        () => _client.from('poi_reviews').select('id').eq('user_id', user.id),
      );
      final checkins = await _runAuthed(
        () =>
            _client.from('place_checkins').select('id').eq('user_id', user.id),
      );
      final trips = await _runAuthed(
        () => _client.from('trips_clean').select('id').eq('user_id', user.id),
      );
      final reviewedPois = await _runAuthed(
        () => _client
            .from('poi_reviews')
            .select('poi_id, pois(city)')
            .eq('user_id', user.id),
      );

      final cities = <String>{};
      for (final raw in (reviewedPois as List)) {
        final row = Map<String, dynamic>.from(raw as Map);
        final poi = row['pois'] as Map?;
        final city = poi?['city']?.toString().trim();
        if (city != null && city.isNotEmpty) {
          cities.add(city);
        }
      }

      return {
        'checkins': (checkins as List).length,
        'favorites': (favorites as List).length,
        'reviews': (reviews as List).length,
        'trips': (trips as List).length,
        'cities_visited': cities.length,
        'top_city': cities.isEmpty ? null : cities.first,
        'category_breakdown': const <String, int>{},
      };
    }
  }

  Future<List<Map<String, dynamic>>> listSavedPlaces({
    required String type,
    int limit = 80,
  }) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }

    final normalizedType = type.trim().toLowerCase();
    if (normalizedType != 'favorite' && normalizedType != 'checkin') {
      throw ArgumentError.value(type, 'type', 'Unsupported saved place type');
    }

    final rawRows = normalizedType == 'favorite'
        ? await _runAuthed(
            () => _client
                .from('poi_signals')
                .select('poi_id,created_at')
                .eq('user_id', user.id)
                .eq('type', 'favorite')
                .order('created_at', ascending: false)
                .limit(limit),
          )
        : await _runAuthed(
            () => _client
                .from('place_checkins')
                .select('place_id,created_at')
                .eq('user_id', user.id)
                .order('created_at', ascending: false)
                .limit(limit * 2),
          );

    final seenPlaceIds = <String>{};
    final records = <Map<String, dynamic>>[];
    for (final raw in (rawRows as List)) {
      final row = Map<String, dynamic>.from(raw as Map);
      final placeId =
          (normalizedType == 'favorite' ? row['poi_id'] : row['place_id'])
              ?.toString();
      if (placeId == null || placeId.isEmpty || !seenPlaceIds.add(placeId)) {
        continue;
      }
      records.add({'place_id': placeId, 'saved_at': row['created_at']});
      if (records.length >= limit) break;
    }

    if (records.isEmpty) return const [];
    final placeIds = records
        .map((row) => row['place_id'] as String)
        .toList(growable: false);

    final placeRows = await _runAuthed(
      () => _client
          .from('places_clean_with_coords')
          .select(
            'id,province_id,district_id,name,slug,category,short_summary,best_time,duration_min,tags,popularity_score,lat,lng,app_rating,rating_count',
          )
          .inFilter('id', placeIds),
    );
    final placeById = <String, Map<String, dynamic>>{
      for (final raw in (placeRows as List))
        raw['id'].toString(): Map<String, dynamic>.from(raw as Map),
    };

    final stateRows = await _runAuthed(
      () => _client
          .from('place_community_state')
          .select(
            'place_id,cover_photo,routevia_score,avg_rating,review_count,checkins_count,photo_count',
          )
          .inFilter('place_id', placeIds),
    );
    final stateById = <String, Map<String, dynamic>>{
      for (final raw in (stateRows as List))
        raw['place_id'].toString(): Map<String, dynamic>.from(raw as Map),
    };

    final items = <Map<String, dynamic>>[];
    for (final record in records) {
      final placeId = record['place_id'] as String;
      final base = placeById[placeId];
      if (base == null) continue;
      final state = stateById[placeId] ?? const <String, dynamic>{};
      final coverPhoto = state['cover_photo']?.toString();
      final stats = {
        'place_id': placeId,
        'avg_rating': state['avg_rating'] ?? base['app_rating'] ?? 0,
        'review_count': state['review_count'] ?? base['rating_count'] ?? 0,
        'routevia_score': state['routevia_score'] ?? 0,
        'checkins_count': state['checkins_count'] ?? 0,
        'photo_count': state['photo_count'] ?? 0,
        'crowded_count': 0,
        'family_count': 0,
        'photo_spot_count': 0,
        'sunset_worthy_count': 0,
        'recent_reviews': const [],
      };
      final place = PlaceModel.fromMap({
        ...base,
        'media': coverPhoto == null || coverPhoto.isEmpty
            ? const []
            : [
                {
                  'storage_path': coverPhoto,
                  'public_url': coverPhoto,
                  'sort_order': 0,
                },
              ],
        'app_score': state['routevia_score'] ?? base['popularity_score'] ?? 0,
        'app_rating': state['avg_rating'] ?? base['app_rating'] ?? 0,
        'rating_count': state['review_count'] ?? base['rating_count'] ?? 0,
        'stats': stats,
      });
      items.add({
        'type': normalizedType,
        'saved_at': record['saved_at'],
        'place': place,
      });
    }

    return items;
  }

  Future<List<Map<String, dynamic>>> getMyPlaceReviews({
    int limit = 100,
  }) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) return const [];
    final rows = await _runAuthed(
      () => _client
          .from('poi_reviews')
          .select(
            'id,poi_id,rating,comment_short,flags,status,created_at,updated_at,'
            'pois(name,city,district)',
          )
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit),
    );
    return (rows as List).map((e) {
      final row = Map<String, dynamic>.from(e as Map);
      row['place_id'] = row['poi_id'];
      row['comment'] = row['comment_short'] ?? '';
      return row;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getMyPlacePhotos({int limit = 100}) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) return const [];
    final rows = await _runAuthed(
      () => _client
          .from('place_photos')
          .select(
            'id,place_id,image_url,storage_path,status,moderation_note,'
            'created_at,updated_at,pois(name,city,district)',
          )
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit),
    );
    return (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> deleteMyPlaceReview(String reviewId) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    await _runAuthed(
      () => _client
          .from('poi_reviews')
          .delete()
          .eq('id', reviewId)
          .eq('user_id', user.id),
    );
  }

  Future<void> deleteMyPlacePhoto(String photoId) async {
    await _ensureFreshSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('jwt expired');
    }
    final row = await _runAuthed(
      () => _client
          .from('place_photos')
          .select('storage_path')
          .eq('id', photoId)
          .eq('user_id', user.id)
          .maybeSingle(),
    );
    if (row == null) return;
    final storagePath = row['storage_path']?.toString();
    await _runAuthed(
      () => _client
          .from('place_photos')
          .delete()
          .eq('id', photoId)
          .eq('user_id', user.id),
    );
    if (storagePath != null && storagePath.trim().isNotEmpty) {
      try {
        await _runAuthed(
          () => _client.storage.from('place-photos').remove([storagePath]),
        );
      } catch (_) {}
    }
  }

  Future<void> deleteAccount() async {
    await _invokeFunction('delete_account', requireAuth: true);
  }

  Future<Map<String, dynamic>?> getTripById(String tripId) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _runAuthed(
      () => _client
          .from('trips_clean')
          .select(
            'id,days,transport_mode,pace,persona_mode,preferences,created_at,province_id',
          )
          .eq('id', tripId)
          .eq('user_id', user.id)
          .maybeSingle(),
    );
    if (row == null) return null;
    return Map<String, dynamic>.from(row as Map);
  }

  // ── Admin: Photo Moderation ───────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> adminGetPhotos({
    int limit = 50,
    String? status,
  }) async {
    final normalizedStatus =
        (status == null || status.trim().isEmpty || status == 'all')
        ? null
        : status.trim();

    // Fetch from new unified table first
    List<Map<String, dynamic>> newRows = const [];
    try {
      dynamic q = _client
          .from('user_photo_submissions')
          .select(
            'id,place_id,user_id,bucket,object_path,mime_type,width,height,file_size_bytes,caption,status,admin_note,rejection_reason,approved_place_image_id,submitted_at,created_at',
          )
          .order('submitted_at', ascending: false)
          .order('created_at', ascending: false);
      if (normalizedStatus != null) q = q.eq('status', normalizedStatus);
      q = q.limit(limit);
      newRows = ((await _runAuthed(() => q)) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    } catch (_) {}

    // Also fetch from legacy place_photos that aren't mirrored (no object_path key)
    List<Map<String, dynamic>> legacyRows = const [];
    try {
      final legacyStatus = normalizedStatus ?? 'pending';
      final rawLegacy = await _runAuthed(
        () => _client
            .from('place_photos')
            .select(
              'id,place_id,user_id,image_url,storage_path,status,created_at',
            )
            .eq('status', legacyStatus)
            .order('created_at', ascending: false)
            .limit(limit),
      );
      // Convert legacy format to unified format
      legacyRows = ((rawLegacy as List))
          .map((e) {
            final row = Map<String, dynamic>.from(e as Map);
            return {
              'id': row['id'],
              'place_id': row['place_id'],
              'user_id': row['user_id'],
              'bucket': 'place-photos',
              'object_path': row['storage_path'] ?? '',
              'mime_type': null,
              'width': null,
              'height': null,
              'file_size_bytes': null,
              'caption': null,
              'status': row['status'],
              'admin_note': row['moderation_note'],
              'rejection_reason': null,
              'approved_place_image_id': null,
              'submitted_at': row['created_at'],
              'created_at': row['created_at'],
              // Mark as legacy so admin can handle differently
              '_legacy': true,
              '_image_url': row['image_url'],
            };
          })
          .toList(growable: false);
    } catch (_) {}

    // Merge: prefer new unified rows, then legacy
    final seenIds = newRows.map((r) => r['id']?.toString() ?? '').toSet();
    final merged = [
      ...newRows,
      ...legacyRows.where((r) {
        // Deduplicate: if the same ID already came from user_photo_submissions, skip
        return !seenIds.contains(r['id']?.toString() ?? '');
      }),
    ];
    merged.sort((a, b) {
      final dateA =
          a['submitted_at']?.toString() ?? a['created_at']?.toString() ?? '';
      final dateB =
          b['submitted_at']?.toString() ?? b['created_at']?.toString() ?? '';
      return dateB.compareTo(dateA);
    });
    return _hydrateAdminPhotos(merged.take(limit).toList(growable: false));
  }

  Future<List<Map<String, dynamic>>> _hydrateAdminPhotos(
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return rows;
    final placeIds = rows
        .map((row) => row['place_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    final places = placeIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : ((await _runAuthed(
                    () => _client
                        .from('pois')
                        .select('id,name')
                        .inFilter('id', placeIds),
                  ))
                  as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(growable: false);
    final placeById = {
      for (final row in places) row['id']?.toString() ?? '': row['name'],
    };

    return rows
        .map((row) {
          // Legacy rows from place_photos already have a computed image_url
          final existingUrl = row['_image_url']?.toString();
          final objectPath = row['object_path']?.toString() ?? '';
          final bucket = row['bucket']?.toString() ?? 'community-photos';
          final computedUrl = existingUrl?.isNotEmpty == true
              ? existingUrl!
              : objectPath.isNotEmpty
              ? _client.storage.from(bucket).getPublicUrl(objectPath)
              : '';
          return {
            ...row,
            'image_url': computedUrl,
            'storage_path': objectPath.isNotEmpty ? objectPath : null,
            'moderation_note': row['admin_note'],
            'pois': {
              'name':
                  placeById[row['place_id']?.toString() ?? ''] ??
                  'Bilinmeyen yer',
            },
          };
        })
        .toList(growable: false);
  }

  Future<void> adminReviewPhoto(
    String photoId, {
    required String status, // 'approved' | 'rejected' | 'hidden'
    String? note,
    bool setCover = false, // If true, set as place cover image
    String? userId,
    String? placeName,
  }) async {
    // Try unified RPC first (handles photos submitted via new unified flow)
    bool rpcSucceeded = false;
    try {
      await _runAuthed(
        () => _client.rpc(
          'admin_moderate_submission',
          params: {
            'p_submission_type': 'photo_submission',
            'p_submission_id': photoId,
            'p_decision': status == 'hidden' ? 'rejected' : status,
            'p_admin_note': note?.trim().isEmpty ?? true ? null : note!.trim(),
            'p_rejection_reason': status == 'rejected' || status == 'hidden'
                ? (note?.trim().isEmpty ?? true
                      ? 'Rejected by admin'
                      : note!.trim())
                : null,
            'p_publish': status == 'approved',
            'p_set_cover': setCover,
          },
        ),
      );
      rpcSucceeded = true;
    } catch (_) {
      // RPC not available or photo not in unified queue — fall back to
      // direct update on the legacy place_photos table.
    }

    if (!rpcSucceeded) {
      final normalizedStatus = status == 'hidden' ? 'rejected' : status;
      final updatePayload = {
        'status': normalizedStatus,
        if (note != null && note.trim().isNotEmpty)
          'moderation_note': note.trim(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      // Try both tables — the ID will only match in one of them, the other silently no-ops.
      bool directSucceeded = false;
      try {
        await _runAuthed(
          () => _client
              .from('user_photo_submissions')
              .update({
                'status': normalizedStatus,
                if (note != null && note.trim().isNotEmpty)
                  'admin_note': note.trim(),
                'updated_at': DateTime.now().toUtc().toIso8601String(),
              })
              .eq('id', photoId),
        );
        directSucceeded = true;
      } catch (_) {}

      // Always also try legacy table (no-ops if not present there)
      try {
        await _runAuthed(
          () => _client
              .from('place_photos')
              .update(updatePayload)
              .eq('id', photoId),
        );
        directSucceeded = true;
      } catch (_) {}

      if (!directSucceeded) {
        throw Exception('Fotoğraf durumu güncellenemedi.');
      }
    }

    if (status == 'approved' && userId != null && userId.isNotEmpty) {
      try {
        await _invokeFunction(
          'notify_user_content_approved',
          body: {
            'user_id': userId,
            'content_kind': 'photo',
            'place_name': placeName,
          },
          requireAuth: true,
        );
      } catch (_) {}
    }
  }

  Future<List<Map<String, dynamic>>> adminGetReviews({
    int limit = 50,
    String? status,
  }) async {
    final rows = await _runAuthed(() {
      var query = _client
          .from('poi_reviews')
          .select(
            'id,poi_id,user_id,rating,comment_short,flags,status,created_at,updated_at,pois(name)',
          );
      if (status != null && status.trim().isNotEmpty) {
        query = query.eq('status', status.trim());
      }
      return query.order('created_at', ascending: false).limit(limit);
    });
    return (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<List<CommunityPostModel>> adminGetCommunityPosts({
    int limit = 80,
    String? status,
  }) async {
    final rows = await _runAuthed(() {
      var query = _client
          .from('community_posts')
          .select(
            'id,user_id,related_route_id,title,summary,city,country,post_type,'
            'cover_storage_path,content_body,tags,status,admin_note,submitted_at,'
            'published_at,reviewed_at,created_at,updated_at,estimated_read_minutes',
          );
      if (status != null && status.trim().isNotEmpty && status != 'all') {
        query = query.eq('status', status.trim());
      }
      return query
          .order('submitted_at', ascending: false)
          .order('updated_at', ascending: false)
          .limit(limit);
    });
    return _hydrateCommunityPosts(
      (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false),
    );
  }

  Future<void> adminReviewCommunityPost(
    String postId, {
    required String status,
    String? adminNote,
  }) async {
    final isAdmin = await isCurrentUserAdmin();
    if (!isAdmin) throw Exception('Admin yetkisi gerekli.');
    // community_post is not in the moderation_submission_type enum so we
    // cannot use admin_moderate_submission RPC here — use a direct update
    // which is protected by the admin RLS policy on community_posts.
    final payload = <String, dynamic>{
      'status': status,
      'admin_note': adminNote?.trim().isEmpty ?? true
          ? null
          : adminNote!.trim(),
      'reviewed_at': DateTime.now().toUtc().toIso8601String(),
      'reviewed_by': _client.auth.currentUser?.id,
      'published_at': status == 'approved'
          ? DateTime.now().toUtc().toIso8601String()
          : null,
    };
    await _runAuthed(
      () => _client.from('community_posts').update(payload).eq('id', postId),
    );
  }

  Future<List<Map<String, dynamic>>> adminGetCommunityReports({
    int limit = 100,
    String status = 'pending',
  }) async {
    final rows = await _runAuthed(
      () => _client
          .from('community_post_reports')
          .select(
            'id,post_id,reporter_user_id,reason,details,status,created_at,reviewed_at',
          )
          .eq('status', status)
          .order('created_at', ascending: false)
          .limit(limit),
    );
    final items = (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
    if (items.isEmpty) return items;
    final postIds = items
        .map((row) => row['post_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    final reporterIds = items
        .map((row) => row['reporter_user_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    final posts = await _runAuthed(
      () => _client
          .from('community_posts')
          .select('id,title,user_id')
          .inFilter('id', postIds),
    );
    final profiles = await _runAuthed(
      () => _client
          .from('profiles')
          .select('id,display_name')
          .inFilter('id', reporterIds),
    );
    final postById = {
      for (final row in (posts as List))
        row['id']?.toString() ?? '': Map<String, dynamic>.from(row as Map),
    };
    final profileById = {
      for (final row in (profiles as List))
        row['id']?.toString() ?? '': row['display_name']?.toString(),
    };
    return items
        .map(
          (row) => {
            ...row,
            'post_title':
                postById[row['post_id']?.toString() ?? '']?['title'] ??
                'Topluluk yazısı',
            'reporter_name':
                profileById[row['reporter_user_id']?.toString() ?? ''] ??
                'Kullanıcı',
          },
        )
        .toList(growable: false);
  }

  Future<void> adminReviewCommunityReport(
    String reportId, {
    required String status,
  }) async {
    await _runAuthed(
      () => _client
          .from('community_post_reports')
          .update({
            'status': status,
            'reviewed_at': DateTime.now().toUtc().toIso8601String(),
            'reviewed_by': _client.auth.currentUser?.id,
          })
          .eq('id', reportId),
    );
  }

  Future<List<Map<String, dynamic>>> adminGetPlaceStorySubmissions({
    int limit = 100,
    String status = 'pending',
  }) async {
    final rows = await _runAuthed(
      () => _client
          .from('user_story_submissions')
          .select(
            'id,place_id,user_id,title,story_text,story_kind,status,admin_note,rejection_reason,submitted_at,created_at',
          )
          .eq('status', status)
          .order('submitted_at', ascending: false)
          .order('created_at', ascending: false)
          .limit(limit),
    );
    final items = (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
    if (items.isEmpty) return items;
    final placeIds = items
        .map((row) => row['place_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    final userIds = items
        .map((row) => row['user_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    final places = await _runAuthed(
      () => _client.from('pois').select('id,name').inFilter('id', placeIds),
    );
    final profiles = await _runAuthed(
      () => _client
          .from('profiles')
          .select('id,display_name')
          .inFilter('id', userIds),
    );
    final placeById = {
      for (final row in (places as List))
        row['id']?.toString() ?? '': row['name']?.toString(),
    };
    final profileById = {
      for (final row in (profiles as List))
        row['id']?.toString() ?? '': row['display_name']?.toString(),
    };
    return items
        .map(
          (row) => {
            ...row,
            'fact_type': row['story_kind'],
            'place_name':
                placeById[row['place_id']?.toString() ?? ''] ??
                'Bilinmeyen yer',
            'submitter_name':
                profileById[row['user_id']?.toString() ?? ''] ?? 'Kullanıcı',
          },
        )
        .toList(growable: false);
  }

  Future<void> adminReviewPlaceStorySubmission(
    String submissionId, {
    required String status,
    String? adminNote,
  }) async {
    // Try unified RPC first (requires moderation_queue row).
    bool rpcSucceeded = false;
    try {
      await _runAuthed(
        () => _client.rpc(
          'admin_moderate_submission',
          params: {
            'p_submission_type': 'story_submission',
            'p_submission_id': submissionId,
            'p_decision': status,
            'p_admin_note': adminNote?.trim().isEmpty ?? true
                ? null
                : adminNote!.trim(),
            'p_rejection_reason': status == 'rejected'
                ? (adminNote?.trim().isEmpty ?? true
                      ? 'Rejected by admin'
                      : adminNote!.trim())
                : null,
            'p_publish': status == 'approved',
            'p_set_cover': false,
          },
        ),
      );
      rpcSucceeded = true;
    } catch (_) {
      // moderation_queue row missing or RPC not yet deployed — use fallbacks.
    }
    if (rpcSucceeded) return;

    // Fallback: for approve, call publish_story_submission directly.
    if (status == 'approved') {
      bool publishSucceeded = false;
      try {
        await _runAuthed(
          () => _client.rpc(
            'publish_story_submission',
            params: {
              'p_submission_id': submissionId,
              'p_admin_note': adminNote?.trim().isEmpty ?? true
                  ? null
                  : adminNote!.trim(),
            },
          ),
        );
        publishSucceeded = true;
      } catch (_) {}
      if (publishSucceeded) return;
    }

    // Final fallback: direct update on user_story_submissions.
    await _runAuthed(
      () => _client
          .from('user_story_submissions')
          .update({
            'status': status,
            'admin_note': adminNote?.trim().isEmpty ?? true
                ? null
                : adminNote!.trim(),
            'rejection_reason': status == 'rejected'
                ? (adminNote?.trim().isEmpty ?? true
                      ? 'Rejected by admin'
                      : adminNote!.trim())
                : null,
            'reviewed_at': DateTime.now().toUtc().toIso8601String(),
            'reviewed_by': _client.auth.currentUser?.id,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', submissionId),
    );
  }

  Future<List<Map<String, dynamic>>> adminGetFeedback({int limit = 100}) async {
    final rows = await _runAuthed(
      () => _client
          .from('feedback')
          .select('id,user_id,message,rating,created_at')
          .order('created_at', ascending: false)
          .limit(limit),
    );
    final items = (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final userIds = items
        .map((row) => row['user_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    if (userIds.isEmpty) return items;

    final profiles = await _runAuthed(
      () => _client
          .from('profiles')
          .select('id,display_name')
          .inFilter('id', userIds),
    );
    final profileById = {
      for (final raw in (profiles as List))
        (raw['id'] as String): Map<String, dynamic>.from(raw as Map),
    };
    return items
        .map(
          (row) => {
            ...row,
            'display_name':
                profileById[row['user_id']]?['display_name'] ?? 'Kullanici',
          },
        )
        .toList();
  }

  Future<void> adminReviewReview(
    String reviewId, {
    required String status, // 'approved' | 'hidden'
    String? userId,
    String? placeName,
  }) async {
    await _runAuthed(
      () => _client
          .from('poi_reviews')
          .update({
            'status': status,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', reviewId),
    );
    if (status == 'approved' && userId != null && userId.isNotEmpty) {
      try {
        await _invokeFunction(
          'notify_user_content_approved',
          body: {
            'user_id': userId,
            'content_kind': 'review',
            'place_name': placeName,
          },
          requireAuth: true,
        );
      } catch (_) {}
    }
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

  /// Fetches a Pexels image for a specific place (falls back to province-level).
  /// Non-fatal — returns null if not found. Result cached server-side.
  Future<Map<String, dynamic>?> getPlaceImage({
    required String placeName,
    required String provinceName,
    String category = '',
  }) async {
    try {
      final result = await _invokeFunction(
        'get_destination_image',
        body: {
          'city': provinceName,
          'place_name': placeName,
          'category': category,
        },
      );
      final data = result.data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns similar places (same category + province), excluding current place.
  Future<List<PlaceModel>> getSimilarPlaces({
    required String placeId,
    required String category,
    required String provinceSlug,
    int limit = 5,
  }) async {
    if (provinceSlug.isEmpty) return [];
    try {
      final rows = await _client
          .from('places_clean')
          .select('id,name,slug,category,short_summary,popularity_score,provinces(name,slug)')
          .eq('category', category)
          .neq('id', placeId)
          .order('popularity_score', ascending: false)
          .limit(limit * 3); // fetch more, filter by province client-side
      final all = (rows as List).map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        final province = map['provinces'] as Map?;
        return PlaceModel.fromMap({
          ...map,
          'province_name': province?['name'],
          'province_slug': province?['slug'],
          'best_time': 'day',
          'duration_min': 60,
        });
      }).toList();
      // Prefer same province, fall back to any
      final sameProvince = all.where((p) => p.provinceSlug == provinceSlug).take(limit).toList();
      if (sameProvince.isNotEmpty) return sameProvince;
      return all.take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  /// Global place search — queries places_clean by name with province join.
  /// Returns up to [limit] results ordered by popularity_score descending.
  Future<List<PlaceModel>> searchPlaces(String query, {int limit = 40}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    try {
      final rows = await _client
          .from('places_clean')
          .select(
            'id,name,slug,category,short_summary,popularity_score,provinces(name,slug)',
          )
          .ilike('name', '%$q%')
          .order('popularity_score', ascending: false)
          .limit(limit);

      return (rows as List).map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        final province = map['provinces'] as Map?;
        return PlaceModel.fromMap({
          ...map,
          'province_name': province?['name'],
          'province_slug': province?['slug'],
          'best_time': 'day',
          'duration_min': 60,
        });
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Admin: send push notification to a specific user (or all if userId is null).
  Future<Map<String, dynamic>> adminSendPushNotification({
    String? userId,
    required String title,
    required String body,
    Map<String, String> data = const {},
  }) async {
    // Force a fresh access token for admin operations so edge function
    // never rejects a stale JWT with a misleading "session expired" error.
    try {
      await _client.auth.refreshSession();
    } catch (_) {}
    try {
      final result = await _invokeFunction(
        'admin_send_push',
        body: {
          if (userId != null && userId.isNotEmpty) 'user_id': userId,
          'title': title,
          'body': body,
          if (data.isNotEmpty) 'data': data,
        },
        requireAuth: true,
      );
      return Map<String, dynamic>.from((result.data as Map?) ?? const {});
    } catch (e) {
      // Re-throw with function name so friendlyError shows the right message
      // instead of the generic "oturum süreniz dolmuş" for 401 responses.
      throw Exception('admin_send_push: $e');
    }
  }

  // ── Weather ────────────────────────────────────────────────────────────────
  // No auth required — weather is a shared cached resource, not user-specific.
  // TTL is managed server-side; many users for the same city share one cache row.

  Future<WeatherData> getWeather({
    required String citySlug,
    required String cityName,
    required double lat,
    required double lng,
    String? districtSlug,
    String? districtName,
  }) async {
    final result = await _invokeFunction(
      'get_weather',
      body: {
        'city_slug': citySlug,
        'city_name': cityName,
        'lat': lat,
        'lng': lng,
        'district_slug': districtSlug,
        'district_name': districtName,
      },
    );
    final data = Map<String, dynamic>.from((result.data as Map?) ?? const {});
    return WeatherData.fromJson(data);
  }
}

class _NearbyCacheEntry {
  const _NearbyCacheEntry({required this.items, required this.createdAt});

  final List<PlaceModel> items;
  final DateTime createdAt;
}

class _SignedUrlCacheEntry {
  const _SignedUrlCacheEntry({required this.url, required this.cachedAt});

  final String url;
  final DateTime cachedAt;
}
