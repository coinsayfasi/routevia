import 'package:hive/hive.dart';

import '../core/constants.dart';

class LocalCache {
  Future<Box<dynamic>> _openSafeBox() async {
    try {
      return await Hive.openBox<dynamic>(AppConstants.cacheBox);
    } catch (_) {
      try {
        await Hive.deleteBoxFromDisk(AppConstants.cacheBox);
      } catch (_) {}
      return Hive.openBox<dynamic>(AppConstants.cacheBox);
    }
  }

  Future<void> saveLastTrip(Map<String, dynamic> tripJson) async {
    final box = await _openSafeBox();
    await box.put('last_trip', tripJson);
  }

  Future<Map<String, dynamic>?> readLastTrip() async {
    final box = await _openSafeBox();
    final value = box.get('last_trip');
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  Future<void> saveTripHistoryEntry(Map<String, dynamic> tripJson) async {
    final box = await _openSafeBox();
    final raw = box.get('trip_history');
    final items = ((raw as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final tripId = tripJson['trip_id']?.toString() ?? '';
    final nextItems = <Map<String, dynamic>>[
      tripJson,
      ...items.where((item) => item['trip_id']?.toString() != tripId),
    ];
    await box.put('trip_history', nextItems.take(20).toList());
  }

  Future<List<Map<String, dynamic>>> readTripHistory() async {
    final box = await _openSafeBox();
    final raw = box.get('trip_history');
    return ((raw as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> deleteTripHistoryEntry(String tripId) async {
    final normalizedTripId = tripId.trim();
    if (normalizedTripId.isEmpty) return;
    final box = await _openSafeBox();
    final raw = box.get('trip_history');
    final items = ((raw as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((item) => item['trip_id']?.toString() != normalizedTripId)
        .toList();
    await box.put('trip_history', items);

    final lastTrip = box.get('last_trip');
    if (lastTrip is Map &&
        lastTrip['trip_id']?.toString() == normalizedTripId) {
      await box.delete('last_trip');
    }
  }

  Future<int> bumpSessionCount() async {
    final box = await _openSafeBox();
    final current = (box.get('session_count') as int?) ?? 0;
    final next = current + 1;
    await box.put('session_count', next);
    return next;
  }

  Future<int> getSessionCount() async {
    final box = await _openSafeBox();
    return (box.get('session_count') as int?) ?? 0;
  }

  Future<void> setLastRatingPromptAt(DateTime dt) async {
    final box = await _openSafeBox();
    await box.put('last_rating_prompt_at', dt.toIso8601String());
  }

  Future<DateTime?> getLastRatingPromptAt() async {
    final box = await _openSafeBox();
    final raw = box.get('last_rating_prompt_at');
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  Future<void> setPendingReferralCode(String? code) async {
    final box = await _openSafeBox();
    if (code == null || code.trim().isEmpty) {
      await box.delete('pending_referral_code');
      return;
    }
    await box.put('pending_referral_code', code.trim().toUpperCase());
  }

  Future<String?> getPendingReferralCode() async {
    final box = await _openSafeBox();
    final raw = box.get('pending_referral_code');
    return raw is String ? raw : null;
  }

  Future<void> setPreferredProvinceSlug(String? slug) async {
    final box = await _openSafeBox();
    if (slug == null || slug.trim().isEmpty) {
      await box.delete('preferred_province_slug');
      return;
    }
    await box.put('preferred_province_slug', slug.trim());
  }

  Future<String?> getPreferredProvinceSlug() async {
    final box = await _openSafeBox();
    final raw = box.get('preferred_province_slug');
    return raw is String ? raw : null;
  }

  Future<void> setPreferredDistrictId(String? districtId) async {
    final box = await _openSafeBox();
    if (districtId == null || districtId.trim().isEmpty) {
      await box.delete('preferred_district_id');
      return;
    }
    await box.put('preferred_district_id', districtId.trim());
  }

  Future<String?> getPreferredDistrictId() async {
    final box = await _openSafeBox();
    final raw = box.get('preferred_district_id');
    return raw is String ? raw : null;
  }

  Future<void> setLocationSetupSkipped(bool skipped) async {
    final box = await _openSafeBox();
    await box.put('location_setup_skipped', skipped);
  }

  Future<bool> getLocationSetupSkipped() async {
    final box = await _openSafeBox();
    return (box.get('location_setup_skipped') as bool?) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final box = await _openSafeBox();
    await box.put('onboarding_completed_local', completed);
  }

  Future<bool> getOnboardingCompleted() async {
    final box = await _openSafeBox();
    return (box.get('onboarding_completed_local') as bool?) ?? false;
  }

  Future<void> setPreferredLanguageCode(String? code) async {
    final box = await _openSafeBox();
    if (code == null || code.trim().isEmpty || code.trim() == 'system') {
      await box.delete('preferred_language_code');
      return;
    }
    await box.put('preferred_language_code', code.trim().toLowerCase());
  }

  Future<String?> getPreferredLanguageCode() async {
    final box = await _openSafeBox();
    final raw = box.get('preferred_language_code');
    return raw is String ? raw : null;
  }

  Future<void> savePlanSettings({
    required int days,
    required String transportMode,
    required String pace,
    required String persona,
    required int radiusKm,
    required bool allowOutside,
    required Set<String> prefs,
  }) async {
    final box = await _openSafeBox();
    await box.put('plan_settings', {
      'days': days,
      'transport_mode': transportMode,
      'pace': pace,
      'persona': persona,
      'radius_km': radiusKm,
      'allow_outside': allowOutside,
      'prefs': prefs.toList(growable: false),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> getPlanSettings() async {
    final box = await _openSafeBox();
    final raw = box.get('plan_settings');
    if (raw is! Map) return const {};
    return Map<String, dynamic>.from(raw);
  }

  Future<void> saveOfflineCityPack(
    String provinceSlug,
    List<Map<String, dynamic>> places,
  ) async {
    final box = await _openSafeBox();
    final key = 'offline_city_pack_$provinceSlug';
    final payload = {
      'province_slug': provinceSlug,
      'saved_at': DateTime.now().toIso8601String(),
      'places': places,
    };
    await box.put(key, payload);

    final idxRaw = box.get('offline_city_pack_index');
    final idx = <String, dynamic>{
      if (idxRaw is Map) ...Map<String, dynamic>.from(idxRaw),
    };
    idx[provinceSlug] = payload['saved_at'];
    await box.put('offline_city_pack_index', idx);
  }

  Future<Map<String, dynamic>?> readOfflineCityPack(String provinceSlug) async {
    final box = await _openSafeBox();
    final raw = box.get('offline_city_pack_$provinceSlug');
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  Future<void> removeOfflineCityPack(String provinceSlug) async {
    final box = await _openSafeBox();
    await box.delete('offline_city_pack_$provinceSlug');
    final idxRaw = box.get('offline_city_pack_index');
    if (idxRaw is Map) {
      final idx = Map<String, dynamic>.from(idxRaw);
      idx.remove(provinceSlug);
      await box.put('offline_city_pack_index', idx);
    }
  }

  Future<Map<String, String>> listOfflineCityPacks() async {
    final box = await _openSafeBox();
    final idxRaw = box.get('offline_city_pack_index');
    if (idxRaw is! Map) return const {};
    return Map<String, dynamic>.from(
      idxRaw,
    ).map((k, v) => MapEntry(k, v.toString()));
  }

  // ── Daily Plan Count ───────────────────────────────────────────────────

  String get _todayKey {
    final now = DateTime.now();
    return 'plan_count_${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<int> getDailyPlanCount() async {
    final box = await _openSafeBox();
    return (box.get(_todayKey) as int?) ?? 0;
  }

  Future<int> incrementDailyPlanCount() async {
    final box = await _openSafeBox();
    final key = _todayKey;
    final current = (box.get(key) as int?) ?? 0;
    final next = current + 1;
    await box.put(key, next);
    return next;
  }

  Future<void> setConsentPreferences({
    required bool analyticsEnabled,
    required bool personalizedAdsEnabled,
    required bool policyAccepted,
  }) async {
    final box = await _openSafeBox();
    await box.put('consent_analytics_enabled', analyticsEnabled);
    await box.put('consent_personalized_ads_enabled', personalizedAdsEnabled);
    await box.put('consent_policy_accepted', policyAccepted);
    await box.put('consent_updated_at', DateTime.now().toIso8601String());
  }

  Future<Map<String, dynamic>> getConsentPreferences() async {
    final box = await _openSafeBox();
    return {
      'analytics_enabled':
          (box.get('consent_analytics_enabled') as bool?) ?? false,
      'personalized_ads_enabled':
          (box.get('consent_personalized_ads_enabled') as bool?) ?? false,
      'policy_accepted': (box.get('consent_policy_accepted') as bool?) ?? false,
      'updated_at': box.get('consent_updated_at') as String?,
    };
  }
}
