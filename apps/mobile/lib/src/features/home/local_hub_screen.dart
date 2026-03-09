import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/widgets/safe_network_image.dart';
import '../../data/providers.dart';
import '../../models/trip_models.dart';

Color _categoryColor(String category) {
  const colors = {
    'museum': Color(0xFF1565C0),
    'historical': Color(0xFFF57F17),
    'nature': Color(0xFF2E7D32),
    'beach': Color(0xFF0097A7),
    'viewpoint': Color(0xFF00897B),
    'food': Color(0xFFD84315),
    'cafe': Color(0xFF6D4C41),
    'lodging': Color(0xFF7B1FA2),
    'activity': Color(0xFF283593),
    'market': Color(0xFFC2185B),
    'tour': Color(0xFFE65100),
    'waterfall': Color(0xFF0288D1),
    'canyon': Color(0xFF4527A0),
  };
  return colors[category] ?? const Color(0xFF78909C);
}

IconData _categoryIcon(String category) {
  const icons = {
    'museum': Icons.museum,
    'historical': Icons.account_balance,
    'nature': Icons.park,
    'beach': Icons.beach_access,
    'viewpoint': Icons.panorama,
    'food': Icons.restaurant,
    'cafe': Icons.coffee,
    'lodging': Icons.hotel,
    'activity': Icons.directions_run,
    'market': Icons.shopping_bag,
    'tour': Icons.tour,
    'waterfall': Icons.water_drop,
    'canyon': Icons.terrain,
  };
  return icons[category] ?? Icons.place;
}

String _categoryLabel(String category) {
  const labels = {
    'museum': 'Müze',
    'historical': 'Tarihi',
    'nature': 'Doğa',
    'beach': 'Plaj',
    'viewpoint': 'Manzara',
    'food': 'Yemek',
    'cafe': 'Kafe',
    'lodging': 'Konaklama',
    'activity': 'Aktivite',
    'market': 'Çarşı',
    'tour': 'Tur',
    'waterfall': 'Şelale',
    'canyon': 'Kanyon',
  };
  return labels[category] ?? category;
}

class LocalHubScreen extends ConsumerStatefulWidget {
  const LocalHubScreen({super.key, this.initialProvinceSlug});
  final String? initialProvinceSlug;

  @override
  ConsumerState<LocalHubScreen> createState() => _LocalHubScreenState();
}

class _LocalHubScreenState extends ConsumerState<LocalHubScreen> {
  final MapController _mapController = MapController();
  bool _mapReady = false;

  String _mode = 'relax';
  bool _loading = false;
  bool _hasError = false;
  List<PlaceModel> _places = const [];
  List<Map<String, dynamic>> _provinces = const [];
  String? _provinceSlug;
  String _provinceName = 'Yerel Keşif';
  LatLng _center = const LatLng(39.9255, 32.8663);
  final double _zoom = 10.8;
  PlaceModel? _selectedPlace;

  // Pexels cover
  String? _coverImageUrl;
  bool _coverLoading = false;

