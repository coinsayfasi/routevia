import 'dart:math' as math;

import '../models/trip_models.dart';
import '../models/return_plan.dart';

/// Travel times are seconds. Null entries mean no route is available.
class DayRouteResult {
  const DayRouteResult(this.day, this.travelMinutes, this.savedMinutes);
  final TripDay day;
  final int travelMinutes;
  final int savedMinutes;
}

bool hasCoordinates(PlaceModel p) =>
    p.lat != null &&
    p.lng != null &&
    p.lat!.isFinite &&
    p.lng!.isFinite &&
    p.lat!.abs() <= 90 &&
    p.lng!.abs() <= 180;

List<List<double?>> estimateTravelMatrix(
  List<({double lat, double lng})> coords,
  String mode,
) {
  final speed = switch (mode) {
    'car' => 30.0,
    'bike' => 12.0,
    _ => 4.5,
  };
  return List.generate(
    coords.length,
    (i) => List.generate(coords.length, (j) {
      if (i == j) return 0.0;
      final a = coords[i];
      final b = coords[j];
      double rad(double v) => v * math.pi / 180;
      final h =
          math.pow(math.sin(rad(b.lat - a.lat) / 2), 2) +
          math.cos(rad(a.lat)) *
              math.cos(rad(b.lat)) *
              math.pow(math.sin(rad(b.lng - a.lng) / 2), 2);
      final km = 6371 * 2 * math.asin(math.sqrt(h.clamp(0, 1)));
      // Detour allowance, explicitly an estimate, never a road-service result.
      return km * 1.35 / speed * 3600;
    }),
  );
}

