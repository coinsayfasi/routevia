import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error_utils.dart';
import '../../core/widgets/safe_network_image.dart';
import '../../data/providers.dart';

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

  // ── Data state ─────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _provinces = const [];
  List<Map<String, dynamic>> _districts = const [];
  List<Map<String, dynamic>> _places = const [];
  List<Map<String, dynamic>> _suggestions = const [];
  List<Map<String, dynamic>> _pendingPhotos = const [];
  List<Map<String, dynamic>> _pendingReviews = const [];
  Map<String, dynamic> _referralReport = const {};

  // ── Filter state ───────────────────────────────────────────────────────────
  String? _provinceSlug;
  String? _districtSlug;
  String _search = '';
  bool _includeUnpublished = true;
  String _suggestionStatus = 'pending';

  // ── Loading flags ──────────────────────────────────────────────────────────
  bool _placesLoading = false;
  bool _suggestionsLoading = false;
  bool _photosLoading = false;
  bool _reviewsLoading = false;
  bool _reportLoading = false;

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
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      final i = _tabController.index;
      if (i == 0 && _places.isEmpty) _loadPlaces();
      if (i == 1 && _suggestions.isEmpty) _loadSuggestions();
      if (i == 2 && _pendingPhotos.isEmpty) _loadPendingPhotos();
      if (i == 3 && _pendingReviews.isEmpty) _loadPendingReviews();
      if (i == 4 && _referralReport.isEmpty) _loadReferralReport();
    });
    _init();
  }

  Future<void> _init() async {
    await _loadProvinces();
    _loadPlaces();
    _loadSuggestions();
    _loadPendingPhotos();
    _loadPendingReviews();
    _loadReferralReport();
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

  Future<void> _loadPlaces() async {
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
      _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _placesLoading = false);
    }
  }

  Future<void> _loadSuggestions() async {
    setState(() => _suggestionsLoading = true);
    try {
      final items = await ref.read(repositoryProvider).adminSuggestions(
        status: _suggestionStatus,
        provinceSlug: _provinceSlug,
        limit: 120,
      );
      if (!mounted) return;
      setState(() => _suggestions = items);
    } catch (e) {
      _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _suggestionsLoading = false);
    }
  }

  Future<void> _loadPendingPhotos() async {
    setState(() => _photosLoading = true);
    try {
      final photos =
          await ref.read(repositoryProvider).adminGetPendingPhotos(limit: 50);
      if (!mounted) return;
      setState(() => _pendingPhotos = photos);
    } catch (e) {
      _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _photosLoading = false);
    }
  }

  Future<void> _loadPendingReviews() async {
    setState(() => _reviewsLoading = true);
    try {
      final reviews =
          await ref.read(repositoryProvider).adminGetPendingReviews(limit: 50);
      if (!mounted) return;
      setState(() => _pendingReviews = reviews);
    } catch (e) {
      _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _reviewsLoading = false);
    }
  }

  Future<void> _loadReferralReport() async {
    setState(() => _reportLoading = true);
    try {
      final report = await ref
          .read(repositoryProvider)
          .adminReferralReport(days: 30, limit: 300);
      if (!mounted) return;
      setState(() => _referralReport = report);
    } catch (e) {
      _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _reportLoading = false);
    }
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
        _category == 'food' ||
            _category == 'cafe' ||
            _category == 'lodging'
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

  Future<void> _reviewPhoto(String photoId, String status) async {
    try {
      await ref.read(repositoryProvider).adminReviewPhoto(
        photoId,
        status: status,
        note: status == 'approved' ? 'admin_approved' : 'admin_rejected',
      );
      _toast(status == 'approved' ? 'Fotoğraf yayınlandı.' : 'Reddedildi.');
      await _loadPendingPhotos();
    } catch (e) {
      _toast(friendlyError(e));
    }
  }

  Future<void> _reviewSuggestion(
    Map<String, dynamic> suggestion,
    String decision,
  ) async {
    final noteCtrl = TextEditingController(
      text: decision == 'approved'
          ? 'Moderasyon tamamlandı.'
          : 'Yetersiz içerik / doğrulanamadı.',
    );
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(decision == 'approved' ? 'Öneriyi Onayla' : 'Öneriyi Reddet'),
        content: TextField(
          controller: noteCtrl,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Admin notu'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(decision == 'approved' ? 'Onayla' : 'Reddet'),
          ),
        ],
      ),
    );
    noteCtrl.dispose();
    if (submitted != true) return;
    try {
      await ref.read(repositoryProvider).adminReviewSuggestion(
        suggestionId: suggestion['id'] as String,
        decision: decision,
        adminNote: noteCtrl.text.trim(),
      );
      _toast(decision == 'approved' ? 'Öneri onaylandı' : 'Öneri reddedildi');
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
        appBar: AppBar(title: const Text('Admin Panel')),
        body: const Center(child: Text('Admin için önce giriş yapmalısın.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(
              child: _tabLabel(
                Icons.place_outlined,
                'Yerler',
                _places.isNotEmpty ? '${_places.length}' : null,
              ),
            ),
            Tab(
              child: _tabLabel(
                Icons.lightbulb_outline,
                'Öneriler',
                _suggestionStatus == 'pending' && _suggestions.isNotEmpty
                    ? '${_suggestions.length}'
                    : null,
                badge: _suggestionStatus == 'pending' && _suggestions.isNotEmpty,
              ),
            ),
            Tab(
              child: _tabLabel(
                Icons.photo_library_outlined,
                'Fotoğraflar',
                _pendingPhotos.isNotEmpty ? '${_pendingPhotos.length}' : null,
                badge: _pendingPhotos.isNotEmpty,
              ),
            ),
            Tab(
              child: _tabLabel(
                Icons.star_outline,
                'Yorumlar',
                _pendingReviews.isNotEmpty ? '${_pendingReviews.length}' : null,
                badge: _pendingReviews.isNotEmpty,
              ),
            ),
            Tab(
              child: _tabLabel(Icons.analytics_outlined, 'Rapor', null),
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
          _buildReportTab(),
        ],
      ),
    );
  }

  Widget _tabLabel(IconData icon, String label, String? count,
      {bool badge = false}) {
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
                      key: ValueKey(_provinceSlug),
                      initialValue: _provinceSlug,
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
                      key: ValueKey(_districtSlug),
                      initialValue: _districtSlug,
                      decoration: const InputDecoration(
                        labelText: 'İlçe',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Tümü'),
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
                    label: const Text('Taslak'),
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
              ? const Center(child: Text('Sonuç yok'))
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
                                    (p['app_rating'] ?? p['rating'])
                                        .toString(),
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
                  segments: const [
                    ButtonSegment(value: 'pending', label: Text('Bekleyen')),
                    ButtonSegment(value: 'approved', label: Text('Onaylı')),
                    ButtonSegment(value: 'rejected', label: Text('Reddedildi')),
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
              const Expanded(
                child: Text(
                  'Onay bekleyen fotoğraflar',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              IconButton.filled(
                onPressed: _loadPendingPhotos,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: _photosLoading
              ? const Center(child: CircularProgressIndicator())
              : _pendingPhotos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: Colors.black26,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Onay bekleyen fotoğraf yok',
                        style: TextStyle(color: Colors.black45),
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
                      onApprove: () =>
                          _reviewPhoto(photo['id'] as String, 'approved'),
                      onReject: () =>
                          _reviewPhoto(photo['id'] as String, 'rejected'),
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
    if (_reviewsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pendingReviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF15803D)),
            SizedBox(height: 12),
            Text('Bekleyen yorum yok', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
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
              await ref
                  .read(repositoryProvider)
                  .adminReviewReview(review['id'] as String, status: 'approved');
              setState(() => _pendingReviews.removeAt(index));
            },
            onReject: () async {
              await ref
                  .read(repositoryProvider)
                  .adminReviewReview(review['id'] as String, status: 'hidden');
              setState(() => _pendingReviews.removeAt(index));
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 4: Report
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildReportTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Son 30 gün — Referral Raporu',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              IconButton.filled(
                onPressed: _loadReferralReport,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: _reportLoading
              ? const Center(child: CircularProgressIndicator())
              : _referralReport.isEmpty
              ? const Center(child: Text('Rapor verisi yok'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  child: _buildReferralContent(),
                ),
        ),
      ],
    );
  }

  Widget _buildReferralContent() {
    final summary = Map<String, dynamic>.from(
      (_referralReport['summary'] as Map?) ?? const {},
    );
    final topCodes =
        ((_referralReport['top_codes'] as List?) ?? const [])
            .cast<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .take(5)
            .toList();
    final suspicious =
        ((_referralReport['suspicious'] as List?) ?? const [])
            .cast<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .take(5)
            .toList();
    final referrals =
        ((_referralReport['referrals'] as List?) ?? const [])
            .cast<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .take(15)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Summary chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatChip(
              label: 'Referral',
              value: '${summary['referrals_count'] ?? 0}',
              color: const Color(0xFF0284C7),
            ),
            _StatChip(
              label: 'Kod',
              value: '${summary['unique_codes'] ?? 0}',
              color: const Color(0xFF059669),
            ),
            _StatChip(
              label: 'Entitlement',
              value: '${summary['entitlements_count'] ?? 0}',
              color: const Color(0xFF7C3AED),
            ),
            _StatChip(
              label: 'Event',
              value: '${summary['events_count'] ?? 0}',
              color: const Color(0xFFD97706),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Top codes
        _SectionHeader(
          icon: Icons.bar_chart_rounded,
          title: 'En çok kullanılan referral kodları',
        ),
        if (topCodes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Veri yok', style: TextStyle(color: Colors.black45)),
          )
        else
          ...topCodes.map(
            (e) => ListTile(
              dense: true,
              leading: const Icon(Icons.vpn_key_outlined, size: 18),
              title: Text(e['code'] as String? ?? '—'),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${e['count']} kullanım',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0284C7),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Suspicious
        _SectionHeader(
          icon: Icons.warning_amber_rounded,
          title: 'Şüpheli pattern',
          iconColor: const Color(0xFFDC2626),
        ),
        if (suspicious.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 16, color: Colors.green),
                SizedBox(width: 6),
                Text('Şüpheli pattern tespit edilmedi'),
              ],
            ),
          )
        else
          ...suspicious.map(
            (e) => ListTile(
              dense: true,
              leading: const Icon(Icons.error_outline,
                  size: 18, color: Color(0xFFDC2626)),
              title: Text('${e['code']} / ${e['day']}'),
              trailing: Text('${e['redeem_count']} kullanım',
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),

        const SizedBox(height: 16),

        // Recent referrals
        _SectionHeader(
          icon: Icons.people_outline_rounded,
          title: 'Son referral kayıtları',
        ),
        if (referrals.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Veri yok', style: TextStyle(color: Colors.black45)),
          )
        else
          ...referrals.map(
            (r) => ListTile(
              dense: true,
              leading: const Icon(Icons.arrow_forward_outlined, size: 16),
              title: Text(
                '${r['referrer_name'] ?? r['referrer_user_id']} → ${r['referee_name'] ?? r['referee_user_id']}',
                style: const TextStyle(fontSize: 13),
              ),
              subtitle: Text(
                r['code'] as String? ?? '—',
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
      ],
    );
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
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
                  child: const Text('Temizle'),
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
                          onChanged: (v) =>
                              setState(() => _provinceSlug = v),
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
                          onChanged: (v) =>
                              setState(() => _districtSlug = v),
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
                          .replaceAll(
                            RegExp(r'[çÇ]'), 'c',
                          )
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
                          items: const [
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
                          items: const [
                            'morning',
                            'day',
                            'sunset',
                            'night',
                          ]
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ),
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
                        label: const Text('Ücretsiz'),
                        selected: _isFree,
                        onSelected: (v) => setState(() => _isFree = v),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Yayında'),
                        selected: _isPublished,
                        selectedColor: const Color(0xFFDCFCE7),
                        onSelected: (v) => setState(() => _isPublished = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const _FormSectionLabel('Tarihçe maddeleri (satır başına, max 3)'),
                  TextField(
                    controller: p._historyCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'M.S. 7. yüzyılda inşa edildi\n...',
                    ),
                  ),
                  const SizedBox(height: 10),

                  const _FormSectionLabel('Yeme/İçme maddeleri (satır başına, max 3)'),
                  TextField(
                    controller: p._eatDrinkCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Yakında çok sayıda restoran\n...',
                    ),
                  ),
                  const SizedBox(height: 10),

                  const _FormSectionLabel('İpucu maddeleri (satır başına, max 4)'),
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
                      icon: Icon(isEditing ? Icons.save_outlined : Icons.add_rounded),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                  const Icon(Icons.person_outline, size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    s['submitter_name'] as String,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
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
                  label: const Text('Forma Aktar'),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                if (onApprove != null)
                  FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Onayla'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF15803D),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                if (onReject != null)
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Reddet'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    final placeName = (review['pois'] as Map?)?['name'] as String? ?? 'Bilinmeyen Yer';
    final rating = review['rating'] as int? ?? 0;
    final comment = review['comment'] as String? ?? '';
    final flags = (review['flags'] as List?)?.cast<String>() ?? [];
    final createdAt = review['created_at'] as String? ?? '';
    final dateStr = createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt;

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
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 16,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(comment, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
            ],
            if (flags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                children: flags
                    .map((f) => Chip(
                          label: Text(f, style: const TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 8),
            Text(dateStr, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Yayınla'),
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
                    label: const Text('Reddet'),
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
    required this.onReject,
  });

  final Map<String, dynamic> photo;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final place = photo['pois'] as Map?;
    final placeName = place?['name'] as String? ?? '—';
    final imageUrl = photo['image_url'] as String? ?? '';
    final createdAt = DateTime.tryParse(photo['created_at'] as String? ?? '');

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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
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
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Yayınla'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF15803D),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Reddet'),
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? const Color(0xFF0B3B68)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

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
