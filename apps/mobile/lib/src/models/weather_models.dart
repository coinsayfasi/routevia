class WeatherData {
  const WeatherData({
    required this.cacheKey,
    required this.citySlug,
    required this.cityName,
    this.districtSlug,
    this.districtName,
    required this.temperature,
    this.apparentTemperature,
    required this.weatherCode,
    required this.conditionText,
    required this.conditionEmoji,
    required this.isDay,
    required this.precipitationProbability,
    required this.windSpeed,
    required this.humidity,
    this.sunrise,
    this.sunset,
    required this.suggestionMode,
    required this.provider,
    required this.fetchedAt,
    required this.expiresAt,
    this.fromCache = true,
    this.stale = false,
  });

  final String cacheKey;
  final String citySlug;
  final String cityName;
  final String? districtSlug;
  final String? districtName;
  final double temperature;
  final double? apparentTemperature;
  final int weatherCode;
  final String conditionText;
  final String conditionEmoji;
  final bool isDay;
  final int precipitationProbability;
  final double windSpeed;
  final int humidity;
  final String? sunrise;
  final String? sunset;

  /// outdoor | indoor | sunset | mixed
  final String suggestionMode;

  final String provider;
  final DateTime fetchedAt;
  final DateTime expiresAt;
  final bool fromCache;
  final bool stale;

  factory WeatherData.fromJson(Map<String, dynamic> j) {
    return WeatherData(
      cacheKey: j['cache_key'] as String? ?? '',
      citySlug: j['city_slug'] as String? ?? '',
      cityName: j['city_name'] as String? ?? '',
      districtSlug: j['district_slug'] as String?,
      districtName: j['district_name'] as String?,
      temperature: (j['temperature'] as num?)?.toDouble() ?? 0,
      apparentTemperature: (j['apparent_temperature'] as num?)?.toDouble(),
      weatherCode: (j['weather_code'] as num?)?.toInt() ?? 0,
      conditionText: j['condition_text'] as String? ?? '',
      conditionEmoji: j['condition_emoji'] as String? ?? '🌤️',
      isDay: j['is_day'] as bool? ?? true,
      precipitationProbability:
          (j['precipitation_probability'] as num?)?.toInt() ?? 0,
      windSpeed: (j['wind_speed'] as num?)?.toDouble() ?? 0,
      humidity: (j['humidity'] as num?)?.toInt() ?? 0,
      sunrise: j['sunrise'] as String?,
      sunset: j['sunset'] as String?,
      suggestionMode: j['suggestion_mode'] as String? ?? 'mixed',
      provider: j['provider'] as String? ?? 'open-meteo',
      fetchedAt: _parseDate(j['fetched_at']),
      expiresAt: _parseDate(j['expires_at']),
      fromCache: j['from_cache'] as bool? ?? false,
      stale: j['stale'] as bool? ?? false,
    );
  }

  static DateTime _parseDate(dynamic v) {
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  /// Human-readable temperature string, e.g. "23°"
  String get tempLabel => '${temperature.round()}°';

  /// Compact label for suggestion strip
  String get suggestionLabel {
    switch (suggestionMode) {
      case 'outdoor':
        return 'Dışarı çıkmak için güzel bir gün';
      case 'indoor':
        return 'Kapalı mekanlar için iyi bir gün';
      case 'sunset':
        return 'Gün batımı için ideal vakit';
      case 'mixed':
      default:
        return 'Karma aktiviteler için uygun';
    }
  }
}
