import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/error_utils.dart';
import '../../core/i18n.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../models/trip_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TrendMapScreen — Shows trending POIs as a heat layer on a map
// ─────────────────────────────────────────────────────────────────────────────

class TrendMapScreen extends ConsumerStatefulWidget {
  const TrendMapScreen({super.key, this.provinceSlug});

  final String? provinceSlug;

  @override
  ConsumerState<TrendMapScreen> createState() => _TrendMapScreenState();
}

class _TrendMapScreenState extends ConsumerState<TrendMapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final TabController _tabController;

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const [];
  List<Map<String, dynamic>> _provinces = const [];
  String? _selectedProvinceSlug;
  String _selectedCategory = 'all';
  bool _showList = false;
  LatLng _center = const LatLng(39.9255, 32.8663);

  static const _categoryFilters = <String, String>{
    'all': 'Tümü',
    'museum': 'Müze',
    'historical': 'Tarihi',
    'nature': 'Doğa',
    'beach': 'Plaj',
    'viewpoint': 'Manzara',
    'food': 'Yemek',
    'activity': 'Aktivite',
  };

  static const _categoryColors = <String, Color>{
    'museum': Color(0xFF1565C0),
    'historical': Color(0xFFF57F17),
    'nature': Color(0xFF2E7D32),
    'beach': Color(0xFF0097A7),
    'viewpoint': Color(0xFF00897B),
    'food': Color(0xFFD84315),
    'cafe': Color(0xFF6D4C41),
    'activity': Color(0xFF283593),
    'market': Color(0xFFC2185B),
    'waterfall': Color(0xFF0288D1),
    'canyon': Color(0xFF4527A0),
  };

  static const _categoryGroups = <String, Set<String>>{
    'museum': {'museum'},
    'historical': {'historical'},
    'nature': {'nature', 'viewpoint', 'waterfall', 'canyon'},
    'beach': {'beach'},
    'viewpoint': {'viewpoint', 'nature'},
    'food': {'food', 'cafe'},
    'activity': {'activity', 'tour'},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedProvinceSlug = widget.provinceSlug;
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(repositoryProvider);
      List<Map<String, dynamic>> items;
      try {
        items = await repo.getTrendMapItems(
          provinceSlug: _selectedProvinceSlug,
          limit: 220,
        );
      } catch (_) {
        items = await repo.getSmartSeasonSuggestions(
          provinceSlug: _selectedProvinceSlug,
          limit: 60,
        );
      }

      if (_provinces.isEmpty) {
        try {
          final provinces = await repo.listProvinces();
          if (!mounted) return;
          setState(() => _provinces = provinces);
        } catch (_) {
          // Province dropdown is optional for this screen.
        }
      }
      if (!mounted) return;
      LatLng center = _center;
      if (items.isNotEmpty) {
        final first = items.first;
        center = LatLng(
          (first['lat'] as num?)?.toDouble() ?? _center.latitude,
          (first['lng'] as num?)?.toDouble() ?? _center.longitude,
        );
      }
      setState(() {
        _items = items;
        _center = center;
      });
      try {
        _mapController.move(center, _selectedProvinceSlug != null ? 10.0 : 6.5);
      } catch (_) {}
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _items = const [];
        _error = friendlyError(e);
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedCategory == 'all') return _items;
    final allowed =
        _categoryGroups[_selectedCategory] ?? {_selectedCategory};
    return _items
        .where((x) => allowed.contains(x['category']?.toString() ?? ''))
        .toList();
  }

  Color _scoreColor(double score) {
    if (score >= 75) return const Color(0xFFB91C1C);
    if (score >= 55) return const Color(0xFFEA580C);
    if (score >= 35) return const Color(0xFF0284C7);
    return const Color(0xFF475569);
  }

  double _circleRadius(double score) {
    final normalized = (score.clamp(0, 100)) / 100;
    return 12 + (normalized * 30);
  }

  Color _catColor(String? cat) =>
      _categoryColors[cat ?? ''] ?? RouteviaColors.navyMid;

  String _categoryLabel(String? category) {
    return switch (category) {
      'museum' => context.tr('Müze', 'Museum'),
      'historical' => context.tr('Tarihi', 'Historical'),
      'nature' => context.tr('Doğa', 'Nature'),
      'beach' => context.tr('Plaj', 'Beach'),
      'viewpoint' => context.tr('Manzara', 'Viewpoint'),
      'food' => context.tr('Yemek', 'Food'),
      'cafe' => context.tr('Kafe', 'Cafe'),
      'activity' => context.tr('Aktivite', 'Activity'),
      'tour' => context.tr('Tur', 'Tour'),
      'waterfall' => context.tr('Şelale', 'Waterfall'),
      'canyon' => context.tr('Kanyon', 'Canyon'),
      _ => category?.toString() ?? '-',
    };
  }

  PlaceModel _toPlace(Map<String, dynamic> x) => PlaceModel.fromMap({
    'id': x['id'],
    'name': x['name'],
    'slug': x['id'],
    'category': x['category'] ?? 'activity',
    'short_summary': '${x['city'] ?? ''}',
    'best_time': 'day',
    'duration_min': 60,
    'lat': x['lat'],
    'lng': x['lng'],
    'tags': const [],
    'source_kind': 'curated',
    'media': const [],
    'app_score': x['trend_score'],
  });

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final points = filtered
        .where((x) => x['lat'] != null && x['lng'] != null)
        .toList();

    final circles = points.map((x) {
      final score = (x['trend_score'] as num?)?.toDouble() ?? 0;
      final color = _scoreColor(score);
      return CircleMarker(
        point: LatLng(
          (x['lat'] as num).toDouble(),
          (x['lng'] as num).toDouble(),
        ),
        radius: _circleRadius(score),
        useRadiusInMeter: false,
        color: color.withValues(alpha: 0.18),
        borderStrokeWidth: 1.4,
        borderColor: color.withValues(alpha: 0.60),
      );
    }).toList();

    final sortedPoints = [...points]
      ..sort(
        (a, b) => ((b['trend_score'] as num?) ?? 0).compareTo(
          (a['trend_score'] as num?) ?? 0,
        ),
      );

    final markers = sortedPoints.take(40).map((x) {
      final score = (x['trend_score'] as num?)?.toDouble() ?? 0;
      final color = _scoreColor(score);
      final place = _toPlace(x);
      return Marker(
        point: LatLng(
          (x['lat'] as num).toDouble(),
          (x['lng'] as num).toDouble(),
        ),
        width: 36,
        height: 36,
        child: GestureDetector(
          onTap: () => context.push('/place', extra: place),
          child: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                score.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: RouteviaColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : Stack(
              children: [
                // Map
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: _selectedProvinceSlug != null ? 10.0 : 6.5,
                    minZoom: 4.0,
                    maxZoom: 17.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.routevia.mobile',
                    ),
                    CircleLayer(circles: circles),
                    MarkerLayer(markers: markers),
                  ],
                ),

                // Top controls
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Column(
                      children: [
                        // AppBar area
                        Container(
                          color: Colors.white.withValues(alpha: 0.95),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => context.pop(),
                                tooltip: 'Geri',
                              ),
                              const Expanded(
                                child: Text(
                                  'Trend Harita',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              // Province selector
                              if (_provinces.isNotEmpty)
                                _ProvinceDropdown(
                                  provinces: _provinces,
                                  selectedSlug: _selectedProvinceSlug,
                                  onChanged: (slug) {
                                    setState(
                                      () => _selectedProvinceSlug = slug,
                                    );
                                    _load();
                                  },
                                ),
                              IconButton(
                                icon: Icon(
                                  _showList
                                      ? Icons.map_outlined
                                      : Icons.list_alt,
                                ),
                                tooltip: _showList ? 'Harita' : 'Liste',
                                onPressed: () =>
                                    setState(() => _showList = !_showList),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                tooltip: 'Yenile',
                                onPressed: _load,
                              ),
                            ],
                          ),
                        ),

                        // Category chips
                        Container(
                          color: Colors.white.withValues(alpha: 0.95),
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            itemCount: _categoryFilters.length,
                            itemBuilder: (ctx, i) {
                              final entry = _categoryFilters.entries.elementAt(
                                i,
                              );
                              final isSelected = _selectedCategory == entry.key;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedCategory = entry.key,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? RouteviaColors.navyDark
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? RouteviaColors.navyDark
                                            : RouteviaColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      entry.value,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : RouteviaColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // List overlay
                if (_showList)
                  Positioned(
                    top: 120,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildList(sortedPoints),
                  ),

                // Legend (bottom) — only when map visible
                if (!_showList)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 24,
                    child: _buildLegend(filtered.length),
                  ),
              ],
            ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Trend Harita', 'Trend Map'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: RouteviaColors.rose,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: RouteviaColors.textSecondary),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: Text(context.tr('Tekrar Dene', 'Retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(int count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Color(0xFFB91C1C),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                context.tr('$count nokta gösteriliyor', '$count points shown'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                context.tr(
                  'Puan: trend skoru (0–100)',
                  'Score: trend score (0-100)',
                ),
                style: const TextStyle(
                  fontSize: 11,
                  color: RouteviaColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _LegendDot(color: const Color(0xFF475569), label: '0–34'),
              const SizedBox(width: 12),
              _LegendDot(color: const Color(0xFF0284C7), label: '35–54'),
              const SizedBox(width: 12),
              _LegendDot(color: const Color(0xFFEA580C), label: '55–74'),
              const SizedBox(width: 12),
              _LegendDot(color: const Color(0xFFB91C1C), label: '75+'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              'Trend skoru; Routevia check-in, yorum, fotograf ve benzeri topluluk sinyallerinden turetilir. Birebir gercek zamanli fiziksel insan yogunlugu olcumu degildir.',
              'Trend score is derived from Routevia check-ins, reviews, photos, and similar community signals. It is not an exact real-time physical crowd measurement.',
            ),
            style: const TextStyle(
              fontSize: 11,
              color: RouteviaColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> sorted) {
    return Container(
      color: RouteviaColors.background,
      child: sorted.isEmpty
          ? const Center(
              child: Text(
                'Bu kategoride trend nokta yok.',
                style: TextStyle(color: RouteviaColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: sorted.length,
              itemBuilder: (ctx, i) {
                final x = sorted[i];
                final score = (x['trend_score'] as num?)?.toDouble() ?? 0;
                final color = _scoreColor(score);
                final catColor = _catColor(x['category'] as String?);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          score.toStringAsFixed(0),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      x['name'] as String? ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${x['city'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: RouteviaColors.textSecondary,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _categoryLabel(x['category'] as String?),
                        style: TextStyle(
                          fontSize: 10,
                          color: catColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() => _showList = false);
                      _mapController.move(
                        LatLng(
                          (x['lat'] as num).toDouble(),
                          (x['lng'] as num).toDouble(),
                        ),
                        13.0,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

class _ProvinceDropdown extends StatelessWidget {
  const _ProvinceDropdown({
    required this.provinces,
    required this.selectedSlug,
    required this.onChanged,
  });

  final List<Map<String, dynamic>> provinces;
  final String? selectedSlug;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String?>(
      value: selectedSlug,
      underline: const SizedBox.shrink(),
      isDense: true,
      hint: const Text('Tüm Türkiye', style: TextStyle(fontSize: 12)),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Tüm Türkiye', style: TextStyle(fontSize: 12)),
        ),
        ...provinces.map(
          (p) => DropdownMenuItem<String?>(
            value: p['slug'] as String?,
            child: Text(
              p['name'] as String? ?? '-',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
