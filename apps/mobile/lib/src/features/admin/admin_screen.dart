import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/providers.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  List<Map<String, dynamic>> _provinces = const [];
  List<Map<String, dynamic>> _districts = const [];
  List<Map<String, dynamic>> _places = const [];

  String? _provinceSlug;
  String? _districtSlug;
  String _search = '';
  bool _includeUnpublished = true;
  bool _loading = false;
  bool _reportLoading = false;
  Map<String, dynamic> _referralReport = const {};

  final _name = TextEditingController();
  final _slug = TextEditingController();
  final _summary = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  final _duration = TextEditingController(text: '60');
  final _tags = TextEditingController();
  final _popularity = TextEditingController(text: '500');
  final _price = TextEditingController();
  final _history = TextEditingController();
  final _eatDrink = TextEditingController();
  final _tips = TextEditingController();
  final _media = TextEditingController();

  String _category = 'historical';
  String _bestTime = 'day';
  bool _isFree = false;
  bool _isPublished = true;
  String? _editingPlaceId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadProvinces();
    await _loadPlaces();
    await _loadReferralReport();
  }

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
    setState(() => _loading = true);
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
    } finally {
      if (mounted) setState(() => _loading = false);
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
      _toast('Referral raporu alınamadı: $e');
    } finally {
      if (mounted) setState(() => _reportLoading = false);
    }
  }

  void _clearForm() {
    _editingPlaceId = null;
    _name.clear();
    _slug.clear();
    _summary.clear();
    _lat.clear();
    _lng.clear();
    _duration.text = '60';
    _tags.clear();
    _popularity.text = '500';
    _price.clear();
    _history.clear();
    _eatDrink.clear();
    _tips.clear();
    _media.clear();
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
    _name.text = p['name'] as String? ?? '';
    _slug.text = p['slug'] as String? ?? '';
    _summary.text = p['short_summary'] as String? ?? '';
    _lat.text = ((p['lat'] as num?) ?? 0).toString();
    _lng.text = ((p['lng'] as num?) ?? 0).toString();
    _duration.text = ((p['duration_min'] as num?) ?? 60).toString();
    _tags.text = ((p['tags'] as List?) ?? const []).join(',');
    _popularity.text = ((p['popularity_score'] as num?) ?? 500).toString();
    _price.text = ((p['price_level'] as num?)?.toInt()).toString();
    _category = p['category'] as String? ?? 'historical';
    _bestTime = p['best_time'] as String? ?? 'day';
    _isFree = p['is_free'] as bool? ?? false;
    _isPublished = p['is_published'] as bool? ?? true;
    setState(() {});
  }

  Future<void> _savePlace() async {
    if (_provinceSlug == null) return;
    final lat = double.tryParse(_lat.text.trim());
    final lng = double.tryParse(_lng.text.trim());
    if (lat == null || lng == null) {
      _toast('Lat/Lng gecersiz');
      return;
    }

    final payload = {
      if (_editingPlaceId != null) 'id': _editingPlaceId,
      'province_slug': _provinceSlug,
      'district_slug': _districtSlug,
      'name': _name.text.trim(),
      'slug': _slug.text.trim(),
      'category': _category,
      'lat': lat,
      'lng': lng,
      'short_summary': _summary.text.trim(),
      'best_time': _bestTime,
      'duration_min': int.tryParse(_duration.text.trim()) ?? 60,
      'tags': _tags.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'popularity_score': int.tryParse(_popularity.text.trim()) ?? 500,
      'is_free': _isFree,
      'price_level': int.tryParse(_price.text.trim()),
      'is_published': _isPublished,
      'history_bullets': _history.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .take(3)
          .toList(),
      'eat_drink_bullets': _eatDrink.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .take(3)
          .toList(),
      'tips_bullets': _tips.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .take(4)
          .toList(),
      'media_paths': _media.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    };

    try {
      await ref.read(repositoryProvider).adminUpsertPlace(payload);
      _toast('Kaydedildi');
      await _loadPlaces();
    } catch (e) {
      _toast('Kayit hatasi: $e');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _name.dispose();
    _slug.dispose();
    _summary.dispose();
    _lat.dispose();
    _lng.dispose();
    _duration.dispose();
    _tags.dispose();
    _popularity.dispose();
    _price.dispose();
    _history.dispose();
    _eatDrink.dispose();
    _tips.dispose();
    _media.dispose();
    super.dispose();
  }

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
        actions: [
          IconButton(
            onPressed: _clearForm,
            icon: const Icon(Icons.add_box_outlined),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _provinceSlug,
                              decoration: const InputDecoration(
                                labelText: 'İl',
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
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _districtSlug,
                              decoration: const InputDecoration(
                                labelText: 'İlçe',
                              ),
                              items: _districts
                                  .map(
                                    (d) => DropdownMenuItem(
                                      value: d['slug'] as String,
                                      child: Text(d['name'] as String),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _districtSlug = v),
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
                                labelText: 'Arama',
                              ),
                              onChanged: (v) => _search = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Unpublished dahil'),
                            selected: _includeUnpublished,
                            onSelected: (v) =>
                                setState(() => _includeUnpublished = v),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _loadPlaces,
                            child: const Text('Yenile'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          itemCount: _places.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final p = _places[index];
                            final published =
                                p['is_published'] as bool? ?? false;
                            return ListTile(
                              title: Text('${p['name']} • ${p['category']}'),
                              subtitle: Text(
                                '${p['district_name'] ?? '-'} • Puan ${p['app_rating'] ?? p['rating'] ?? '-'}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Chip(
                                    label: Text(
                                      published ? 'yayında' : 'taslak',
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _loadPlaceToForm(p),
                                    icon: const Icon(Icons.edit),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Card(
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: const Text('Referral / Entitlement Raporu'),
                    subtitle: const Text(
                      'Son 30 gün dönüşüm ve şüpheli pattern',
                    ),
                    trailing: _reportLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            onPressed: _loadReferralReport,
                            icon: const Icon(Icons.refresh),
                          ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: _buildReferralReport(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _editingPlaceId == null ? 'Yeni Yer' : 'Yer Düzenle',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Ad'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _slug,
                  decoration: const InputDecoration(labelText: 'Slug'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _summary,
                  maxLength: 160,
                  decoration: const InputDecoration(
                    labelText: 'Kısa açıklama (<=160)',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
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
                        initialValue: _bestTime,
                        decoration: const InputDecoration(
                          labelText: 'En iyi zaman',
                        ),
                        items: const ['morning', 'day', 'sunset', 'night']
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _bestTime = v ?? 'day'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _lat,
                        decoration: const InputDecoration(labelText: 'Enlem'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _lng,
                        decoration: const InputDecoration(labelText: 'Boylam'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    'Konum önizleme: ${_lat.text.trim().isEmpty ? '-' : _lat.text.trim()}, ${_lng.text.trim().isEmpty ? '-' : _lng.text.trim()}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _duration,
                        decoration: const InputDecoration(
                          labelText: 'Süre (dk)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _popularity,
                        decoration: const InputDecoration(
                          labelText: 'Popülerlik',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _price,
                        decoration: const InputDecoration(
                          labelText: 'Fiyat seviyesi 0..4',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _tags,
                  decoration: const InputDecoration(
                    labelText: 'Etiketler (virgül)',
                  ),
                ),
                const SizedBox(height: 8),
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
                      onSelected: (v) => setState(() => _isPublished = v),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _history,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Tarih maddeleri (satır başına, max 3)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _eatDrink,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Yeme/İçme maddeleri (satır başına, max 3)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _tips,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'İpucu maddeleri (satır başına, max 4)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _media,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Medya path (satır başına)',
                    hintText: 'public-media/seed/izmir/kordon/1.jpg',
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton(
                      onPressed: _savePlace,
                      child: const Text('Kaydet / Publish'),
                    ),
                    OutlinedButton(
                      onPressed: _clearForm,
                      child: const Text('Temizle'),
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

  Widget _buildReferralReport() {
    if (_referralReport.isEmpty) {
      return const Text('Henüz rapor verisi yok.');
    }
    final summary = Map<String, dynamic>.from(
      (_referralReport['summary'] as Map?) ?? const {},
    );
    final topCodes = ((_referralReport['top_codes'] as List?) ?? const [])
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .take(5)
        .toList();
    final suspicious = ((_referralReport['suspicious'] as List?) ?? const [])
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .take(5)
        .toList();
    final referrals = ((_referralReport['referrals'] as List?) ?? const [])
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .take(10)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('Referral: ${summary['referrals_count'] ?? 0}')),
            Chip(label: Text('Kod: ${summary['unique_codes'] ?? 0}')),
            Chip(
              label: Text('Entitlement: ${summary['entitlements_count'] ?? 0}'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'En çok kullanılan kodlar',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        ...topCodes.map((e) => Text('• ${e['code']} → ${e['count']} kullanım')),
        const SizedBox(height: 8),
        const Text(
          'Şüpheli pattern',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        if (suspicious.isEmpty) const Text('• Şüpheli pattern yok'),
        ...suspicious.map(
          (e) => Text('• ${e['code']} / ${e['day']} → ${e['redeem_count']}'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Son referral kayıtları',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        ...referrals.map(
          (r) => Text(
            '• ${r['referrer_name'] ?? r['referrer_user_id']} → ${r['referee_name'] ?? r['referee_user_id']} (${r['code']})',
          ),
        ),
      ],
    );
  }
}
