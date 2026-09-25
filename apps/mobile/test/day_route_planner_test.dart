import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/data/day_route_planner.dart';
import 'package:mobile/src/models/trip_models.dart';

TripDay day(int count, {int duration = 30, String arrival = '09:00:00'}) =>
    TripDay(
      dayNumber: 2,
      stops: List.generate(
        count,
        (i) => TripStop(
          orderIndex: i + 1,
          arrivalTime: arrival,
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

void main() {
  test('shortens a directed route and retains every stop', () {
    final result = planDayRoute(
      day: day(3),
      hasOrigin: true,
      matrix: [
        [0, 600, 60, 600],
        [600, 0, 600, 60],
        [600, 60, 0, 600],
        [600, 600, 600, 0],
      ],
    );
    expect(result.day.stops.map((s) => s.place.id), ['1', '0', '2']);
    expect(result.travelMinutes, 3);
    expect(result.savedMinutes, 27);
    expect(result.day.stops.map((s) => s.orderIndex), [1, 2, 3]);
    expect(result.day.stops[1].arrivalTime, '09:22:00');
  });
  test('keeps the first stop when origin is unknown', () {
    final result = planDayRoute(
      day: day(3),
      hasOrigin: false,
      matrix: [
        [0, 600, 60],
        [60, 0, 600],
        [600, 60, 0],
      ],
    );
    expect(result.day.stops.map((s) => s.place.id), ['0', '2', '1']);
    expect(result.travelMinutes, 2);
  });
  test(
    'budget includes origin travel and visits, without shortening visits',
    () {
      final result = planDayRoute(
        day: day(3, duration: 50),
        hasOrigin: true,
        startMinute: 600,
        budgetMinutes: 120,
        matrix: List.generate(
          4,
          (i) => List.generate(4, (j) => i == j ? 0 : 600),
        ),
      );
      expect(result.day.stops.length, 2);
      expect(result.travelMinutes, 20);
      expect(result.day.stops.last.arrivalTime, '11:10:00');
      expect(result.day.stops.every((s) => s.durationMin == 50), isTrue);
    },
  );
  test('unreachable edges are not converted into zero-minute travel', () {
    expect(
      () => planDayRoute(
        day: day(2),
        hasOrigin: false,
        matrix: [
          [0, null],
          [null, 0],
        ],
      ),
      throwsFormatException,
    );
  });
  test('does not silently remove stops to make an existing day fit', () {
    expect(
      () => planDayRoute(
        day: day(2, arrival: '23:00:00', duration: 60),
        hasOrigin: false,
        matrix: [
          [0, 60],
          [60, 0],
        ],
      ),
      throwsFormatException,
    );
  });
  test('fails clearly when no visit fits the requested budget', () {
    expect(
      () => planDayRoute(
        day: day(1, duration: 150),
        budgetMinutes: 120,
        hasOrigin: false,
        matrix: [
          [0],
        ],
      ),
      throwsFormatException,
    );
  });
  test('invalid matrix dimensions fail before changing a plan', () {
    expect(
      () => planDayRoute(
        day: day(2),
        hasOrigin: true,
        matrix: [
          [0],
        ],
      ),
      throwsFormatException,
    );
  });
  test('estimates differ for walking and driving, and stay finite', () {
    final coords = [(lat: 41.0, lng: 29.0), (lat: 41.01, lng: 29.01)];
    final walk = estimateTravelMatrix(coords, 'walk');
    final car = estimateTravelMatrix(coords, 'car');
    expect(walk[0][0], 0);
    expect(walk[0][1]!, greaterThan(car[0][1]!));
    expect(walk[0][1]!.isFinite, isTrue);
  });
  test('day metadata round-trips with legacy defaults', () {
    final parsed = TripDay.fromMap({
      'day_number': 1,
      'stops': [],
      'travel_minutes': 20,
      'duration_estimated': false,
      'budget_minutes': 120,
    });
    expect(parsed.travelMinutes, 20);
    expect(parsed.durationEstimated, isFalse);
    expect(parsed.budgetMinutes, 120);
    expect(
      TripDay.fromMap({'day_number': 1, 'stops': []}).durationEstimated,
      isTrue,
    );
  });
}
