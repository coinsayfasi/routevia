import 'trip_models.dart';

/// Private progress per trip and day; separate from public place check-ins.
class JourneyProgress {
  JourneyProgress({Set<int>? startedDays, Map<String, String>? stops})
    : startedDays = Set.unmodifiable(startedDays ?? {}),
      stops = Map.unmodifiable(stops ?? {});
  final Set<int> startedDays;
  final Map<String, String> stops;
  static String key(int day, String placeId) => '$day:$placeId';
  String? status(int day, String placeId) => stops[key(day, placeId)];
  bool resolved(int day, String placeId) => status(day, placeId) != null;
  TripStop? nextStop(TripDay day) =>
      day.stops.where((s) => !resolved(day.dayNumber, s.place.id)).firstOrNull;
  JourneyProgress start(int day) =>
      JourneyProgress(startedDays: {...startedDays, day}, stops: stops);
  JourneyProgress mark(int day, String placeId, String? status) {
    if (status != null && status != 'visited' && status != 'skipped') {
      throw ArgumentError.value(status, 'status');
    }
    final updated = Map<String, String>.from(stops);
    if (status == null) {
      updated.remove(key(day, placeId));
    } else {
      updated[key(day, placeId)] = status;
    }
    return JourneyProgress(startedDays: {...startedDays, day}, stops: updated);
  }

  Map<String, dynamic> toMap() => {
    'started_days': startedDays.toList(),
    'stops': stops,
  };
  factory JourneyProgress.fromMap(Map<String, dynamic> map) => JourneyProgress(
    startedDays: ((map['started_days'] as List?) ?? [])
        .whereType<int>()
        .toSet(),
    stops: Map<String, String>.from(map['stops'] as Map? ?? {})
      ..removeWhere((_, v) => v != 'visited' && v != 'skipped'),
  );
}
