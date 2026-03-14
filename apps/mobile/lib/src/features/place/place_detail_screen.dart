import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/error_utils.dart';
import '../../core/i18n.dart';
import '../../core/theme.dart';
import '../../core/widgets/ad_banner.dart';
import '../../data/providers.dart';
import '../../models/trip_models.dart';
import '../../core/widgets/safe_network_image.dart';

// Reuse same category styling from map_screen
class _CatStyle {
  const _CatStyle(this.color, this.icon, this.label);
  final Color color;
  final IconData icon;
  final String label;
}

const _catStyles = <String, _CatStyle>{
  'museum': _CatStyle(Color(0xFF1565C0), Icons.museum, 'Müze'),
  'historical': _CatStyle(Color(0xFFF57F17), Icons.account_balance, 'Tarihi'),
  'nature': _CatStyle(Color(0xFF2E7D32), Icons.park, 'Doğa'),
  'beach': _CatStyle(Color(0xFF0097A7), Icons.beach_access, 'Plaj'),
  'viewpoint': _CatStyle(Color(0xFF00897B), Icons.panorama, 'Manzara'),
  'food': _CatStyle(Color(0xFFD84315), Icons.restaurant, 'Yemek'),
  'cafe': _CatStyle(Color(0xFF6D4C41), Icons.coffee, 'Kafe'),
  'lodging': _CatStyle(Color(0xFF7B1FA2), Icons.hotel, 'Konaklama'),
  'activity': _CatStyle(Color(0xFF283593), Icons.directions_run, 'Aktivite'),
  'market': _CatStyle(Color(0xFFC2185B), Icons.shopping_bag, 'Pazar/Çarşı'),
  'tour': _CatStyle(Color(0xFFE65100), Icons.tour, 'Tur'),
  'waterfall': _CatStyle(Color(0xFF0288D1), Icons.water_drop, 'Şelale'),
  'canyon': _CatStyle(Color(0xFF4527A0), Icons.terrain, 'Kanyon'),
};

_CatStyle _styleOf(String cat) =>
    _catStyles[cat] ?? const _CatStyle(Color(0xFF78909C), Icons.place, 'Diğer');

