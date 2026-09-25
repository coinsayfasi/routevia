import 'dart:math' as math;

/// Kullanıcının açıkça başlattığı, yalnız cihazda saklanan gerçek GPS izi.
/// Plan çizgisi ile karıştırılmaz: iz yoksa arayüz "gerçek iz değil" etiketiyle durakları bağlar.
class TrackPoint {
  const TrackPoint(this.lat, this.lng, this.at);
  final double lat;
  final double lng;
  final DateTime at;

  Map<String, dynamic> toMap() => {
    'lat': lat,
    'lng': lng,
    'at': at.toIso8601String(),
  };

  static TrackPoint? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final rawLat = raw['lat'];
    final rawLng = raw['lng'];
    final lat = rawLat is num ? rawLat.toDouble() : null;
    final lng = rawLng is num ? rawLng.toDouble() : null;
    final at = DateTime.tryParse(raw['at']?.toString() ?? '');
    if (lat == null || lng == null || at == null) return null;
    if (!lat.isFinite || !lng.isFinite || lat.abs() > 90 || lng.abs() > 180) {
      return null;
    }
    return TrackPoint(lat, lng, at);
  }
}

double haversineMeters(double lat1, double lng1, double lat2, double lng2) {
  double rad(double v) => v * math.pi / 180;
  final h =
      math.pow(math.sin(rad(lat2 - lat1) / 2), 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.pow(math.sin(rad(lng2 - lng1) / 2), 2);
  return 6371000 * 2 * math.asin(math.sqrt(h.clamp(0, 1)));
}

class JourneyTrack {
  JourneyTrack({List<TrackPoint>? points, this.recording = false})
    : points = List.unmodifiable(points ?? const []);

  /// Mikro kıpırtıları ve kötü GPS okumalarını elemek için eşikler.
  static const minStepMeters = 15.0;
  static const maxAccuracyMeters = 50.0;

  /// Yürüyüşte bile ulaşılamayacak hızda "sıçrama" noktaları (ör. hücre konumu) elenir.
  static const maxSpeedMps = 70.0;
  static const maxPoints = 3000;

  final List<TrackPoint> points;
  final bool recording;

  bool get hasTrack => points.length >= 2;

  double get distanceKm {
    var meters = 0.0;
    for (var i = 1; i < points.length; i++) {
      meters += haversineMeters(
        points[i - 1].lat,
        points[i - 1].lng,
        points[i].lat,
        points[i].lng,
      );
    }
    return meters / 1000;
  }

  Duration get duration => points.length < 2
      ? Duration.zero
      : points.last.at.difference(points.first.at);

  JourneyTrack withRecording(bool value) =>
      JourneyTrack(points: points, recording: value);

  /// Kayıt açıksa ve nokta güvenilirse ekler; değilse aynı nesneyi döndürür.
  JourneyTrack append(TrackPoint p, {double? accuracyMeters}) {
    if (!recording || points.length >= maxPoints) return this;
    if (accuracyMeters != null && accuracyMeters > maxAccuracyMeters) {
      return this;
    }
    if (points.isNotEmpty) {
      final last = points.last;
      final meters = haversineMeters(last.lat, last.lng, p.lat, p.lng);
      if (meters < minStepMeters) return this;
      final seconds = p.at.difference(last.at).inMilliseconds / 1000;
      if (seconds <= 0 || meters / seconds > maxSpeedMps) return this;
    }
    return JourneyTrack(points: [...points, p], recording: recording);
  }

  Map<String, dynamic> toMap() => {
    'recording': recording,
    'points': points.map((p) => p.toMap()).toList(),
  };

  factory JourneyTrack.fromMap(Map<String, dynamic> map) => JourneyTrack(
    // Uygulama kapanınca kayıt kendiliğinden durur; yeniden açılışta sessizce sürmez.
    recording: false,
    points: ((map['points'] as List?) ?? const [])
        .map(TrackPoint.tryParse)
        .whereType<TrackPoint>()
        .take(maxPoints)
        .toList(),
  );
}
