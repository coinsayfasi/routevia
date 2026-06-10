class EventModel {
  EventModel({
    required this.id,
    required this.provinceId,
    required this.provinceName,
    required this.name,
    required this.slug,
    required this.monthStart,
    required this.monthEnd,
    required this.category,
    this.district,
    this.description,
    this.isRecurring = true,
    this.tags = const [],
    this.lat,
    this.lng,
    this.sourceUrl,
    this.isActive = true,
  });

  final String id;
  final String provinceId;
  final String provinceName;
  final String? district;
  final String name;
  final String slug;
  final String? description;
  final int monthStart;
  final int monthEnd;
  final String category;
  final bool isRecurring;
  final List<String> tags;
  final double? lat;
  final double? lng;
  final String? sourceUrl;
  final bool isActive;

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String? ?? '',
      provinceId: map['province_id'] as String? ?? '',
      provinceName: map['province_name'] as String? ?? '',
      district: map['district'] as String?,
      name: map['name'] as String? ?? '',
      slug: map['slug'] as String? ?? '',
      description: map['description'] as String?,
      monthStart: (map['month_start'] as num?)?.toInt() ?? 1,
      monthEnd: (map['month_end'] as num?)?.toInt() ?? 1,
      category: map['category'] as String? ?? 'festival',
      isRecurring: map['is_recurring'] as bool? ?? true,
      tags: ((map['tags'] as List?) ?? const []).cast<String>(),
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
      sourceUrl: map['source_url'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  bool isActiveInMonth(int month) => month >= monthStart && month <= monthEnd;
}

class EventReminderSetting {
  EventReminderSetting({required this.eventId, required this.enabled});

  final String eventId;
  final bool enabled;

  factory EventReminderSetting.fromMap(Map<String, dynamic> map) {
    return EventReminderSetting(
      eventId: map['event_id'] as String? ?? '',
      // Row presence alone means enabled; no is_enabled column in DB
      enabled: true,
    );
  }
}
