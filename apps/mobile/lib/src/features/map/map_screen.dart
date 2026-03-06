import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/safe_network_image.dart';
import '../../data/providers.dart';
import '../../models/trip_models.dart';

// ─── Category Styling ───────────────────────────────────────────────
class _CategoryStyle {
  const _CategoryStyle(this.color, this.icon, this.label);
  final Color color;
  final IconData icon;
  final String label;
}

const _categoryStyles = <String, _CategoryStyle>{
  'museum':     _CategoryStyle(Color(0xFF1565C0), Icons.museum,            'Müze'),
  'historical': _CategoryStyle(Color(0xFFF57F17), Icons.account_balance,   'Tarihi'),
  'nature':     _CategoryStyle(Color(0xFF2E7D32), Icons.park,              'Doğa'),
  'beach':      _CategoryStyle(Color(0xFF0097A7), Icons.beach_access,      'Plaj'),
  'viewpoint':  _CategoryStyle(Color(0xFF00897B), Icons.panorama,          'Manzara'),
  'food':       _CategoryStyle(Color(0xFFD84315), Icons.restaurant,        'Yemek'),
  'cafe':       _CategoryStyle(Color(0xFF6D4C41), Icons.coffee,            'Kafe'),
  'lodging':    _CategoryStyle(Color(0xFF7B1FA2), Icons.hotel,             'Konaklama'),
  'activity':   _CategoryStyle(Color(0xFF283593), Icons.directions_run,    'Aktivite'),
  'market':     _CategoryStyle(Color(0xFFC2185B), Icons.shopping_bag,      'Pazar/Çarşı'),
  'tour':       _CategoryStyle(Color(0xFFE65100), Icons.tour,              'Tur'),
  'waterfall':  _CategoryStyle(Color(0xFF0288D1), Icons.water_drop,        'Şelale'),
  'canyon':     _CategoryStyle(Color(0xFF4527A0), Icons.terrain,           'Kanyon'),
};

_CategoryStyle _styleOf(String category) =>
    _categoryStyles[category] ??
    const _CategoryStyle(Color(0xFF78909C), Icons.place, 'Diğer');

