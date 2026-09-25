import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/data/day_route_planner.dart';
import 'package:mobile/src/models/journey_progress.dart';
import 'package:mobile/src/models/return_plan.dart';
import 'package:mobile/src/models/trip_models.dart';

TripDay day(int count, {int dayNumber = 1, int duration = 30}) => TripDay(
  dayNumber: dayNumber,
  stops: List.generate(
    count,
    (i) => TripStop(
      orderIndex: i + 1,
      arrivalTime: '09:00:00',
      durationMin: duration,
      transportMode: 'walk',
      place: PlaceModel.fromMap({
        'id': '$i',
        'name': 'Stop $i',
        'slug': '$i',
        'category': 'museum',
        'lat': 41.0 + i * .01,
        'lng': 29.0,
      }),
    ),
  ),
);

/// Başlangıç + [stops] durak + dönüş noktası; her yön 10 dk.
List<List<double?>> uniform(int stops, {bool returnReachable = true}) {
  final size = stops + 2;
  return List.generate(
    size,
    (i) => List.generate(size, (j) {
      if (i == j) return 0.0;
      if (!returnReachable && (i == size - 1 || j == size - 1)) return null;
      return 600.0;
    }),
  );
}

ReturnPlan back({int hour = 10, int minute = 40, int buffer = 15}) =>
    ReturnPlan(
      label: 'Otel',
      lat: 41.1,
      lng: 29.1,
      deadline: DateTime(2026, 9, 26, hour, minute),
      bufferMinutes: buffer,
    );

void main() {
  group('Pro dönüş saati', () {
    test('dönüş yolculuğu ve zaman payı bütçeden düşülür', () {
      final result = planDayRoute(
        day: day(2),
        hasOrigin: true,
        matrix: uniform(2),
        startMinute: 9 * 60,
        returnPlan: back(),
      );
      // 09:10 varış, 09:40 çıkış + 10 dk dönüş = 09:50 ≤ 10:25 (10:40 − 15 dk).
      // İkinci durak 10:20'de biter + 10 dk dönüş = 10:30 > 10:25 → sığmaz.
      expect(result.day.stops.map((s) => s.place.id), ['0']);
      expect(result.day.returnPlan!.arrival, DateTime(2026, 9, 26, 9, 50));
      expect(result.day.returnPlan!.travelMinutes, 10);
      expect(result.travelMinutes, 20);
    });

    test('zaman payı sıfırsa iki durak da sığar', () {
      final result = planDayRoute(
        day: day(2),
        hasOrigin: true,
        matrix: uniform(2),
        startMinute: 9 * 60,
        returnPlan: back(buffer: 0),
      );
      expect(result.day.stops.length, 2);
      expect(result.day.returnPlan!.arrival, DateTime(2026, 9, 26, 10, 30));
    });

    test('sığmayan zorunlu durak sessizce atlanmaz, açık hata verir', () {
      expect(
        () => planDayRoute(
          day: day(2),
          hasOrigin: true,
          matrix: uniform(2),
          startMinute: 9 * 60,
          returnPlan: back(),
          requiredPlaceIds: {'1'},
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('dönüş noktasına yol yoksa sıfır dakika sayılmaz', () {
      expect(
        () => planDayRoute(
          day: day(2),
          hasOrigin: true,
          matrix: uniform(2, returnReachable: false),
          startMinute: 9 * 60,
          returnPlan: back(),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('dönüş saati başlangıçtan önceyse plan kurulmaz', () {
      expect(
        () => planDayRoute(
          day: day(2),
          hasOrigin: true,
          matrix: uniform(2),
          startMinute: 9 * 60,
          returnPlan: back(hour: 9, minute: 10),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('başlangıç saati olmadan dönüş planı kabul edilmez', () {
      expect(
        () => planDayRoute(
          day: day(2),
          hasOrigin: true,
          matrix: uniform(2),
          returnPlan: back(),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('dönüş planı buluta yazılıp okunduğunda kaybolmaz', () {
      final original = back().scheduled(DateTime(2026, 9, 26, 10, 5), 12);
      final restored = TripDay.fromMap({
        'day_number': 1,
        'travel_minutes': 42,
        'duration_estimated': false,
        'budget_minutes': 240,
        'return_plan': original.toMap(),
      });
      expect(restored.returnPlan!.label, 'Otel');
      expect(restored.returnPlan!.deadline, original.deadline);
      expect(restored.returnPlan!.arrival, original.arrival);
      expect(restored.returnPlan!.travelMinutes, 12);
      expect(restored.returnPlan!.bufferMinutes, 15);
      expect(restored.durationEstimated, isFalse);
      expect(restored.budgetMinutes, 240);
    });
  });

  group('Ücretsiz gezi modu', () {
    test('gezdim, atla ve geri al sıradaki durağı doğru ilerletir', () {
      final d = day(3);
      var p = JourneyProgress().start(1);
      expect(p.nextStop(d)!.place.id, '0');
      p = p.mark(1, '0', 'visited');
      expect(p.nextStop(d)!.place.id, '1');
      p = p.mark(1, '1', 'skipped');
      expect(p.nextStop(d)!.place.id, '2');
      p = p.mark(1, '1', null); // geri al
      expect(p.nextStop(d)!.place.id, '1');
      expect(p.status(1, '0'), 'visited');
    });

    test('aynı yer farklı günlerde ayrı izlenir', () {
      final p = JourneyProgress().mark(1, '0', 'visited');
      expect(p.resolved(1, '0'), isTrue);
      expect(p.resolved(2, '0'), isFalse);
      expect(p.nextStop(day(2, dayNumber: 2))!.place.id, '0');
      expect(p.startedDays, {1});
    });

    test('tüm duraklar çözülünce sıradaki durak kalmaz', () {
      final d = day(2);
      final p = JourneyProgress()
          .mark(1, '0', 'visited')
          .mark(1, '1', 'skipped');
      expect(p.nextStop(d), isNull);
    });

    test('yeniden açılışta ilerleme korunur, bozuk kayıtlar elenir', () {
      final saved = JourneyProgress()
          .start(2)
          .mark(1, '0', 'visited')
          .mark(1, '1', 'skipped')
          .toMap();
      final restored = JourneyProgress.fromMap({
        ...saved,
        'stops': {...saved['stops'] as Map, '1:9': 'hacked'},
      });
      expect(restored.startedDays, {1, 2});
      expect(restored.status(1, '0'), 'visited');
      expect(restored.status(1, '1'), 'skipped');
      expect(restored.resolved(1, '9'), isFalse);
    });

    test('geçersiz durum reddedilir', () {
      expect(
        () => JourneyProgress().mark(1, '0', 'checked_in'),
        throwsArgumentError,
      );
    });
  });
}
