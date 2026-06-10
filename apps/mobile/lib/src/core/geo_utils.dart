import 'dart:math' as math;

abstract final class GeoUtils {
  static double distanceKm(
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
}
