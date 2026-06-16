import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/ad_service.dart';
import '../../core/i18n.dart';
import '../../core/premium_gate.dart';
import '../../core/widgets/safe_network_image.dart';
import '../../core/widgets/place_pexels_image.dart';
import '../../data/fallback_provinces.dart';
import '../../data/providers.dart';
import '../../models/event_models.dart';
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

String _categoryLabel(String category, {bool isEnglish = false}) {
  const labelsTr = {
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
  const labelsEn = {
    'museum': 'Museum',
    'historical': 'Historical',
    'nature': 'Nature',
    'beach': 'Beach',
    'viewpoint': 'Viewpoint',
    'food': 'Food',
    'cafe': 'Cafe',
    'lodging': 'Lodging',
    'activity': 'Activity',
    'market': 'Market',
    'tour': 'Tour',
    'waterfall': 'Waterfall',
    'canyon': 'Canyon',
  };
  final map = isEnglish ? labelsEn : labelsTr;
  return map[category] ?? category;
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
  const LocalHubScreen({
    super.key,
    this.initialProvinceSlug,
    this.initialEventId,
  });
  final String? initialProvinceSlug;
  final String? initialEventId;

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
  int _startHour = 9; // 9=Sabah, 12=Öğle, 15=Öğleden Sonra
  bool _loading = false;
  bool _planBuilding = false; // debounce: spam tıklamayı önler
  bool _hasError = false;
  List<PlaceModel> _places = const [];
  List<Map<String, dynamic>> _provinces = const [];
  List<Map<String, dynamic>> _districts = const [];
  String? _provinceSlug;
  String _provinceName = '';
  String? _nearestDistrictId;
  String? _nearestDistrictName;
  // Explicitly user-selected district (overrides GPS-based nearest district)
  String? _selectedDistrictId;
  String? _selectedDistrictName;
  LatLng _center = const LatLng(39.9255, 32.8663);
  final double _zoom = 10.8;
  PlaceModel? _selectedPlace;

  // Pexels cover
  String? _coverImageUrl;
  bool _coverLoading = false;

  // Weather (loaded async after province selection, non-fatal if fails)
  WeatherData? _weather;
  List<EventModel> _events = const [];
  Map<String, EventReminderSetting> _eventReminders =
      const <String, EventReminderSetting>{};
  final Set<String> _eventBusyIds = <String>{};
  bool _eventsLoading = false;
  String? _selectedEventId;

  // User location for distance calc
  double? _userLat;
  double? _userLng;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedEventId = widget.initialEventId;
    _initHub().catchError((e, st) {
      debugPrint('[LocalHub] _initHub crashed: $e\n$st');
      if (mounted) setState(() => _hasError = true);
    });
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
    Map<String, dynamic> planSettings = const {};
    try {
      planSettings = await ref.read(localCacheProvider).getPlanSettings();
    } catch (_) {}
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
              _userLat!,
              _userLng!,
              (a['lat'] as num).toDouble(),
              (a['lng'] as num).toDouble(),
            );
            final db = Geolocator.distanceBetween(
              _userLat!,
              _userLng!,
              (b['lat'] as num).toDouble(),
              (b['lng'] as num).toDouble(),
            );
            return da.compareTo(db);
          });
          provinceSlug = withCoords.firstOrNull?['slug'] as String?;
        }
      } catch (_) {}
      provinceSlug ??= provinces.firstOrNull?['slug'] as String?;
      if (provinceSlug == null) return; // boş province listesi — sessizce çık
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
      _eventsLoading = true;
    });
    try {
      final province = await repo.getProvinceBySlug(slug);
      final districts = await repo.listDistrictsByProvinceSlug(slug);
      _districts = districts;
      _resolveNearestDistrict();
      // Explicit user district selection takes priority; fallback to GPS-nearest
      final effectiveDistrictName =
          _selectedDistrictName ??
          (_userLat == null || _userLng == null ? _nearestDistrictName : null);
      // Scope strictly to the district ONLY when the user explicitly picked one;
      // a province-only selection returns the whole province.
      var places = await repo.listProvinceHubPlaces(
        provinceSlug: slug,
        personaMode: _mode,
        preferences: _prefsForMode(_mode),
        districtName: _selectedDistrictName,
      );
      // Fall back to the whole province only when no district was explicitly
      // selected (so an explicitly chosen district stays district-scoped).
      if (places.isEmpty && _selectedDistrictName == null) {
        places = await repo.listProvinceHubPlaces(
          provinceSlug: slug,
          personaMode: _mode,
          preferences: _prefsForMode(_mode),
        );
      }
      if (places.isEmpty) {
        places = await repo.listProvinceOrNationalTopPicks(
          provinceSlug: slug,
          districtName: effectiveDistrictName,
          limit: 120,
        );
      }
      places = _filterPlacesByRadius(
        _sortPlacesForUser(
          places.where((p) => p.category != 'lodging').toList(),
        ),
      );
      if (!mounted) return;
      final lat = (province?['lat'] as num?)?.toDouble();
      final lng = (province?['lng'] as num?)?.toDouble();
      setState(() {
        _provinceName = (province?['name'] as String?) ?? slug;
        _districts = districts;
        // If user explicitly picked a district, keep map centered there.
        // Always center on the selected province — user location is shown
        // as a separate marker, not as the map center.
        if (_selectedDistrictId == null) {
          if (lat != null && lng != null) {
            _center = LatLng(lat, lng);
          }
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
      unawaited(_loadEvents().catchError((_) {}));
    } catch (e, st) {
      debugPrint('[LocalHub] _loadPlaces error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _hasError = true;
        if (_provinceName.isEmpty && _provinceSlug != null) {
          _provinceName = _provinces
                  .firstWhere(
                    (p) => p['slug'] == _provinceSlug,
                    orElse: () => <String, dynamic>{},
                  )['name']
                  as String? ??
              _provinceSlug!;
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadEvents() async {
    final slug = _provinceSlug;
    if (slug == null) return;
    final repo = ref.read(repositoryProvider);
    try {
      final futures = <Future<dynamic>>[repo.listProvinceEvents(slug)];
      if (Supabase.instance.client.auth.currentUser != null) {
        futures.add(repo.listMyEventReminders());
      }
      final results = await Future.wait(futures);
      var events = results.first as List<EventModel>;
      final selectedEventId = _selectedEventId;
      if (selectedEventId != null && selectedEventId.isNotEmpty) {
        events = [...events]
          ..sort((a, b) {
            if (a.id == selectedEventId) return -1;
            if (b.id == selectedEventId) return 1;
            final monthCompare = a.monthStart.compareTo(b.monthStart);
            if (monthCompare != 0) return monthCompare;
            return a.name.compareTo(b.name);
          });
      }
      if (!mounted) return;
      setState(() {
        _events = events;
        _eventReminders = results.length > 1
            ? (results[1] as Map<String, EventReminderSetting>)
            : const <String, EventReminderSetting>{};
        _eventsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _events = const [];
        _eventReminders = const <String, EventReminderSetting>{};
        _eventsLoading = false;
      });
    }
  }

  Future<void> _toggleEventReminder(EventModel event, bool enabled) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) context.push('/auth');
      return;
    }
    if (_eventBusyIds.contains(event.id)) return;
    setState(() {
      _selectedEventId = event.id;
      _eventBusyIds.add(event.id);
    });
    try {
      await ref
          .read(repositoryProvider)
          .setEventReminder(eventId: event.id, enabled: enabled);
      if (!mounted) return;
      setState(() {
        final updated = Map<String, EventReminderSetting>.from(_eventReminders);
        if (enabled) {
          updated[event.id] = EventReminderSetting(
            eventId: event.id,
            enabled: true,
          );
        } else {
          updated.remove(event.id);
        }
        _eventReminders = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? context.tr(
                    'Festival hatırlatıcısı açıldı.',
                    'Festival reminder enabled.',
                  )
                : context.tr(
                    'Festival hatırlatıcısı kapatıldı.',
                    'Festival reminder disabled.',
                  ),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Hatırlatıcı kaydedilemedi, tekrar dene.',
              'Reminder could not be saved. Try again.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _eventBusyIds.remove(event.id));
    }
  }

  String _monthRangeLabel(EventModel event) {
    const monthsTr = [
      '',
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    const monthsEn = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final months = isEnglish ? monthsEn : monthsTr;
    if (event.monthStart == event.monthEnd) {
      return months[event.monthStart];
    }
    return '${months[event.monthStart]} - ${months[event.monthEnd]}';
  }

  String _eventStatusLabel(EventModel event) {
    final currentMonth = DateTime.now().month;
    if (event.isActiveInMonth(currentMonth)) {
      return context.tr('Bu ay', 'This month');
    }
    if (event.monthStart > currentMonth) {
      return context.tr('Yaklaşıyor', 'Upcoming');
    }
    return context.tr('Sezonluk', 'Seasonal');
  }

  Color _eventAccent(EventModel event) {
    switch (event.category) {
      case 'müzik':
        return const Color(0xFF7C3AED);
      case 'yemek':
        return const Color(0xFFD97706);
      case 'sanat':
        return const Color(0xFFDB2777);
      case 'spor':
        return const Color(0xFF059669);
      case 'doğa':
        return const Color(0xFF0F766E);
      case 'geleneksel':
        return const Color(0xFFB45309);
      default:
        return const Color(0xFF0B3B68);
    }
  }

  IconData _eventCategoryIcon(String category) {
    switch (category) {
      case 'müzik':
        return Icons.music_note_rounded;
      case 'yemek':
        return Icons.restaurant_menu_rounded;
      case 'sanat':
        return Icons.palette_rounded;
      case 'spor':
        return Icons.sports_handball_rounded;
      case 'doğa':
        return Icons.forest_rounded;
      case 'geleneksel':
        return Icons.celebration_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  void _selectEvent(EventModel event) {
    setState(() => _selectedEventId = event.id);
  }

  Future<void> _loadCoverImage() async {
    if (_provinceName.isEmpty) return;
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
      final data = await ref
          .read(repositoryProvider)
          .getWeather(citySlug: slug, cityName: cityName, lat: lat, lng: lng);
      if (!mounted) return;
      setState(() => _weather = data);
    } catch (e, st) {
      // Non-fatal: weather is an enhancement, not critical
      debugPrint('[weather] load failed: $e\n$st');
    }
  }

  double? _distanceTo(PlaceModel p) {
    if (_userLat == null ||
        _userLng == null ||
        p.lat == null ||
        p.lng == null) {
      return null;
    }
    return Geolocator.distanceBetween(_userLat!, _userLng!, p.lat!, p.lng!) /
        1000;
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
      return Geolocator.distanceBetween(_userLat!, _userLng!, lat, lng) /
              1000 <=
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

  void _onDistrictSelected(String? districtId) {
    if (districtId == _selectedDistrictId) return;
    final district = districtId == null
        ? null
        : _districts.firstWhere(
            (d) => d['id'] == districtId,
            orElse: () => <String, dynamic>{},
          );
    final lat = (district?['lat'] as num?)?.toDouble();
    final lng = (district?['lng'] as num?)?.toDouble();
    setState(() {
      _selectedDistrictId = districtId;
      _selectedDistrictName = district?['name'] as String?;
      _nearestDistrictId = districtId;
      _nearestDistrictName = _selectedDistrictName;
      if (lat != null && lng != null) {
        _center = LatLng(lat, lng);
      }
    });
    // Zoom in on the selected district
    if (_mapReady && lat != null && lng != null) {
      try {
        _mapController.move(LatLng(lat, lng), 12.5);
      } catch (_) {}
    }
    _loadPlaces();
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
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _buildPlan() async {
    if (_planBuilding || _places.isEmpty || _provinceSlug == null) return;
    setState(() => _planBuilding = true);
    final premiumState = ref.read(premiumStateProvider).valueOrNull;
    if (premiumState != null && !premiumState.canGeneratePlan) {
      if (mounted) {
        showPremiumGate(context, feature: 'Günlük plan limiti doldu');
      }
      return;
    }
    final repo = ref.read(repositoryProvider);
    try {
      TripPlan plan = await repo.generateTripPlan(
        provinceSlug: _provinceSlug!,
        days: _planDays,
        transportMode: _userLat != null && _userLng != null
            ? 'walk'
            : 'transit',
        pace: 'medium',
        personaMode: _mode,
        preferences: _prefsForMode(_mode),
        districtId: _nearestDistrictId,
        maxRadiusKm: _radiusKm,
        allowOutsideDistrict: false,
        startLat: _userLat,
        startLng: _userLng,
        startHour: _startHour,
      );
      var stopCount = plan.daysPlan.fold<int>(
        0,
        (sum, day) => sum + day.stops.length,
      );
      if (_nearestDistrictId != null && stopCount < 5) {
        plan = await repo.generateTripPlan(
          provinceSlug: _provinceSlug!,
          days: _planDays,
          transportMode: _userLat != null && _userLng != null
              ? 'walk'
              : 'transit',
          pace: 'medium',
          personaMode: _mode,
          preferences: _prefsForMode(_mode),
          districtId: _nearestDistrictId,
          maxRadiusKm: _radiusKm,
          allowOutsideDistrict: _allowOutsideDistrict,
          startLat: _userLat,
          startLng: _userLng,
          startHour: _startHour,
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
      AdService().showInterstitialIfAllowed();
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
    } finally {
      if (mounted) setState(() => _planBuilding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final placeMarkers = _places
        .where((p) => p.lat != null && p.lng != null)
        .take(500)
        .map(
          (p) => Marker(
            key: ValueKey('m:${p.id}'),
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
                      color:
                          (_selectedPlace?.id == p.id
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
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _provinceName.isEmpty
              ? context.tr('Yerel Keşif', 'Local Discovery')
              : context.tr('$_provinceName Keşif', 'Discover $_provinceName'),
        ),
        centerTitle: false,
        actions: [
          if (_places.isNotEmpty)
            TextButton.icon(
              onPressed: _planBuilding ? null : () => _buildPlan(),
              icon: _planBuilding
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.route_rounded, size: 18),
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
                        decoration: InputDecoration(
                          labelText: context.tr('İl', 'Province'),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
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
                          setState(() {
                            _provinceSlug = v;
                            // Reset district selection when province changes
                            _selectedDistrictId = null;
                            _selectedDistrictName = null;
                          });
                          _loadPlaces();
                        },
                      ),
                    ),
                  ],
                ),
                // ── District selector (shown only when districts available)
                if (_districts.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    key: ValueKey(
                      'district_${_provinceSlug}_$_selectedDistrictId',
                    ),
                    initialValue: _selectedDistrictId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: context.tr('İlçe', 'District'),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(context.tr('Tüm İlçeler', 'All Districts')),
                      ),
                      ..._districts
                          .where((d) => d['name'] != null)
                          .map(
                            (d) => DropdownMenuItem<String>(
                              value: d['id'] as String,
                              child: Text(
                                d['name'] as String,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                    ],
                    onChanged: _onDistrictSelected,
                  ),
                ],
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
                const SizedBox(height: 6),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _StartTimeChip(
                        label: context.tr(
                          '🌅 Sabah (09:00)',
                          '🌅 Morning (09:00)',
                        ),
                        selected: _startHour == 9,
                        onTap: () => setState(() => _startHour = 9),
                      ),
                      _StartTimeChip(
                        label: context.tr('☀️ Öğle (12:00)', '☀️ Noon (12:00)'),
                        selected: _startHour == 12,
                        onTap: () => setState(() => _startHour = 12),
                      ),
                      _StartTimeChip(
                        label: context.tr(
                          '🌆 Öğleden Sonra (14:00)',
                          '🌆 Afternoon (14:00)',
                        ),
                        selected: _startHour == 14,
                        onTap: () => setState(() => _startHour = 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable body (cover → map → festival → places) ────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover image
                  if (_coverLoading || _coverImageUrl != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                      child: _buildCoverCard(),
                    ),

                  // Weather banner
                  if (_weather != null) _WeatherBanner(weather: _weather!),

                  // Map
                  SizedBox(
                    height: 270,
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
                    onTap: (pos, point) =>
                        setState(() => _selectedPlace = null),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.yunusgunes.routevia',
                      errorTileCallback: (tile, error, stackTrace) {
                        debugPrint('[local_hub] tile error ignored: $error');
                      },
                    ),
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 55,
                        size: const Size(46, 46),
                        markers: placeMarkers,
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
                                color: const Color(0xFFFFD600),
                                width: 2,
                              ),
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
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_userLat != null && _userLng != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_userLat!, _userLng!),
                            width: 30,
                            height: 30,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
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
                        ],
                      ),
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
                          const Icon(
                            Icons.wifi_off_rounded,
                            size: 40,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr(
                              'Veriler yüklenemedi',
                              'Data could not be loaded',
                            ),
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
                // ── Fullscreen map button ─────────────────────────────────
                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    elevation: 3,
                    shadowColor: Colors.black26,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => context.push('/map-explore'),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.fullscreen_rounded,
                          size: 22,
                          color: Color(0xFF0B3B68),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

                  // ── Selected place popup ─────────────────────────────────
                  if (_selectedPlace != null)
                    _buildSelectedCard(_selectedPlace!),

                  // ── Festivals ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
                    child: _buildFestivalSection(),
                  ),

                  // ── Place cards ──────────────────────────────────────────
                  if (_selectedPlace == null)
                    SizedBox(
                      height: 196,
                      child: _places.isEmpty && !_loading
                          ? Center(
                              child: Text(
                                context.tr(
                                  'Bu modda yer bulunamadı',
                                  'No places found for this mode',
                                ),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.fromLTRB(12, 8, 4, 8),
                              itemCount: _places.length,
                              itemBuilder: (context, i) {
                                return _buildPlaceCard(_places[i]);
                              },
                            ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
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
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: p.media.isNotEmpty
                        ? SafeNetworkImage(
                            url: p.media.first.publicUrl,
                            fit: BoxFit.cover,
                            imageSize: ImageSize.thumbnail,
                          )
                        // No stored cover → resolve via Wikidata/Wikipedia/Pexels
                        // (same fallback the home & detail screens use).
                        : PlacePexelsImage(
                            placeName: p.name,
                            provinceName: _provinceName,
                            category: p.category,
                            fit: BoxFit.cover,
                            fallbackWidget: Container(
                              color: catColor.withValues(alpha: 0.15),
                              alignment: Alignment.center,
                              child: Text(
                                _categoryEmoji(p.category),
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
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
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _categoryIcon(p.category),
                                size: 10,
                                color: catColor,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _categoryLabel(
                                  p.category,
                                  isEnglish: context.isEnglish,
                                ),
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
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              p.effectiveRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.timer_outlined,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${p.durationMin} ${context.tr('dk', 'min')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        if (dist != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.near_me_outlined,
                                size: 11,
                                color: Color(0xFF0B3B68),
                              ),
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
        border: Border.all(
          color: const Color(0xFF0B3B68).withValues(alpha: 0.3),
        ),
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
              child: p.media.isNotEmpty
                  ? SafeNetworkImage(
                      url: p.media.first.publicUrl,
                      fit: BoxFit.cover,
                    )
                  : PlacePexelsImage(
                      placeName: p.name,
                      provinceName: _provinceName,
                      category: p.category,
                      fit: BoxFit.cover,
                      fallbackWidget: Container(
                        color: _categoryColor(p.category).withValues(alpha: 0.15),
                        alignment: Alignment.center,
                        child: Text(
                          _categoryEmoji(p.category),
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
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
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _categoryLabel(p.category),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: catColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (dist != null)
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
                const SizedBox(height: 4),
                Text(
                  p.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      p.effectiveRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.timer_outlined,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${p.durationMin} ${context.tr('dk', 'min')}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
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
                    '${_places.length} ${context.tr('keşif noktası', 'discovery spots')}',
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
    final isEnglish = context.isEnglish;
    switch (mode) {
      case 'photo':
        return isEnglish ? '📸 Photo' : '📸 Foto';
      case 'family':
        return isEnglish ? '👨‍👩‍👧 Family' : '👨‍👩‍👧 Aile';
      case 'budget':
        return isEnglish ? '💰 Budget' : '💰 Bütçe';
      case 'romantic':
        return isEnglish ? '🌹 Romantic' : '🌹 Romantik';
      default:
        return isEnglish ? '😌 Relax' : '😌 Rahat';
    }
  }

  Widget _buildFestivalSection() {
    if (_eventsLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('Festival Takvimi', 'Festival Calendar'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr(
                'Bu il için festival verisi hazırlanıyor. Yakında hatırlatıcı ile birlikte burada görünecek.',
                'Festival data for this province is being prepared and will appear here with reminders soon.',
              ),
              style: const TextStyle(color: Color(0xFF475569), height: 1.35),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.tr('Festival Takvimi', 'Festival Calendar'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            Text(
              '${_events.length} ${context.tr('etkinlik', 'events')}',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 176,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _events.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final event = _events[index];
              final reminder = _eventReminders[event.id];
              final reminderOn = reminder?.enabled == true;
              final busy = _eventBusyIds.contains(event.id);
              return SizedBox(
                width: 316,
                child: _FestivalCard(
                  event: event,
                  accent: _eventAccent(event),
                  monthLabel: _monthRangeLabel(event),
                  statusLabel: _eventStatusLabel(event),
                  icon: _eventCategoryIcon(event.category),
                  reminderOn: reminderOn,
                  selected: _selectedEventId == event.id,
                  busy: busy,
                  onTap: () => _selectEvent(event),
                  onToggleReminder: (value) =>
                      _toggleEventReminder(event, value),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FestivalCard extends StatelessWidget {
  const _FestivalCard({
    required this.event,
    required this.accent,
    required this.monthLabel,
    required this.statusLabel,
    required this.icon,
    required this.reminderOn,
    required this.selected,
    required this.busy,
    required this.onTap,
    required this.onToggleReminder,
  });

  final EventModel event;
  final Color accent;
  final String monthLabel;
  final String statusLabel;
  final IconData icon;
  final bool reminderOn;
  final bool selected;
  final bool busy;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggleReminder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: selected ? 0.16 : 0.1),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? accent.withValues(alpha: 0.55)
              : accent.withValues(alpha: 0.16),
          width: selected ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Üst satır: ikon + chip'ler ──────────────────────────────────
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
              ),
              const Spacer(),
              if (selected) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    context.tr('Seçili', 'Selected'),
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ── İsim — tam genişlik ─────────────────────────────────────────
          Text(
            event.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 3),
          // ── İlçe • ay ───────────────────────────────────────────────────
          Text(
            [
              if ((event.district ?? '').isNotEmpty) event.district!,
              monthLabel,
            ].join(' • '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          // ── Hatırlatıcı satırı ──────────────────────────────────────────
          Row(
            children: [
              Icon(
                reminderOn
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                size: 16,
                color: reminderOn ? accent : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Text(
                context.tr('Hatırlatıcı', 'Reminder'),
                style: TextStyle(
                  color: reminderOn ? accent : const Color(0xFF334155),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Switch.adaptive(
                value: reminderOn,
                onChanged: busy ? null : onToggleReminder,
                activeTrackColor: accent.withValues(alpha: 0.45),
                activeThumbColor: accent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Start Time Chip ──────────────────────────────────────────────────────────

class _StartTimeChip extends StatelessWidget {
  const _StartTimeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0B3B68) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? const Color(0xFF0B3B68)
                  : const Color(0xFFCBD5E1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
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
          Text(weather.conditionEmoji, style: const TextStyle(fontSize: 22)),
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
