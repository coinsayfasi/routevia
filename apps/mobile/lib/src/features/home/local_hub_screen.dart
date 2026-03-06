import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/widgets/glass_panel.dart';
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

class LocalHubScreen extends ConsumerStatefulWidget {
  const LocalHubScreen({super.key, this.initialProvinceSlug});

  final String? initialProvinceSlug;

  @override
  ConsumerState<LocalHubScreen> createState() => _LocalHubScreenState();
}

class _LocalHubScreenState extends ConsumerState<LocalHubScreen> {
  final MapController _mapController = MapController();

  String _mode = 'relax';
  int _days = 3;
  bool _loading = false;
  List<PlaceModel> _places = const [];
  List<Map<String, dynamic>> _provinces = const [];
  String? _provinceSlug;
  String _provinceName = 'Yerel Keşif';
  LatLng _center = const LatLng(39.9255, 32.8663);
  final double _zoom = 10.8;

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
    final provinces = await repo.listProvinces();

    String? provinceSlug = widget.initialProvinceSlug;
    if (provinceSlug == null && provinces.isNotEmpty) {
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition();
          final withCoords = provinces
              .where((p) => p['lat'] != null && p['lng'] != null)
              .toList();
          withCoords.sort((a, b) {
            final da = Geolocator.distanceBetween(
              pos.latitude,
              pos.longitude,
              (a['lat'] as num).toDouble(),
              (a['lng'] as num).toDouble(),
            );
            final db = Geolocator.distanceBetween(
              pos.latitude,
              pos.longitude,
              (b['lat'] as num).toDouble(),
              (b['lng'] as num).toDouble(),
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
    setState(() => _loading = true);
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
      if (!mounted) return;
      setState(() {
        _provinceName = (province?['name'] as String?) ?? slug;
        final lat = (province?['lat'] as num?)?.toDouble();
        final lng = (province?['lng'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          _center = LatLng(lat, lng);
        }
        _places = places;
      });
      _mapController.move(_center, _zoom);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _buildPlan() async {
    if (_provinceSlug == null) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(repositoryProvider);
      final trip = await repo.generateTripPlan(
        provinceSlug: _provinceSlug!,
        days: _days,
        transportMode: 'car',
        pace: 'medium',
        personaMode: _mode,
        preferences: _prefsForMode(_mode),
        mustIncludePlaceIds: _places.take(4).map((e) => e.id).toList(),
      );
      if (!mounted) return;
      context.push('/map', extra: trip);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Plan üretilemedi: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
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
            width: 34,
            height: 34,
            child: GestureDetector(
              onTap: () => context.push('/place', extra: p),
              child: Container(
                decoration: BoxDecoration(
                  color: _categoryColor(p.category),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _categoryColor(p.category).withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _categoryIcon(p.category),
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('$_provinceName Keşif Hub')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _provinceSlug,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'İl'),
                  items: _provinces
                      .map(
                        (p) => DropdownMenuItem<String>(
                          value: p['slug'] as String,
                          child: Text(p['name'] as String),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _provinceSlug = v);
                    _loadPlaces();
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['relax', 'photo', 'family', 'budget', 'romantic']
                        .map(
                          (m) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(_modeLabel(m)),
                              selected: _mode == m,
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Gün:'),
                    const SizedBox(width: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment<int>(value: 1, label: Text('1')),
                        ButtonSegment<int>(value: 2, label: Text('2')),
                        ButtonSegment<int>(value: 3, label: Text('3')),
                        ButtonSegment<int>(value: 4, label: Text('4')),
                      ],
                      selected: {_days},
                      onSelectionChanged: (s) =>
                          setState(() => _days = s.first),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _loading ? null : _buildPlan,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('WOW Plan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: _zoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.routevia.mobile',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                if (_loading)
                  const Positioned.fill(
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _places.length,
              itemBuilder: (context, i) {
                final p = _places[i];
                return SizedBox(
                  width: 280,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 0, 8),
                    child: GlassPanel(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.push('/place', extra: p),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: SafeNetworkImage(
                                url: p.media.firstOrNull?.publicUrl,
                                fit: BoxFit.cover,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      p.shortSummary,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '⭐ ${p.effectiveRating.toStringAsFixed(1)} • ${p.durationMin} dk',
                                    ),
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
              },
            ),
          ),
        ],
      ),
    );
  }

  String _modeLabel(String mode) {
    switch (mode) {
      case 'photo':
        return 'Foto';
      case 'family':
        return 'Aile';
      case 'budget':
        return 'Bütçe';
      case 'romantic':
        return 'Romantik';
      default:
        return 'Rahat';
    }
  }
}
