class ProvinceModel {
  ProvinceModel({required this.id, required this.name, required this.slug});

  final String id;
  final String name;
  final String slug;

  factory ProvinceModel.fromMap(Map<String, dynamic> map) {
    return ProvinceModel(
      id: map['id'] as String,
      name: map['name'] as String,
      slug: map['slug'] as String,
    );
  }
}

class MediaModel {
  MediaModel({
    required this.storagePath,
    this.publicUrl,
    required this.sortOrder,
  });

  final String storagePath;
  final String? publicUrl;
  final int sortOrder;

  factory MediaModel.fromMap(Map<String, dynamic> map) {
    return MediaModel(
      storagePath: map['storage_path'] as String? ?? '',
      publicUrl: map['public_url'] as String?,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class PlacePhotoModel {
  PlacePhotoModel({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.imageUrl,
    required this.storagePath,
    required this.status,
    required this.likesCount,
    required this.reportsCount,
    this.createdAt,
    this.updatedAt,
    this.uploaderTrustScore = 0,
  });

  final String id;
  final String placeId;
  final String userId;
  final String imageUrl;
  final String storagePath;
  final String status;
  final int likesCount;
  final int reportsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int uploaderTrustScore;

  bool get isApproved => status == 'approved';

  factory PlacePhotoModel.fromMap(Map<String, dynamic> map) {
    return PlacePhotoModel(
      id: map['id'] as String? ?? '',
      placeId: map['place_id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      storagePath: map['storage_path'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      likesCount: (map['likes_count'] as num?)?.toInt() ?? 0,
      reportsCount: (map['reports_count'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.tryParse(map['updated_at'] as String),
      uploaderTrustScore: (map['uploader_trust_score'] as num?)?.toInt() ?? 0,
    );
  }
}

class PlaceModel {
  PlaceModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.shortSummary,
    required this.bestTime,
    required this.durationMin,
    this.lat,
    this.lng,
    this.media = const [],
    this.tipsBullets = const [],
    this.historyBullets = const [],
    this.eatDrinkBullets = const [],
    this.tags = const [],
    this.stats,
    this.metersFromUser,
    this.isFree = false,
    this.sourceKind = 'curated',
    this.sourceUrl,
    this.appScore,
    this.appRating,
    this.ratingCount,
    this.sourceWeight,
    this.provinceName,
    this.provinceSlug,
    this.districtName,
  });

  final String id;
  final String name;
  final String slug;
  final String category;
  final String shortSummary;
  final String bestTime;
  final int durationMin;
  final double? lat;
  final double? lng;
  final List<MediaModel> media;
  final List<String> tipsBullets;
  final List<String> historyBullets;
  final List<String> eatDrinkBullets;
  final List<String> tags;
  final PlaceStats? stats;
  final double? metersFromUser;
  final bool isFree;
  final String sourceKind;
  final String? sourceUrl;
  final double? appScore;
  final double? appRating;
  final int? ratingCount;
  final double? sourceWeight;
  final String? provinceName;
  final String? provinceSlug;
  final String? districtName;

  double get routeviaScore => (appScore ?? 0).toDouble();
  double get effectiveRating => (appRating ?? stats?.avgRating ?? 0).toDouble();
  int get effectiveRatingCount =>
      (ratingCount ?? stats?.reviewCount ?? 0).toInt();

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    return PlaceModel(
      id: map['id'] as String,
      name: map['name'] as String,
      slug: map['slug'] as String,
      category: map['category'] as String,
      shortSummary: map['short_summary'] as String? ?? '',
      bestTime: map['best_time'] as String? ?? 'day',
      durationMin: (map['duration_min'] as num?)?.toInt() ?? 60,
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
      media: ((map['media'] as List?) ?? const [])
          .map((e) => MediaModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      tipsBullets: ((map['tips_bullets'] as List?) ?? const []).cast<String>(),
      historyBullets: ((map['history_bullets'] as List?) ?? const [])
          .cast<String>(),
      eatDrinkBullets: ((map['eat_drink_bullets'] as List?) ?? const [])
          .cast<String>(),
      tags: ((map['tags'] as List?) ?? const []).cast<String>(),
      stats: map['stats'] == null
          ? null
          : PlaceStats.fromMap(Map<String, dynamic>.from(map['stats'] as Map)),
      metersFromUser: (map['meters_from_user'] as num?)?.toDouble(),
      isFree: map['is_free'] as bool? ?? false,
      sourceKind: map['source_kind'] as String? ?? 'curated',
      sourceUrl: map['source_url'] as String?,
      appScore:
          (map['app_score'] as num?)?.toDouble() ??
          (map['score'] as num?)?.toDouble(),
      appRating:
          (map['app_rating'] as num?)?.toDouble() ??
          (map['rating'] as num?)?.toDouble(),
      ratingCount: (map['rating_count'] as num?)?.toInt(),
      sourceWeight: (map['source_weight'] as num?)?.toDouble(),
      provinceName: map['province_name'] as String? ?? map['city'] as String?,
      provinceSlug: map['province_slug'] as String?,
      districtName:
          map['district_name'] as String? ?? map['district'] as String?,
    );
  }

  PlaceModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? category,
    String? shortSummary,
    String? bestTime,
    int? durationMin,
    double? lat,
    double? lng,
    List<MediaModel>? media,
    List<String>? tipsBullets,
    List<String>? historyBullets,
    List<String>? eatDrinkBullets,
    List<String>? tags,
    PlaceStats? stats,
    double? metersFromUser,
    bool? isFree,
    String? sourceKind,
    String? sourceUrl,
    double? appScore,
    double? appRating,
    int? ratingCount,
    double? sourceWeight,
    String? provinceName,
    String? provinceSlug,
    String? districtName,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      category: category ?? this.category,
      shortSummary: shortSummary ?? this.shortSummary,
      bestTime: bestTime ?? this.bestTime,
      durationMin: durationMin ?? this.durationMin,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      media: media ?? this.media,
      tipsBullets: tipsBullets ?? this.tipsBullets,
      historyBullets: historyBullets ?? this.historyBullets,
      eatDrinkBullets: eatDrinkBullets ?? this.eatDrinkBullets,
      tags: tags ?? this.tags,
      stats: stats ?? this.stats,
      metersFromUser: metersFromUser ?? this.metersFromUser,
      isFree: isFree ?? this.isFree,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      appScore: appScore ?? this.appScore,
      appRating: appRating ?? this.appRating,
      ratingCount: ratingCount ?? this.ratingCount,
      sourceWeight: sourceWeight ?? this.sourceWeight,
      provinceName: provinceName ?? this.provinceName,
      provinceSlug: provinceSlug ?? this.provinceSlug,
      districtName: districtName ?? this.districtName,
    );
  }
}

class PlaceStats {
  PlaceStats({
    required this.placeId,
    required this.avgRating,
    required this.reviewCount,
    required this.crowdedCount,
    required this.familyCount,
    required this.photoSpotCount,
    required this.sunsetWorthyCount,
    this.routeviaScore = 0,
    this.checkinsCount = 0,
    this.photoCount = 0,
    this.recentReviews = const [],
  });

  final String placeId;
  final double avgRating;
  final int reviewCount;
  final int crowdedCount;
  final int familyCount;
  final int photoSpotCount;
  final int sunsetWorthyCount;
  final double routeviaScore;
  final int checkinsCount;
  final int photoCount;
  final List<PlaceReviewModel> recentReviews;

  factory PlaceStats.fromMap(Map<String, dynamic> map) {
    return PlaceStats(
      placeId: map['place_id'] as String,
      avgRating: (map['avg_rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (map['review_count'] as num?)?.toInt() ?? 0,
      crowdedCount: (map['crowded_count'] as num?)?.toInt() ?? 0,
      familyCount: (map['family_count'] as num?)?.toInt() ?? 0,
      photoSpotCount: (map['photo_spot_count'] as num?)?.toInt() ?? 0,
      sunsetWorthyCount: (map['sunset_worthy_count'] as num?)?.toInt() ?? 0,
      routeviaScore: (map['routevia_score'] as num?)?.toDouble() ?? 0,
      checkinsCount: (map['checkins_count'] as num?)?.toInt() ?? 0,
      photoCount: (map['photo_count'] as num?)?.toInt() ?? 0,
      recentReviews: ((map['recent_reviews'] as List?) ?? const [])
          .map(
            (e) =>
                PlaceReviewModel.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
    );
  }
}

class PlaceReviewModel {
  PlaceReviewModel({
    required this.id,
    required this.rating,
    required this.flags,
    required this.commentShort,
    required this.createdAt,
    this.status = 'approved',
    this.trustLevel = 'new_user',
    this.reviewerScore = 40,
  });

  final String id;
  final int rating;
  final List<String> flags;
  final String commentShort;
  final DateTime? createdAt;
  final String status;
  final String trustLevel;
  final int reviewerScore;

  factory PlaceReviewModel.fromMap(Map<String, dynamic> map) {
    return PlaceReviewModel(
      id: map['id'] as String? ?? '',
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      flags: ((map['flags'] as List?) ?? const []).cast<String>(),
      commentShort:
          map['comment_short'] as String? ?? map['comment'] as String? ?? '',
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String),
      status: map['status'] as String? ?? 'approved',
      trustLevel: map['trust_level'] as String? ?? 'new_user',
      reviewerScore: (map['reviewer_score'] as num?)?.toInt() ?? 40,
    );
  }
}

class TripStop {
  TripStop({
    required this.orderIndex,
    required this.arrivalTime,
    required this.durationMin,
    required this.transportMode,
    required this.place,
  });

  final int orderIndex;
  final String arrivalTime;
  final int durationMin;
  final String transportMode;
  final PlaceModel place;

  factory TripStop.fromMap(Map<String, dynamic> map) {
    return TripStop(
      orderIndex: (map['order_index'] as num).toInt(),
      arrivalTime: map['arrival_time'] as String,
      durationMin: (map['duration_min'] as num).toInt(),
      transportMode: map['transport_mode'] as String,
      place: PlaceModel.fromMap(Map<String, dynamic>.from(map['place'] as Map)),
    );
  }
}

class TripDay {
  TripDay({required this.dayNumber, required this.stops});

  final int dayNumber;
  final List<TripStop> stops;

  factory TripDay.fromMap(Map<String, dynamic> map) {
    return TripDay(
      dayNumber: (map['day_number'] as num).toInt(),
      stops: ((map['stops'] as List?) ?? const [])
          .map((e) => TripStop.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class TripPlan {
  TripPlan({
    required this.tripId,
    required this.days,
    required this.transportMode,
    required this.pace,
    required this.personaMode,
    required this.preferences,
    required this.province,
    required this.daysPlan,
    this.startLat,
    this.startLng,
    this.radiusUsedKm,
    this.districtStrict,
  });

  final String tripId;
  final int days;
  final String transportMode;
  final String pace;
  final String personaMode;
  final List<String> preferences;
  final ProvinceModel province;
  final List<TripDay> daysPlan;
  final double? startLat;
  final double? startLng;
  final int? radiusUsedKm;
  final bool? districtStrict;

  factory TripPlan.fromMap(Map<String, dynamic> map) {
    return TripPlan(
      tripId: map['trip_id']?.toString() ?? '',
      days: (map['days'] as num?)?.toInt() ?? 1,
      transportMode: map['transport_mode']?.toString() ?? 'car',
      pace: map['pace']?.toString() ?? 'normal',
      personaMode: map['persona_mode']?.toString() ?? 'explorer',
      preferences: ((map['preferences'] as List?) ?? const []).cast<String>(),
      province: map['province'] is Map
          ? ProvinceModel.fromMap(Map<String, dynamic>.from(map['province'] as Map))
          : ProvinceModel(id: '', name: '', slug: ''),
      daysPlan: ((map['days_plan'] as List?) ?? const [])
          .map((e) => TripDay.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      startLat: (map['start_lat'] as num?)?.toDouble(),
      startLng: (map['start_lng'] as num?)?.toDouble(),
      radiusUsedKm: (map['radius_used_km'] as num?)?.toInt(),
      districtStrict: map['district_strict'] as bool?,
    );
  }

  Map<String, dynamic> toMap() => {
    'trip_id': tripId,
    'days': days,
    'transport_mode': transportMode,
    'pace': pace,
    'persona_mode': personaMode,
    'preferences': preferences,
    'province': {
      'id': province.id,
      'name': province.name,
      'slug': province.slug,
    },
    'start_lat': startLat,
    'start_lng': startLng,
    'radius_used_km': radiusUsedKm,
    'district_strict': districtStrict,
    'days_plan': daysPlan
        .map(
          (d) => {
            'day_number': d.dayNumber,
            'stops': d.stops
                .map(
                  (s) => {
                    'order_index': s.orderIndex,
                    'arrival_time': s.arrivalTime,
                    'duration_min': s.durationMin,
                    'transport_mode': s.transportMode,
                    'place': {
                      'id': s.place.id,
                      'name': s.place.name,
                      'slug': s.place.slug,
                      'category': s.place.category,
                      'short_summary': s.place.shortSummary,
                      'best_time': s.place.bestTime,
                      'duration_min': s.place.durationMin,
                      'lat': s.place.lat,
                      'lng': s.place.lng,
                      'tags': s.place.tags,
                      'source_kind': s.place.sourceKind,
                      'source_url': s.place.sourceUrl,
                      'media': s.place.media
                          .map(
                            (m) => {
                              'storage_path': m.storagePath,
                              'public_url': m.publicUrl,
                              'sort_order': m.sortOrder,
                            },
                          )
                          .toList(),
                    },
                  },
                )
                .toList(),
          },
        )
        .toList(),
  };
}
