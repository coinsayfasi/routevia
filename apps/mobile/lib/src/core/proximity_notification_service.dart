import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';

import '../data/local_cache.dart';
import 'geo_utils.dart';

/// Fires a local notification when the user enters a new province/city.
/// Called from the foreground (app open / app resume) — no background location
/// needed, no store review risk.
class ProximityNotificationService {
  ProximityNotificationService._();
  static final ProximityNotificationService instance =
      ProximityNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
    _initialized = true;
  }

  Future<void> requestPermission() async {
    try {
      final impl = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      impl?.requestPermissions(alert: true, badge: true, sound: true);
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      androidImpl?.requestNotificationsPermission();
    } catch (_) {}
  }

  /// Call this when the app opens / resumes with the user's current location.
  /// [nearbyPlaceCount] is how many must-see/tourist places are in the province.
  Future<void> checkAndNotify({
    required double userLat,
    required double userLng,
    required List<Map<String, dynamic>> provinces,
    LocalCache? cache,
    int nearbyPlaceCount = 0,
  }) async {
    if (!_initialized) await init();
    try {
      final localCache = cache ?? LocalCache();

      // Find nearest province
      Map<String, dynamic>? nearest;
      var bestKm = double.infinity;
      for (final p in provinces) {
        final lat = (p['lat'] as num?)?.toDouble();
        final lng = (p['lng'] as num?)?.toDouble();
        if (lat == null || lng == null) continue;
        final km = GeoUtils.distanceKm(userLat, userLng, lat, lng);
        if (km < bestKm) {
          bestKm = km;
          nearest = p;
        }
      }
      if (nearest == null || bestKm > 80) return;

      final slug = nearest['slug']?.toString() ?? '';
      final name = nearest['name']?.toString() ?? '';
      if (slug.isEmpty) return;

      // Record this province as visited
      await localCache.recordVisitedProvince(slug, name);

      // Cooldown: don't spam
      final shouldShow = await localCache.shouldShowProximityNotif(slug);
      if (!shouldShow) return;

      await localCache.markProximityNotifShown(slug);

      final count = nearbyPlaceCount > 0 ? nearbyPlaceCount : 5;
      final body = nearbyPlaceCount > 0
          ? '$count must-see yer yakınında keşfedilmeyi bekliyor!'
          : 'Çevredeki en güzel yerleri keşfetmek için Routevia\'yı aç!';

      await _plugin.show(
        slug.hashCode,
        '$name\'dasın 📍',
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'routevia_proximity',
            'Yakın Yer Bildirimleri',
            channelDescription:
                'Yeni bir şehre girdiğinizde öneriler sunar',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('[ProximityNotif] error: $e');
    }
  }

  /// Checks Open-Meteo for current weather and fires a local notification
  /// if conditions are outdoor-worthy (clear sky, temp >= 10°C).
  /// 8-hour cooldown so it never spams.
  Future<void> checkWeatherAndNotify({
    required double userLat,
    required double userLng,
    LocalCache? cache,
  }) async {
    if (!_initialized) await init();
    final localCache = cache ?? LocalCache();
    try {
      final shouldShow = await localCache.shouldShowWeatherNotif();
      if (!shouldShow) return;

      final dio = Dio();
      final response = await dio.get<String>(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': userLat.toStringAsFixed(4),
          'longitude': userLng.toStringAsFixed(4),
          'current': 'temperature_2m,weather_code,wind_speed_10m',
          'timezone': 'auto',
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 6),
          sendTimeout: const Duration(seconds: 6),
          responseType: ResponseType.plain,
        ),
      );

      if (response.statusCode != 200 || response.data == null) return;
      final body = jsonDecode(response.data!) as Map<String, dynamic>;
      final current = body['current'] as Map<String, dynamic>?;
      if (current == null) return;

      final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 99;
      final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 0.0;

      // WMO codes 0–3: clear / mainly clear / partly cloudy
      final isGoodWeather = weatherCode <= 3 && temp >= 10;
      if (!isGoodWeather) return;

      await localCache.markWeatherNotifShown();

      final String body2;
      if (temp >= 25) {
        body2 = 'Bugün ${temp.round()}°C, mükemmel bir gezi günü!';
      } else if (temp >= 15) {
        body2 = 'Bugün ${temp.round()}°C, keşif için ideal hava!';
      } else {
        body2 = 'Bugün ${temp.round()}°C, doğa yürüyüşü için güzel bir gün!';
      }

      await _plugin.show(
        'weather_notif'.hashCode,
        'Hava harika, keşfetme zamanı! ☀️',
        body2,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'routevia_weather',
            'Hava Durumu Bildirimleri',
            channelDescription: 'Hava güzel olduğunda keşif önerisi sunar',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('[WeatherNotif] error: $e');
    }
  }

}