  // User location for distance calc
  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
    _initHub();
  }

  List<String> _prefsForMode(String mode) {
    switch (mode) {
      case 'photo':
        return const ['sunset', 'instagrammable', 'nature'];
      case 'family':
        return const ['family', 'beach', 'nature'];
      case 'budget':
        return const ['budget', 'free', 'walkable'];
      case 'romantic':
        return const ['sunset', 'viewpoint', 'cafe'];
      default:
        return const ['sunset', 'nature', 'cafe'];
    }
  }

  Future<void> _initHub() async {
    final repo = ref.read(repositoryProvider);
    List<Map<String, dynamic>> provinces = const [];
    try {
      provinces = await repo.listProvinces();
    } catch (_) {}

    String? provinceSlug = widget.initialProvinceSlug;
    if (provinceSlug == null && provinces.isNotEmpty) {
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 5),
            ),
          );
          _userLat = pos.latitude;
          _userLng = pos.longitude;
          final withCoords = provinces
              .where((p) => p['lat'] != null && p['lng'] != null)
              .toList();
          withCoords.sort((a, b) {
            final da = Geolocator.distanceBetween(
              pos.latitude, pos.longitude,
              (a['lat'] as num).toDouble(), (a['lng'] as num).toDouble(),
            );
            final db = Geolocator.distanceBetween(
              pos.latitude, pos.longitude,
              (b['lat'] as num).toDouble(), (b['lng'] as num).toDouble(),
            );
            return da.compareTo(db);
          });
          provinceSlug = withCoords.firstOrNull?['slug'] as String?;
        }
      } catch (_) {}
      provinceSlug ??= provinces.first['slug'] as String;
    }

    if (!mounted) return;
    setState(() {
      _provinces = provinces;
      _provinceSlug = provinceSlug;
    });
    await _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    final slug = _provinceSlug;
    if (slug == null) return;
    final repo = ref.read(repositoryProvider);
    setState(() {
      _loading = true;
      _hasError = false;
      _selectedPlace = null;
    });
    try {
      final province = await repo.getProvinceBySlug(slug);
      var places = await repo.listProvinceHubPlaces(
        provinceSlug: slug,
        personaMode: _mode,
        preferences: _prefsForMode(_mode),
      );
      if (places.isEmpty) {
        places = await repo.listProvinceOrNationalTopPicks(
          provinceSlug: slug,
          limit: 120,
        );
      }
      places = places.where((p) => p.category != 'lodging').toList();
      if (!mounted) return;
      final lat = (province?['lat'] as num?)?.toDouble();
      final lng = (province?['lng'] as num?)?.toDouble();
      setState(() {
        _provinceName = (province?['name'] as String?) ?? slug;
        if (lat != null && lng != null) {
          _center = LatLng(lat, lng);
        }
        _places = places;
      });
      if (_mapReady) {
        try {
          _mapController.move(_center, _zoom);
        } catch (_) {}
      }
      unawaited(_loadCoverImage().catchError((_) {}));
    } catch (e) {
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadCoverImage() async {
    if (_provinceName == 'Yerel Keşif') return;
    if (!mounted) return;
    setState(() {
      _coverLoading = true;
      _coverImageUrl = null;
    });
    try {
      final result = await ref
          .read(repositoryProvider)
          .getDestinationImage(_provinceName);
      if (!mounted) return;
      setState(() {
        _coverImageUrl = result?['image_url'] as String?;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _coverLoading = false);
    }
  }

  double? _distanceTo(PlaceModel p) {
    if (_userLat == null || _userLng == null || p.lat == null || p.lng == null) {
      return null;
    }
    return Geolocator.distanceBetween(_userLat!, _userLng!, p.lat!, p.lng!) / 1000;
  }

  String _formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  Future<void> _buildPlan() async {
    if (_places.isEmpty || _provinceSlug == null) return;
    final repo = ref.read(repositoryProvider);
    try {
      final plan = await repo.generateTripPlan(
        provinceSlug: _provinceSlug!,
        days: 1,
        transportMode: 'car',
        pace: 'relaxed',
        personaMode: _mode,
        preferences: _prefsForMode(_mode),
        startLat: _userLat,
        startLng: _userLng,
      );
      if (!mounted) return;
      context.push('/day-plan', extra: plan);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan oluşturulamadı, tekrar dene.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = _places
        .where((p) => p.lat != null && p.lng != null)
        .take(500)
        .map(
          (p) => Marker(
            point: LatLng(p.lat!, p.lng!),
            width: 38,
            height: 38,
            child: GestureDetector(
              onTap: () => setState(() => _selectedPlace = p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _selectedPlace?.id == p.id
                      ? const Color(0xFF0B3B68)
                      : _categoryColor(p.category),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: _selectedPlace?.id == p.id ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_selectedPlace?.id == p.id
                              ? const Color(0xFF0B3B68)
                              : _categoryColor(p.category))
                          .withValues(alpha: 0.45),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _categoryIcon(p.category),
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('$_provinceName Keşif'),
        centerTitle: false,
        actions: [
          if (_places.isNotEmpty)
            TextButton.icon(
              onPressed: () => _buildPlan(),
              icon: const Icon(Icons.route_rounded, size: 18),
              label: const Text('Plan Yap'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0B3B68),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Filters ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(_provinceSlug),
                        initialValue: _provinceSlug,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'İl',
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: _provinces
                            .map(
                              (p) => DropdownMenuItem<String>(
                                value: p['slug'] as String,
                                child: Text(
                                  p['name'] as String,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v == null || v == _provinceSlug) return;
                          setState(() => _provinceSlug = v);
                          _loadPlaces();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['relax', 'photo', 'family', 'budget', 'romantic']
                        .map(
                          (m) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(_modeLabel(m)),
                              selected: _mode == m,
                              visualDensity: VisualDensity.compact,
                              onSelected: (_) {
                                setState(() => _mode = m);
                                _loadPlaces();
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // ── Cover image ──────────────────────────────────────────────────
          if (_coverLoading || _coverImageUrl != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: _buildCoverCard(),
            ),

          // ── Map ──────────────────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: _zoom,
                    onMapReady: () {
                      _mapReady = true;
                      try {
                        _mapController.move(_center, _zoom);
                      } catch (_) {}
                    },
                    onTap: (pos, point) => setState(() => _selectedPlace = null),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.yunusgunes.routevia',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                if (_loading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x55FFFFFF),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                if (_hasError)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.white.withValues(alpha: 0.9),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              size: 40, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('Veriler yüklenemedi',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: _loadPlaces,
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Selected place popup ─────────────────────────────────────────
          if (_selectedPlace != null) _buildSelectedCard(_selectedPlace!),

          // ── Place cards ──────────────────────────────────────────────────
          if (_selectedPlace == null)
            SizedBox(
              height: 180,
              child: _places.isEmpty && !_loading
                  ? const Center(
                      child: Text('Bu modda yer bulunamadı',
                          style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                      itemCount: _places.length,
                      itemBuilder: (context, i) {
                        return _buildPlaceCard(_places[i]);
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(PlaceModel p) {
    final dist = _distanceTo(p);
    final catColor = _categoryColor(p.category);
    return SizedBox(
      width: 260,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push('/place', extra: p),
            child: Row(
              children: [
                // Image
                SizedBox(
                  width: 90,
                  child: SafeNetworkImage(
                    url: p.media.firstOrNull?.publicUrl,
                    fit: BoxFit.cover,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_categoryIcon(p.category),
                                  size: 10, color: catColor),
                              const SizedBox(width: 3),
                              Text(
                                _categoryLabel(p.category),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: catColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Name
                        Text(
                          p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        // Rating + duration
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 13, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 2),
                            Text(
                              p.effectiveRating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.timer_outlined,
                                size: 12, color: Colors.grey),
                            const SizedBox(width: 2),
                            Text(
                              '${p.durationMin} dk',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        if (dist != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.near_me_outlined,
                                  size: 11, color: Color(0xFF0B3B68)),
                              const SizedBox(width: 2),
                              Text(
                                _formatDistance(dist),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF0B3B68),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedCard(PlaceModel p) {
    final catColor = _categoryColor(p.category);
    final dist = _distanceTo(p);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF0B3B68).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 70,
              height: 70,
              child: SafeNetworkImage(
                url: p.media.firstOrNull?.publicUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _categoryLabel(p.category),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: catColor),
                      ),
                    ),
                    const Spacer(),
                    if (dist != null)
                      Text(
                        _formatDistance(dist),
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF0B3B68),
                            fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  p.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 13, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 2),
                    Text(p.effectiveRating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    const Icon(Icons.timer_outlined,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text('${p.durationMin} dk',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: () => context.push('/place', extra: p),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0B3B68),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Detay', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoverCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 110,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_coverLoading)
              Container(
                color: const Color(0xFF1A2E50),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (_coverImageUrl != null)
              CachedNetworkImage(
                imageUrl: _coverImageUrl!,
                fit: BoxFit.cover,
                placeholder: (ctx, url) =>
                    Container(color: const Color(0xFF1A2E50)),
                errorWidget: (ctx, url, err) =>
                    Container(color: const Color(0xFF1A2E50)),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _provinceName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(blurRadius: 6)],
                    ),
                  ),
                  Text(
                    '${_places.length} keşif noktası',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _modeLabel(String mode) {
    switch (mode) {
      case 'photo':
        return '📸 Foto';
      case 'family':
        return '👨‍👩‍👧 Aile';
      case 'budget':
        return '💰 Bütçe';
      case 'romantic':
        return '🌹 Romantik';
      default:
        return '😌 Rahat';
    }
  }
}
