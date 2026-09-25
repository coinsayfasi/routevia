import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/models/journey_track.dart';

final t0 = DateTime(2026, 9, 26, 10);
TrackPoint p(double lat, int seconds) =>
    TrackPoint(lat, 29.0, t0.add(Duration(seconds: seconds)));

void main() {
  test('kayıt kapalıyken nokta eklenmez', () {
    final t = JourneyTrack().append(p(41.0, 0));
    expect(t.points, isEmpty);
  });

  test('mikro kıpırtı, kötü doğruluk ve sıçramalar elenir', () {
    var t = JourneyTrack(recording: true).append(p(41.0, 0));
    t = t.append(p(41.00005, 30)); // ~5 m → elenir
    expect(t.points.length, 1);
    t = t.append(p(41.001, 60), accuracyMeters: 120); // kötü GPS → elenir
    expect(t.points.length, 1);
    t = t.append(p(41.1, 61)); // ~11 km/1 sn → sıçrama, elenir
    expect(t.points.length, 1);
    t = t.append(p(41.001, 90)); // ~111 m / 90 sn → kabul
    expect(t.points.length, 2);
    expect(t.hasTrack, isTrue);
  });

  test('mesafe ve süre gerçek noktalardan hesaplanır', () {
    var t = JourneyTrack(recording: true);
    for (var i = 0; i <= 10; i++) {
      t = t.append(p(41.0 + i * 0.001, i * 60));
    }
    expect(t.distanceKm, closeTo(1.11, 0.02));
    expect(t.duration, const Duration(minutes: 10));
  });

  test('üst sınır aşılmaz', () {
    var t = JourneyTrack(recording: true);
    for (var i = 0; i < JourneyTrack.maxPoints + 20; i++) {
      t = t.append(p(41.0 + i * 0.001, i * 60));
    }
    expect(t.points.length, JourneyTrack.maxPoints);
  });

  test('geri yüklenen iz korunur ama kayıt kendiliğinden sürmez', () {
    var t = JourneyTrack(recording: true).append(p(41.0, 0));
    t = t.append(p(41.001, 60));
    final map = t.toMap();
    (map['points'] as List).add({'lat': 'bozuk'});
    final restored = JourneyTrack.fromMap(map);
    expect(restored.points.length, 2);
    expect(restored.recording, isFalse);
    expect(restored.points.last.at, t0.add(const Duration(seconds: 60)));
  });
}