// ─── Map Screen ─────────────────────────────────────────────────────
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({
    super.key,
    this.plan,
    this.readOnly = false,
    this.initialLat,
    this.initialLng,
    this.initialProvinceSlug,
    this.initialDistrictId,
    this.initialDistrictSlug,
  });

  final TripPlan? plan;
  final bool readOnly;
  final double? initialLat;
  final double? initialLng;
  final String? initialProvinceSlug;
  final String? initialDistrictId;
  final String? initialDistrictSlug;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final TextEditingController _searchController = TextEditingController();

  // Plan mode
  int _selectedDay = 1;

  // Explore mode
  bool _loading = false;
  final Set<String> _categoryFilters = <String>{};
  List<PlaceModel> _allPlaces = const [];
  String? _effectiveProvinceSlug;
  String? _error;
  bool _showLegend = false;
  bool _showFilters = true;
  bool _offline = false;
  String _searchQuery = '';
  String _allPlacesSignature = '';
  String? _effectiveCityName;
  LatLngBounds? _lastFetchedBounds;
  double _lastFetchedZoom = -1;
  Timer? _viewportDebounce;
  Timer? _searchDebounce;
  final _bboxCache = _LruBBoxCache(maxEntries: 24);

  LatLng _center = const LatLng(39.9255, 32.8663);
  double _zoom = 8.0;

  bool get _exploreMode => widget.plan == null;

  // ── Plan helpers ──────────────────────────────────────────────────
  List<TripStop> get _stops {
    if (widget.plan == null || widget.plan!.daysPlan.isEmpty) return const [];
    return widget.plan!.daysPlan
        .firstWhere(
          (d) => d.dayNumber == _selectedDay,
          orElse: () => widget.plan!.daysPlan.first,
        )
        .stops;
  }

  List<LatLng> get _polylinePoints {
    if (_exploreMode) return const [];
    return _stops
        .where((s) => s.place.lat != null && s.place.lng != null)
        .map((s) => LatLng(s.place.lat!, s.place.lng!))
        .toList();
  }

  // ── Filtered places ───────────────────────────────────────────────
  List<PlaceModel> get _filteredPlaces {
    if (_categoryFilters.isEmpty) return _allPlaces;
    return _allPlaces
        .where((p) => _categoryFilters.contains(p.category))
        .toList();
  }

  List<PlaceModel> get _topPicks {
    final source = _filteredPlaces;
    final sorted = List<PlaceModel>.from(source)
      ..sort((a, b) {
        final sa = a.routeviaScore + a.effectiveRating;
        final sb = b.routeviaScore + b.effectiveRating;
        return sb.compareTo(sa);
      });
    return sorted.take(20).toList();
  }

  // ── Init ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final lat = widget.initialLat ?? widget.plan?.startLat;
    final lng = widget.initialLng ?? widget.plan?.startLng;
    if (lat != null && lng != null) {
      _center = LatLng(lat, lng);
    }
    _loadLocationAndData();
  }

  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * 3.141592653589793 / 180.0;
    final dLng = (lng2 - lng1) * 3.141592653589793 / 180.0;
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1 * 3.141592653589793 / 180.0) *
            cos(lat2 * 3.141592653589793 / 180.0) *
            (sin(dLng / 2) * sin(dLng / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  Future<void> _loadLocationAndData() async {
    final hasInitialPoint =
        widget.initialLat != null && widget.initialLng != null;

    if (!hasInitialPoint && widget.initialProvinceSlug != null) {
      try {
        final province = await ref
            .read(repositoryProvider)
            .getProvinceBySlug(widget.initialProvinceSlug!);
        final lat = (province?['lat'] as num?)?.toDouble();
        final lng = (province?['lng'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          _center = LatLng(lat, lng);
        }
      } catch (_) {}
    }

    _effectiveProvinceSlug = widget.initialProvinceSlug;
    if (_effectiveProvinceSlug == null) {
      try {
        final provinces = await ref.read(repositoryProvider).listProvinces();
        final withCoords = provinces
            .where((p) => p['lat'] != null && p['lng'] != null)
            .toList();
        if (withCoords.isNotEmpty) {
          withCoords.sort((a, b) {
            final da = _distanceKm(
              _center.latitude,
              _center.longitude,
              (a['lat'] as num).toDouble(),
              (a['lng'] as num).toDouble(),
            );
            final db = _distanceKm(
              _center.latitude,
              _center.longitude,
              (b['lat'] as num).toDouble(),
              (b['lng'] as num).toDouble(),
            );
            return da.compareTo(db);
          });
          _effectiveProvinceSlug = withCoords.first['slug'] as String?;
        }
      } catch (_) {}
    }

    if (_effectiveProvinceSlug != null) {
      try {
        final province = await ref
            .read(repositoryProvider)
            .client
            .from('provinces')
            .select('name')
            .eq('slug', _effectiveProvinceSlug!)
            .maybeSingle();
        _effectiveCityName = (province as Map?)?['name']?.toString();
      } catch (_) {}
    }

    if (_exploreMode) {
      _scheduleViewportLoad(force: true);
    } else {
      final points = _polylinePoints;
      if (points.isNotEmpty) {
        setState(() => _center = points.first);
      }
    }
  }

  bool _isSignificantBoundsChange(LatLngBounds next, double zoom) {
    final prev = _lastFetchedBounds;
    if (prev == null) return true;
    final prevCenter = prev.center;
    final nextCenter = next.center;
    final latSpan = (prev.north - prev.south).abs();
    final lngSpan = (prev.east - prev.west).abs();
    final moveLat = (nextCenter.latitude - prevCenter.latitude).abs();
    final moveLng = (nextCenter.longitude - prevCenter.longitude).abs();
    final movedEnough = moveLat > latSpan * 0.18 || moveLng > lngSpan * 0.18;
    final zoomEnough = (zoom - _lastFetchedZoom).abs() >= 0.7;
    return movedEnough || zoomEnough;
  }

  String _boundsCacheKey(LatLngBounds b, double zoom) {
    final minLat = (b.south * 100).round() / 100.0;
    final maxLat = (b.north * 100).round() / 100.0;
    final minLng = (b.west * 100).round() / 100.0;
    final maxLng = (b.east * 100).round() / 100.0;
    final zoomBucket = (zoom * 2).round() / 2.0;
    final cats = (_categoryFilters.toList()..sort()).join(',');
    final city = (_effectiveCityName ?? '').toLowerCase();
    return '$minLat|$maxLat|$minLng|$maxLng|$zoomBucket|$cats|$city|${_searchQuery.toLowerCase()}';
  }

  String _signatureOf(List<PlaceModel> places) {
    final ids = places.map((e) => e.id).toList()..sort();
    return '${ids.length}:${ids.join(",")}';
  }

  void _applyPlaces(List<PlaceModel> places) {
    final sig = _signatureOf(places);
    if (sig == _allPlacesSignature) return;
    _allPlacesSignature = sig;
    _allPlaces = places;
  }

  void _scheduleViewportLoad({bool force = false}) {
    if (!_exploreMode) return;
    _viewportDebounce?.cancel();
    _viewportDebounce = Timer(const Duration(milliseconds: 400), () {
      _loadViewportPlaces(force: force);
    });
  }

  Future<void> _loadViewportPlaces({bool force = false}) async {
    LatLngBounds? bounds;
    try {
      bounds = _mapController.camera.visibleBounds;
    } catch (_) {
      // Map controller may not be attached yet on first frame.
      if (force) {
        _viewportDebounce?.cancel();
        _viewportDebounce = Timer(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          _loadViewportPlaces(force: true);
        });
      }
      return;
    }
    if (!force && !_isSignificantBoundsChange(bounds, _zoom)) return;

    final cacheKey = _boundsCacheKey(bounds, _zoom);
    final cached = _bboxCache.get(cacheKey);
    if (cached != null) {
      if (!mounted) return;
      setState(() {
        _offline = false;
        _error = null;
        _applyPlaces(cached);
      });
      _lastFetchedBounds = bounds;
      _lastFetchedZoom = _zoom;
      return;
    }

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final repo = ref.read(repositoryProvider);
      final places = await repo.fetchPoisByViewport(
        minLat: bounds.south,
        maxLat: bounds.north,
        minLng: bounds.west,
        maxLng: bounds.east,
        categories: _categoryFilters.toList(),
        searchQuery: _searchQuery,
        cityName: _effectiveCityName,
        limit: 1000,
      );
      _bboxCache.put(cacheKey, places);
      _lastFetchedBounds = bounds;
      _lastFetchedZoom = _zoom;

      if (!mounted) return;
      setState(() {
        _offline = false;
        _error = null;
        _applyPlaces(places);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _offline = true;
        _error = 'Ağ bağlantısı yok veya veriler alınamadı.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fitToPlaces(List<PlaceModel> places) {
    final points = places
        .where((p) => p.lat != null && p.lng != null)
        .map((p) => LatLng(p.lat!, p.lng!))
        .toList();
    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, 13);
      return;
    }
    final bounds = LatLngBounds.fromPoints(points);
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.fromLTRB(32, 140, 32, 260),
          maxZoom: 14,
        ),
      );
    } catch (_) {
      _mapController.move(_center, 10);
    }
  }

  Future<void> _goMyLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konum izni verilmedi.')),
        );
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final loc = LatLng(pos.latitude, pos.longitude);
      _mapController.move(loc, 14);
      _scheduleViewportLoad(force: true);
    } catch (_) {}
  }

  // ── Explore Markers (clustered) ───────────────────────────────────
  List<Marker> _buildExploreMarkers() {
    final places = _filteredPlaces;
    final topIds = _topPicks.take(10).map((e) => e.id).toSet();

    // Deduplicate by coordinate
    final byCoord = <String, PlaceModel>{};
    for (final p in places.where((e) => e.lat != null && e.lng != null)) {
      final key = '${p.lat!.toStringAsFixed(5)}:${p.lng!.toStringAsFixed(5)}';
      final prev = byCoord[key];
      if (prev == null) {
        byCoord[key] = p;
        continue;
      }
      final prevScore = prev.routeviaScore + prev.effectiveRating;
      final nextScore = p.routeviaScore + p.effectiveRating;
      if (nextScore > prevScore) byCoord[key] = p;
    }

    return byCoord.values.map((p) {
      final isTop = topIds.contains(p.id);
      final style = _styleOf(p.category);
      final size = isTop ? 42.0 : 34.0;

      return Marker(
        key: ValueKey('m:${p.id}'),
        point: LatLng(p.lat!, p.lng!),
        alignment: Alignment.center,
        width: size,
        height: size,
        child: GestureDetector(
          onTap: () => context.push('/place', extra: p),
          child: Container(
            decoration: BoxDecoration(
              color: style.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isTop ? const Color(0xFFFFD600) : Colors.white,
                width: isTop ? 2.5 : 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: style.color.withValues(alpha: 0.4),
                  blurRadius: isTop ? 12 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              style.icon,
              color: Colors.white,
              size: isTop ? 20 : 15,
            ),
          ),
        ),
      );
    }).toList();
  }

  // ── Plan Markers ──────────────────────────────────────────────────
  List<Marker> _buildPlanMarkers() {
    return _stops
        .where((s) => s.place.lat != null && s.place.lng != null)
        .map(
          (s) => Marker(
            point: LatLng(s.place.lat!, s.place.lng!),
            alignment: Alignment.center,
            width: 44,
            height: 44,
            child: GestureDetector(
              onTap: () => context.push('/place', extra: s.place),
              child: Container(
                decoration: BoxDecoration(
                  color: RouteviaColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: RouteviaColors.accent, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x44000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${s.orderIndex}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  List<Polyline> _buildPolylines() {
    if (_polylinePoints.length < 2) return const [];
    return [
      Polyline(
        points: _polylinePoints,
        strokeWidth: 4,
        color: RouteviaColors.accent,
      ),
    ];
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final markers = _exploreMode ? _buildExploreMarkers() : _buildPlanMarkers();
    final cardItems =
        _exploreMode ? _topPicks : _stops.map((s) => s.place).toList();

    // Count by category for info display
    final categoryCounts = <String, int>{};
    for (final p in _filteredPlaces) {
      categoryCounts[p.category] = (categoryCounts[p.category] ?? 0) + 1;
    }

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ───────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _zoom,
              onPositionChanged: (position, _) {
                _center = position.center;
                _zoom = position.zoom;
                if (_exploreMode) {
                  _scheduleViewportLoad();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.routevia.mobile',
              ),
              if (_exploreMode)
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 60,
                    size: const Size(48, 48),
                    markers: markers,
                    zoomToBoundsOnClick: true,
                    spiderfyCluster: true,
                    builder: (context, clusterMarkers) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0B1F3A), Color(0xFF14487A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: RouteviaColors.accent, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x44000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${clusterMarkers.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (!_exploreMode) MarkerLayer(markers: markers),
              if (!_exploreMode) PolylineLayer(polylines: _buildPolylines()),
            ],
          ),

          // ── Top bar ───────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: GlassPanel(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _exploreMode
                              ? _effectiveProvinceSlug?.toUpperCase() ??
                                  'TÜRKİYE'
                              : 'Gün $_selectedDay',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          _exploreMode
                              ? '${_filteredPlaces.length} nokta${_categoryFilters.isEmpty ? '' : ' (filtrelenmiş)'}${_offline ? ' • çevrimdışı' : ''}'
                              : '${_stops.length} durak',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_exploreMode) ...[
                    _MapIconButton(
                      icon: Icons.legend_toggle,
                      active: _showLegend,
                      onTap: () =>
                          setState(() => _showLegend = !_showLegend),
                      tooltip: 'Kategori Rehberi',
                    ),
                    const SizedBox(width: 4),
                    _MapIconButton(
                      icon: Icons.tune,
                      active: _showFilters,
                      onTap: () =>
                          setState(() => _showFilters = !_showFilters),
                      tooltip: 'Filtreler',
                    ),
                    const SizedBox(width: 4),
                  ],
                  _MapIconButton(
                    icon: Icons.my_location,
                    onTap: _goMyLocation,
                    tooltip: 'Konumum',
                  ),
                ],
              ),
            ),
          ),

          if (_exploreMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 66,
              left: 12,
              right: 12,
              child: GlassPanel(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Haritada ara',
                    icon: const Icon(Icons.search, size: 18),
                    border: InputBorder.none,
                    isDense: true,
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _scheduleViewportLoad(force: true);
                            },
                          ),
                  ),
                  onChanged: (value) {
                    _searchDebounce?.cancel();
                    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                      if (!mounted) return;
                      setState(() => _searchQuery = value.trim());
                      _scheduleViewportLoad(force: true);
                    });
                  },
                ),
              ),
            ),

          // ── Category Filter Chips ─────────────────────────────────
          if (_exploreMode && _showFilters)
            Positioned(
              top: MediaQuery.of(context).padding.top + 118,
              left: 12,
              right: 12,
              child: GlassPanel(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _categoryStyles.entries.map((entry) {
                        final cat = entry.key;
                        final style = entry.value;
                        final count = categoryCounts[cat] ?? 0;
                        final isSelected = _categoryFilters.contains(cat);

                        return FilterChip(
                          avatar: Icon(style.icon, size: 16,
                              color: isSelected
                                  ? style.color
                                  : Colors.grey.shade600),
                          label: Text(
                            '${ style.label} ($count)',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? style.color
                                  : Colors.grey.shade700,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: style.color.withValues(alpha: 0.15),
                          checkmarkColor: style.color,
                          side: BorderSide(
                            color: isSelected
                                ? style.color
                                : Colors.grey.shade300,
                          ),
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _categoryFilters.add(cat);
                              } else {
                                _categoryFilters.remove(cat);
                              }
                            });
                            _scheduleViewportLoad(force: true);
                          },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        );
                      }).toList(),
                    ),
                    if (_categoryFilters.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _categoryFilters.clear());
                            _scheduleViewportLoad(force: true);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.clear_all,
                                  size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                'Tüm filtreleri temizle',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // ── Legend Panel ───────────────────────────────────────────
          if (_showLegend)
            Positioned(
              top: MediaQuery.of(context).padding.top + 118,
              right: 12,
              child: GlassPanel(
                padding: const EdgeInsets.all(12),
                backgroundOpacity: 0.92,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kategori Rehberi',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._categoryStyles.entries.map((entry) {
                      final style = entry.value;
                      final count = categoryCounts[entry.key] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: style.color,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(style.icon,
                                  color: Colors.white, size: 12),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${style.label} ($count)',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

          // ── Day tabs (plan mode) ──────────────────────────────────
          if (!_exploreMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 72,
              left: 12,
              right: 12,
              child: _buildDayTabs(),
            ),

          // ── Loading indicator ─────────────────────────────────────
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black12,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                          color: RouteviaColors.accent),
                      SizedBox(height: 12),
                      Text(
                        'Görünür alan yükleniyor...',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Error panel ───────────────────────────────────────────
          if (_error != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 240,
              child: GlassPanel(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline, size: 18,
                            color: Color(0xFFB42318)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: () => _loadViewportPlaces(force: true),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            ),

          // ── Empty state ───────────────────────────────────────────
          if (_exploreMode && !_loading && _allPlaces.isEmpty && _error == null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 240,
              child: GlassPanel(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bu bölgede henüz yeterli veri yok.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: () => _loadViewportPlaces(force: true),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Yenile'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('Şehir Değiştir'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // ── Bottom place cards ─────────────────────────────────────
          if (cardItems.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.8),
                      Colors.white,
                    ],
                    stops: const [0, 0.15, 0.4],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: RouteviaColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    color: Color(0xFFFFD600), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  _exploreMode
                                      ? 'En İyiler'
                                      : 'Gün $_selectedDay',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${cardItems.length} yer',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const Spacer(),
                          if (_exploreMode)
                            GestureDetector(
                              onTap: () {
                                _fitToPlaces(_filteredPlaces);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.fit_screen,
                                    size: 18, color: Colors.grey.shade700),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 168,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: cardItems.length,
                        onPageChanged: (idx) {
                          final p = cardItems[idx];
                          if (p.lat != null && p.lng != null) {
                            _mapController.move(
                              LatLng(p.lat!, p.lng!),
                              _zoom < 13 ? 13 : _zoom,
                            );
                          }
                        },
                        itemBuilder: (context, idx) {
                          final p = cardItems[idx];
                          final style = _styleOf(p.category);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            child: _PlaceCard(
                              place: p,
                              style: style,
                              onTap: () =>
                                  context.push('/place', extra: p),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 8),
                  ],
                ),
              ),
            ),

          // ── OSM Attribution ───────────────────────────────────────
          Positioned(
            left: 8,
            bottom: (cardItems.isNotEmpty ? 232 : 8) +
                MediaQuery.of(context).padding.bottom,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '© OpenStreetMap contributors',
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: !_exploreMode
          ? FloatingActionButton.extended(
              onPressed: _openDayNavigation,
              icon: const Icon(Icons.navigation),
              label: const Text('Güne Başla'),
              backgroundColor: RouteviaColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildDayTabs() {
    final days = widget.plan?.daysPlan ?? const [];
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Wrap(
        spacing: 6,
        children: days
            .map(
              (d) => ChoiceChip(
                label: Text('Gün ${d.dayNumber}'),
                selected: _selectedDay == d.dayNumber,
                selectedColor: RouteviaColors.accent.withValues(alpha: 0.2),
                onSelected: (_) =>
                    setState(() => _selectedDay = d.dayNumber),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _openDayNavigation() async {
    final points = _polylinePoints;
    if (points.isEmpty) return;
    final destination = points.first;
    final uri = Uri.parse(
      'geo:${destination.latitude},${destination.longitude}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _viewportDebounce?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

class _LruBBoxCache {
  _LruBBoxCache({required this.maxEntries});

  final int maxEntries;
  final LinkedHashMap<String, List<PlaceModel>> _store =
      LinkedHashMap<String, List<PlaceModel>>();

  List<PlaceModel>? get(String key) {
    final value = _store.remove(key);
    if (value == null) return null;
    _store[key] = value;
    return value;
  }

  void put(String key, List<PlaceModel> value) {
    _store.remove(key);
    _store[key] = value;
    while (_store.length > maxEntries) {
      _store.remove(_store.keys.first);
    }
  }
}

// ─── Place Card Widget ──────────────────────────────────────────────
class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.place,
    required this.style,
    required this.onTap,
  });

  final PlaceModel place;
  final _CategoryStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(18),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8ECF0)),
          ),
          child: Row(
            children: [
              // Image
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(17),
                    bottomLeft: Radius.circular(17),
                  ),
                  child: SafeNetworkImage(
                    url: place.media.firstOrNull?.publicUrl,
                    fit: BoxFit.cover,
                    height: double.infinity,
                  ),
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place.shortSummary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Category badge
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: style.color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(style.icon,
                                            size: 12, color: style.color),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            style.label,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: style.color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Rating
                                if (place.effectiveRating > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8E1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star,
                                            size: 12,
                                            color: Color(0xFFF57F17)),
                                        const SizedBox(width: 2),
                                        Text(
                                          place.effectiveRating
                                              .toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFF57F17),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Duration
                          Text(
                            '${place.durationMin} dk',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Map Icon Button ────────────────────────────────────────────────
class _MapIconButton extends StatelessWidget {
  const _MapIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active
                ? RouteviaColors.accent.withValues(alpha: 0.15)
                : Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? RouteviaColors.accent : Colors.grey.shade300,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: active ? RouteviaColors.accent : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
