import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error_utils.dart';
import '../../core/theme.dart';
import '../../core/widgets/safe_network_image.dart';
import '../../data/providers.dart';

class MyContentScreen extends ConsumerStatefulWidget {
  const MyContentScreen({super.key});

  @override
  ConsumerState<MyContentScreen> createState() => _MyContentScreenState();
}

class _MyContentScreenState extends ConsumerState<MyContentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _reviews = const [];
  List<Map<String, dynamic>> _photos = const [];
  bool _deletingReview = false;
  String? _deletingPhotoId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(repositoryProvider);
      final results = await Future.wait([
        repo.getMyPlaceReviews(),
        repo.getMyPlacePhotos(),
      ]);
      if (!mounted) return;
      setState(() {
        _reviews = results[0];
        _photos = results[1];
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF15803D);
      case 'pending':
        return const Color(0xFFD97706);
      case 'hidden':
      case 'rejected':
        return const Color(0xFFB42318);
      default:
        return const Color(0xFF475467);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Yayında';
      case 'pending':
        return 'İncelemede';
      case 'hidden':
        return 'Gizlendi';
      case 'rejected':
        return 'Reddedildi';
      default:
        return status;
    }
  }

  String _placeLabel(Map<String, dynamic> row) {
    final poi = row['pois'];
    if (poi is! Map) return 'Bilinmeyen yer';
    final name = poi['name']?.toString() ?? 'Bilinmeyen yer';
    final district = poi['district']?.toString();
    final city = poi['city']?.toString();
    final locality = [
      district,
      city,
    ].whereType<String>().where((e) => e.trim().isNotEmpty).join(', ');
    return locality.isEmpty ? name : '$name • $locality';
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildReviews() {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    if (_reviews.isEmpty) {
      return _EmptyState(
        icon: Icons.rate_review_outlined,
        title: isEnglish ? 'You have not posted a review yet' : 'Henüz yorum göndermedin',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final row = _reviews[index];
        final status = row['status']?.toString() ?? 'pending';
        final createdAt = DateTime.tryParse(
          row['created_at']?.toString() ?? '',
        );
        final rating = (row['rating'] as num?)?.toInt() ?? 0;
        final comment = row['comment']?.toString() ?? '';
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RouteviaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _placeLabel(row),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _statusChip(status),
                  IconButton(
                    onPressed: _deletingReview
                        ? null
                        : () => _deleteReview(row),
                    tooltip: isEnglish ? 'Delete review' : 'Yorumu sil',
                    icon: _deletingReview
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (createdAt != null)
                    Text(
                      '${createdAt.day}.${createdAt.month}.${createdAt.year}',
                      style: const TextStyle(
                        color: RouteviaColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              if (comment.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(comment.trim()),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotos() {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    if (_photos.isEmpty) {
      return _EmptyState(
        icon: Icons.photo_camera_back_outlined,
        title: isEnglish ? 'You have not uploaded a photo yet' : 'Henüz fotoğraf yüklemedin',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _photos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final row = _photos[index];
        final status = row['status']?.toString() ?? 'pending';
        final note = row['moderation_note']?.toString();
        final createdAt = DateTime.tryParse(
          row['created_at']?.toString() ?? '',
        );
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RouteviaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: SafeNetworkImage(
                    url: row['image_url']?.toString() ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _placeLabel(row),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _statusChip(status),
                  IconButton(
                    onPressed: _deletingPhotoId != null
                        ? null
                        : () => _deletePhoto(row),
                    tooltip: isEnglish ? 'Delete photo' : 'Fotografi sil',
                    icon: _deletingPhotoId == row['id']?.toString()
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline, size: 20),
                  ),
                ],
              ),
              if (createdAt != null) ...[
                const SizedBox(height: 6),
                Text(
                  '${createdAt.day}.${createdAt.month}.${createdAt.year}',
                  style: const TextStyle(
                    color: RouteviaColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
              if (note != null && note.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  note.trim(),
                  style: const TextStyle(
                    color: RouteviaColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEnglish ? 'My Reviews and Photos' : 'Yorumlarım ve Fotoğraflarım',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '${isEnglish ? 'Reviews' : 'Yorumlarım'} (${_reviews.length})'),
            Tab(text: '${isEnglish ? 'Photos' : 'Fotoğraflarım'} (${_photos.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _load,
                      child: Text(isEnglish ? 'Try Again' : 'Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [_buildReviews(), _buildPhotos()],
            ),
    );
  }

  Future<void> _deleteReview(Map<String, dynamic> row) async {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEnglish ? 'Delete Review' : 'Yorumu Sil'),
        content: Text(
          isEnglish
              ? 'This review will be removed from your profile and the place page.'
              : 'Bu yorum profilinden ve ilgili yer sayfasından kaldirilacak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isEnglish ? 'Cancel' : 'Vazgec'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isEnglish ? 'Delete' : 'Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _deletingReview = true);
    try {
      await ref.read(repositoryProvider).deleteMyPlaceReview(
            row['id']?.toString() ?? '',
          );
      if (!mounted) return;
      setState(() {
        _reviews = _reviews.where((e) => e['id'] != row['id']).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEnglish ? 'Review deleted.' : 'Yorum silindi.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    } finally {
      if (mounted) setState(() => _deletingReview = false);
    }
  }

  Future<void> _deletePhoto(Map<String, dynamic> row) async {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEnglish ? 'Delete Photo' : 'Fotografi Sil'),
        content: Text(
          isEnglish
              ? 'This photo will be removed from your profile and the place page.'
              : 'Bu fotograf profilinden ve ilgili yer sayfasindan kaldirilacak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isEnglish ? 'Cancel' : 'Vazgec'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isEnglish ? 'Delete' : 'Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final photoId = row['id']?.toString() ?? '';
    setState(() => _deletingPhotoId = photoId);
    try {
      await ref.read(repositoryProvider).deleteMyPlacePhoto(photoId);
      if (!mounted) return;
      setState(() {
        _photos = _photos.where((e) => e['id'] != row['id']).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEnglish ? 'Photo deleted.' : 'Fotograf silindi.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    } finally {
      if (mounted) setState(() => _deletingPhotoId = null);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: RouteviaColors.textTertiary),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: RouteviaColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
