/// A user-selected destination and deadline, never a live arrival guarantee.
class ReturnPlan {
  const ReturnPlan({
    required this.label,
    required this.lat,
    required this.lng,
    required this.deadline,
    this.bufferMinutes = 15,
    this.arrival,
    this.travelMinutes,
  });
  final String label;
  final double lat;
  final double lng;
  final DateTime deadline;
  final int bufferMinutes;
  final DateTime? arrival;
  final int? travelMinutes;

  bool get valid =>
      label.trim().isNotEmpty &&
      lat.isFinite &&
      lng.isFinite &&
      lat.abs() <= 90 &&
      lng.abs() <= 180 &&
      bufferMinutes >= 0 &&
      bufferMinutes <= 60;

  ReturnPlan scheduled(DateTime value, int minutes) => ReturnPlan(
    label: label,
    lat: lat,
    lng: lng,
    deadline: deadline,
    bufferMinutes: bufferMinutes,
    arrival: value,
    travelMinutes: minutes,
  );

  Map<String, dynamic> toMap() => {
    'label': label,
    'lat': lat,
    'lng': lng,
    'deadline': deadline.toIso8601String(),
    'buffer_minutes': bufferMinutes,
    'arrival': arrival?.toIso8601String(),
    'travel_minutes': travelMinutes,
  };
  factory ReturnPlan.fromMap(Map<String, dynamic> map) => ReturnPlan(
    label: map['label'] as String,
    lat: (map['lat'] as num).toDouble(),
    lng: (map['lng'] as num).toDouble(),
    deadline: DateTime.parse(map['deadline'] as String),
    bufferMinutes: (map['buffer_minutes'] as num?)?.toInt() ?? 15,
    arrival: DateTime.tryParse(map['arrival']?.toString() ?? ''),
    travelMinutes: (map['travel_minutes'] as num?)?.toInt(),
  );
}