// ─────────────────────────────────────────────────────────────────────
class PlaceDetailScreen extends ConsumerStatefulWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final PlaceModel place;

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  PlaceModel? _detail;
  PlaceStats? _stats;
  List<PlacePhotoModel> _photos = const [];
  Map<String, dynamic>? _trustMetric;
  Map<String, dynamic>? _liveStatus;
  List<Map<String, dynamic>> _placeStories = const [];
  bool _posting = false;
  bool _uploadingPhoto = false;
  bool _favoriteActive = false;
  bool _checkinActive = false;
  int _rating = 5;
  final Set<String> _flags = {};
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool get _isLoggedIn =>
      ref.read(repositoryProvider).client.auth.currentSession != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(repositoryProvider);
    try {
      final detail = await repo.fetchPlaceDetail(widget.place.id);
      List<PlacePhotoModel> photos = const [];
      try {
        photos = await repo.getPlacePhotos(widget.place.id);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _photos = photos;
        _detail = detail;
      });
    } catch (_) {
      setState(() => _detail = widget.place);
    }
    try {
      final stats = await repo.getPlaceStats(widget.place.id);
      if (!mounted) return;
      setState(() => _stats = stats);
    } catch (_) {}
    try {
      final trust = await repo.getPlaceTrustMetrics(widget.place.id);
      final live = await repo.getLiveStatusForPlaces([
        widget.place.id,
      ], hours: 6);
      final savedState = await repo.getPlaceSavedState(widget.place.id);
      if (!mounted) return;
      setState(() {
        _trustMetric = trust;
        _liveStatus = live[widget.place.id];
        _favoriteActive = savedState['favorite'] ?? false;
        _checkinActive = savedState['checkin'] ?? false;
      });
    } catch (_) {}
    try {
      final stories = await repo.getApprovedPlaceStories(widget.place.id);
      if (!mounted) return;
      setState(() => _placeStories = stories);
    } catch (_) {}
  }

  Future<void> _submitReview() async {
    if (!_isLoggedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Yorum ve puan icin once giris yapmalisin.',
              'You need to sign in before posting a review or rating.',
            ),
          ),
        ),
      );
      context.push('/auth');
      return;
    }
    final comment = _commentController.text.trim();
    if (comment.length > 240) return;
    setState(() => _posting = true);
    try {
      final stats = await ref
          .read(repositoryProvider)
          .submitPlaceReview(
            placeId: widget.place.id,
            rating: _rating,
            flags: _flags.toList(),
            commentShort: comment,
          );
      try {
        await ref
            .read(repositoryProvider)
            .submitUserSignal(
              placeId: widget.place.id,
              type: 'rating',
              rating: _rating.toDouble(),
            );
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _rating = 5;
        _flags.clear();
        _commentController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Yorumun alindi. Admin onayindan sonra yayinlanacak.',
              'Your review was received. It will be published after admin approval.',
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<void> _uploadPhoto() async {
    if (!_isLoggedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Fotoğraf yüklemek için önce giriş yapmalısın.',
              'You need to sign in before uploading a photo.',
            ),
          ),
        ),
      );
      context.push('/auth');
      return;
    }
    setState(() => _uploadingPhoto = true);
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 88,
      );
      if (picked == null) {
        if (mounted) setState(() => _uploadingPhoto = false);
        return;
      }
      await ref
          .read(repositoryProvider)
          .uploadPlacePhoto(placeId: widget.place.id, file: File(picked.path));
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Fotoğrafın alındı! Moderasyon onayının ardından yayınlanacak.',
              'Your photo was received. It will be published after moderation approval.',
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _openNavigation() async {
    final p = _detail ?? widget.place;
    final lat = p.lat ?? 0;
    final lng = p.lng ?? 0;
    final name = Uri.encodeComponent(p.name);

    // Show bottom sheet with multiple options
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$lat, $lng',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 16),
              if (Platform.isIOS)
                _NavOption(
                  icon: Icons.map,
                  label: 'Apple Maps',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await launchUrl(
                      Uri.parse(
                        'https://maps.apple.com/?daddr=$lat,$lng&q=$name',
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              _NavOption(
                icon: Icons.map_outlined,
                label: 'Google Maps',
                onTap: () async {
                  Navigator.pop(ctx);
                  await launchUrl(
                    Uri.parse(
                      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
                    ),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              _NavOption(
                icon: Icons.copy,
                label: 'Koordinatları Kopyala',
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: '$lat, $lng'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Koordinatlar kopyalandı.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sharePlace() async {
    final p = _detail ?? widget.place;
    final districtText = p.tags.isEmpty
        ? ''
        : ' - ${p.tags.take(2).join(", ")}';
    final summaryLine = p.shortSummary.length > 25 ? '${p.shortSummary}\n' : '';
    final text =
        '${p.name}$districtText\n$summaryLine'
        'routevia://place/${p.id}';
    await SharePlus.instance.share(ShareParams(text: text));
    await ref
        .read(repositoryProvider)
        .logAppEvent('place_shared', payload: {'place_id': p.id});
  }

  Future<void> _signal(String type, {double? rating}) async {
    final session = ref.read(repositoryProvider).client.auth.currentSession;
    if (session == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Check-in ve favori icin giris yapmalisin.',
              'You need to sign in before using check-in and favorites.',
            ),
          ),
        ),
      );
      context.push('/auth');
      return;
    }
    try {
      bool? activeState;
      if (type == 'checkin') {
        activeState = await ref
            .read(repositoryProvider)
            .toggleCheckin(widget.place.id);
        if (mounted) setState(() => _checkinActive = activeState ?? false);
      } else if (type == 'favorite') {
        activeState = await ref
            .read(repositoryProvider)
            .toggleFavorite(widget.place.id);
        if (mounted) setState(() => _favoriteActive = activeState ?? false);
      } else {
        await ref
            .read(repositoryProvider)
            .submitUserSignal(
              placeId: widget.place.id,
              type: type,
              rating: rating,
            );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            type == 'checkin'
                ? (activeState == true
                      ? 'Check-in kaydedildi'
                      : 'Check-in kaldırıldı')
                : type == 'favorite'
                ? (activeState == true
                      ? 'Favorilere eklendi'
                      : 'Favoriden kaldırıldı')
                : 'Puan sinyali kaydedildi',
          ),
        ),
      );
      try {
        await _load();
      } catch (_) {}
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  String _flagLabel(String f) {
    final map = {
      'crowded': context.tr('Kalabalık', 'Crowded'),
      'family': context.tr('Aile Dostu', 'Family Friendly'),
      'quiet': context.tr('Sakin', 'Quiet'),
      'photo_spot': context.tr('Fotoğraf Noktası', 'Photo Spot'),
      'budget': context.tr('Bütçe Dostu', 'Budget Friendly'),
      'sunset_worthy': context.tr('Gün Batımı', 'Sunset'),
    };
    return map[f] ?? f;
  }

  String _summaryText(PlaceStats? stats) {
    if (stats == null || stats.reviewCount == 0) {
      return context.tr(
        'Bu yer icin ilk yorumu sen birak.',
        'Be the first to review this place.',
      );
    }
    return context.tr(
      '${stats.reviewCount} topluluk yorumu, ${stats.checkinsCount} check-in ve ${stats.photoCount} fotoğraf var. Ortalama ${stats.avgRating.toStringAsFixed(1)} / 5.',
      '${stats.reviewCount} community reviews, ${stats.checkinsCount} check-ins, and ${stats.photoCount} photos. Average ${stats.avgRating.toStringAsFixed(1)} / 5.',
    );
  }

  Future<void> _submitPlaceStory() async {
    if (!_isLoggedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Yer hikayesi paylaşmak için önce giriş yapmalısın.',
              'Sign in before sharing a place story.',
            ),
          ),
        ),
      );
      context.push('/auth');
      return;
    }
    final titleCtrl = TextEditingController();
    final storyCtrl = TextEditingController();
    var factType = 'story';
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: Text(
            context.tr(
              'Yer hikayesi veya gizli özelliği paylaş',
              'Share a place story or hidden detail',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: factType,
                  items: [
                    DropdownMenuItem(
                      value: 'story',
                      child: Text(context.tr('Hikâye', 'Story')),
                    ),
                    DropdownMenuItem(
                      value: 'local_tip',
                      child: Text(context.tr('Yerel İpucu', 'Local Tip')),
                    ),
                    DropdownMenuItem(
                      value: 'history_note',
                      child: Text(context.tr('Tarih Notu', 'History Note')),
                    ),
                    DropdownMenuItem(
                      value: 'hidden_feature',
                      child: Text(
                        context.tr('Bilinmeyen Özellik', 'Hidden Feature'),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setLocalState(() => factType = value ?? 'story'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: context.tr('Kısa Başlık', 'Short Title'),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: storyCtrl,
                  minLines: 5,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: context.tr('Katkın', 'Your contribution'),
                    hintText: context.tr(
                      'Bu yerde insanların bilmediği bir detay, kısa hikâye veya yerel ipucu yaz.',
                      'Share a detail, short story, or local tip people may not know.',
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(context.tr('Vazgeç', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(context.tr('Gönder', 'Submit')),
            ),
          ],
        ),
      ),
    );
    if (submitted != true) return;
    final trimmedTitle = titleCtrl.text.trim();
    final trimmedStory = storyCtrl.text.trim();
    if (trimmedStory.length < 40) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Yer hikayesi en az 40 karakter olmalı.',
              'Place story must be at least 40 characters.',
            ),
          ),
        ),
      );
      return;
    }
    if (trimmedStory.length > 2000) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Yer hikayesi 2000 karakteri aşamaz.',
              'Place story cannot exceed 2000 characters.',
            ),
          ),
        ),
      );
      return;
    }
    if (trimmedTitle.length > 140) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Kısa başlık 140 karakteri aşamaz.',
              'Short title cannot exceed 140 characters.',
            ),
          ),
        ),
      );
      return;
    }
    try {
      await ref
          .read(repositoryProvider)
          .submitPlaceStoryContribution(
            placeId: widget.place.id,
            title: trimmedTitle,
            storyText: trimmedStory,
            factType: factType,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Katkın alındı. Moderasyon sonrası bu yerde görünebilir.',
              'Your contribution was received and may appear here after moderation.',
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return context.tr('Çok kötü', 'Very bad');
      case 2:
        return context.tr('Kötü', 'Bad');
      case 3:
        return context.tr('Orta', 'Average');
      case 4:
        return context.tr('İyi', 'Good');
      case 5:
        return context.tr('Mükemmel!', 'Excellent!');
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = _detail ?? widget.place;
    final images = place.media;
    final cat = _styleOf(place.category);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero image app bar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: RouteviaColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (images.isNotEmpty)
                    PageView(
                      children: images
                          .map(
                            (m) => SafeNetworkImage(
                              url: m.publicUrl,
                              fit: BoxFit.cover,
                            ),
                          )
                          .toList(),
                    )
                  else
                    Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.image,
                        size: 48,
                        color: Colors.white54,
                      ),
                    ),
                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                  // Category badge on image
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 48,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cat.color,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            cat.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Title on image
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Rating + duration row
                        Wrap(
                          spacing: 8,
                          children: [
                            if (place.effectiveRating > 0)
                              _infoBadge(
                                Icons.star,
                                '${place.effectiveRating.toStringAsFixed(1)}${place.effectiveRatingCount > 0 ? ' (${place.effectiveRatingCount})' : ''}',
                                const Color(0xFFFFD600),
                              ),
                            if (place.routeviaScore > 0)
                              _infoBadge(
                                Icons.verified,
                                'Routevia ${place.routeviaScore.toStringAsFixed(1)}',
                                RouteviaColors.accent,
                              ),
                            _infoBadge(
                              Icons.schedule,
                              '${place.durationMin} dk',
                              Colors.white70,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.share), onPressed: _sharePlace),
            ],
          ),

          // ── Content ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _openNavigation,
                        icon: const Icon(Icons.navigation, size: 18),
                        label: const Text('Yol Tarifi'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: _checkinActive
                          ? Icons.check_circle_rounded
                          : Icons.place,
                      label: 'Check-in',
                      foreground: _checkinActive
                          ? const Color(0xFFDC2626)
                          : null,
                      onTap: () => _signal('checkin'),
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: _favoriteActive
                          ? Icons.favorite
                          : Icons.favorite_border,
                      label: 'Favori',
                      foreground: _favoriteActive
                          ? const Color(0xFFDC2626)
                          : null,
                      onTap: () => _signal('favorite'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _uploadingPhoto ? null : _uploadPhoto,
                    icon: Icon(
                      _uploadingPhoto ? Icons.hourglass_top : Icons.add_a_photo,
                      size: 18,
                    ),
                    label: Text(
                      _uploadingPhoto
                          ? 'Fotoğraf işleniyor...'
                          : 'Topluluk Fotoğrafı Yükle',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Topluluk fotoğrafı notu',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Yalnızca kendi çektiğin veya kullanım hakkına sahip olduğun fotoğrafları yükle. Moderasyondan geçen görseller topluluk galerisinde ve seçilirse yerin ana görselinde kullanılabilir.',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          height: 1.45,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Net kadraj, yatay çekim ve mekanın ayırt edici detayları daha hızlı öne çıkar.',
                        style: TextStyle(
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                          'Bu yerin hikâyesini sen tamamla',
                          'Help complete this place story',
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr(
                          'Gittiğin yerle ilgili kısa hikâye, bilinmeyen özellik veya yerel ipucu ekleyebilirsin. Onay sonrası burada görünür.',
                          'Add a short story, hidden feature, or local tip about this place. It appears here after approval.',
                        ),
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.tonalIcon(
                        onPressed: _submitPlaceStory,
                        icon: const Icon(Icons.auto_stories_outlined, size: 18),
                        label: Text(
                          context.tr(
                            'Hikâye veya Özellik Ekle',
                            'Add Story or Feature',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_placeStories.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(
                            'Topluluktan Yer Hikâyeleri',
                            'Community Place Stories',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._placeStories.map(
                          (story) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (story['title']
                                              ?.toString()
                                              .trim()
                                              .isNotEmpty ??
                                          false)
                                      ? story['title'].toString()
                                      : context.tr(
                                          'Topluluk notu',
                                          'Community note',
                                        ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  story['story_text']?.toString() ?? '',
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${story['submitter_name'] ?? 'Routevia gezgini'} • ${story['fact_type'] ?? 'story'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Summary — sadece gerçek açıklama varsa göster (ilçe adı gibi kısa değerler atlanır)
                if (place.shortSummary.length > 25) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8ECF0)),
                    ),
                    child: Text(
                      place.shortSummary,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Source attribution
                _SourceBadge(place: place),
                const SizedBox(height: 12),
                if (_trustMetric != null) ...[
                  _TrustCard(metric: _trustMetric!, live: _liveStatus),
                  const SizedBox(height: 12),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            ((_stats?.avgRating ?? 0) > 0)
                                ? _stats!.avgRating.toStringAsFixed(1)
                                : '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Routevia Topluluk Skoru',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _summaryText(_stats),
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (_photos.isNotEmpty) ...[
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _photos.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final photo = _photos[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: 132,
                                child: SafeNetworkImage(
                                  url: photo.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (!photo.isApproved)
                                Positioned(
                                  left: 8,
                                  right: 8,
                                  bottom: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      photo.status == 'pending'
                                          ? 'Onay bekliyor'
                                          : 'Gizlendi',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Stats row
                if (_stats != null) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_stats!.familyCount > 0)
                        _StatChip(
                          Icons.family_restroom,
                          'Aile Dostu',
                          _stats!.familyCount,
                        ),
                      if (_stats!.photoSpotCount > 0)
                        _StatChip(
                          Icons.camera_alt,
                          'Foto Noktası',
                          _stats!.photoSpotCount,
                        ),
                      if (_stats!.sunsetWorthyCount > 0)
                        _StatChip(
                          Icons.wb_twilight,
                          'Gün Batımı',
                          _stats!.sunsetWorthyCount,
                        ),
                      if (_stats!.crowdedCount > 0)
                        _StatChip(
                          Icons.groups,
                          'Kalabalık',
                          _stats!.crowdedCount,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Tags
                if (place.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: place.tags
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '#$t',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Content sections
                _SectionCard(
                  icon: Icons.history_edu,
                  title: 'Tarih',
                  items: place.historyBullets,
                  color: const Color(0xFFF57F17),
                ),
                _SectionCard(
                  icon: Icons.restaurant_menu,
                  title: 'Yeme / İçme',
                  items: place.eatDrinkBullets,
                  color: const Color(0xFFD84315),
                ),
                _SectionCard(
                  icon: Icons.lightbulb_outline,
                  title: 'İpuçları',
                  items: place.tipsBullets,
                  color: RouteviaColors.accent,
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Review section
                const Text(
                  'Değerlendirme Yap',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 12),
                if (!_isLoggedIn) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF6FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF1D4ED8),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Yorum, puan, check-in ve favori icin giris gerekli.',
                            style: TextStyle(
                              color: Color(0xFF1E3A8A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/auth'),
                          child: const Text('Giris Yap'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                const Text(
                  'Puanın',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final starValue = i + 1;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = starValue),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0.8,
                            end: starValue <= _rating ? 1.15 : 1.0,
                          ),
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.elasticOut,
                          builder: (ctx, scale, child) =>
                              Transform.scale(scale: scale, child: child),
                          child: Icon(
                            starValue <= _rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 40,
                            color: starValue <= _rating
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    _ratingLabel(_rating),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B3B68),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Quick flags
                const Text(
                  'Hızlı Etiketler',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children:
                      [
                            'crowded',
                            'family',
                            'quiet',
                            'photo_spot',
                            'budget',
                            'sunset_worthy',
                          ]
                          .map(
                            (f) => FilterChip(
                              label: Text(_flagLabel(f)),
                              selected: _flags.contains(f),
                              onSelected: (on) => setState(() {
                                if (on) {
                                  _flags.add(f);
                                } else {
                                  _flags.remove(f);
                                }
                              }),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  maxLength: 240,
                  decoration: const InputDecoration(
                    labelText: 'Kısa yorum',
                    hintText: 'Manzara harika, akşamüstü gidin.',
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _posting ? null : _submitReview,
                  icon: Icon(
                    _posting ? Icons.hourglass_top : Icons.send,
                    size: 18,
                  ),
                  label: Text(_posting ? 'Kaydediliyor...' : 'Yorumu Kaydet'),
                ),

                // Community reviews
                if ((_stats?.recentReviews.length ?? 0) > 0) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Topluluk Yorumları',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...(List<PlaceReviewModel>.from(_stats!.recentReviews)..sort(
                        (a, b) => b.reviewerScore.compareTo(a.reviewerScore),
                      ))
                      .map(
                        (r) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8ECF0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ...List.generate(
                                    r.rating.clamp(0, 5),
                                    (_) => const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Color(0xFFF57F17),
                                    ),
                                  ),
                                  const Spacer(),
                                  _TrustBadge(level: r.trustLevel),
                                  const SizedBox(width: 8),
                                  if (r.createdAt != null)
                                    Text(
                                      '${r.createdAt!.day}.${r.createdAt!.month}.${r.createdAt!.year}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                ],
                              ),
                              if (r.commentShort.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(r.commentShort),
                              ],
                              if (r.status != 'approved') ...[
                                const SizedBox(height: 6),
                                Text(
                                  r.status == 'pending'
                                      ? 'Moderasyon bekliyor'
                                      : 'Görünürlüğü kısıtlandı',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ],
                              if (r.flags.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 4,
                                  children: r.flags
                                      .map(
                                        (f) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE0F2FE),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            _flagLabel(f),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF0369A1),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                ] else ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8ECF0)),
                    ),
                    child: const Text(
                      'Henüz topluluk yorumu yok. İlk yorumu sen bırak!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const AdBannerWidget(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

// ─── Action Button ──────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.foreground,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final color = foreground ?? RouteviaColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Source Badge ────────────────────────────────────────────────────
class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.place});
  final PlaceModel place;

  @override
  Widget build(BuildContext context) {
    final isOsm = place.sourceKind == 'osm';
    final label = isOsm
        ? 'OpenStreetMap Contributors'
        : place.sourceKind == 'open_license'
        ? 'Açık Lisans'
        : 'Routevia Curated';
    final icon = isOsm
        ? Icons.public
        : place.sourceKind == 'open_license'
        ? Icons.verified_user
        : Icons.verified;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: RouteviaColors.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Kaynak: $label',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          if (isOsm)
            GestureDetector(
              onTap: () => launchUrl(
                Uri.parse('https://www.openstreetmap.org/copyright'),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text(
                'Lisans',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0369A1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  const _TrustCard({required this.metric, required this.live});

  final Map<String, dynamic> metric;
  final Map<String, dynamic>? live;

  @override
  Widget build(BuildContext context) {
    final trust = (metric['trust_score'] as num?)?.toDouble() ?? 0;
    final spamRisk = (metric['spam_risk'] as num?)?.toDouble() ?? 0;
    final freshness = (metric['freshness_score'] as num?)?.toDouble() ?? 0;
    final signalQuality = (metric['signal_quality'] as num?)?.toDouble() ?? 0;
    final liveTags = ((live?['tag_labels'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, size: 18, color: Color(0xFF0369A1)),
              const SizedBox(width: 8),
              Text(
                'Routevia Trust ${trust.toStringAsFixed(1)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                'Spam riski ${(spamRisk * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: RouteviaColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Guncellik ${(freshness * 100).toStringAsFixed(0)}% • Sinyal kalitesi ${(signalQuality * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: RouteviaColors.textSecondary,
              fontSize: 12,
            ),
          ),
          if (liveTags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: liveTags
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    final label = switch (level) {
      'local_contributor' => 'Yerel',
      'verified_traveler' => 'Dogrulanmis',
      _ => 'Yeni',
    };
    final color = switch (level) {
      'local_contributor' => const Color(0xFF14532D),
      'verified_traveler' => const Color(0xFF075985),
      _ => const Color(0xFF64748B),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Section Card ───────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.items,
    required this.color,
  });

  final IconData icon;
  final String title;
  final List<String> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items
              .take(4)
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// ─── Stat Chip ──────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  const _StatChip(this.icon, this.label, this.count);
  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: RouteviaColors.primary),
          const SizedBox(width: 6),
          Text(
            '$label $count',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _NavOption extends StatelessWidget {
  const _NavOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: RouteviaColors.primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
