import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n.dart';
import '../../core/widgets/safe_network_image.dart';
import '../../data/fallback_provinces.dart';
import '../../data/providers.dart';
import '../../models/trip_models.dart';
import '../../models/weather_models.dart';

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

String _categoryEmoji(String category) {
  const emojis = {
    'museum': '🏛️',
    'historical': '🏰',
    'nature': '🌿',
    'beach': '🏖️',
    'viewpoint': '🔭',
    'food': '🍽️',
    'cafe': '☕',
    'lodging': '🏨',
    'activity': '🎯',
    'market': '🛍️',
    'tour': '🗺️',
    'waterfall': '💧',
    'canyon': '🏔️',
  };
  return emojis[category] ?? '📍';
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

  int _planDays = 3;
  String _mode = 'relax';
  int _radiusKm = 10;
  bool _allowOutsideDistrict = false;
  bool _loading = false;
  bool _hasError = false;
  List<PlaceModel> _places = const [];
  List<Map<String, dynamic>> _provinces = const [];
  List<Map<String, dynamic>> _districts = const [];
  String? _provinceSlug;
  String _provinceName = 'Yerel Keşif';
  String? _nearestDistrictId;
  String? _nearestDistrictName;
  LatLng _center = const LatLng(39.9255, 32.8663);
  final double _zoom = 10.8;
  PlaceModel? _selectedPlace;

  // Pexels cover
  String? _coverImageUrl;
  bool _coverLoading = false;

  // Weather (loaded async after province selection, non-fatal if fails)
  WeatherData? _weather;

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
    final planSettings = await ref.read(localCacheProvider).getPlanSettings();
    List<Map<String, dynamic>> provinces = const [];
    try {
      provinces = await repo.listProvinces();
    } catch (_) {}

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
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
      }
    } catch (_) {}

    String? provinceSlug = widget.initialProvinceSlug;
    if (provinceSlug == null && provinces.isNotEmpty) {
      try {
        if (_userLat != null && _userLng != null) {
          final withCoords = provinces
              .where((p) => p['lat'] != null && p['lng'] != null)
              .toList();
          withCoords.sort((a, b) {
            final da = Geolocator.distanceBetween(
              _userLat!, _userLng!,
              (a['lat'] as num).toDouble(), (a['lng'] as num).toDouble(),
            );
            final db = Geolocator.distanceBetween(
              _userLat!, _userLng!,
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
      _planDays = (planSettings['days'] as num?)?.toInt() ?? _planDays;
      _radiusKm = (planSettings['radius_km'] as num?)?.toInt() ?? _radiusKm;
      _allowOutsideDistrict =
          (planSettings['allow_outside'] as bool?) ?? _allowOutsideDistrict;
      _mode = (planSettings['persona'] as String?)?.trim().isNotEmpty == true
          ? planSettings['persona'] as String
          : _mode;
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
      final districts = await repo.listDistrictsByProvinceSlug(slug);
      _districts = districts;
      _resolveNearestDistrict();
      final strictDistrictName =
          _userLat == null || _userLng == null ? _nearestDistrictName : null;
      var places = await repo.listProvinceHubPlaces(
        provinceSlug: slug,
        personaMode: _mode,
        preferences: _prefsForMode(_mode),
        districtName: strictDistrictName,
      );
      if (places.isEmpty) {
        places = await repo.listProvinceHubPlaces(
          provinceSlug: slug,
          personaMode: _mode,
          preferences: _prefsForMode(_mode),
        );
      }
      if (places.isEmpty) {
        places = await repo.listProvinceOrNationalTopPicks(
          provinceSlug: slug,
          districtName: strictDistrictName,
          limit: 120,
        );
      }
      places = _filterPlacesByRadius(
        _sortPlacesForUser(places.where((p) => p.category != 'lodging').toList()),
      );
      if (!mounted) return;
      final lat = (province?['lat'] as num?)?.toDouble();
      final lng = (province?['lng'] as num?)?.toDouble();
      setState(() {
        _provinceName = (province?['name'] as String?) ?? slug;
        _districts = districts;
        if (_userLat != null && _userLng != null) {
          _center = LatLng(_userLat!, _userLng!);
        } else if (lat != null && lng != null) {
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
      unawaited(_loadWeather().catchError((_) {}));
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

  Future<void> _loadWeather() async {
    final slug = _provinceSlug;
    if (slug == null) return;

    // Try _provinces first (may come from DB without lat/lng),
    // then fall back to kFallbackProvinces which always has coordinates.
    Map<String, dynamic> province = _provinces.firstWhere(
      (p) => p['slug'] == slug,
      orElse: () => const {},
    );
    double? lat = (province['lat'] as num?)?.toDouble();
    double? lng = (province['lng'] as num?)?.toDouble();

    if (lat == null || lng == null) {
      province = kFallbackProvinces.firstWhere(
        (p) => p['slug'] == slug,
        orElse: () => const {},
      );
      lat = (province['lat'] as num?)?.toDouble();
      lng = (province['lng'] as num?)?.toDouble();
    }

    if (lat == null || lng == null) return;
    final cityName = (province['name'] as String?)?.isNotEmpty == true
        ? province['name'] as String
        : _provinceName;

    try {
      final data = await ref.read(repositoryProvider).getWeather(
            citySlug: slug,
            cityName: cityName,
            lat: lat,
            lng: lng,
          );
      if (!mounted) return;
      setState(() => _weather = data);
    } catch (_) {
      // Non-fatal: weather is an enhancement, not critical
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

  List<PlaceModel> _filterPlacesByRadius(List<PlaceModel> places) {
    if (_userLat == null || _userLng == null) return places;
    final inRadius = places.where((p) {
      final lat = p.lat;
      final lng = p.lng;
      if (lat == null || lng == null) return false;
      return Geolocator.distanceBetween(_userLat!, _userLng!, lat, lng) / 1000 <=
          _radiusKm;
    }).toList();
    return inRadius.isNotEmpty ? inRadius : places;
  }

  void _resolveNearestDistrict() {
    if (_userLat == null || _userLng == null || _districts.isEmpty) {
      _nearestDistrictId = null;
      _nearestDistrictName = null;
      return;
    }

    Map<String, dynamic>? nearest;
    var bestDistanceKm = double.infinity;
    for (final district in _districts) {
      final lat = (district['lat'] as num?)?.toDouble();
      final lng = (district['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;
      final distanceKm =
          Geolocator.distanceBetween(_userLat!, _userLng!, lat, lng) / 1000;
      if (distanceKm < bestDistanceKm) {
        bestDistanceKm = distanceKm;
        nearest = district;
      }
    }

    _nearestDistrictId = nearest?['id'] as String?;
    _nearestDistrictName = nearest?['name'] as String?;
  }

  List<PlaceModel> _sortPlacesForUser(List<PlaceModel> places) {
    final sorted = List<PlaceModel>.from(places);
    sorted.sort((a, b) {
      final da = _distanceTo(a);
      final db = _distanceTo(b);
      if (da != null || db != null) {
        if (da == null) return 1;
        if (db == null) return -1;
        final cmp = da.compareTo(db);
        if (cmp != 0) return cmp;
      }

      return a.name.compareTo(b.name);
    });
    return sorted;
  }

  void _focusPlaceOnMap(PlaceModel place) {
    final lat = place.lat;
    final lng = place.lng;
    setState(() => _selectedPlace = place);
    if (lat == null || lng == null || !_mapReady) return;
    try {
      _mapController.move(LatLng(lat, lng), _zoom < 14 ? 14 : _zoom);
    } catch (_) {}
  }

  Future<void> _openDirections(PlaceModel place) async {
    final lat = place.lat;
    final lng = place.lng;
    if (lat == null || lng == null) return;
    final encodedName = Uri.encodeComponent(place.name);
    final url = Platform.isIOS
        ? 'https://maps.apple.com/?daddr=$lat,$lng&q=$encodedName'
        : 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _buildPlan() async {
    if (_places.isEmpty || _provinceSlug == null) return;
    final repo = ref.read(repositoryProvider);
    try {
      TripPlan plan = await repo.generateTripPlan(
        provinceSlug: _provinceSlug!,
        days: _planDays,
        transportMode: _userLat != null && _userLng != null ? 'walk' : 'transit',
        pace: 'medium',
        personaMode: _mode,
        preferences: _prefsForMode(_mode),
        districtId: _nearestDistrictId,
        maxRadiusKm: _radiusKm,
        allowOutsideDistrict: false,
        startLat: _userLat,
        startLng: _userLng,
      );
      var stopCount = plan.daysPlan.fold<int>(
        0,
        (sum, day) => sum + day.stops.length,
      );
      if (_nearestDistrictId != null && stopCount < 5) {
        plan = await repo.generateTripPlan(
          provinceSlug: _provinceSlug!,
          days: _planDays,
          transportMode:
              _userLat != null && _userLng != null ? 'walk' : 'transit',
          pace: 'medium',
          personaMode: _mode,
          preferences: _prefsForMode(_mode),
          districtId: _nearestDistrictId,
          maxRadiusKm: _radiusKm,
          allowOutsideDistrict: _allowOutsideDistrict,
          startLat: _userLat,
          startLng: _userLng,
        );
        stopCount = plan.daysPlan.fold<int>(
          0,
          (sum, day) => sum + day.stops.length,
        );
      }
      if (!mounted) return;
      final expectedStops = _planDays * 4;
      if (stopCount < expectedStops) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.tr('Bolgede Yer Azaldi', 'Area Running Low')),
            content: Text(
              context.tr(
                'Bolgende daha fazla yer kalmadi. Gittigin yeni bir yeri bize onerirsen local hub daha da guclenir.',
                'There are not many places left in this area. If you suggest a place you visited, local hub gets stronger.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(context.tr('Bu Planla Devam Et', 'Continue')),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.push('/suggest');
                },
                child: Text(context.tr('Yer Oner', 'Suggest Place')),
              ),
            ],
          ),
        );
        if (!mounted) return;
      }
      context.push('/day-plan', extra: plan);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Plan oluşturulamadı, tekrar dene.',
              'Plan could not be created. Please try again.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = [
          if (_userLat != null && _userLng != null)
            Marker(
              point: LatLng(_userLat!, _userLng!),
              width: 30,
              height: 30,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x332563EB),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.my_location_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ..._places
              .where((p) => p.lat != null && p.lng != null)
              .take(500)
              .map(
          (p) => Marker(
            point: LatLng(p.lat!, p.lng!),
            width: 38,
            height: 38,
            child: GestureDetector(
              onTap: () => _focusPlaceOnMap(p),
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
                child: Text(
                  _categoryEmoji(p.category),
                  style: const TextStyle(fontSize: 14, height: 1),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            ),
        ),
        ];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('$_provinceName Keşif', 'Discover $_provinceName')),
        centerTitle: false,
        actions: [
          if (_places.isNotEmpty)
            TextButton.icon(
              onPressed: () => _buildPlan(),
              icon: const Icon(Icons.route_rounded, size: 18),
              label: Text(context.tr('Plan Yap', 'Build Plan')),
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
                const SizedBox(height: 6),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [6, 10, 15, 25, 40].map((km) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text('$km km'),
                          selected: _radiusKm == km,
                          visualDensity: VisualDensity.compact,
                          onSelected: (_) {
                            setState(() => _radiusKm = km);
                            _loadPlaces();
                          },
                        ),
                      );
                    }).toList(),
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

          // ── Weather banner ───────────────────────────────────────────────
          if (_weather != null)
            _WeatherBanner(weather: _weather!),

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
                          Text(
                            context.tr('Veriler yüklenemedi', 'Data could not be loaded'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: _loadPlaces,
                            child: Text(context.tr('Tekrar Dene', 'Try Again')),
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
                  ? Center(
                      child: Text(
                        context.tr('Bu modda yer bulunamadı', 'No places found for this mode'),
                        style: const TextStyle(color: Colors.grey),
                      ),
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
            onTap: () => _focusPlaceOnMap(p),
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
                child: Text(
                  context.tr('Detay', 'Details'),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 6),
              OutlinedButton(
                onPressed: () => _openDirections(p),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0B3B68),
                  side: const BorderSide(color: Color(0xFFBFD0E2)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  context.tr('Git', 'Go'),
                  style: const TextStyle(fontSize: 12),
                ),
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

// ── Weather Banner ──────────────────────────────────────────────────────────
// Compact, non-blocking weather strip shown below the city cover.
// Loads asynchronously after province selection; failure is silent.

class _WeatherBanner extends StatelessWidget {
  const _WeatherBanner({required this.weather});

  final WeatherData weather;

  static const _modeIcon = {
    'outdoor': '🌳',
    'indoor': '🏛️',
    'sunset': '🌅',
    'mixed': '🌆',
  };

  @override
  Widget build(BuildContext context) {
    final modeIcon = _modeIcon[weather.suggestionMode] ?? '🌤️';
    final hasRain = weather.precipitationProbability >= 30;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFD0E2)),
      ),
      child: Row(
        children: [
          Text(
            weather.conditionEmoji,
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      weather.tempLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF0B3B68),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      weather.conditionText,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                      ),
                    ),
                    if (hasRain) ...[
                      const SizedBox(width: 6),
                      Text(
                        '💧${weather.precipitationProbability}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '$modeIcon ${weather.suggestionLabel}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '💨 ${weather.windSpeed.round()} km/h',
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
