import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error_utils.dart';
import '../../core/i18n.dart';
import '../../core/widgets/safe_network_image.dart';
import '../../data/providers.dart';
import '../../models/community_post_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Admin Screen — Tab-based mobile layout
// ─────────────────────────────────────────────────────────────────────────────

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _adminAccessChecked = false;
  bool _hasAdminAccess = false;

  // ── Data state ─────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _provinces = const [];
  List<Map<String, dynamic>> _districts = const [];
  List<Map<String, dynamic>> _places = const [];
  List<Map<String, dynamic>> _suggestions = const [];
  List<Map<String, dynamic>> _pendingPhotos = const [];
  List<Map<String, dynamic>> _pendingReviews = const [];
  List<Map<String, dynamic>> _feedbackItems = const [];
  List<CommunityPostModel> _communityPosts = const [];
  List<Map<String, dynamic>> _communityReports = const [];
  List<Map<String, dynamic>> _placeStorySubmissions = const [];
  List<Map<String, dynamic>> _coordinateQueue = const [];
  final Set<String> _selectedCoordinatePlaceIds = <String>{};

  // ── Filter state ───────────────────────────────────────────────────────────
  String? _provinceSlug;
  String? _districtSlug;
  String _search = '';
  bool _includeUnpublished = true;
  String _suggestionStatus = 'pending';
  String _photoStatus = 'pending';
  String _reviewStatus = 'pending';
  String _communityPostStatus = 'pending';
  String? _coordinateProvinceFilter;
  bool _hideCoreSpotsInCoordinateQueue = true;

  // ── Loading flags ──────────────────────────────────────────────────────────
  bool _placesLoading = false;
  bool _suggestionsLoading = false;
  bool _photosLoading = false;
  bool _reviewsLoading = false;
  bool _communityPostsLoading = false;
  bool _feedbackLoading = false;
  bool _coordinateQueueLoading = false;
  bool _notifSending = false;

  int get _communityPendingCount =>
      _communityPosts.length +
      _placeStorySubmissions.length +
      _communityReports.length;

  // ── Notification state ─────────────────────────────────────────────────────
  final _notifTitleCtrl = TextEditingController(text: 'Routevia');
  final _notifBodyCtrl = TextEditingController();
  final _notifUserIdCtrl = TextEditingController();
  String? _notifResult;

  // ── Place form state ───────────────────────────────────────────────────────
  String? _editingPlaceId;
  final _nameCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '60');
  final _tagsCtrl = TextEditingController();
  final _popularityCtrl = TextEditingController(text: '500');
  final _priceCtrl = TextEditingController();
  final _historyCtrl = TextEditingController();
  final _eatDrinkCtrl = TextEditingController();
  final _tipsCtrl = TextEditingController();
  final _mediaCtrl = TextEditingController();
  String _category = 'historical';
  String _bestTime = 'day';
  bool _isFree = false;
  bool _isPublished = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      final i = _tabController.index;
      if (i == 0 && _places.isEmpty) _loadPlaces();
      if (i == 1 && _suggestions.isEmpty) _loadSuggestions();
      if (i == 2 && _pendingPhotos.isEmpty) _loadPendingPhotos();
      if (i == 3 && _pendingReviews.isEmpty) _loadPendingReviews();
      if (i == 4 && _communityPosts.isEmpty) _loadCommunityPosts();
      if (i == 5 && _feedbackItems.isEmpty) _loadFeedback();
      if (i == 6 && _coordinateQueue.isEmpty) _loadCoordinateQueue();
      // Tab 7 = notifications, no preload needed
    });
    _init();
  }

  Future<void> _init() async {
    final isAdmin = await ref.read(repositoryProvider).isCurrentUserAdmin();
    if (!mounted) return;
    setState(() {
      _adminAccessChecked = true;
      _hasAdminAccess = isAdmin;
    });
    if (!isAdmin) return;
    await _loadProvinces();
    _loadPlaces(silent: true);
    _loadSuggestions(silent: true);
    _loadPendingPhotos(silent: true);
    _loadPendingReviews(silent: true);
    _loadCommunityPosts(silent: true);
    _loadFeedback(silent: true);
    _loadCoordinateQueue(silent: true);
  }

  // ── Data loaders ───────────────────────────────────────────────────────────

  Future<void> _loadProvinces() async {
    final repo = ref.read(repositoryProvider);
    final provinces = await repo.adminQuery(mode: 'provinces');
    if (!mounted) return;
    setState(() {
      _provinces = provinces;
      _provinceSlug ??= provinces.firstOrNull?['slug'] as String?;
    });
    await _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    if (_provinceSlug == null) return;
    final repo = ref.read(repositoryProvider);
    final districts = await repo.adminQuery(
      mode: 'districts',
      provinceSlug: _provinceSlug,
    );
    if (!mounted) return;
    setState(() {
      _districts = districts;
      _districtSlug ??= districts.firstOrNull?['slug'] as String?;
    });
  }

  Future<void> _loadPlaces({bool silent = false}) async {
    if (_provinceSlug == null) return;
    setState(() => _placesLoading = true);
    try {
      final repo = ref.read(repositoryProvider);
      final places = await repo.adminQuery(
        mode: 'places',
        provinceSlug: _provinceSlug,
        query: _search.trim().isEmpty ? null : _search.trim(),
        includeUnpublished: _includeUnpublished,
      );
      if (!mounted) return;
      setState(() => _places = places);
    } catch (e) {
      if (!silent) _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _placesLoading = false);
    }
  }

  Future<void> _loadSuggestions({bool silent = false}) async {
    setState(() => _suggestionsLoading = true);
    try {
      final items = await ref
          .read(repositoryProvider)
          .adminSuggestions(
            status: _suggestionStatus,
            provinceSlug: null,
            limit: 120,
          );
      if (!mounted) return;
      setState(() => _suggestions = items);
    } catch (e) {
      if (!silent) _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _suggestionsLoading = false);
    }
  }

  Future<void> _loadPendingPhotos({bool silent = false}) async {
    setState(() => _photosLoading = true);
    try {
      final photos = await ref
          .read(repositoryProvider)
          .adminGetPhotos(
            limit: _photoStatus == 'pending' ? 100 : 200,
            status: _photoStatus == 'all' ? null : _photoStatus,
          );
      if (!mounted) return;
      setState(() => _pendingPhotos = photos);
    } catch (e) {
      if (!silent) _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _photosLoading = false);
    }
  }

  Future<void> _loadPendingReviews({bool silent = false}) async {
    setState(() => _reviewsLoading = true);
    try {
      final reviews = await ref
          .read(repositoryProvider)
          .adminGetReviews(
            limit: _reviewStatus == 'pending' ? 100 : 200,
            status: _reviewStatus == 'all' ? null : _reviewStatus,
          );
      if (!mounted) return;
      setState(() => _pendingReviews = reviews);
    } catch (e) {
      if (!silent) _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _reviewsLoading = false);
    }
  }

  Future<void> _loadFeedback({bool silent = false}) async {
    setState(() => _feedbackLoading = true);
    try {
      final items = await ref
          .read(repositoryProvider)
          .adminGetFeedback(limit: 200);
      if (!mounted) return;
      setState(() => _feedbackItems = items);
    } catch (e) {
      if (!silent) _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _feedbackLoading = false);
    }
  }

  Future<void> _loadCommunityPosts({bool silent = false}) async {
    setState(() => _communityPostsLoading = true);
    try {
      final repo = ref.read(repositoryProvider);
      final results = await Future.wait([
        repo.adminGetCommunityPosts(
          limit: _communityPostStatus == 'pending' ? 100 : 200,
          status: _communityPostStatus,
        ),
        repo.adminGetCommunityReports(),
        repo.adminGetPlaceStorySubmissions(),
      ]);
      if (!mounted) return;
      setState(() {
        _communityPosts = results[0] as List<CommunityPostModel>;
        _communityReports = results[1] as List<Map<String, dynamic>>;
        _placeStorySubmissions = results[2] as List<Map<String, dynamic>>;
      });
    } catch (e) {
      if (!silent) _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _communityPostsLoading = false);
    }
  }

  Future<void> _loadCoordinateQueue({bool silent = false}) async {
    setState(() => _coordinateQueueLoading = true);
    try {
      final items = await ref
          .read(repositoryProvider)
          .adminGetCoordinateQueue(
            limit: 150,
            provinceSlug: _coordinateProvinceFilter,
          );
      if (!mounted) return;
      setState(() {
        _coordinateQueue = items;
        _selectedCoordinatePlaceIds.removeWhere(
          (id) => !_coordinateQueue.any((item) => item['place_id'] == id),
        );
      });
    } catch (e) {
      if (!silent) _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _coordinateQueueLoading = false);
    }
  }

  Future<void> _markCoordinateVerified(
    Map<String, dynamic> item,
    String coordinateSource,
  ) async {
    final noteCtrl = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('Koordinatı Doğrula', 'Verify Coordinate')),
        content: TextField(
          controller: noteCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.tr('Not (isteğe bağlı)', 'Note (optional)'),
            hintText: context.tr(
              'Örn: OSM + manuel kontrol ile doğrulandı',
              'Ex: Verified with OSM + manual check',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.tr('Vazgeç', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.tr('Onayla', 'Confirm')),
          ),
        ],
      ),
    );
    if (submitted != true) {
      noteCtrl.dispose();
      return;
    }
    try {
      await ref
          .read(repositoryProvider)
          .adminMarkCoordinateVerified(
            placeId: item['place_id'] as String,
            coordinateSource: coordinateSource,
            note: noteCtrl.text,
          );
      if (!mounted) return;
      _toast(context.tr('Koordinat doğrulandı.', 'Coordinate verified.'));
      await _loadCoordinateQueue();
    } catch (e) {
      _toast(friendlyError(e));
    } finally {
      noteCtrl.dispose();
    }
  }

  Future<void> _bulkMarkCoordinates(String coordinateSource) async {
    final selectedIds = _selectedCoordinatePlaceIds.toList(growable: false);
    if (selectedIds.isEmpty) {
      _toast(
        context.tr(
          'Önce en az bir kayıt seç.',
          'Select at least one record first.',
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.tr('Toplu Koordinat Onayı', 'Bulk Coordinate Review'),
        ),
        content: Text(
          context.tr(
            '${selectedIds.length} kayıt $coordinateSource olarak işaretlenecek.',
            '${selectedIds.length} records will be marked as $coordinateSource.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.tr('Vazgeç', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.tr('Devam et', 'Continue')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _coordinateQueueLoading = true);
    var completed = 0;
    try {
      for (final placeId in selectedIds) {
        await ref
            .read(repositoryProvider)
            .adminMarkCoordinateVerified(
              placeId: placeId,
              coordinateSource: coordinateSource,
              note: 'bulk_admin_review',
            );
        completed += 1;
      }
      _selectedCoordinatePlaceIds.clear();
      if (!mounted) return;
      _toast(
        context.tr(
          '$completed kayıt doğrulandı.',
          '$completed records verified.',
        ),
      );
      await _loadCoordinateQueue();
    } catch (e) {
      if (!mounted) return;
      _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _coordinateQueueLoading = false);
    }
  }

  void _selectAllCoordinatesOnPage() {
    final filteredItems = _filteredCoordinateQueueItems();
    setState(() {
      _selectedCoordinatePlaceIds
        ..clear()
        ..addAll(
          filteredItems
              .map((item) => item['place_id'] as String?)
              .whereType<String>(),
        );
    });
  }

  List<Map<String, dynamic>> _filteredCoordinateQueueItems() {
    return _coordinateQueue
        .where((item) {
          if (!_hideCoreSpotsInCoordinateQueue) return true;
          final placeName = (item['place_name']?.toString() ?? '')
              .toLowerCase();
          return !placeName.contains('core spot');
        })
        .toList(growable: false);
  }

  // ── Form helpers ───────────────────────────────────────────────────────────

  void _clearForm() {
    _editingPlaceId = null;
    _nameCtrl.clear();
    _slugCtrl.clear();
    _summaryCtrl.clear();
    _latCtrl.clear();
    _lngCtrl.clear();
    _durationCtrl.text = '60';
    _tagsCtrl.clear();
    _popularityCtrl.text = '500';
    _priceCtrl.clear();
    _historyCtrl.clear();
    _eatDrinkCtrl.clear();
    _tipsCtrl.clear();
    _mediaCtrl.clear();
    _category = 'historical';
    _bestTime = 'day';
    _isFree = false;
    _isPublished = true;
    setState(() {});
  }

  void _loadPlaceToForm(Map<String, dynamic> p) {
    _editingPlaceId = p['id'] as String?;
    _provinceSlug = p['province_slug'] as String?;
    _districtSlug = p['district_slug'] as String?;
    _nameCtrl.text = p['name'] as String? ?? '';
    _slugCtrl.text = p['slug'] as String? ?? '';
    _summaryCtrl.text = p['short_summary'] as String? ?? '';
    _latCtrl.text = ((p['lat'] as num?) ?? 0).toString();
    _lngCtrl.text = ((p['lng'] as num?) ?? 0).toString();
    _durationCtrl.text = ((p['duration_min'] as num?) ?? 60).toString();
    _tagsCtrl.text = ((p['tags'] as List?) ?? const []).join(',');
    _popularityCtrl.text = ((p['popularity_score'] as num?) ?? 500).toString();
    _priceCtrl.text = ((p['price_level'] as num?)?.toInt()).toString();
    _category = p['category'] as String? ?? 'historical';
    _bestTime = p['best_time'] as String? ?? 'day';
    _isFree = p['is_free'] as bool? ?? false;
    _isPublished = p['is_published'] as bool? ?? true;
    setState(() {});
  }

  void _loadSuggestionToForm(Map<String, dynamic> s) {
    _editingPlaceId = null;
    _provinceSlug = s['province_slug'] as String?;
    _districtSlug = s['district_slug'] as String?;
    _nameCtrl.text = s['suggested_name'] as String? ?? '';
    final rawName = _nameCtrl.text.trim().toLowerCase();
    _slugCtrl.text = rawName
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
    _summaryCtrl.text = s['short_note'] as String? ?? '';
    _latCtrl.text = ((s['lat'] as num?)?.toDouble())?.toString() ?? '';
    _lngCtrl.text = ((s['lng'] as num?)?.toDouble())?.toString() ?? '';
    _durationCtrl.text = '60';
    _tagsCtrl.text = ((s['suggested_tags'] as List?) ?? const []).join(',');
    _popularityCtrl.text = '500';
    _priceCtrl.clear();
    _historyCtrl.clear();
    _eatDrinkCtrl.clear();
    _tipsCtrl.text = [
      if ((s['source_url'] as String?)?.isNotEmpty ?? false)
        'Kaynak: ${s['source_url']}',
    ].join('\n');
    _mediaCtrl.clear();
    _category = s['suggested_category'] as String? ?? 'historical';
    _bestTime =
        _category == 'food' || _category == 'cafe' || _category == 'lodging'
        ? 'night'
        : 'day';
    _isFree = false;
    _isPublished = false;
    setState(() {});
  }

  Future<void> _savePlace() async {
    if (_provinceSlug == null) {
      _toast('Önce il seçin');
      return;
    }
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null || lng == null) {
      _toast('Enlem/Boylam geçersiz');
      return;
    }
    final payload = {
      if (_editingPlaceId != null) 'id': _editingPlaceId,
      'province_slug': _provinceSlug,
      'district_slug': _districtSlug,
      'name': _nameCtrl.text.trim(),
      'slug': _slugCtrl.text.trim(),
      'category': _category,
      'lat': lat,
      'lng': lng,
      'short_summary': _summaryCtrl.text.trim(),
      'best_time': _bestTime,
      'duration_min': int.tryParse(_durationCtrl.text.trim()) ?? 60,
      'tags': _tagsCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'popularity_score': int.tryParse(_popularityCtrl.text.trim()) ?? 500,
      'is_free': _isFree,
      'price_level': int.tryParse(_priceCtrl.text.trim()),
      'is_published': _isPublished,
      'history_bullets': _historyCtrl.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .take(3)
          .toList(),
      'eat_drink_bullets': _eatDrinkCtrl.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .take(3)
          .toList(),
      'tips_bullets': _tipsCtrl.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .take(4)
          .toList(),
      'media_paths': _mediaCtrl.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    };
    try {
      await ref.read(repositoryProvider).adminUpsertPlace(payload);
      _toast('Kaydedildi');
      if (mounted) Navigator.of(context).pop();
      await _loadPlaces();
    } catch (e) {
      _toast(friendlyError(e));
    }
  }

  Future<void> _reviewPhoto(
    Map<String, dynamic> photo,
    String status, {
    bool setCover = false,
  }) async {
    try {
      await ref
          .read(repositoryProvider)
          .adminReviewPhoto(
            photo['id'] as String,
            status: status,
            note: status == 'approved' ? 'admin_approved' : 'admin_rejected',
            setCover: setCover,
            userId: photo['user_id'] as String?,
            placeName: (photo['pois'] as Map?)?['name'] as String?,
          );
      _toast(
        status == 'approved'
            ? (setCover
                  ? 'Fotoğraf yayınlandı ve ana görsel yapıldı.'
                  : 'Fotoğraf yayınlandı.')
            : 'Reddedildi.',
      );
      await _loadPendingPhotos();
    } catch (e) {
      _toast(friendlyError(e));
    }
  }

  Future<void> _reviewSuggestion(
    Map<String, dynamic> suggestion,
    String decision,
  ) async {
    final successMessage = decision == 'approved'
        ? context.tr('Öneri onaylandı', 'Suggestion approved')
        : context.tr('Öneri reddedildi', 'Suggestion rejected');
    final noteCtrl = TextEditingController(
      text: decision == 'approved'
          ? context.tr('Moderasyon tamamlandı.', 'Moderation completed.')
          : context.tr(
              'Yetersiz içerik / doğrulanamadı.',
              'Insufficient content / could not be verified.',
            ),
    );
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          decision == 'approved'
              ? context.tr('Öneriyi Onayla', 'Approve Suggestion')
              : context.tr('Öneriyi Reddet', 'Reject Suggestion'),
        ),
        content: TextField(
          controller: noteCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.tr('Admin notu', 'Admin note'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.tr('Vazgeç', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              decision == 'approved'
                  ? context.tr('Onayla', 'Approve')
                  : context.tr('Reddet', 'Reject'),
            ),
          ),
        ],
      ),
    );
    if (submitted != true) {
      noteCtrl.dispose();
      return;
    }
    final adminNote = noteCtrl.text.trim();
    noteCtrl.dispose();
    try {
      await ref
          .read(repositoryProvider)
          .adminReviewSuggestion(
            suggestionId: suggestion['id'] as String,
            decision: decision,
            adminNote: adminNote,
          );
      _toast(successMessage);
      await _loadSuggestions();
    } catch (e) {
      _toast(friendlyError(e));
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openPlaceForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => _PlaceFormSheet(
        parent: this,
        provinces: _provinces,
        districts: _districts,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _summaryCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _durationCtrl.dispose();
    _tagsCtrl.dispose();
    _popularityCtrl.dispose();
    _priceCtrl.dispose();
    _historyCtrl.dispose();
    _eatDrinkCtrl.dispose();
    _tipsCtrl.dispose();
    _mediaCtrl.dispose();
    _notifTitleCtrl.dispose();
    _notifBodyCtrl.dispose();
    _notifUserIdCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('Admin Panel', 'Admin Panel'))),
        body: Center(
          child: Text(
            context.tr(
              'Admin için önce giriş yapmalısın.',
              'You need to sign in before opening the admin panel.',
            ),
          ),
        ),
      );
    }
    if (!_adminAccessChecked) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('Admin Panel', 'Admin Panel'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!_hasAdminAccess) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('Admin Panel', 'Admin Panel'))),
        body: Center(
          child: Text(
            context.tr(
              'Bu hesap admin yetkisine sahip değil.',
              'This account does not have admin access.',
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Admin Panel', 'Admin Panel')),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(
              child: _tabLabel(
                Icons.place_outlined,
                context.tr('Yerler', 'Places'),
                _places.isNotEmpty ? '${_places.length}' : null,
              ),
            ),
            Tab(
              child: _tabLabel(
                Icons.lightbulb_outline,
                context.tr('Öneriler', 'Suggestions'),
                _suggestionStatus == 'pending' && _suggestions.isNotEmpty
                    ? '${_suggestions.length}'
                    : null,
                badge:
                    _suggestionStatus == 'pending' && _suggestions.isNotEmpty,
              ),
            ),
            Tab(
              child: _tabLabel(
                Icons.photo_library_outlined,
                context.tr('Fotoğraflar', 'Photos'),
                _pendingPhotos.isNotEmpty ? '${_pendingPhotos.length}' : null,
                badge: _pendingPhotos.isNotEmpty,
              ),
            ),
            Tab(
              child: _tabLabel(
                Icons.star_outline,
                context.tr('Yorumlar', 'Reviews'),
                _pendingReviews.isNotEmpty ? '${_pendingReviews.length}' : null,
                badge: _pendingReviews.isNotEmpty,
              ),
            ),
            Tab(
              child: _tabLabel(
                Icons.auto_stories_outlined,
                context.tr('Topluluk', 'Community'),
                _communityPendingCount > 0 ? '$_communityPendingCount' : null,
                badge: _communityPendingCount > 0,
              ),
            ),
            Tab(
              child: _tabLabel(
                Icons.feedback_outlined,
                'Feedback',
                _feedbackItems.isNotEmpty ? '${_feedbackItems.length}' : null,
              ),
            ),
            Tab(
              child: _tabLabel(
                Icons.my_location_outlined,
                context.tr('Koordinat', 'Coordinates'),
                _coordinateQueue.isNotEmpty
                    ? '${_coordinateQueue.length}'
                    : null,
                badge: _coordinateQueue.isNotEmpty,
              ),
            ),
            Tab(
              child: _tabLabel(
                Icons.notifications_outlined,
                context.tr('Bildirim', 'Notifications'),
                null,
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlacesTab(),
          _buildSuggestionsTab(),
          _buildPhotosTab(),
          _buildReviewsTab(),
          _buildCommunityPostsTab(),
          _buildFeedbackTab(),
          _buildCoordinateQueueTab(),
          _buildNotifTab(),
        ],
      ),
    );
  }

  Widget _tabLabel(
    IconData icon,
    String label,
    String? count, {
    bool badge = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Text(label),
        if (count != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: badge
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF0B3B68).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: badge ? Colors.white : const Color(0xFF0B3B68),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 0: Places
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPlacesTab() {
    if (_provinces.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_city_outlined,
                size: 48,
                color: Colors.black26,
              ),
              const SizedBox(height: 12),
              Text(
                context.tr(
                  'Il listesi yuklenemedi. Yeniden dene.',
                  'Province list could not be loaded. Try again.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loadProvinces,
                icon: const Icon(Icons.refresh),
                label: Text(context.tr('Tekrar Dene', 'Retry')),
              ),
            ],
          ),
        ),
      );
    }

    final provinceValues = _provinces
        .map((p) => p['slug']?.toString())
        .whereType<String>()
        .toSet();
    final safeProvinceSlug = provinceValues.contains(_provinceSlug)
        ? _provinceSlug
        : (_provinces.firstOrNull?['slug'] as String?);

    final districtValues = _districts
        .map((d) => d['slug']?.toString())
        .whereType<String>()
        .toSet();
    final safeDistrictSlug = districtValues.contains(_districtSlug)
        ? _districtSlug
        : null;

    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(safeProvinceSlug),
                      initialValue: safeProvinceSlug,
                      decoration: const InputDecoration(
                        labelText: 'İl',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items: _provinces
                          .map(
                            (p) => DropdownMenuItem(
                              value: p['slug'] as String,
                              child: Text(p['name'] as String),
                            ),
                          )
                          .toList(),
                      onChanged: (v) async {
                        if (v == null) return;
                        setState(() {
                          _provinceSlug = v;
                          _districtSlug = null;
                        });
                        await _loadDistricts();
                        await _loadPlaces();
                        await _loadSuggestions();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      key: ValueKey(safeDistrictSlug),
                      initialValue: safeDistrictSlug,
                      decoration: const InputDecoration(
                        labelText: 'İlçe',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(context.tr('Tümü', 'All')),
                        ),
                        ..._districts.map(
                          (d) => DropdownMenuItem(
                            value: d['slug'] as String,
                            child: Text(d['name'] as String),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _districtSlug = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Yer ara...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => _search = v,
                      onSubmitted: (_) => _loadPlaces(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(context.tr('Taslak', 'Draft')),
                    selected: _includeUnpublished,
                    onSelected: (v) {
                      setState(() => _includeUnpublished = v);
                      _loadPlaces();
                    },
                  ),
                  const SizedBox(width: 6),
                  IconButton.filled(
                    onPressed: _loadPlaces,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Yenile',
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 16),
        // Place list
        Expanded(
          child: _placesLoading
              ? const Center(child: CircularProgressIndicator())
              : _places.isEmpty
              ? Center(child: Text(context.tr('Sonuç yok', 'No results')))
              : ListView.separated(
                  itemCount: _places.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = _places[index];
                    final published = p['is_published'] as bool? ?? false;
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: published
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          published
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: published
                              ? const Color(0xFF15803D)
                              : const Color(0xFFD97706),
                        ),
                      ),
                      title: Text(
                        p['name'] as String? ?? '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${p['category'] ?? '-'} • ${p['district_name'] ?? 'Merkez'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if ((p['app_rating'] ?? p['rating']) != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: Color(0xFFFFB703),
                                  ),
                                  Text(
                                    (p['app_rating'] ?? p['rating']).toString(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          IconButton(
                            onPressed: () {
                              _loadPlaceToForm(p);
                              _openPlaceForm();
                            },
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Düzenle',
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 1: Suggestions
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSuggestionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'pending',
                      label: Text(context.tr('Bekleyen', 'Pending')),
                    ),
                    ButtonSegment(
                      value: 'approved',
                      label: Text(context.tr('Onaylı', 'Approved')),
                    ),
                    ButtonSegment(
                      value: 'rejected',
                      label: Text(context.tr('Reddedildi', 'Rejected')),
                    ),
                  ],
                  selected: {_suggestionStatus},
                  onSelectionChanged: (values) async {
                    setState(() => _suggestionStatus = values.first);
                    await _loadSuggestions();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _loadSuggestions,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _suggestionsLoading
              ? const Center(child: CircularProgressIndicator())
              : _suggestions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.black26,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _suggestionStatus == 'pending'
                            ? 'Bekleyen öneri yok'
                            : 'Bu filtrede öneri yok',
                        style: const TextStyle(color: Colors.black45),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final s = _suggestions[index];
                    return _SuggestionCard(
                      suggestion: s,
                      onFormLoad: () {
                        _loadSuggestionToForm(s);
                        _tabController.animateTo(0);
                        Future.delayed(const Duration(milliseconds: 300), () {
                          _openPlaceForm();
                        });
                      },
                      onApprove: _suggestionStatus == 'pending'
                          ? () => _reviewSuggestion(s, 'approved')
                          : null,
                      onReject: _suggestionStatus == 'pending'
                          ? () => _reviewSuggestion(s, 'rejected')
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 2: Photos
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPhotosTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Foto moderasyonu',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _photoStatus == 'pending'
                          ? 'Onay bekleyen fotoğraflar'
                          : _photoStatus == 'approved'
                          ? 'Onaylanmış fotoğraflar'
                          : _photoStatus == 'rejected'
                          ? 'Reddedilmiş fotoğraflar'
                          : 'Tum fotoğraflar',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: _loadPendingPhotos,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'pending',
                  label: Text(context.tr('Bekleyen', 'Pending')),
                ),
                ButtonSegment(
                  value: 'approved',
                  label: Text(context.tr('Onaylı', 'Approved')),
                ),
                ButtonSegment(
                  value: 'rejected',
                  label: Text(context.tr('Reddedildi', 'Rejected')),
                ),
                ButtonSegment(
                  value: 'all',
                  label: Text(context.tr('Tümü', 'All')),
                ),
              ],
              selected: {_photoStatus},
              onSelectionChanged: (values) async {
                setState(() => _photoStatus = values.first);
                await _loadPendingPhotos();
              },
            ),
          ),
        ),
        Expanded(
          child: _photosLoading
              ? const Center(child: CircularProgressIndicator())
              : _pendingPhotos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: Colors.black26,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _photoStatus == 'pending'
                            ? 'Onay bekleyen fotoğraf yok'
                            : 'Bu filtrede fotoğraf yok',
                        style: const TextStyle(color: Colors.black45),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  itemCount: _pendingPhotos.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final photo = _pendingPhotos[index];
                    return _PhotoCard(
                      photo: photo,
                      onApprove: photo['status'] == 'approved'
                          ? null
                          : () => _reviewPhoto(photo, 'approved'),
                      onApproveAsCover: () =>
                          _reviewPhoto(photo, 'approved', setCover: true),
                      onReject: photo['status'] == 'rejected'
                          ? null
                          : () => _reviewPhoto(photo, 'rejected'),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 3: Reviews
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildReviewsTab() {
    final emptyText = _reviewStatus == 'pending'
        ? 'Onay bekleyen yorum yok'
        : 'Bu filtrede yorum yok';
    if (_reviewsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pendingReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Color(0xFF15803D),
            ),
            const SizedBox(height: 12),
            Text(emptyText, style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'pending',
                  label: Text(context.tr('Bekleyen', 'Pending')),
                ),
                ButtonSegment(
                  value: 'approved',
                  label: Text(context.tr('Onaylı', 'Approved')),
                ),
                ButtonSegment(
                  value: 'hidden',
                  label: Text(context.tr('Gizli', 'Hidden')),
                ),
                ButtonSegment(
                  value: 'all',
                  label: Text(context.tr('Tümü', 'All')),
                ),
              ],
              selected: {_reviewStatus},
              onSelectionChanged: (values) async {
                setState(() => _reviewStatus = values.first);
                await _loadPendingReviews();
              },
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadPendingReviews,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _pendingReviews.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final review = _pendingReviews[index];
                return _ReviewCard(
                  review: review,
                  onApprove: () async {
                    try {
                      await ref
                          .read(repositoryProvider)
                          .adminReviewReview(
                            review['id'] as String,
                            status: 'approved',
                            userId: review['user_id'] as String?,
                            placeName:
                                (review['pois'] as Map?)?['name'] as String?,
                          );
                      if (mounted) {
                        setState(() => _pendingReviews.removeAt(index));
                        _toast('Yorum onaylandı.');
                      }
                    } catch (e) {
                      if (mounted) _toast(friendlyError(e));
                    }
                  },
                  onReject: () async {
                    try {
                      await ref
                          .read(repositoryProvider)
                          .adminReviewReview(
                            review['id'] as String,
                            status: 'hidden',
                            userId: review['user_id'] as String?,
                            placeName:
                                (review['pois'] as Map?)?['name'] as String?,
                          );
                      if (mounted) {
                        setState(() => _pendingReviews.removeAt(index));
                        _toast('Yorum gizlendi.');
                      }
                    } catch (e) {
                      if (mounted) _toast(friendlyError(e));
                    }
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityPostsTab() {
    final emptyText = _communityPostStatus == 'pending'
        ? context.tr(
            'Onay bekleyen topluluk yazısı yok',
            'There is no pending community post',
          )
        : context.tr(
            'Bu filtrede yazı yok',
            'There are no posts in this filter',
          );
    final hasAnyCommunityQueueItems =
        _communityPosts.isNotEmpty ||
        _placeStorySubmissions.isNotEmpty ||
        _communityReports.isNotEmpty;
    if (_communityPostsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!hasAnyCommunityQueueItems) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Color(0xFF15803D),
            ),
            const SizedBox(height: 12),
            Text(emptyText, style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'pending',
                  label: Text(context.tr('Bekleyen', 'Pending')),
                ),
                ButtonSegment(
                  value: 'approved',
                  label: Text(context.tr('Onaylı', 'Approved')),
                ),
                ButtonSegment(
                  value: 'rejected',
                  label: Text(context.tr('Reddedildi', 'Rejected')),
                ),
                ButtonSegment(
                  value: 'all',
                  label: Text(context.tr('Tümü', 'All')),
                ),
              ],
              selected: {_communityPostStatus},
              onSelectionChanged: (values) async {
                setState(() => _communityPostStatus = values.first);
                await _loadCommunityPosts();
              },
            ),
          ),
        ),
        if (_placeStorySubmissions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.tr(
                  'Yer hikayeleri bu sekmede gorunur.',
                  'Place stories appear in this tab.',
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadCommunityPosts,
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                ...List.generate(_communityPosts.length, (index) {
                  final post = _communityPosts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CommunityModerationCard(
                      post: post,
                      onApprove: () async {
                        try {
                          final message = context.tr(
                            'Yazı onaylandı.',
                            'Post approved.',
                          );
                          await ref
                              .read(repositoryProvider)
                              .adminReviewCommunityPost(
                                post.id,
                                status: 'approved',
                              );
                          if (!context.mounted) return;
                          setState(() => _communityPosts.removeAt(index));
                          _toast(message);
                        } catch (e) {
                          if (!context.mounted) return;
                          _toast(friendlyError(e));
                        }
                      },
                      onReject: () async {
                        final rejectedMessage = context.tr(
                          'Yazı reddedildi.',
                          'Post rejected.',
                        );
                        final noteCtrl = TextEditingController(
                          text: post.adminNote,
                        );
                        final note = await showDialog<String?>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(
                              context.tr('Red Notu', 'Rejection Note'),
                            ),
                            content: TextField(
                              controller: noteCtrl,
                              minLines: 3,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: context.tr(
                                  'Neyi düzeltmesi gerektiğini kısa anlat.',
                                  'Briefly explain what needs to be fixed.',
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(null),
                                child: Text(context.tr('Vazgeç', 'Cancel')),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(noteCtrl.text.trim()),
                                child: Text(context.tr('Reddet', 'Reject')),
                              ),
                            ],
                          ),
                        );
                        if (note == null) return;
                        try {
                          await ref
                              .read(repositoryProvider)
                              .adminReviewCommunityPost(
                                post.id,
                                status: 'rejected',
                                adminNote: note,
                              );
                          if (!context.mounted) return;
                          setState(() => _communityPosts.removeAt(index));
                          _toast(rejectedMessage);
                        } catch (e) {
                          if (!context.mounted) return;
                          _toast(friendlyError(e));
                        }
                      },
                    ),
                  );
                }),
                if (_placeStorySubmissions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    context.tr('Yer Hikâyeleri', 'Place Stories'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(_placeStorySubmissions.length, (index) {
                    final item = _placeStorySubmissions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PlaceStoryModerationCard(
                        item: item,
                        onApprove: () async {
                          try {
                            final message = context.tr(
                              'Yer hikâyesi onaylandı.',
                              'Place story approved.',
                            );
                            await ref
                                .read(repositoryProvider)
                                .adminReviewPlaceStorySubmission(
                                  item['id'].toString(),
                                  status: 'approved',
                                );
                            if (!context.mounted) return;
                            await _loadCommunityPosts(silent: true);
                            _toast(message);
                          } catch (e) {
                            if (!context.mounted) return;
                            _toast(friendlyError(e));
                          }
                        },
                        onReject: () async {
                          try {
                            final message = context.tr(
                              'Yer hikâyesi reddedildi.',
                              'Place story rejected.',
                            );
                            await ref
                                .read(repositoryProvider)
                                .adminReviewPlaceStorySubmission(
                                  item['id'].toString(),
                                  status: 'rejected',
                                  adminNote: 'Rejected by admin',
                                );
                            if (!context.mounted) return;
                            await _loadCommunityPosts(silent: true);
                            _toast(message);
                          } catch (e) {
                            if (!context.mounted) return;
                            _toast(friendlyError(e));
                          }
                        },
                      ),
                    );
                  }),
                ],
                if (_communityReports.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    context.tr('İçerik Bildirimleri', 'Content Reports'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(_communityReports.length, (index) {
                    final item = _communityReports[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CommunityReportCard(
                        item: item,
                        onResolve: () async {
                          final message = context.tr(
                            'Bildirim incelendi.',
                            'Report marked as reviewed.',
                          );
                          await ref
                              .read(repositoryProvider)
                              .adminReviewCommunityReport(
                                item['id'].toString(),
                                status: 'reviewed',
                              );
                          if (!context.mounted) return;
                          setState(() => _communityReports.removeAt(index));
                          _toast(message);
                        },
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 5: Feedback
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFeedbackTab() {
    if (_feedbackLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_feedbackItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: Colors.black26),
            const SizedBox(height: 12),
            Text(context.tr('Henüz geri bildirim yok', 'No feedback yet')),
          ],
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Kullanıcı geri bildirimleri',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              IconButton.filled(
                onPressed: _loadFeedback,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadFeedback,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              itemCount: _feedbackItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _feedbackItems[index];
                final createdAt = DateTime.tryParse(
                  item['created_at'] as String? ?? '',
                );
                final rating = (item['rating'] as num?)?.toInt();
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['display_name'] as String? ??
                                        'Kullanici',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['user_id'] as String? ?? 'Anonim',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (rating != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: Color(0xFFF59E0B),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$rating/5',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['message'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF374151),
                            height: 1.45,
                          ),
                        ),
                        if (createdAt != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            '${createdAt.day}.${createdAt.month}.${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 5: Coordinate Queue
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCoordinateQueueTab() {
    final filteredItems = _filteredCoordinateQueueItems();
    final provinceOptions = _provinces
        .map((item) => item['slug']?.toString() ?? '')
        .where((slug) => slug.isNotEmpty)
        .toList(growable: false);
    final selectedCount = _selectedCoordinatePlaceIds.length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Text(
                    context.tr(
                      'Legacy koordinatlar burada doğrulanır. Onay verildiğinde kayıt güvenli kaynak sınıfına taşınır.',
                      'Legacy coordinates are verified here. Once approved, the record moves to a trusted source class.',
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _loadCoordinateQueue,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: Text(context.tr('Core Spot gizle', 'Hide Core Spot')),
                  selected: _hideCoreSpotsInCoordinateQueue,
                  onSelected: (value) {
                    setState(() {
                      _hideCoreSpotsInCoordinateQueue = value;
                      _selectedCoordinatePlaceIds.clear();
                    });
                  },
                ),
              ),
              Text(
                context.tr(
                  '${filteredItems.length} kayıt görünüyor',
                  '${filteredItems.length} records visible',
                ),
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: DropdownButtonFormField<String?>(
            initialValue: _coordinateProvinceFilter,
            decoration: InputDecoration(
              labelText: context.tr('İl Filtresi', 'Province Filter'),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(context.tr('Tümü', 'All')),
              ),
              ...provinceOptions.map(
                (provinceSlug) => DropdownMenuItem<String?>(
                  value: provinceSlug,
                  child: Text(
                    (_provinces.firstWhere(
                              (item) => item['slug'] == provinceSlug,
                              orElse: () => const {},
                            )['name'] ??
                            provinceSlug)
                        .toString(),
                  ),
                ),
              ),
            ],
            onChanged: (value) async {
              setState(() {
                _coordinateProvinceFilter = value;
                _selectedCoordinatePlaceIds.clear();
              });
              await _loadCoordinateQueue();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedCount == 0
                      ? context.tr(
                          'Toplu onay için kayıt seçebilirsin.',
                          'You can select records for bulk review.',
                        )
                      : context.tr(
                          '$selectedCount kayıt seçildi.',
                          '$selectedCount records selected.',
                        ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              TextButton(
                onPressed: _selectedCoordinatePlaceIds.isEmpty
                    ? null
                    : () => setState(() => _selectedCoordinatePlaceIds.clear()),
                child: Text(context.tr('Temizle', 'Clear')),
              ),
              TextButton(
                onPressed: filteredItems.isEmpty
                    ? null
                    : _selectAllCoordinatesOnPage,
                child: Text(context.tr('Sayfayı Seç', 'Select Page')),
              ),
              FilledButton.tonal(
                onPressed: _selectedCoordinatePlaceIds.isEmpty
                    ? null
                    : () => _bulkMarkCoordinates('admin_verified'),
                child: const Text('Bulk Admin'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _coordinateQueueLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredItems.isEmpty
              ? Center(
                  child: Text(
                    context.tr(
                      'Bekleyen koordinat doğrulaması yok.',
                      'There is no pending coordinate verification.',
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final placeId = item['place_id'] as String;
                    final isSelected = _selectedCoordinatePlaceIds.contains(
                      placeId,
                    );
                    final lat = (item['lat'] as num?)?.toDouble();
                    final lng = (item['lng'] as num?)?.toDouble();
                    final province = item['province_name']?.toString() ?? '—';
                    final source =
                        item['coordinate_source']?.toString() ??
                        'legacy_curated_unverified';
                    final note = item['note']?.toString();
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (_) {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedCoordinatePlaceIds.remove(
                                        placeId,
                                      );
                                    } else {
                                      _selectedCoordinatePlaceIds.add(placeId);
                                    }
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  item['place_name']?.toString() ?? '—',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  source,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF3730A3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${item['place_category'] ?? '—'} • $province',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          if ((item['place_summary']
                                  ?.toString()
                                  .trim()
                                  .isNotEmpty ??
                              false)) ...[
                            const SizedBox(height: 6),
                            Text(
                              item['place_summary'].toString(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Lat/Lng: ${lat?.toStringAsFixed(5) ?? '—'}, ${lng?.toStringAsFixed(5) ?? '—'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          if (note != null && note.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              note,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () => _markCoordinateVerified(
                                  item,
                                  'osm_verified',
                                ),
                                icon: const Icon(Icons.public, size: 18),
                                label: const Text('OSM'),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: () => _markCoordinateVerified(
                                  item,
                                  'admin_verified',
                                ),
                                icon: const Icon(
                                  Icons.verified_user_outlined,
                                  size: 18,
                                ),
                                label: const Text('Admin'),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: () => _markCoordinateVerified(
                                  item,
                                  'user_verified',
                                ),
                                icon: const Icon(
                                  Icons.people_alt_outlined,
                                  size: 18,
                                ),
                                label: const Text('User'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 6: Push Notifications
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildNotifTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Push Bildirimi Gönder',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: const Text(
            'Kullanıcı ID boş bırakılırsa tüm kullanıcılara (maks 500) bildirim gönderilir. Belirli bir kullanıcıya göndermek için User UUID girin.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF0369A1),
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notifUserIdCtrl,
          decoration: const InputDecoration(
            labelText: 'Kullanıcı ID (isteğe bağlı)',
            hintText: 'UUID — boş bırakılırsa herkese',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notifTitleCtrl,
          decoration: const InputDecoration(
            labelText: 'Başlık',
            prefixIcon: Icon(Icons.title),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notifBodyCtrl,
          decoration: const InputDecoration(
            labelText: 'Mesaj',
            prefixIcon: Icon(Icons.message_outlined),
          ),
          minLines: 3,
          maxLines: 5,
          maxLength: 500,
        ),
        const SizedBox(height: 16),
        if (_notifResult != null)
          _NotifResultBanner(result: _notifResult!),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _notifSending ? null : _sendNotification,
            icon: _notifSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(_notifSending ? 'Gönderiliyor…' : 'Bildirim Gönder'),
          ),
        ),
      ],
    );
  }

  Future<void> _sendNotification() async {
    final title = _notifTitleCtrl.text.trim();
    final body = _notifBodyCtrl.text.trim();
    final userId = _notifUserIdCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      _toast('Başlık ve mesaj zorunludur.');
      return;
    }
    setState(() {
      _notifSending = true;
      _notifResult = null;
    });
    try {
      final result = await ref
          .read(repositoryProvider)
          .adminSendPushNotification(
            userId: userId.isEmpty ? null : userId,
            title: title,
            body: body,
          );
      if (!mounted) return;
      final sent = result['sent'] as int? ?? 0;
      final failed = result['failed'] as int? ?? 0;
      final skipped = result['skipped'] as String?;
      if (skipped == 'firebase_secrets_missing') {
        setState(
          () => _notifResult =
              'setup:Firebase kimlik bilgileri ayarlanmamış.\n'
              'Supabase → Edge Functions → Secrets bölümüne şunları ekle:\n'
              '• FIREBASE_SERVICE_ACCOUNT_JSON\n'
              '  (ya da ayrı ayrı: FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY)',
        );
      } else if (skipped == 'no_push_tokens') {
        setState(
          () => _notifResult = 'warn:Kayıtlı push token yok — henüz bildirim izni veren kullanıcı bulunmuyor.',
        );
      } else if (skipped != null) {
        setState(() => _notifResult = 'warn:Atlandı: $skipped');
      } else {
        setState(
          () => _notifResult =
              'ok:Gönderildi: $sent cihaz${failed > 0 ? ' | Başarısız: $failed' : ''}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _notifResult = 'err:${friendlyError(e)}');
    } finally {
      if (mounted) setState(() => _notifSending = false);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Place Form Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PlaceFormSheet extends StatefulWidget {
  const _PlaceFormSheet({
    required this.parent,
    required this.provinces,
    required this.districts,
  });

  final _AdminScreenState parent;
  final List<Map<String, dynamic>> provinces;
  final List<Map<String, dynamic>> districts;

  @override
  State<_PlaceFormSheet> createState() => _PlaceFormSheetState();
}

class _PlaceFormSheetState extends State<_PlaceFormSheet> {
  late String _category;
  late String _bestTime;
  late bool _isFree;
  late bool _isPublished;
  String? _provinceSlug;
  String? _districtSlug;

  @override
  void initState() {
    super.initState();
    final p = widget.parent;
    _category = p._category;
    _bestTime = p._bestTime;
    _isFree = p._isFree;
    _isPublished = p._isPublished;
    _provinceSlug = p._provinceSlug;
    _districtSlug = p._districtSlug;
  }

  void _syncToParent() {
    final p = widget.parent;
    p._category = _category;
    p._bestTime = _bestTime;
    p._isFree = _isFree;
    p._isPublished = _isPublished;
    p._provinceSlug = _provinceSlug;
    p._districtSlug = _districtSlug;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.parent;
    final isEditing = p._editingPlaceId != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isEditing ? 'Yer Düzenle' : 'Yeni Yer Ekle',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    p._clearForm();
                    Navigator.of(context).pop();
                  },
                  child: Text(context.tr('Temizle', 'Clear')),
                ),
              ],
            ),
          ),
          const Divider(),
          // Scrollable form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Province / District
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(_provinceSlug),
                          initialValue: _provinceSlug,
                          decoration: const InputDecoration(
                            labelText: 'İl',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: widget.provinces
                              .map(
                                (pr) => DropdownMenuItem(
                                  value: pr['slug'] as String,
                                  child: Text(pr['name'] as String),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _provinceSlug = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          key: ValueKey(_districtSlug),
                          initialValue: _districtSlug,
                          decoration: const InputDecoration(
                            labelText: 'İlçe',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('—'),
                            ),
                            ...widget.districts.map(
                              (d) => DropdownMenuItem(
                                value: d['slug'] as String,
                                child: Text(d['name'] as String),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _districtSlug = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Name
                  TextField(
                    controller: p._nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Yer Adı',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      // auto-slug
                      final slug = v
                          .toLowerCase()
                          .replaceAll(RegExp(r'[çÇ]'), 'c')
                          .replaceAll(RegExp(r'[şŞ]'), 's')
                          .replaceAll(RegExp(r'[ğĞ]'), 'g')
                          .replaceAll(RegExp(r'[üÜ]'), 'u')
                          .replaceAll(RegExp(r'[öÖ]'), 'o')
                          .replaceAll(RegExp(r'[ıİ]'), 'i')
                          .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
                          .trim()
                          .replaceAll(RegExp(r'\s+'), '-');
                      if (p._editingPlaceId == null) {
                        p._slugCtrl.text = slug;
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // Slug
                  TextField(
                    controller: p._slugCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Slug (URL anahtarı)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Summary
                  TextField(
                    controller: p._summaryCtrl,
                    maxLength: 160,
                    decoration: const InputDecoration(
                      labelText: 'Kısa açıklama (≤160 karakter)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Category + Best time
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(_category),
                          initialValue: _category,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items:
                              const [
                                    'museum',
                                    'historical',
                                    'nature',
                                    'beach',
                                    'viewpoint',
                                    'market',
                                    'mall',
                                    'cafe',
                                    'food',
                                    'activity',
                                    'lodging',
                                  ]
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) =>
                              setState(() => _category = v ?? 'historical'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(_bestTime),
                          initialValue: _bestTime,
                          decoration: const InputDecoration(
                            labelText: 'En iyi zaman',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: const ['morning', 'day', 'sunset', 'night']
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _bestTime = v ?? 'day'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Lat / Lng
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: p._latCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Enlem (lat)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: p._lngCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Boylam (lng)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Duration / Popularity / Price
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: p._durationCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Süre (dk)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: p._popularityCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Popülerlik',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: p._priceCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Fiyat (0-4)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Tags
                  TextField(
                    controller: p._tagsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Etiketler (virgülle ayır)',
                      hintText: 'tarih,kültür,doğa',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Flags
                  Row(
                    children: [
                      FilterChip(
                        label: Text(context.tr('Ücretsiz', 'Free')),
                        selected: _isFree,
                        onSelected: (v) => setState(() => _isFree = v),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text(context.tr('Yayında', 'Published')),
                        selected: _isPublished,
                        selectedColor: const Color(0xFFDCFCE7),
                        onSelected: (v) => setState(() => _isPublished = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const _FormSectionLabel(
                    'Tarihçe maddeleri (satır başına, max 3)',
                  ),
                  TextField(
                    controller: p._historyCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'M.S. 7. yüzyılda inşa edildi\n...',
                    ),
                  ),
                  const SizedBox(height: 10),

                  const _FormSectionLabel(
                    'Yeme/İçme maddeleri (satır başına, max 3)',
                  ),
                  TextField(
                    controller: p._eatDrinkCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Yakında çok sayıda restoran\n...',
                    ),
                  ),
                  const SizedBox(height: 10),

                  const _FormSectionLabel(
                    'İpucu maddeleri (satır başına, max 4)',
                  ),
                  TextField(
                    controller: p._tipsCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Sabah erken saatlerde gidin\n...',
                    ),
                  ),
                  const SizedBox(height: 10),

                  const _FormSectionLabel('Medya path (satır başına)'),
                  TextField(
                    controller: p._mediaCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'public-media/seed/izmir/kordon/1.jpg\n...',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        _syncToParent();
                        widget.parent._savePlace();
                      },
                      icon: Icon(
                        isEditing ? Icons.save_outlined : Icons.add_rounded,
                      ),
                      label: Text(isEditing ? 'Güncelle' : 'Yayınla'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0B3B68),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Community Moderation Card
// ─────────────────────────────────────────────────────────────────────────────

class _CommunityModerationCard extends StatelessWidget {
  const _CommunityModerationCard({
    required this.post,
    required this.onApprove,
    required this.onReject,
  });

  final CommunityPostModel post;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (post.status) {
      'approved' => const Color(0xFF15803D),
      'rejected' => const Color(0xFFDC2626),
      _ => const Color(0xFFD97706),
    };
    final statusLabel = switch (post.status) {
      'approved' => context.tr('Onaylı', 'Approved'),
      'rejected' => context.tr('Reddedildi', 'Rejected'),
      _ => context.tr('Beklemede', 'Pending'),
    };
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((post.coverImageUrl ?? '').isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SafeNetworkImage(
                  url: post.coverImageUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${post.city}, ${post.country} • ${post.postType == 'guide' ? 'guide' : 'story'}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF334155), height: 1.45),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                'Gönderen: ${post.submitterName ?? 'Routevia gezgini'}',
                'By ${post.submitterName ?? 'Routevia traveler'}',
              ),
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            if ((post.relatedRouteTitle ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                context.tr(
                  'Bağlı rota: ${post.relatedRouteTitle}',
                  'Related route: ${post.relatedRouteTitle}',
                ),
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
            if ((post.adminNote ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                post.adminNote!,
                style: const TextStyle(
                  color: Color(0xFFB45309),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text(context.tr('Onayla', 'Approve')),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF15803D),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: Text(context.tr('Reddet', 'Reject')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Place Story Moderation Card
// ─────────────────────────────────────────────────────────────────────────────

class _PlaceStoryModerationCard extends StatelessWidget {
  const _PlaceStoryModerationCard({
    required this.item,
    required this.onApprove,
    required this.onReject,
  });

  final Map<String, dynamic> item;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['place_name']?.toString() ?? 'Bilinmeyen yer',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              '${item['submitter_name'] ?? 'Kullanıcı'} • ${item['fact_type'] ?? 'story'}',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            if ((item['title']?.toString().trim().isNotEmpty ?? false)) ...[
              const SizedBox(height: 8),
              Text(
                item['title'].toString(),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              item['story_text']?.toString() ?? '',
              style: const TextStyle(color: Color(0xFF334155), height: 1.45),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text(context.tr('Onayla', 'Approve')),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF15803D),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: Text(context.tr('Reddet', 'Reject')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Community Report Card
// ─────────────────────────────────────────────────────────────────────────────

class _CommunityReportCard extends StatelessWidget {
  const _CommunityReportCard({required this.item, required this.onResolve});

  final Map<String, dynamic> item;
  final VoidCallback onResolve;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['post_title']?.toString() ?? 'Topluluk yazısı',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              '${item['reporter_name'] ?? 'Kullanıcı'} • ${item['reason'] ?? '-'}',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            if ((item['details']?.toString().trim().isNotEmpty ?? false)) ...[
              const SizedBox(height: 8),
              Text(
                item['details'].toString(),
                style: const TextStyle(color: Color(0xFF334155), height: 1.45),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onResolve,
                icon: const Icon(Icons.fact_check_outlined, size: 16),
                label: Text(context.tr('İncelendi', 'Reviewed')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Suggestion Card widget
// ─────────────────────────────────────────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.onFormLoad,
    this.onApprove,
    this.onReject,
  });

  final Map<String, dynamic> suggestion;
  final VoidCallback onFormLoad;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final s = suggestion;
    final status = s['status'] as String? ?? 'pending';
    final statusColor = switch (status) {
      'approved' => const Color(0xFF15803D),
      'rejected' => const Color(0xFFDC2626),
      _ => const Color(0xFFD97706),
    };
    final statusLabel = switch (status) {
      'approved' => 'Onaylandı',
      'rejected' => 'Reddedildi',
      _ => 'Beklemede',
    };

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((s['source_url'] as String?)?.contains(
                  '/storage/v1/object/public/place-photos/',
                ) ??
                false) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SafeNetworkImage(
                  url: s['source_url'] as String,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['suggested_name'] as String? ?? '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${s['province_name'] ?? '—'} / ${s['district_name'] ?? 'Merkez'} • ${s['suggested_category'] ?? '-'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            if ((s['short_note'] as String?)?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(
                s['short_note'] as String,
                style: const TextStyle(fontSize: 13, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if ((s['submitter_name'] as String?)?.isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    s['submitter_name'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
            if ((s['source_url'] as String?)?.isNotEmpty ?? false) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.link, size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      s['source_url'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onFormLoad,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(context.tr('Forma Aktar', 'Load Into Form')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                if (onApprove != null)
                  FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text(context.tr('Onayla', 'Approve')),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF15803D),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                if (onReject != null)
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: Text(context.tr('Reddet', 'Reject')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review Card widget
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.onApprove,
    required this.onReject,
  });

  final Map<String, dynamic> review;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final placeName =
        (review['pois'] as Map?)?['name'] as String? ?? 'Bilinmeyen Yer';
    final rating = review['rating'] as int? ?? 0;
    final comment =
        review['comment_short'] as String? ??
        review['comment'] as String? ??
        '';
    final flags = (review['flags'] as List?)?.cast<String>() ?? [];
    final status = review['status'] as String? ?? 'pending';
    final createdAt = review['created_at'] as String? ?? '';
    final dateStr = createdAt.length >= 10
        ? createdAt.substring(0, 10)
        : createdAt;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    placeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: switch (status) {
                      'approved' => const Color(0xFFDCFCE7),
                      'hidden' => const Color(0xFFFEE2E2),
                      _ => const Color(0xFFFFEDD5),
                    },
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    switch (status) {
                      'approved' => 'Yayinda',
                      'hidden' => 'Gizli',
                      _ => 'Bekliyor',
                    },
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: switch (status) {
                        'approved' => const Color(0xFF166534),
                        'hidden' => const Color(0xFF991B1B),
                        _ => const Color(0xFF9A3412),
                      },
                    ),
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 16,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                comment,
                style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
              ),
            ],
            if (flags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                children: flags
                    .map(
                      (f) => Chip(
                        label: Text(f, style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              dateStr,
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 16),
                    label: Text(context.tr('Yayinda', 'Publish')),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF15803D),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.block, size: 16),
                    label: Text(context.tr('Kaldir', 'Remove')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Photo Card widget
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.photo,
    required this.onApprove,
    required this.onApproveAsCover,
    required this.onReject,
  });

  final Map<String, dynamic> photo;
  final VoidCallback? onApprove;
  final VoidCallback onApproveAsCover;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final place = photo['pois'] as Map?;
    final placeName = place?['name'] as String? ?? '—';
    final imageUrl = photo['image_url'] as String? ?? '';
    final createdAt = DateTime.tryParse(photo['created_at'] as String? ?? '');
    final status = photo['status'] as String? ?? 'pending';
    final statusColor = switch (status) {
      'approved' => const Color(0xFF15803D),
      'rejected' => const Color(0xFFDC2626),
      _ => const Color(0xFFD97706),
    };
    final statusLabel = switch (status) {
      'approved' => 'Onaylı',
      'rejected' => 'Reddedildi',
      _ => 'Beklemede',
    };

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo preview
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: SafeNetworkImage(
                url: imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        placeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                    if (createdAt != null)
                      Text(
                        '${createdAt.day}.${createdAt.month}.${createdAt.year}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: onApprove,
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: Text(context.tr('Yayınla', 'Publish')),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF15803D),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onReject,
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: Text(context.tr('Reddet', 'Reject')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFDC2626)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: onApproveAsCover,
                      icon: const Icon(Icons.image_rounded, size: 16),
                      label: Text(
                        status == 'approved'
                            ? 'Ana Görsel Yap'
                            : 'Yayınla + Ana Görsel Yap',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0B3B68),
                        side: const BorderSide(color: Color(0xFF0B3B68)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _FormSectionLabel extends StatelessWidget {
  const _FormSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
    );
  }
}

// Push notification result banner — handles ok / warn / setup / err prefixes.
class _NotifResultBanner extends StatelessWidget {
  const _NotifResultBanner({required this.result});

  final String result;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    final Color fg;
    final String label;

    if (result.startsWith('ok:')) {
      bg = const Color(0xFFF0FDF4);
      border = const Color(0xFFBBF7D0);
      fg = const Color(0xFF166534);
      label = result.substring(3);
    } else if (result.startsWith('warn:')) {
      bg = const Color(0xFFFFFBEB);
      border = const Color(0xFFFDE68A);
      fg = const Color(0xFF92400E);
      label = result.substring(5);
    } else if (result.startsWith('setup:')) {
      bg = const Color(0xFFFFF7ED);
      border = const Color(0xFFFED7AA);
      fg = const Color(0xFF9A3412);
      label = result.substring(6);
    } else {
      // err: or legacy "Hata: ..."
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFFCA5A5);
      fg = const Color(0xFFB42318);
      label = result.startsWith('err:') ? result.substring(4) : result;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, height: 1.5),
      ),
    );
  }
}
