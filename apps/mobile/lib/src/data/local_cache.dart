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
    return Map<String, dynamic>.from(idxRaw).map(
      (k, v) => MapEntry(k, v.toString()),
    );
  }
}