DayRouteResult planDayRoute({
  required TripDay day,
  required List<List<double?>> matrix,
  required bool hasOrigin,
  int? budgetMinutes,
  int? startMinute,
  ReturnPlan? returnPlan,
  Set<String> requiredPlaceIds = const {},
}) {
  final n = day.stops.length;
  final offset = hasOrigin ? 1 : 0;
  final size = n + offset + (returnPlan != null ? 1 : 0);
  if (returnPlan != null && (!returnPlan.valid || startMinute == null)) {
    throw const FormatException('Dönüş noktası veya başlangıç saati geçersiz.');
  }
  if (matrix.length != size || matrix.any((r) => r.length != size)) {
    throw const FormatException('Yol süreleri eksik.');
  }
  double edge(int from, int to) {
    final value = matrix[from][to];
    return value != null && value.isFinite && value >= 0
        ? value
        : double.infinity;
  }

  double cost(List<int> order) {
    var total = hasOrigin && order.isNotEmpty
        ? edge(0, order.first + offset)
        : 0.0;
    for (var i = 1; i < order.length; i++) {
      total += edge(order[i - 1] + offset, order[i] + offset);
    }
    if (returnPlan != null && order.isNotEmpty) {
      total += edge(order.last + offset, size - 1);
    }
    return total;
  }

  final original = List.generate(n, (i) => i);
  var order = <int>[];
  final remaining = original.toList();
  // Without an origin keep the user's first stop as the starting point.
  if (!hasOrigin && remaining.isNotEmpty) order.add(remaining.removeAt(0));
  while (remaining.isNotEmpty) {
    final from = order.isEmpty ? 0 : order.last + offset;
    remaining.sort((a, b) {
      final comparison = edge(
        from,
        a + offset,
      ).compareTo(edge(from, b + offset));
      return comparison != 0 ? comparison : a.compareTo(b);
    });
    order.add(remaining.removeAt(0));
  }
  // Evaluate the entire directed path: reversing a segment can change every edge.
  for (var pass = 0; pass < n; pass++) {
    var improved = false;
    for (var i = hasOrigin ? 0 : 1; i < n - 1; i++) {
      for (var j = i + 1; j < n; j++) {
        final candidate = [
          ...order.take(i),
          ...order.sublist(i, j + 1).reversed,
          ...order.skip(j + 1),
        ];
        if (cost(candidate) + 0.01 < cost(order)) {
          order = candidate;
          improved = true;
        }
      }
    }
    if (!improved) break;
  }
  if (cost(original) <= cost(order)) order = original;
  if (budgetMinutes == null && returnPlan == null && !cost(order).isFinite) {
    throw const FormatException('Bu duraklar arasında uygun yol bulunamadı.');
  }
  final parts = (day.stops.firstOrNull?.arrivalTime ?? '09:00').split(':');
  final firstArrival =
      (int.tryParse(parts[0]) ?? 9) * 60 + (int.tryParse(parts[1]) ?? 0);
  final firstLeg = hasOrigin && order.isNotEmpty ? edge(0, offset) / 60 : 0.0;
  // Existing arrival time is already at the first stop; avoid adding travel twice.
  var minute =
      (startMinute ??
              (firstArrival - (firstLeg.isFinite ? firstLeg.ceil() : 0)))
          .toDouble();
  final start = minute;
  final deadlineMinute = returnPlan == null
      ? null
      : returnPlan.deadline.hour * 60 +
            returnPlan.deadline.minute -
            returnPlan.bufferMinutes;
  if (deadlineMinute != null && deadlineMinute <= start) {
    throw const FormatException('Dönüş saati için yeterli zaman kalmadı.');
  }
  var travel = 0.0;
  int? previous;
  final stops = <TripStop>[];
  for (final index in order) {
    final seconds = previous != null
        ? edge(previous + offset, index + offset)
        : hasOrigin
        ? edge(0, index + offset)
        : 0.0;
    if (!seconds.isFinite) continue;
    final leg = (seconds / 60).ceil();
    final stop = day.stops[index];
    final returnSeconds = returnPlan == null
        ? 0.0
        : edge(index + offset, size - 1);
    final returnMinutes = (returnSeconds / 60);
    final finish = minute + leg + stop.durationMin;
    if (!returnSeconds.isFinite ||
        (deadlineMinute != null &&
            finish + returnMinutes.ceil() > deadlineMinute)) {
      continue;
    }
    if (finish >= 24 * 60 ||
        (budgetMinutes != null &&
            finish + returnMinutes.ceil() - start > budgetMinutes)) {
      continue;
    }
    minute += leg;
    final arrival = minute.round();
    stops.add(
      TripStop(
        orderIndex: stops.length + 1,
        arrivalTime:
            '${(arrival ~/ 60).toString().padLeft(2, '0')}:${(arrival % 60).toString().padLeft(2, '0')}:00',
        durationMin: stop.durationMin,
        transportMode: stop.transportMode,
        place: stop.place,
      ),
    );
    minute += stop.durationMin;
    travel += leg;
    previous = index;
  }
  if (stops.isEmpty && n > 0) {
    throw const FormatException(
      'Bu süreye uygun durak bulunamadı. Süreyi uzatmayı deneyin.',
    );
  }
  if (budgetMinutes == null && returnPlan == null && stops.length != n) {
    throw const FormatException(
      'Plan gece yarısını aşıyor. Daha erken bir başlangıç seçin.',
    );
  }
  if (!stops.map((s) => s.place.id).toSet().containsAll(requiredPlaceIds)) {
    throw const FormatException(
      'Mutlaka görmek istediğin durak bu süreye sığmıyor. Dönüş saatini veya gezi süresini değiştir.',
    );
  }
  ReturnPlan? scheduledReturn;
  if (returnPlan != null && previous != null) {
    final back = (edge(previous + offset, size - 1) / 60).ceil();
    travel += back;
    final date = returnPlan.deadline;
    scheduledReturn = returnPlan.scheduled(
      DateTime(
        date.year,
        date.month,
        date.day,
      ).add(Duration(minutes: minute.round() + back)),
      back,
    );
  }
  final before = cost(original);
  return DayRouteResult(
    TripDay(
      dayNumber: day.dayNumber,
      stops: stops,
      returnPlan: scheduledReturn,
    ),
    travel.ceil(),
    budgetMinutes == null && returnPlan == null && before.isFinite
        ? math.max(0, ((before - cost(order)) / 60).floor())
        : 0,
  );
}
