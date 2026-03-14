class CommunityPostImageModel {
  CommunityPostImageModel({
    required this.id,
    required this.postId,
    required this.storagePath,
    required this.sortOrder,
    this.imageUrl,
    this.createdAt,
  });

  final String id;
  final String postId;
  final String storagePath;
  final String? imageUrl;
  final int sortOrder;
  final DateTime? createdAt;

  factory CommunityPostImageModel.fromMap(Map<String, dynamic> map) {
    return CommunityPostImageModel(
      id: map['id']?.toString() ?? '',
      postId: map['post_id']?.toString() ?? '',
      storagePath: map['storage_path']?.toString() ?? '',
      imageUrl: map['image_url']?.toString(),
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString()),
    );
  }
}

class CommunityPostModel {
  CommunityPostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.summary,
    required this.city,
    required this.country,
    required this.postType,
    required this.contentBody,
    required this.tags,
    required this.status,
    required this.estimatedReadMinutes,
    this.coverStoragePath,
    this.coverImageUrl,
    this.relatedRouteId,
    this.relatedRouteTitle,
    this.adminNote,
    this.submitterName,
    this.createdAt,
    this.updatedAt,
    this.submittedAt,
    this.publishedAt,
    this.reviewedAt,
    this.gallery = const [],
  });

  final String id;
  final String userId;
  final String title;
  final String summary;
  final String city;
  final String country;
  final String postType;
  final String contentBody;
  final List<String> tags;
  final String status;
  final int estimatedReadMinutes;
  final String? coverStoragePath;
  final String? coverImageUrl;
  final String? relatedRouteId;
  final String? relatedRouteTitle;
  final String? adminNote;
  final String? submitterName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? submittedAt;
  final DateTime? publishedAt;
  final DateTime? reviewedAt;
  final List<CommunityPostImageModel> gallery;

  bool get isDraft => status == 'draft';
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory CommunityPostModel.fromMap(Map<String, dynamic> map) {
    return CommunityPostModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      summary: map['summary']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      country: map['country']?.toString() ?? '',
      postType: map['post_type']?.toString() ?? 'story',
      contentBody: map['content_body']?.toString() ?? '',
      tags: ((map['tags'] as List?) ?? const []).cast<String>(),
      status: map['status']?.toString() ?? 'draft',
      estimatedReadMinutes:
          (map['estimated_read_minutes'] as num?)?.toInt() ?? 1,
      coverStoragePath: map['cover_storage_path']?.toString(),
      coverImageUrl: map['cover_image_url']?.toString(),
      relatedRouteId: map['related_route_id']?.toString(),
      relatedRouteTitle: map['related_route_title']?.toString(),
      adminNote: map['admin_note']?.toString(),
      submitterName: map['submitter_name']?.toString(),
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString()),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.tryParse(map['updated_at'].toString()),
      submittedAt: map['submitted_at'] == null
          ? null
          : DateTime.tryParse(map['submitted_at'].toString()),
      publishedAt: map['published_at'] == null
          ? null
          : DateTime.tryParse(map['published_at'].toString()),
      reviewedAt: map['reviewed_at'] == null
          ? null
          : DateTime.tryParse(map['reviewed_at'].toString()),
      gallery: ((map['gallery'] as List?) ?? const [])
          .map(
            (item) => CommunityPostImageModel.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  CommunityPostModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? summary,
    String? city,
    String? country,
    String? postType,
    String? contentBody,
    List<String>? tags,
    String? status,
    int? estimatedReadMinutes,
    String? coverStoragePath,
    String? coverImageUrl,
    String? relatedRouteId,
    String? relatedRouteTitle,
    String? adminNote,
    String? submitterName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? submittedAt,
    DateTime? publishedAt,
    DateTime? reviewedAt,
    List<CommunityPostImageModel>? gallery,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      city: city ?? this.city,
      country: country ?? this.country,
      postType: postType ?? this.postType,
      contentBody: contentBody ?? this.contentBody,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      estimatedReadMinutes: estimatedReadMinutes ?? this.estimatedReadMinutes,
      coverStoragePath: coverStoragePath ?? this.coverStoragePath,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      relatedRouteId: relatedRouteId ?? this.relatedRouteId,
      relatedRouteTitle: relatedRouteTitle ?? this.relatedRouteTitle,
      adminNote: adminNote ?? this.adminNote,
      submitterName: submitterName ?? this.submitterName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      gallery: gallery ?? this.gallery,
    );
  }
}
