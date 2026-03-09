import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/error_utils.dart';
import '../../core/premium_gate.dart';
import '../../core/theme.dart';
import '../../core/widgets/ad_banner.dart';
import '../../data/providers.dart';
import '../../data/routevia_repository.dart';
import '../../models/trip_models.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/widgets/safe_network_image.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const String _allDistrictValue = '__all__';
  StreamSubscription<AuthState>? _authSub;
  String? _lastSessionUserId;
  bool _initialLoadRunning = false;
  bool _initialLoadQueued = false;

  // Plan state
  String? _provinceSlug;
  int _days = 3;
  String _transportMode = 'transit';
  String _pace = 'medium';
  int _planRadiusKm = 25;
  bool _allowOutsideDistrict = false;
  String _persona = 'relax';
  final Set<String> _prefs = {'sunset', 'food'};
  String? _districtId;

  // UI state
  bool _dataLoading = true;
  bool _popularLoading = false;
  bool _popularServiceError = false;
  bool _isAdmin = false;
  bool _premiumPreviewActive = false;
  DateTime? _premiumPreviewExpiry;
  String _pickMode = 'all';

  // Data
  List<Map<String, dynamic>> _provinces = const [];
  List<Map<String, dynamic>> _districts = const [];
  List<PlaceModel> _popularPlaces = const [];
  List<PlaceModel> _scenicPicks = const [];
  List<PlaceModel> _foodPicks = const [];
  List<PlaceModel> _stayPicks = const [];
  List<Map<String, dynamic>> _smartSeason = const [];
  bool _smartSeasonLoading = false;
  Map<String, String> _offlinePacks = const {};
  bool _offlineBusy = false;
  Map<String, Map<String, dynamic>> _liveStatusByPlaceId = const {};
  bool _liveLoading = false;
  Position? _position;

  // Pexels destination cover
  String? _coverImageUrl;
  bool _coverLoading = false;

  // ── Helpers ──────────────────────────────────────────────────────────────

  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * 3.141592653589793 / 180.0;
    final dLng = (lng2 - lng1) * 3.141592653589793 / 180.0;
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1 * 3.141592653589793 / 180.0) *
            cos(lat2 * 3.141592653589793 / 180.0) *
            (sin(dLng / 2) * sin(dLng / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  String _transportLabel(String v) => switch (v) {
    'walk' => 'Yürüyüş',
    'transit' => 'Toplu Taşıma',
    'car' => 'Araç',
    'bike' => 'Bisiklet',
    'scooter' => 'Scooter',
    _ => v,
  };

  String _paceLabel(String v) => switch (v) {
    'slow' => 'Yavaş',
    'medium' => 'Orta',
    'fast' => 'Hızlı',
    _ => v,
  };

  String _personaLabel(String v) => switch (v) {
    'relax' => 'Rahat',
    'romantic' => 'Romantik',
    'family' => 'Aile',
    'budget' => 'Bütçe',
    'photo' => 'Fotoğraf',
    'foodie' => 'Yeme-İçme',
    _ => v,
  };

  String _prefLabel(String v) =>
      const {
        'sunset': 'Gün Batımı',
        'sunrise': 'Gün Doğumu',
        'museum': 'Müze',
        'history': 'Tarih',
        'nature': 'Doğa',
        'food': 'Yemek',
        'cafe': 'Kafe',
        'beach': 'Plaj',
        'market': 'Pazar',
        'mall': 'AVM',
        'free': 'Ücretsiz',
        'lodging': 'Konaklama',
      }[v] ??
      v;

  String get _selectedProvinceName {
    if (_provinceSlug == null) return 'İl Seç';
    return _provinces.firstWhere(
              (p) => p['slug'] == _provinceSlug,
              orElse: () => <String, dynamic>{},
            )['name']
            as String? ??
        _provinceSlug!;
  }

  String get _selectedDistrictName {
    if (_districtId == null) return 'Tüm İl';
    return _districts.firstWhere(
              (d) => d['id'] == _districtId,
              orElse: () => <String, dynamic>{},
            )['name']
            as String? ??
        _districtId!;
  }

  List<PlaceModel> _activeTopPicks() {
    final selected = switch (_pickMode) {
      'scenic' => _scenicPicks,
      'food' => _foodPicks,
      _ => _popularPlaces,
    };
    List<PlaceModel> real(List<PlaceModel> list) => list
        .where((p) => !_isFakePlaceholder(p) && p.category != 'lodging')
        .toList();
    final filtered = real(selected);
    if (filtered.isNotEmpty) return filtered;
    final pop = real(_popularPlaces);
    if (pop.isNotEmpty) return pop;
    final sc = real(_scenicPicks);
    if (sc.isNotEmpty) return sc;
    return real(_foodPicks);
  }

  // ── Smart Context Helpers ────────────────────────────────────────────────

  int _minutesUntil(DateTime now, int h, int m) {
    final t = DateTime(now.year, now.month, now.day, h, m);
    return t.difference(now).inMinutes;
  }

  // Astronomical sunrise/sunset for given lat/lng (Turkey = UTC+3).
  // Accuracy: ±5 min — sufficient for UX display.
  ({int riseH, int riseM, int setH, int setM}) _solarForCoords(
    double lat,
    double lng,
  ) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
    const deg2rad = pi / 180;

    // Declination
    final declination = -23.45 * cos(2 * pi * (dayOfYear + 10) / 365.0);
    final decRad = declination * deg2rad;
    final latRad = lat * deg2rad;

    // Hour angle
    final cosHA = -tan(latRad) * tan(decRad);
    final ha = cosHA.clamp(-1.0, 1.0);
    final haAngle = acos(ha) / deg2rad; // degrees

    // Equation of time (minutes)
    final b = 2 * pi * (dayOfYear - 81) / 364.0;
    final eqTime = 9.87 * sin(2 * b) - 7.53 * cos(b) - 1.5 * sin(b);

    // Solar noon in local time (UTC+3 → standard meridian 45°)
    final solarNoonMin = 720 - eqTime - (lng - 45) * 4;

    final sunriseMin = (solarNoonMin - haAngle * 4).round();
    final sunsetMin = (solarNoonMin + haAngle * 4).round();

    return (
      riseH: (sunriseMin ~/ 60).clamp(0, 23),
      riseM: sunriseMin % 60,
      setH: (sunsetMin ~/ 60).clamp(0, 23),
      setM: sunsetMin % 60,
    );
  }

  ({int riseH, int riseM, int setH, int setM}) _solar() {
    final prov = _provinces.firstWhere(
      (p) => p['slug'] == _provinceSlug,
      orElse: () => const {},
    );
    final lat = (prov['lat'] as num?)?.toDouble();
    final lng = (prov['lng'] as num?)?.toDouble();
    // Fallback to Ankara if no coords
    return _solarForCoords(lat ?? 39.92, lng ?? 32.85);
  }

  String _timeStr(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  // Radius (km) travellable by the selected transport in ~30–40min
  double _transportRadiusKm() => switch (_transportMode) {
    'walk' => 2.0,
    'bike' => 12.0,
    'scooter' => 8.0,
    'transit' => 30.0,
    'car' => 60.0,
    _ => 25.0,
  };

  String _travelTimeStr(double km) {
    final speed = switch (_transportMode) {
      'walk' => 5.0,
      'bike' => 15.0,
      'scooter' => 20.0,
      'transit' => 25.0,
      'car' => 40.0,
      _ => 25.0,
    };
    final mins = (km / speed * 60).round().clamp(1, 600);
    return mins < 60 ? '~$mins dk' : '~${mins ~/ 60}s ${mins % 60}dk';
  }

  String _kmLabel(double km) =>
      km < 1.0 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(1)} km';

  IconData _transportIcon() => switch (_transportMode) {
    'walk' => Icons.directions_walk_rounded,
    'bike' || 'scooter' => Icons.directions_bike_rounded,
    'car' => Icons.directions_car_rounded,
    _ => Icons.directions_transit_rounded,
  };

  // ── Data loading ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _lastSessionUserId = Supabase.instance.client.auth.currentUser?.id;
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final nextUserId = event.session?.user.id;
      if (nextUserId == _lastSessionUserId) return;
      _lastSessionUserId = nextUserId;
      _scheduleInitialReload();
    });
    _scheduleInitialReload();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  void _scheduleInitialReload() {
    if (_initialLoadRunning) {
      _initialLoadQueued = true;
      return;
    }
    unawaited(_loadInitial());
  }

  Future<void> _loadInitial() async {
    _initialLoadRunning = true;
    setState(() => _dataLoading = true);
    final repo = ref.read(repositoryProvider);
    final cache = ref.read(localCacheProvider);
    List<Map<String, dynamic>> provinces = const [];
    bool isAdmin = false;
    Map<String, dynamic>? profile;
    String? startupWarning;
    try {
      try {
        provinces = await repo.listProvinces();
      } catch (_) {
        startupWarning =
            'İl verileri yüklenemedi. İnternet bağlantısını kontrol et.';
      }
      if (provinces.isEmpty) {
        startupWarning ??=
            'İl verileri geçici olarak boş geldi. Lütfen tekrar dene.';
      }

      try {
        isAdmin = await repo.isCurrentUserAdmin();
      } catch (_) {}
      try {
        profile = await repo.getMyProfile();
      } catch (_) {}

      if (provinces.isEmpty) {
        if (!mounted) return;
        setState(() {
          _provinces = const [];
          _districts = const [];
          _provinceSlug = null;
          _districtId = null;
          _position = null;
          _popularPlaces = const [];
          _scenicPicks = const [];
          _foodPicks = const [];
          _stayPicks = const [];
        });
        _showSnack(startupWarning ?? 'Başlangıç verileri yüklenemedi.');
        return;
      }

      final onboardingCompleted =
          (profile?['onboarding_completed'] as bool?) ?? false;

      Position? position;
      LocationPermission permission = LocationPermission.denied;
      try {
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          position = await Geolocator.getCurrentPosition();
        }
      } catch (_) {
        position = null;
      }

      if (!mounted) return;
      final preferredProvince = await cache.getPreferredProvinceSlug();
      final preferredDistrictId = await cache.getPreferredDistrictId();
      String? initialProvince = preferredProvince;

      if (position != null) {
        final posLat = position.latitude;
        final posLng = position.longitude;
        final withCoords = provinces
            .where((p) => p['lat'] != null && p['lng'] != null)
            .toList();
        if (withCoords.isNotEmpty) {
          withCoords.sort((a, b) {
            final da = _distanceKm(
              posLat,
              posLng,
              (a['lat'] as num).toDouble(),
              (a['lng'] as num).toDouble(),
            );
            final db = _distanceKm(
              posLat,
              posLng,
              (b['lat'] as num).toDouble(),
              (b['lng'] as num).toDouble(),
            );
            return da.compareTo(db);
          });
          initialProvince ??= withCoords.first['slug'] as String?;
        }
      }
      initialProvince ??= provinces.firstOrNull?['slug'] as String?;

      List<Map<String, dynamic>> districts = const [];
      if (initialProvince != null) {
        try {
          districts = await repo.listDistrictsByProvinceSlug(initialProvince);
        } catch (_) {}
      }

      if (!mounted) return;
      if (Supabase.instance.client.auth.currentSession != null &&
          !onboardingCompleted) {
        final pendingCode = await ref
            .read(localCacheProvider)
            .getPendingReferralCode();
        if (!mounted) return;
        context.go(
          pendingCode == null ? '/onboarding' : '/onboarding?ref=$pendingCode',
        );
        return;
      }

      List<Map<String, dynamic>> entitlements = const [];
      if (Supabase.instance.client.auth.currentSession != null) {
        try {
          entitlements = await repo.getEntitlements();
        } catch (_) {
          entitlements = const [];
        }
      }
      DateTime? expiry;
      bool isPro = false;
      final now = DateTime.now().toUtc();
      for (final e in entitlements) {
        final key = e['entitlement_key'] as String?;
        if (key == 'pro_preview_7d' || key == 'routevia_pro') {
          final ex = DateTime.tryParse((e['expires_at'] as String?) ?? '');
          if (ex != null && ex.isAfter(now)) {
            isPro = true;
            if (expiry == null || ex.isAfter(expiry)) {
              expiry = ex;
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _provinces = provinces;
        _position = position;
        _provinceSlug = initialProvince;
        _districts = districts;
        _districtId = districts.any((d) => d['id'] == preferredDistrictId)
            ? preferredDistrictId
            : null;
        _isAdmin = isAdmin;
        _premiumPreviewActive = isPro || isAdmin;
        _premiumPreviewExpiry = expiry;
      });

      await _loadPopularForProvince();
      unawaited(_loadCoverImage().catchError((_) {}));
      await _loadOfflinePacks();
      if (startupWarning != null && mounted) {
        _showSnack(startupWarning);
      }

      if (!mounted) return;
      if ((permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) &&
          preferredProvince == null &&
          Supabase.instance.client.auth.currentSession != null) {
        context.go('/location-setup');
        return;
      }
    } catch (e, st) {
      debugPrint('[home] _loadInitial failed: $e');
      debugPrintStack(stackTrace: st);
      if (mounted) {
        _showSnack('Başlangıç verileri yüklenemedi. Lütfen tekrar dene.');
      }
    } finally {
      _initialLoadRunning = false;
      if (mounted && _dataLoading) {
        setState(() => _dataLoading = false);
      }
      if (_initialLoadQueued) {
        _initialLoadQueued = false;
        _scheduleInitialReload();
      }
    }
  }

  String? get _selectedDistrictNameOrNull {
    if (_districtId == null) return null;
    final d = _districts.firstWhere(
      (d) => d['id'] == _districtId,
      orElse: () => <String, dynamic>{},
    );
    return d['name'] as String?;
  }

  Future<void> _loadPopularForProvince() async {
    final slug = _provinceSlug;
    if (slug == null) return;
    setState(() => _popularLoading = true);
    final repo = ref.read(repositoryProvider);
    final districtName = _selectedDistrictNameOrNull;
    var serviceError = false;
    try {
      var places = await repo.listProvinceHubPlaces(
        provinceSlug: slug,
        personaMode: _persona,
        preferences: _prefs.toList(),
        districtName: districtName,
      );
      if (places.isEmpty) {
        final fallbackBundle = await repo.nearbyPlacesBundle(
          lat:
              (await repo.getProvinceBySlug(slug))?['lat']?.toDouble() ??
              _position?.latitude ??
              37.87,
          lng:
              (await repo.getProvinceBySlug(slug))?['lng']?.toDouble() ??
              _position?.longitude ??
              32.50,
          radiusKm: 40,
          provinceSlug: slug,
          districtName: districtName,
          categories: const [],
          tags: const [],
          freeOnly: false,
        );
        final meta = Map<String, dynamic>.from(
          fallbackBundle['meta'] as Map? ?? const {},
        );
        serviceError = (meta['reason'] as String?) == 'service_unavailable';
        final top =
            (fallbackBundle['top_picks'] as List<PlaceModel>? ?? const []);
        places = top.isNotEmpty
            ? top
            : (fallbackBundle['items'] as List<PlaceModel>);
      }
      if (places.isEmpty) {
        places = await repo.listProvinceOrNationalTopPicks(
          provinceSlug: slug,
          districtName: districtName,
          limit: 24,
        );
      }
      if (places.isEmpty) {
        await repo.logAppEvent(
          'top_picks_empty',
          payload: {'province_slug': slug, 'screen': 'home'},
        );
      }
      if (!mounted) return;
      setState(() {
        _popularServiceError = serviceError;
        _popularPlaces = _buildDiversePicks(places, limit: 16);
        _scenicPicks = places
            .where(
              (p) => {
                'nature',
                'historical',
                'museum',
                'viewpoint',
                'beach',
                'waterfall',
                'canyon',
                'activity',
                'tour',
              }.contains(p.category),
            )
            .take(16)
            .toList();
        _foodPicks = places
            .where((p) => p.category == 'food' || p.category == 'cafe')
            .take(10)
            .toList();
        _stayPicks = places
            .where((p) => p.category == 'lodging')
            .take(10)
            .toList();
      });
      unawaited(_loadSmartSeason());
      unawaited(_loadLiveStatusForTopPicks());
    } catch (_) {
      serviceError = true;
      var places = await _fallbackTopPicks(
        repo,
        slug,
        districtName: districtName,
      );
      if (places.isEmpty) {
        places = await repo.listProvinceOrNationalTopPicks(
          provinceSlug: slug,
          districtName: districtName,
          limit: 24,
        );
      }
      if (!mounted) return;
      setState(() {
        _popularServiceError = serviceError;
        _popularPlaces = _buildDiversePicks(places, limit: 16);
        _scenicPicks = places
            .where(
              (p) => {
                'nature',
                'historical',
                'museum',
                'viewpoint',
                'beach',
                'waterfall',
                'canyon',
                'activity',
                'tour',
              }.contains(p.category),
            )
            .take(16)
            .toList();
        _foodPicks = places
            .where((p) => p.category == 'food' || p.category == 'cafe')
            .take(10)
            .toList();
        _stayPicks = places
            .where((p) => p.category == 'lodging')
            .take(10)
            .toList();
      });
      unawaited(_loadSmartSeason());
      unawaited(_loadLiveStatusForTopPicks());
    } finally {
      if (mounted) setState(() => _popularLoading = false);
    }
  }

  Future<void> _loadSmartSeason() async {
    if (_provinceSlug == null) return;
    setState(() => _smartSeasonLoading = true);
    try {
      final items = await ref
          .read(repositoryProvider)
          .getSmartSeasonSuggestions(
            provinceSlug: _provinceSlug,
            districtName: _selectedDistrictNameOrNull,
            limit: 8,
          );
      if (!mounted) return;
      setState(() => _smartSeason = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _smartSeason = const []);
    } finally {
      if (mounted) setState(() => _smartSeasonLoading = false);
    }
  }

  Future<void> _loadOfflinePacks() async {
    try {
      final map = await ref.read(repositoryProvider).listOfflineCityPacks();
      if (!mounted) return;
      setState(() => _offlinePacks = map);
    } catch (_) {
      if (!mounted) return;
      setState(() => _offlinePacks = const {});
    }
  }

  Future<void> _downloadOfflinePack() async {
    final slug = _provinceSlug;
    if (slug == null || _offlineBusy) return;
    setState(() => _offlineBusy = true);
    try {
      await ref.read(repositoryProvider).downloadOfflineCityPack(slug);
      await _loadOfflinePacks();
      if (!mounted) return;
      _showSnack('Offline paket indirildi: $slug');
    } catch (e) {
      if (!mounted) return;
      _showSnack(friendlyError(e));
    } finally {
      if (mounted) setState(() => _offlineBusy = false);
    }
  }

  Future<void> _openOfflinePack() async {
    final slug = _provinceSlug;
    if (slug == null) return;
    final places = await ref.read(repositoryProvider).readOfflineCityPack(slug);
    if (!mounted) return;
    if (places.isEmpty) {
      _showSnack('Bu il için offline paket yok.');
      return;
    }
    final center = places.firstWhere(
      (p) => p.lat != null && p.lng != null,
      orElse: () => places.first,
    );
    context.push(
      '/map-explore',
      extra: {
        'lat': center.lat ?? _position?.latitude,
        'lng': center.lng ?? _position?.longitude,
        'province_slug': slug,
      },
    );
  }

  Future<void> _removeOfflinePack() async {
    final slug = _provinceSlug;
    if (slug == null) return;
    await ref.read(repositoryProvider).removeOfflineCityPack(slug);
    await _loadOfflinePacks();
    if (!mounted) return;
    _showSnack('Offline paket silindi: $slug');
  }

  Future<void> _loadLiveStatusForTopPicks() async {
    final ids = _popularPlaces.take(12).map((p) => p.id).toList();
    if (ids.isEmpty) return;
    setState(() => _liveLoading = true);
    try {
      final map = await ref
          .read(repositoryProvider)
          .getLiveStatusForPlaces(ids, hours: 6);
      if (!mounted) return;
      setState(() => _liveStatusByPlaceId = map);
    } catch (_) {
      if (!mounted) return;
      setState(() => _liveStatusByPlaceId = const {});
    } finally {
      if (mounted) setState(() => _liveLoading = false);
    }
  }

  Future<void> _loadCoverImage() async {
    final slug = _provinceSlug;
    if (slug == null) return;
    final name = _selectedProvinceName;
    if (name == 'İl Seç') return;
    setState(() {
      _coverLoading = true;
      _coverImageUrl = null;
    });
    try {
      final result = await ref
          .read(repositoryProvider)
          .getDestinationImage(name);
      if (!mounted) return;
      setState(() {
        _coverImageUrl = result?['image_url'] as String?;
      });
    } finally {
      if (mounted) setState(() => _coverLoading = false);
    }
  }

  Future<List<PlaceModel>> _fallbackTopPicks(
    RouteviaRepository repo,
    String provinceSlug, {
    String? districtName,
  }) async {
    final province = await repo.getProvinceBySlug(provinceSlug);
    final centerLat = (province?['lat'] as num?)?.toDouble();
    final centerLng = (province?['lng'] as num?)?.toDouble();
    final fallbackLat = centerLat ?? _position?.latitude;
    final fallbackLng = centerLng ?? _position?.longitude;
    if (fallbackLat == null || fallbackLng == null) return const [];
    final bundle = await repo.nearbyPlacesBundle(
      lat: fallbackLat,
      lng: fallbackLng,
      radiusKm: 40,
      provinceSlug: provinceSlug,
      districtName: districtName,
      categories: const [],
      tags: const [],
      freeOnly: false,
    );
    final top = (bundle['top_picks'] as List<PlaceModel>? ?? const []);
    if (top.isNotEmpty) return top;
    return bundle['items'] as List<PlaceModel>;
  }

  // Remove placeholder "core spot" entries that have no real content
  bool _isFakePlaceholder(PlaceModel p) {
    final lower = p.name.toLowerCase();
    return lower.contains('core spot') ||
        lower.contains('öne çıkan') ||
        lower.contains('featured spot') ||
        lower.endsWith('nokta');
  }

  List<PlaceModel> _buildDiversePicks(
    List<PlaceModel> source, {
    int limit = 16,
  }) {
    if (source.isEmpty) return const [];
    final realSource = source.where((p) => !_isFakePlaceholder(p)).toList();
    if (realSource.isEmpty) return const [];
    final isAnkara = _provinceSlug == 'ankara';
    final likesMuseum = _prefs.contains('museum');

    final naturePool = realSource
        .where(
          (p) => {
            'nature',
            'viewpoint',
            'beach',
            'waterfall',
            'canyon',
            'activity',
            'tour',
          }.contains(p.category),
        )
        .toList();
    final historyPool = realSource
        .where((p) => {'historical', 'market'}.contains(p.category))
        .toList();
    final museumPool = realSource.where((p) => p.category == 'museum').toList();
    final foodPool = realSource
        .where((p) => {'food', 'cafe'}.contains(p.category))
        .toList();
    final scenicPool = [...naturePool, ...historyPool, ...museumPool];
    final picks = <PlaceModel>[];
    final seen = <String>{};
    void takeOne(List<PlaceModel> pool) {
      for (final p in pool) {
        if (seen.add(p.id)) {
          picks.add(p);
          return;
        }
      }
    }

    if (isAnkara) {
      var natureQuota = (limit * 0.35).ceil();
      var foodQuota = (limit * 0.25).ceil();
      var historyQuota = (limit * 0.20).ceil();
      var museumQuota = likesMuseum ? (limit * 0.20).ceil() : 1;

      if (_persona == 'foodie') {
        foodQuota += 2;
        museumQuota = (museumQuota - 1).clamp(0, limit);
      } else if (_persona == 'photo') {
        natureQuota += 2;
      } else if (_persona == 'family') {
        natureQuota += 1;
        foodQuota += 1;
      }

      while (picks.where((p) => naturePool.contains(p)).length < natureQuota &&
          picks.length < limit) {
        final before = picks.length;
        takeOne(naturePool);
        if (picks.length == before) break;
      }
      while (picks.where((p) => foodPool.contains(p)).length < foodQuota &&
          picks.length < limit) {
        final before = picks.length;
        takeOne(foodPool);
        if (picks.length == before) break;
      }
      while (picks.where((p) => historyPool.contains(p)).length <
              historyQuota &&
          picks.length < limit) {
        final before = picks.length;
        takeOne(historyPool);
        if (picks.length == before) break;
      }
      while (picks.where((p) => museumPool.contains(p)).length < museumQuota &&
          picks.length < limit) {
        final before = picks.length;
        takeOne(museumPool);
        if (picks.length == before) break;
      }
    }

    // Fill remaining slots: prioritise scenic/nature/historical (3:1 over food).
    int fillCycle = 0;
    while (picks.length < limit) {
      final before = picks.length;
      takeOne(scenicPool);
      if (picks.length >= limit) break;
      takeOne(scenicPool);
      if (picks.length >= limit) break;
      takeOne(scenicPool);
      if (picks.length >= limit) break;
      // Only add food every 4th pick to avoid restaurant dominance.
      if (fillCycle % 4 == 3) takeOne(foodPool);
      fillCycle++;
      if (picks.length >= limit) break;
      takeOne(realSource);
      if (picks.length == before) break;
    }
    return picks;
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _openPromoApplication() async {
    final mailUri = Uri.parse(
      'mailto:${AppConstants.supportEmail}?subject=Routevia%20Tanitim%20Basvurusu&body=Merhaba%2C%20Routevia%20sponsorlu%20alani%20hakkinda%20bilgi%20almak%20istiyorum.',
    );
    try {
      await launchUrl(mailUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      _showSnack(
        'Mail uygulaması açılamadı. ${AppConstants.supportEmail} adresine yazabilirsin.',
      );
    }
  }

  Future<void> _openProvincePicker() async {
    if (_dataLoading) {
      _showSnack('İller yükleniyor, lütfen bekle...');
      return;
    }
    if (_provinces.isEmpty) {
      await _loadInitial();
      if (!mounted) return;
      if (_provinces.isEmpty) {
        _showSnack('İller yüklenemedi. İnternet bağlantısını kontrol et.');
        return;
      }
    }

    final provinces = List<Map<String, dynamic>>.from(_provinces);
    final currentSlug = _provinceSlug;

    if (!mounted) return;
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetCtx) =>
          _ProvincePickerSheet(provinces: provinces, selectedSlug: currentSlug),
    );

    if (selected == null || !mounted) return;
    if (selected == _provinceSlug) return;

    List<Map<String, dynamic>> districts = const [];
    try {
      districts = await ref
          .read(repositoryProvider)
          .listDistrictsByProvinceSlug(selected);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _provinceSlug = selected;
      _districts = districts;
      _districtId = null;
    });
    await _loadPopularForProvince();
    unawaited(_loadCoverImage().catchError((_) {}));
  }

  Future<void> _openDistrictPicker() async {
    if (_districts.isEmpty) {
      _showSnack('Bu il için ilçe verisi bulunamadı.');
      return;
    }
    final districts = List<Map<String, dynamic>>.from(_districts);
    final currentId = _districtId;

    if (!mounted) return;
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetCtx) =>
          _DistrictPickerSheet(districts: districts, selectedId: currentId),
    );

    if (!mounted) return;
    if (selected == _allDistrictValue) {
      setState(() => _districtId = null);
      await _loadPopularForProvince();
    } else if (selected != null) {
      setState(() => _districtId = selected);
      await _loadPopularForProvince();
    }
  }

  Future<void> _openPlanSettings() async {
    if (_provinces.isEmpty) {
      _showSnack('Önce il verilerinin yüklenmesini bekle.');
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetCtx) => _PlanSettingsSheet(
        initialDays: _days,
        initialTransportMode: _transportMode,
        initialPace: _pace,
        initialPersona: _persona,
        initialRadiusKm: _planRadiusKm,
        initialAllowOutside: _allowOutsideDistrict,
        initialPrefs: Set<String>.from(_prefs),
        transportLabel: _transportLabel,
        paceLabel: _paceLabel,
        personaLabel: _personaLabel,
        prefLabel: _prefLabel,
        onApply: (settings) {
          setState(() {
            _days = settings['days'] as int;
            _transportMode = settings['transportMode'] as String;
            _pace = settings['pace'] as String;
            _persona = settings['persona'] as String;
            _planRadiusKm = settings['radiusKm'] as int;
            _allowOutsideDistrict = settings['allowOutside'] as bool;
            final newPrefs = settings['prefs'] as Set<String>;
            _prefs
              ..clear()
              ..addAll(newPrefs);
          });
        },
      ),
    );
  }

  Future<void> _openGrowthSheet() async {
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    if (!isLoggedIn) {
      if (!mounted) return;
      _showSnack('Davet kodu için önce giriş yapmalısın.');
      context.push('/auth');
      return;
    }

    final repo = ref.read(repositoryProvider);
    String? referralCode;

    // 1) Try to read existing code from profile first (no extra RPC)
    try {
      final profile = await repo.getMyProfile();
      referralCode = (profile?['referral_code'] as String?)?.trim();
      if (referralCode?.isEmpty ?? true) referralCode = null;
    } catch (_) {}

    // 2) Only create if still null
    if (referralCode == null) {
      try {
        referralCode = await repo.createReferralCode();
      } catch (e) {
        if (mounted) _showSnack(friendlyError(e));
      }
    }

    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Büyüme Merkezi',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
              ),
              const SizedBox(height: 16),
              if (_premiumPreviewActive) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C2A8), Color(0xFF0B9E8A)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Premium Önizleme aktif${_premiumPreviewExpiry == null ? '' : ' • ${_premiumPreviewExpiry!.day}.${_premiumPreviewExpiry!.month}.${_premiumPreviewExpiry!.year}'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              _GrowthTile(
                icon: Icons.group_add_outlined,
                title: 'Arkadaşını Davet Et',
                subtitle: referralCode == null
                    ? 'Kod hazırlanamadı'
                    : 'Kodun: $referralCode',
                trailing: const Icon(Icons.share_outlined),
                onTap: referralCode == null
                    ? null
                    : () async {
                        Navigator.of(ctx).pop();
                        final text =
                            'Routevia ile gezi planını 1 tıkla yap. Davet kodum: $referralCode\n'
                            'routevia://ref/$referralCode';
                        await SharePlus.instance.share(ShareParams(text: text));
                        await repo.logAppEvent(
                          'referral_shared',
                          payload: {'code': referralCode},
                        );
                      },
              ),
              const SizedBox(height: 8),
              _GrowthTile(
                icon: Icons.feedback_outlined,
                title: 'Geri Bildirim Gönder',
                subtitle: 'Seni dinliyoruz',
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _openFeedbackDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFeedbackDialog() async {
    final controller = TextEditingController();
    double rating = 5;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Geri Bildirim'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Puan'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<double>(
                    value: rating,
                    isDense: true,
                    items: [5, 4, 3, 2, 1]
                        .map(
                          (e) => DropdownMenuItem<double>(
                            value: e.toDouble(),
                            child: Text('$e / 5'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setS(() => rating = v ?? 5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                minLines: 3,
                maxLines: 5,
                maxLength: 600,
                decoration: const InputDecoration(
                  labelText: 'Mesaj',
                  hintText: 'Ne geliştirelim?',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await ref
                      .read(repositoryProvider)
                      .submitFeedback(
                        message: controller.text.trim(),
                        rating: rating,
                      );
                  if (!mounted || !ctx.mounted) return;
                  Navigator.of(ctx).pop();
                  _showSnack('Teşekkürler! Geri bildirimin kaydedildi.');
                } catch (e) {
                  if (!mounted) return;
                  _showSnack(friendlyError(e));
                }
              },
              child: const Text('Gönder'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RouteviaColors.background,
      body: _dataLoading
          ? _buildLoadingBody()
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCard(),
                      const SizedBox(height: 20),
                      _buildLocationSelector(),
                      _buildDestinationCover(),
                      const SizedBox(height: 20),
                      _buildSmartContextSection(),
                      const SizedBox(height: 24),
                      _buildSmartSeasonSection(),
                      _buildOfflinePackSection(),
                      _buildLiveStatusSection(),
                      if (_premiumPreviewActive) ...[
                        _buildPremiumBadge(),
                        const SizedBox(height: 16),
                      ],
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      const AdBannerWidget(),
                      const SizedBox(height: 24),
                      _buildTopPicksSection(),
                      const SizedBox(height: 24),
                      if (_foodPicks.isNotEmpty && _pickMode != 'food') ...[
                        _buildFoodSection(),
                        const SizedBox(height: 24),
                      ],
                      if (_stayPicks.isNotEmpty) ...[
                        _buildStaySection(),
                        const SizedBox(height: 24),
                      ],
                      _buildPromoBanner(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLoadingBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF081A37), Color(0xFF0B1F3A), Color(0xFF123363)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 132,
              height: 132,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0x55D7E5FF)),
              ),
              child: Image.asset('assets/branding/app_icon_1024.png'),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 130,
              child: LinearProgressIndicator(
                minHeight: 3,
                borderRadius: BorderRadius.all(Radius.circular(8)),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64D1F4)),
                backgroundColor: Color(0x334A6B97),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: RouteviaColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: const Color(0x14000000),
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [RouteviaColors.teal, RouteviaColors.tealDark],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.explore, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 8),
          const Text(
            'Routevia',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 19,
              letterSpacing: -0.3,
              color: RouteviaColors.textPrimary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _openGrowthSheet,
          icon: const Icon(Icons.workspace_premium_outlined),
          tooltip: 'Büyüme',
          style: IconButton.styleFrom(
            foregroundColor: RouteviaColors.textSecondary,
          ),
        ),
        IconButton(
          onPressed: () => context.push('/trips'),
          icon: const Icon(Icons.route_outlined),
          tooltip: 'Gezilerim',
          style: IconButton.styleFrom(
            foregroundColor: RouteviaColors.textSecondary,
          ),
        ),
        if (_isAdmin)
          IconButton(
            onPressed: () => context.push('/admin'),
            icon: const Icon(Icons.admin_panel_settings_outlined),
            style: IconButton.styleFrom(
              foregroundColor: RouteviaColors.textSecondary,
            ),
          ),
        IconButton(
          onPressed: () => context.push('/suggest'),
          icon: const Icon(Icons.add_location_alt_outlined),
          tooltip: 'Yer Ekle',
          style: IconButton.styleFrom(
            foregroundColor: RouteviaColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C2A8).withValues(alpha: 0.22),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: const Color(0xFF0B1F3A).withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Multi-stop gradient background – richer & more vivid
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF010915),
                    Color(0xFF071628),
                    Color(0xFF0A2545),
                    Color(0xFF0E3260),
                  ],
                  stops: [0.0, 0.35, 0.7, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Teal glow – top-right
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00C2A8).withValues(alpha: 0.35),
                      const Color(0xFF00C2A8).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Blue glow – bottom-left
            Positioned(
              bottom: -40,
              left: -20,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF1D6FFA).withValues(alpha: 0.28),
                      const Color(0xFF1D6FFA).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Subtle route line decoration
            Positioned.fill(child: CustomPaint(painter: _RouteLinePainter())),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Premium badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C2A8), Color(0xFF009E88)],
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 11,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Routevia',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Info button
                      GestureDetector(
                        onTap: () => showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text('Öneri Kriterleri'),
                            content: const Text(
                              'Yeme-içme ve konaklama için yüksek puan/yorum eşiği uygulanır. '
                              'Tarihi/doğa noktaları kaynak kalitesi ve rota yakınlığına göre dengelenir.',
                            ),
                            actions: [
                              FilledButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Tamam'),
                              ),
                            ],
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 15,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // City name chip
                  if (_provinceSlug != null)
                    GestureDetector(
                      onTap: _openProvincePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: Color(0xFF00C2A8),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _selectedProvinceName.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.expand_more_rounded,
                              size: 13,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 14),

                  // Headline
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 33,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                      children: [
                        const TextSpan(text: 'Şehri Aç,\n'),
                        const TextSpan(text: 'Rota '),
                        TextSpan(
                          text: 'Akmaya',
                          style: TextStyle(
                            foreground: Paint()
                              ..shader =
                                  const LinearGradient(
                                    colors: [
                                      Color(0xFF00C2A8),
                                      Color(0xFF7DD3FC),
                                    ],
                                  ).createShader(
                                    const Rect.fromLTWH(0, 0, 200, 40),
                                  ),
                          ),
                        ),
                        const TextSpan(text: '\nBaşlasın.'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Subtitle
                  Text(
                    'Canlı keşif • Premium noktalar • Saatlik plan',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      height: 1.4,
                      fontSize: 13,
                      letterSpacing: 0.1,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats badges
                  Row(
                    children: [
                      _HeroBadge(
                        icon: Icons.explore_outlined,
                        label: '${_activeTopPicks().length} top pick',
                        color: const Color(0xFF00C2A8),
                      ),
                      const SizedBox(width: 8),
                      _HeroBadge(
                        icon: Icons.schedule_outlined,
                        label: '1–7 gün plan',
                        color: Colors.white.withValues(alpha: 0.0),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _HeroButton(
                          label: 'İl Hub',
                          icon: Icons.hub_outlined,
                          onTap: () => context.push(
                            '/local-hub',
                            extra: {'province_slug': _provinceSlug},
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HeroButton(
                          label: 'Plan Ayarları',
                          icon: Icons.tune_rounded,
                          onTap: _openPlanSettings,
                          accent: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _LocationPill(
              icon: Icons.location_city_rounded,
              label: _selectedProvinceName,
              onTap: _openProvincePicker,
              isLoading: _dataLoading,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _LocationPill(
              icon: Icons.map_outlined,
              label: _selectedDistrictName,
              onTap: _districts.isNotEmpty ? _openDistrictPicker : null,
              isLoading: _dataLoading,
              muted: _districts.isEmpty,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCover() {
    if (_coverImageUrl == null && !_coverLoading) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 160,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_coverLoading)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2E50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
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
                  errorWidget: (ctx, url, err) => const SizedBox.shrink(),
                ),
              // Gradient overlay for text legibility
              if (_coverImageUrl != null)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),
              // City name overlay
              if (_provinceSlug != null && _coverImageUrl != null)
                Positioned(
                  bottom: 28,
                  left: 14,
                  child: Text(
                    _selectedProvinceName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(blurRadius: 8)],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C2A8), Color(0xFF0B9E8A)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '7 gün Premium Önizleme aktif${_premiumPreviewExpiry == null ? '' : ' • ${_premiumPreviewExpiry!.day}.${_premiumPreviewExpiry!.month}.${_premiumPreviewExpiry!.year}'}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final hasMapTarget =
        _position != null || _districts.isNotEmpty || _provinceSlug != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (hasMapTarget)
            Expanded(
              child: _QuickActionCard(
                icon: Icons.map_rounded,
                label: 'Harita',
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C2A8), Color(0xFF0096A8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  final district = _districts.firstWhere(
                    (d) => d['id'] == _districtId,
                    orElse: () => <String, dynamic>{},
                  );
                  final province = _provinces.firstWhere(
                    (p) => p['slug'] == _provinceSlug,
                    orElse: () => <String, dynamic>{},
                  );
                  final lat =
                      (district['lat'] as num?)?.toDouble() ??
                      (province['lat'] as num?)?.toDouble() ??
                      _position?.latitude;
                  final lng =
                      (district['lng'] as num?)?.toDouble() ??
                      (province['lng'] as num?)?.toDouble() ??
                      _position?.longitude;
                  if (lat == null || lng == null) return;
                  final districtSlug = district['slug'] as String?;
                  final districtName = district['name'] as String?;
                  context.push(
                    '/map-explore',
                    extra: {
                      'lat': lat,
                      'lng': lng,
                      'province_slug': _provinceSlug,
                      'district_id': ?_districtId,
                      'district_slug': ?districtSlug,
                      'district_name': ?districtName,
                    },
                  );
                },
              ),
            ),
          if (hasMapTarget) const SizedBox(width: 10),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.login_rounded,
              label: Supabase.instance.client.auth.currentSession == null
                  ? 'Giriş Yap'
                  : 'Gezilerim',
              gradient: const LinearGradient(
                colors: [Color(0xFF0B1F3A), Color(0xFF133E75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                if (Supabase.instance.client.auth.currentSession == null) {
                  context.push('/auth');
                } else {
                  context.push('/trips');
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.add_location_alt_rounded,
              label: 'Yer Ekle',
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB703), Color(0xFFEA8C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => context.push('/suggest'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Smart Context Section ─────────────────────────────────────────────────

  Widget _buildSmartContextSection() {
    final now = DateTime.now();
    final hour = now.hour;
    final solar = _solar();

    // Categorise current time slot
    final (
      String eyebrow,
      IconData timeIcon,
      Color timeAccent,
      List<String> timeCats,
    ) = switch (hour) {
      5 || 6 => (
        'Gün Doğumu 🌅',
        Icons.wb_twilight_rounded,
        const Color(0xFFFF9800),
        ['viewpoint', 'nature', 'beach'],
      ),
      7 || 8 || 9 => (
        'Kahvaltı Vakti ☕',
        Icons.free_breakfast_rounded,
        const Color(0xFFD97706),
        ['cafe', 'food'],
      ),
      10 || 11 => (
        'Sabah Gezisi 🏛',
        Icons.explore_rounded,
        const Color(0xFF0096A8),
        ['historical', 'museum', 'activity'],
      ),
      12 || 13 => (
        'Öğle Molası 🍽',
        Icons.restaurant_rounded,
        const Color(0xFFEA580C),
        ['food', 'cafe'],
      ),
      14 || 15 || 16 => (
        'Öğleden Sonra 🎒',
        Icons.backpack_rounded,
        const Color(0xFF0096A8),
        ['museum', 'viewpoint', 'nature', 'historical'],
      ),
      17 || 18 => (
        'Gün Batımı 🌇',
        Icons.wb_sunny_rounded,
        const Color(0xFFFF5722),
        ['viewpoint', 'beach', 'nature'],
      ),
      19 || 20 || 21 => (
        'Akşam Yemeği 🍜',
        Icons.dinner_dining_rounded,
        const Color(0xFF7C3AED),
        ['food', 'cafe'],
      ),
      _ => (
        'Gece Gezisi 🌙',
        Icons.nightlife_rounded,
        const Color(0xFF0B1F3A),
        ['food', 'cafe', 'viewpoint'],
      ),
    };

    final allPicks = [
      ..._popularPlaces,
      ..._scenicPicks,
      ..._foodPicks,
    ].where((p) => !_isFakePlaceholder(p)).toSet().toList();

    final cards = <_SmartCard>[];

    // ── 1. Time-of-day best place ────────────────────────────────────────
    final timePicks = allPicks
        .where((p) => timeCats.contains(p.category))
        .toList();
    if (timePicks.isNotEmpty) {
      final top = timePicks.first;
      cards.add(
        _SmartCard(
          accentColor: timeAccent,
          icon: timeIcon,
          eyebrow: eyebrow,
          title: _cleanPlaceName(top.name),
          chips: [_SmartChip(_categoryLabels(top.category))],
          onTap: () => context.push('/place', extra: top),
        ),
      );
    } else {
      cards.add(
        _SmartCard(
          accentColor: timeAccent,
          icon: timeIcon,
          eyebrow: eyebrow,
          title: 'Keşfet',
          chips: [_SmartChip('Haritada gör')],
          onTap: () => context.push(
            '/local-hub',
            extra: {'province_slug': _provinceSlug},
          ),
        ),
      );
    }

    // ── 2. Sunrise card (always visible before it rises) ─────────────────
    final sunriseMin = _minutesUntil(now, solar.riseH, solar.riseM);
    if (sunriseMin >= -30 && sunriseMin <= 180) {
      final vp = allPicks
          .where((p) => {'viewpoint', 'nature', 'beach'}.contains(p.category))
          .toList();
      final sunriseTimeStr = _timeStr(solar.riseH, solar.riseM);
      cards.add(
        _SmartCard(
          accentColor: const Color(0xFFFF9800),
          icon: Icons.wb_twilight_rounded,
          eyebrow: sunriseMin > 0
              ? 'Gün Doğumuna $sunriseMin dk kaldı'
              : 'Gün Doğuyor! 🌅',
          title: vp.isNotEmpty
              ? _cleanPlaceName(vp.first.name)
              : 'Manzara noktaları',
          chips: [
            _SmartChip('$sunriseTimeStr gün doğumu · $_selectedProvinceName'),
          ],
          onTap: vp.isNotEmpty
              ? () => context.push('/place', extra: vp.first)
              : () => context.push(
                  '/local-hub',
                  extra: {'province_slug': _provinceSlug},
                ),
        ),
      );
    }

    // ── 3. Sunset card (always visible, even hours before) ───────────────
    final sunsetMin = _minutesUntil(now, solar.setH, solar.setM);
    if (sunsetMin >= -30 && sunsetMin <= 480) {
      final vp = allPicks
          .where((p) => {'viewpoint', 'beach', 'nature'}.contains(p.category))
          .toList();
      final sunsetTimeStr = _timeStr(solar.setH, solar.setM);
      final eyebrowSun = sunsetMin > 60
          ? 'Bugün saat $sunsetTimeStr gün batımı'
          : sunsetMin > 0
          ? 'Gün Batımına $sunsetMin dk kaldı 🌇'
          : 'Gün Batıyor! 🌅';
      cards.add(
        _SmartCard(
          accentColor: const Color(0xFFFF5722),
          icon: Icons.wb_sunny_rounded,
          eyebrow: eyebrowSun,
          title: vp.isNotEmpty
              ? _cleanPlaceName(vp.first.name)
              : 'Manzara noktaları',
          chips: [
            _SmartChip('$sunsetTimeStr · $_selectedProvinceName'),
            if (vp.isNotEmpty) _SmartChip(_categoryLabels(vp.first.category)),
          ],
          onTap: vp.isNotEmpty
              ? () => context.push('/place', extra: vp.first)
              : () => context.push(
                  '/local-hub',
                  extra: {'province_slug': _provinceSlug},
                ),
        ),
      );
    }

    // ── 4. Nearest place by transport ────────────────────────────────────
    if (_position != null && allPicks.isNotEmpty) {
      final radius = _transportRadiusKm();
      final withDist =
          allPicks
              .where((p) => p.lat != null && p.lng != null)
              .map(
                (p) => (
                  p,
                  _distanceKm(
                    _position!.latitude,
                    _position!.longitude,
                    p.lat!,
                    p.lng!,
                  ),
                ),
              )
              .where((e) => e.$2 <= radius)
              .toList()
            ..sort((a, b) => a.$2.compareTo(b.$2));

      if (withDist.isNotEmpty) {
        final (nearest, dist) = withDist.first;
        cards.add(
          _SmartCard(
            accentColor: RouteviaColors.teal,
            icon: _transportIcon(),
            eyebrow: 'En Yakın · ${_transportLabel(_transportMode)}',
            title: _cleanPlaceName(nearest.name),
            chips: [
              _SmartChip(_kmLabel(dist)),
              _SmartChip(_travelTimeStr(dist)),
            ],
            onTap: () => context.push('/place', extra: nearest),
          ),
        );

        // ── 5. Accessible places count ────────────────────────────────
        if (withDist.length > 1) {
          final catCounts = <String, int>{};
          for (final (p, _) in withDist) {
            catCounts[p.category] = (catCounts[p.category] ?? 0) + 1;
          }
          final topCat = catCounts.entries.reduce(
            (a, b) => a.value >= b.value ? a : b,
          );
          cards.add(
            _SmartCard(
              accentColor: const Color(0xFF10B981),
              icon: Icons.place_rounded,
              eyebrow: '${_transportLabel(_transportMode)} Mesafesinde',
              title: '${withDist.length} yer erişilebilir',
              chips: [
                _SmartChip('${_kmLabel(radius)} yarıçap'),
                _SmartChip('${topCat.value} ${_categoryLabels(topCat.key)}'),
              ],
              onTap: _loadPopularForProvince,
            ),
          );
        }
      }
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Şu An İçin',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.2,
                  color: RouteviaColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: RouteviaColors.teal.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: RouteviaColors.teal.withValues(alpha: 0.20),
                  ),
                ),
                child: const Text(
                  'Akıllı',
                  style: TextStyle(
                    color: RouteviaColors.teal,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 136,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _SmartSuggestionCard(card: cards[i]),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Helper to translate category key to Turkish label
  static String _categoryLabels(String cat) =>
      const {
        'nature': 'Doğa',
        'historical': 'Tarihi',
        'museum': 'Müze',
        'viewpoint': 'Manzara',
        'beach': 'Plaj',
        'waterfall': 'Şelale',
        'canyon': 'Kanyon',
        'food': 'Restoran',
        'cafe': 'Kafe',
        'lodging': 'Konaklama',
        'activity': 'Aktivite',
        'tour': 'Tur',
      }[cat] ??
      cat;

  Widget _buildTopPicksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pickMode == 'food'
                          ? 'Bu Haftanin Yemek Stoplari'
                          : _pickMode == 'scenic'
                          ? 'Bu Hafta Nereye Gidilir'
                          : 'Bu Haftanin Kesif Rotasi',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.2,
                        color: RouteviaColors.textPrimary,
                      ),
                    ),
                    if (_provinceSlug != null)
                      Text(
                        _pickMode == 'food'
                            ? 'Hizli yemek ve kafe secimleri • ${_districtId != null ? _selectedDistrictName : _selectedProvinceName}'
                            : 'Editor secimi + topluluk sinyali • ${_districtId != null ? _selectedDistrictName : _selectedProvinceName}',
                        style: const TextStyle(
                          color: RouteviaColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _loadPopularForProvince,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Yenile'),
                style: TextButton.styleFrom(
                  foregroundColor: RouteviaColors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tümü',
                  selected: _pickMode == 'all',
                  onTap: () => setState(() => _pickMode = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Gezilecek',
                  selected: _pickMode == 'scenic',
                  onTap: () => setState(() => _pickMode = 'scenic'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Yeme-İçme',
                  selected: _pickMode == 'food',
                  onTap: () => setState(() => _pickMode = 'food'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: _popularLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      RouteviaColors.teal,
                    ),
                    strokeWidth: 2.5,
                  ),
                )
              : _activeTopPicks().isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.explore_off_rounded,
                          size: 40,
                          color: RouteviaColors.textTertiary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _popularServiceError
                              ? 'Servis geçici kullanılamıyor.'
                              : _districtId != null
                              ? '$_selectedDistrictName için henüz yeterli veri yok.\n"Tüm İl" seçerek tüm ili görebilirsin.'
                              : 'Bu il için öneriler hazırlanıyor.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: RouteviaColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _loadPopularForProvince,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    final p = _activeTopPicks()[i];
                    final province = _provinces.firstWhere(
                      (pr) => pr['slug'] == _provinceSlug,
                      orElse: () => <String, dynamic>{},
                    );
                    final provinceLat = (province['lat'] as num?)?.toDouble();
                    final provinceLng = (province['lng'] as num?)?.toDouble();
                    final districtSlug =
                        _districts.firstWhere(
                              (d) => d['id'] == _districtId,
                              orElse: () => <String, dynamic>{},
                            )['slug']
                            as String?;
                    final districtName =
                        _districts.firstWhere(
                              (d) => d['id'] == _districtId,
                              orElse: () => <String, dynamic>{},
                            )['name']
                            as String?;
                    return _TopPickCard(
                      place: p,
                      onTap: () => context.push(
                        '/map-explore',
                        extra: {
                          'lat': p.lat ?? provinceLat ?? _position?.latitude,
                          'lng': p.lng ?? provinceLng ?? _position?.longitude,
                          'province_slug': _provinceSlug,
                          'district_id': ?_districtId,
                          'district_slug': ?districtSlug,
                          'district_name': ?districtName,
                        },
                      ),
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemCount: _activeTopPicks().length,
                ),
        ),
      ],
    );
  }

  Widget _buildSmartSeasonSection() {
    if (_smartSeasonLoading && _smartSeason.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: LinearProgressIndicator(minHeight: 2),
      );
    }
    if (_smartSeason.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Bu Hafta Nereye Gidilir?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: RouteviaColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 126,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _smartSeason
                .where((s) => s['category'] != 'lodging')
                .toList()
                .length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final filtered = _smartSeason
                  .where((s) => s['category'] != 'lodging')
                  .toList();
              final s = filtered[i];
              return GestureDetector(
                onTap: () {
                  final place = PlaceModel.fromMap({
                    'id': s['id'],
                    'name': s['name'],
                    'slug': s['id'],
                    'category': s['category'] ?? 'activity',
                    'short_summary': s['why'] ?? '',
                    'best_time': 'day',
                    'duration_min': 60,
                    'lat': s['lat'],
                    'lng': s['lng'],
                    'tags': ((s['tags'] as List?) ?? const []),
                  });
                  context.push('/place', extra: place);
                },
                child: Container(
                  width: 230,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: RouteviaColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (s['name'] as String?) ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (s['why'] as String?) ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: RouteviaColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            (s['season_score'] as num?)?.toStringAsFixed(1) ??
                                '-',
                            style: const TextStyle(
                              color: Color(0xFF92400E),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          if (s['category'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _categoryLabels(s['category'] as String),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF0369A1),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildOfflinePackSection() {
    final slug = _provinceSlug;
    if (slug == null) return const SizedBox.shrink();
    final hasPack = _offlinePacks.containsKey(slug);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: RouteviaColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.offline_pin, color: Color(0xFF0369A1)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Offline Sehir Paketi (MVP)',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  hasPack ? 'Hazir' : 'Yok',
                  style: TextStyle(
                    color: hasPack
                        ? const Color(0xFF166534)
                        : RouteviaColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: _offlineBusy
                      ? null
                      : () {
                          if (!_premiumPreviewActive) {
                            showPremiumGate(
                              context,
                              feature: 'Offline paketler',
                            );
                            return;
                          }
                          _downloadOfflinePack();
                        },
                  child: Text(_offlineBusy ? 'Indiriliyor...' : 'Paketi Indir'),
                ),
                OutlinedButton(
                  onPressed: hasPack ? _openOfflinePack : null,
                  child: const Text('Offline Ac'),
                ),
                OutlinedButton(
                  onPressed: hasPack ? _removeOfflinePack : null,
                  child: const Text('Sil'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    if (!_premiumPreviewActive) {
                      showPremiumGate(context, feature: 'Trend harita');
                      return;
                    }
                    context.push(
                      '/trend-map',
                      extra: {'province_slug': _provinceSlug},
                    );
                  },
                  icon: const Icon(Icons.local_fire_department),
                  label: const Text('Trend Harita'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatusSection() {
    final places = _popularPlaces.take(6).toList();
    final available = places
        .map((p) => {'place': p, 'live': _liveStatusByPlaceId[p.id]})
        .where((x) => (x['live'] as Map<String, dynamic>?) != null)
        .where((x) {
          final live = x['live'] as Map<String, dynamic>;
          final conf = (live['confidence'] as num?)?.toInt() ?? 0;
          final labels = ((live['tag_labels'] as List?) ?? const [])
              .map((e) => e.toString())
              .toList();
          return conf >= 35 && labels.isNotEmpty;
        })
        .toList();
    if (places.isEmpty && !_liveLoading) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Canli Durum',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: RouteviaColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (_liveLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (available.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Canli sinyal geldikce burada gorunecek.',
              style: TextStyle(color: RouteviaColors.textSecondary),
            ),
          )
        else
          SizedBox(
            height: 110,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final row = available[i];
                final place = row['place'] as PlaceModel;
                final live = row['live'] as Map<String, dynamic>;
                final labels = ((live['tag_labels'] as List?) ?? const [])
                    .map((e) => e.toString())
                    .toList();
                return InkWell(
                  onTap: () => context.push('/place', extra: place),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: RouteviaColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _cleanPlaceName(place.name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: labels
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
                                      color: Color(0xFF0369A1),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const Spacer(),
                        Text(
                          'Guven: ${(live['confidence'] as num?)?.toInt() ?? 0}%',
                          style: const TextStyle(
                            fontSize: 11,
                            color: RouteviaColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemCount: available.length,
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Yeme-İçme Önerileri',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.2,
              color: RouteviaColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) {
              final p = _foodPicks[i];
              final isCafe = p.category == 'cafe';
              final gradientColors = isCafe
                  ? const [Color(0xFF6D4C41), Color(0xFFFF8F00)]
                  : const [Color(0xFFE65100), Color(0xFFFF5722)];
              final icon = isCafe
                  ? Icons.local_cafe_rounded
                  : Icons.restaurant_rounded;
              return GestureDetector(
                onTap: () => context.push('/place', extra: p),
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                      const Spacer(),
                      Text(
                        _cleanPlaceName(p.name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemCount: _foodPicks.length,
          ),
        ),
      ],
    );
  }

  Widget _buildStaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Nerede Kalınır',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.2,
              color: RouteviaColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Konaklama önerilerini gezi akışından ayrı gösteriyoruz.',
            style: TextStyle(color: RouteviaColors.textSecondary, fontSize: 13),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) {
              final p = _stayPicks[i];
              return ActionChip(
                avatar: const Icon(
                  Icons.hotel_rounded,
                  size: 16,
                  color: Color(0xFF7B1FA2),
                ),
                label: Text(_cleanPlaceName(p.name)),
                onPressed: () => context.push('/place', extra: p),
                backgroundColor: RouteviaColors.surface,
                side: const BorderSide(color: RouteviaColors.border),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemCount: _stayPicks.length,
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RouteviaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(
          BorderSide(color: RouteviaColors.border),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: Color(0xFFEA580C),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDD5),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: const Text(
                    'Sponsorlu / Reklam',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9A3412),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'İşletmeni sponsorlu alanda göster. Organik sıralama ayrı kalır.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: RouteviaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Politika: reklam içeriği etiketlenir ve kullanıcıya şeffaf gösterilir.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: RouteviaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _openPromoApplication,
            child: const Text('Başvur'),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () => context.push('/legal?doc=ads'),
            child: const Text('Politika'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Province Picker Sheet
// ─────────────────────────────────────────��───────────────────────────────────

class _ProvincePickerSheet extends StatefulWidget {
  const _ProvincePickerSheet({
    required this.provinces,
    required this.selectedSlug,
  });

  final List<Map<String, dynamic>> provinces;
  final String? selectedSlug;

  @override
  State<_ProvincePickerSheet> createState() => _ProvincePickerSheetState();
}

class _ProvincePickerSheetState extends State<_ProvincePickerSheet> {
  late List<Map<String, dynamic>> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.provinces;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.provinces
          : widget.provinces
                .where((p) => (p['name'] as String).toLowerCase().contains(q))
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'İl Seç',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: RouteviaColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'İl ara...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _filtered = widget.provinces);
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Sonuç bulunamadı',
                      style: TextStyle(color: RouteviaColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    controller: scrollCtrl,
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final p = _filtered[i];
                      final slug = p['slug'] as String;
                      final name = p['name'] as String;
                      final isSelected = slug == widget.selectedSlug;
                      return ListTile(
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? RouteviaColors.teal
                                : RouteviaColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: RouteviaColors.teal,
                              )
                            : null,
                        onTap: () => Navigator.of(ctx).pop(slug),
                        selectedTileColor: RouteviaColors.teal.withValues(
                          alpha: 0.05,
                        ),
                        selected: isSelected,
                        shape: const RoundedRectangleBorder(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// District Picker Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _DistrictPickerSheet extends StatefulWidget {
  const _DistrictPickerSheet({
    required this.districts,
    required this.selectedId,
  });

  final List<Map<String, dynamic>> districts;
  final String? selectedId;

  @override
  State<_DistrictPickerSheet> createState() => _DistrictPickerSheetState();
}

class _DistrictPickerSheetState extends State<_DistrictPickerSheet> {
  late List<Map<String, dynamic>> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.districts;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.districts
          : widget.districts
                .where((d) => (d['name'] as String).toLowerCase().contains(q))
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'İlçe Seç',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: RouteviaColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'İlçe ara...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _filtered = widget.districts);
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: _filtered.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return ListTile(
                    title: const Text(
                      'Tüm İl',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: widget.selectedId == null
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: RouteviaColors.teal,
                          )
                        : null,
                    onTap: () => Navigator.of(ctx).pop('__all__'),
                    selected: widget.selectedId == null,
                    selectedTileColor: RouteviaColors.teal.withValues(
                      alpha: 0.05,
                    ),
                  );
                }
                final d = _filtered[i - 1];
                final id = d['id'] as String;
                final name = d['name'] as String;
                final isSelected = id == widget.selectedId;
                return ListTile(
                  title: Text(
                    name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? RouteviaColors.teal
                          : RouteviaColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: RouteviaColors.teal,
                        )
                      : null,
                  onTap: () => Navigator.of(ctx).pop(id),
                  selected: isSelected,
                  selectedTileColor: RouteviaColors.teal.withValues(
                    alpha: 0.05,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan Settings Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PlanSettingsSheet extends StatefulWidget {
  const _PlanSettingsSheet({
    required this.initialDays,
    required this.initialTransportMode,
    required this.initialPace,
    required this.initialPersona,
    required this.initialRadiusKm,
    required this.initialAllowOutside,
    required this.initialPrefs,
    required this.transportLabel,
    required this.paceLabel,
    required this.personaLabel,
    required this.prefLabel,
    required this.onApply,
  });

  final int initialDays;
  final String initialTransportMode;
  final String initialPace;
  final String initialPersona;
  final int initialRadiusKm;
  final bool initialAllowOutside;
  final Set<String> initialPrefs;
  final String Function(String) transportLabel;
  final String Function(String) paceLabel;
  final String Function(String) personaLabel;
  final String Function(String) prefLabel;
  final void Function(Map<String, dynamic>) onApply;

  @override
  State<_PlanSettingsSheet> createState() => _PlanSettingsSheetState();
}

class _PlanSettingsSheetState extends State<_PlanSettingsSheet> {
  late int _days;
  late String _transportMode;
  late String _pace;
  late String _persona;
  late int _radiusKm;
  late bool _allowOutside;
  late Set<String> _prefs;

  static const _prefList = [
    'sunset',
    'sunrise',
    'museum',
    'history',
    'nature',
    'food',
    'cafe',
    'beach',
    'market',
    'mall',
    'free',
    'lodging',
  ];

  @override
  void initState() {
    super.initState();
    _days = widget.initialDays;
    _transportMode = widget.initialTransportMode;
    _pace = widget.initialPace;
    _persona = widget.initialPersona;
    _radiusKm = widget.initialRadiusKm;
    _allowOutside = widget.initialAllowOutside;
    _prefs = Set<String>.from(widget.initialPrefs);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                const Text(
                  'Plan Ayarları',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.3,
                    color: RouteviaColors.textPrimary,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    widget.onApply({
                      'days': _days,
                      'transportMode': _transportMode,
                      'pace': _pace,
                      'persona': _persona,
                      'radiusKm': _radiusKm,
                      'allowOutside': _allowOutside,
                      'prefs': Set<String>.from(_prefs),
                    });
                    Navigator.of(ctx).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: RouteviaColors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Uygula'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                // Days
                _SettingsSection(
                  title: 'Kaç Gün?',
                  icon: Icons.calendar_today_outlined,
                  child: Wrap(
                    spacing: 8,
                    children: [1, 2, 3, 4, 5, 6, 7].map((d) {
                      return ChoiceChip(
                        label: Text('$d'),
                        selected: _days == d,
                        onSelected: (_) => setState(() => _days = d),
                        selectedColor: RouteviaColors.navyMid,
                        labelStyle: TextStyle(
                          color: _days == d
                              ? Colors.white
                              : RouteviaColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Transport
                _SettingsSection(
                  title: 'Ulaşım',
                  icon: Icons.directions_rounded,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        const ['walk', 'transit', 'car', 'bike', 'scooter'].map(
                          (m) {
                            return ChoiceChip(
                              label: Text(
                                const {
                                  'walk': 'Yürüyüş',
                                  'transit': 'Toplu Taşıma',
                                  'car': 'Araç',
                                  'bike': 'Bisiklet',
                                  'scooter': 'Scooter',
                                }[m]!,
                              ),
                              selected: _transportMode == m,
                              onSelected: (_) =>
                                  setState(() => _transportMode = m),
                              selectedColor: RouteviaColors.navyMid,
                              labelStyle: TextStyle(
                                color: _transportMode == m
                                    ? Colors.white
                                    : RouteviaColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Pace
                _SettingsSection(
                  title: 'Tempo',
                  icon: Icons.speed_rounded,
                  child: Row(
                    children: ['slow', 'medium', 'fast'].map((p) {
                      final isSelected = _pace == p;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _pace = p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? RouteviaColors.navyMid
                                  : RouteviaColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? RouteviaColors.navyMid
                                    : RouteviaColors.border,
                              ),
                            ),
                            child: Text(
                              widget.paceLabel(p),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : RouteviaColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Persona
                _SettingsSection(
                  title: 'Gezi Modu',
                  icon: Icons.mood_rounded,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        const [
                          'relax',
                          'romantic',
                          'family',
                          'budget',
                          'photo',
                          'foodie',
                        ].map((m) {
                          return ChoiceChip(
                            label: Text(
                              const {
                                'relax': 'Rahat',
                                'romantic': 'Romantik',
                                'family': 'Aile',
                                'budget': 'Bütçe',
                                'photo': 'Fotoğraf',
                                'foodie': 'Yeme-İçme',
                              }[m]!,
                            ),
                            selected: _persona == m,
                            onSelected: (_) => setState(() => _persona = m),
                            selectedColor: RouteviaColors.navyMid,
                            labelStyle: TextStyle(
                              color: _persona == m
                                  ? Colors.white
                                  : RouteviaColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Preferences
                _SettingsSection(
                  title: 'İlgi Alanları',
                  icon: Icons.favorite_outline_rounded,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _prefList.map((p) {
                      final selected = _prefs.contains(p);
                      return FilterChip(
                        label: Text(widget.prefLabel(p)),
                        selected: selected,
                        onSelected: (on) => setState(() {
                          if (on) {
                            _prefs.add(p);
                          } else {
                            _prefs.remove(p);
                          }
                        }),
                        selectedColor: RouteviaColors.navyMid,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : RouteviaColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        side: BorderSide(
                          color: selected
                              ? RouteviaColors.navyMid
                              : RouteviaColors.border,
                        ),
                        backgroundColor: RouteviaColors.surfaceVariant,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Radius
                _SettingsSection(
                  title: 'Plan Menzili',
                  icon: Icons.radar_rounded,
                  child: Wrap(
                    spacing: 8,
                    children: [6, 10, 15, 25, 40, 60].map((km) {
                      return ChoiceChip(
                        label: Text('$km km'),
                        selected: _radiusKm == km,
                        onSelected: (_) => setState(() => _radiusKm = km),
                        selectedColor: RouteviaColors.navyMid,
                        labelStyle: TextStyle(
                          color: _radiusKm == km
                              ? Colors.white
                              : RouteviaColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Allow outside district
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: RouteviaColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: const Border.fromBorderSide(
                      BorderSide(color: RouteviaColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.explore_outlined,
                        size: 20,
                        color: RouteviaColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'İlçe Dışına Çık',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: RouteviaColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Yakın ilçelerdeki yerleri de dahil et',
                              style: TextStyle(
                                fontSize: 12,
                                color: RouteviaColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _allowOutside,
                        onChanged: (v) => setState(() => _allowOutside = v),
                      ),
                    ],
                  ),
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
// Small reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? Colors.white.withValues(alpha: 0.0);
    final isAccent = color != null && (color!.a * 255.0).round() > 5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAccent
            ? accentColor.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isAccent
              ? accentColor.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: isAccent ? accentColor : Colors.white70),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isAccent ? accentColor : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.accent = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          gradient: accent
              ? const LinearGradient(
                  colors: [Color(0xFF00C2A8), Color(0xFF009E88)],
                )
              : null,
          color: accent ? null : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accent
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPill extends StatelessWidget {
  const _LocationPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.muted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null || isLoading || muted;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: disabled
              ? RouteviaColors.surfaceVariant
              : RouteviaColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: disabled
                ? RouteviaColors.borderLight
                : RouteviaColors.border,
            width: 1.2,
          ),
          boxShadow: disabled
              ? null
              : [
                  const BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: disabled
                  ? RouteviaColors.textTertiary
                  : RouteviaColors.teal,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: isLoading
                  ? const SizedBox(
                      height: 10,
                      width: 60,
                      child: LinearProgressIndicator(),
                    )
                  : Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: disabled
                            ? RouteviaColors.textTertiary
                            : RouteviaColors.textPrimary,
                      ),
                    ),
            ),
            if (!disabled)
              const Icon(
                Icons.expand_more_rounded,
                size: 16,
                color: RouteviaColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shadowColor = gradient.colors.first;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.30),
              blurRadius: 18,
              spreadRadius: -2,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? RouteviaColors.navyMid : RouteviaColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? RouteviaColors.navyMid : RouteviaColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : RouteviaColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _TopPickCard extends StatelessWidget {
  const _TopPickCard({required this.place, required this.onTap});

  final PlaceModel place;
  final VoidCallback onTap;

  static const _categoryColors = {
    'nature': Color(0xFF10B981),
    'historical': Color(0xFFB45309),
    'museum': Color(0xFF8B5CF6),
    'viewpoint': Color(0xFF0EA5E9),
    'beach': Color(0xFF06B6D4),
    'waterfall': Color(0xFF2563EB),
    'canyon': Color(0xFFEF4444),
    'food': Color(0xFFEA580C),
    'cafe': Color(0xFFD97706),
    'lodging': Color(0xFF7C3AED),
    'activity': Color(0xFF059669),
    'tour': Color(0xFF00C2A8),
  };

  static const _categoryLabels = {
    'nature': 'Doğa',
    'historical': 'Tarihi',
    'museum': 'Müze',
    'viewpoint': 'Manzara',
    'beach': 'Plaj',
    'waterfall': 'Şelale',
    'canyon': 'Kanyon',
    'food': 'Restoran',
    'cafe': 'Kafe',
    'lodging': 'Konaklama',
    'activity': 'Aktivite',
    'tour': 'Tur',
  };

  static const _categoryIcons = {
    'nature': Icons.forest_rounded,
    'historical': Icons.account_balance_rounded,
    'museum': Icons.museum_rounded,
    'viewpoint': Icons.landscape_rounded,
    'beach': Icons.beach_access_rounded,
    'waterfall': Icons.water_rounded,
    'canyon': Icons.terrain_rounded,
    'food': Icons.restaurant_rounded,
    'cafe': Icons.local_cafe_rounded,
    'lodging': Icons.hotel_rounded,
    'activity': Icons.directions_run_rounded,
    'tour': Icons.tour_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final imageUrl = place.media.firstOrNull?.publicUrl;
    final catColor = _categoryColors[place.category] ?? RouteviaColors.navyMid;
    final catIcon = _categoryIcons[place.category] ?? Icons.place_rounded;
    final catLabel = _categoryLabels[place.category] ?? place.category;
    final rating = place.effectiveRating;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image or gradient
                imageUrl != null
                    ? SafeNetworkImage(url: imageUrl, fit: BoxFit.cover)
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          // Dark navy base
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF060D1A), Color(0xFF0B1F3A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          // Category color radial glow (top-left)
                          Positioned(
                            top: -20,
                            left: -20,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    catColor.withValues(alpha: 0.35),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Large faint icon watermark
                          Positioned(
                            bottom: -10,
                            right: -10,
                            child: Icon(
                              catIcon,
                              size: 90,
                              color: catColor.withValues(alpha: 0.08),
                            ),
                          ),
                        ],
                      ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.72),
                      ],
                      stops: const [0.35, 1.0],
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: catColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(catIcon, size: 11, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              catLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _cleanPlaceName(place.name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                      if (rating > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: Color(0xFFFFB703),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: RouteviaColors.teal),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: RouteviaColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _GrowthTile extends StatelessWidget {
  const _GrowthTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: RouteviaColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: const Border.fromBorderSide(
            BorderSide(color: RouteviaColors.border),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: RouteviaColors.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: RouteviaColors.teal),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: RouteviaColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: RouteviaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Route Line Painter (hero card decoration)
// ─────────────────────────────────────────────────────────────────────────────

class _RouteLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00C2A8).withValues(alpha: 0.12)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFF00C2A8).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Curved route line from bottom-left to top-right
    final path = Path()
      ..moveTo(size.width * 0.05, size.height * 0.85)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.6,
        size.width * 0.6,
        size.height * 0.45,
        size.width * 0.95,
        size.height * 0.15,
      );
    canvas.drawPath(path, paint);

    // Dots along the route
    const dots = [0.15, 0.38, 0.62, 0.85];
    for (final t in dots) {
      final pt = _pathPoint(t, size);
      canvas.drawCircle(pt, 3.5, dotPaint);
      canvas.drawCircle(
        pt,
        6.0,
        Paint()
          ..color = const Color(0xFF00C2A8).withValues(alpha: 0.08)
          ..style = PaintingStyle.fill,
      );
    }
  }

  Offset _pathPoint(double t, Size size) {
    // Matches the cubic bezier in paint()
    final p0 = Offset(size.width * 0.05, size.height * 0.85);
    final p1 = Offset(size.width * 0.25, size.height * 0.6);
    final p2 = Offset(size.width * 0.6, size.height * 0.45);
    final p3 = Offset(size.width * 0.95, size.height * 0.15);
    final mt = 1 - t;
    return Offset(
      mt * mt * mt * p0.dx +
          3 * mt * mt * t * p1.dx +
          3 * mt * t * t * p2.dx +
          t * t * t * p3.dx,
      mt * mt * mt * p0.dy +
          3 * mt * mt * t * p1.dy +
          3 * mt * t * t * p2.dy +
          t * t * t * p3.dy,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Utility
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Smart Context
// ─────────────────────────────────────────────────────────────────────────────

// Simple label chip — color comes from the parent card's accent
class _SmartChip {
  const _SmartChip(this.label);
  final String label;
}

// Card data — all cards share the same dark navy base; accent tints the glow,
// icon, eyebrow and chips to keep the design "yek bütün" with the hero card.
class _SmartCard {
  const _SmartCard({
    required this.accentColor,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.chips,
    required this.onTap,
  });
  final Color accentColor;
  final IconData icon;
  final String eyebrow;
  final String title;
  final List<_SmartChip> chips;
  final VoidCallback onTap;
}

class _SmartSuggestionCard extends StatelessWidget {
  const _SmartSuggestionCard({required this.card});
  final _SmartCard card;

  // Exact same base palette as the hero card
  static const _bg = [
    Color(0xFF010915),
    Color(0xFF071628),
    Color(0xFF0A2545),
    Color(0xFF0E3260),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = card.accentColor;
    return GestureDetector(
      onTap: card.onTap,
      child: Container(
        width: 226,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withValues(alpha: 0.28), width: 1),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.20),
              blurRadius: 22,
              spreadRadius: -3,
              offset: const Offset(0, 9),
            ),
            BoxShadow(
              color: const Color(0xFF0B1F3A).withValues(alpha: 0.50),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // ── Hero-card base gradient ──────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: _bg,
                    stops: [0.0, 0.35, 0.70, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // ── Accent glow — top right (mirrors hero card's teal glow) ─
              Positioned(
                top: -28,
                right: -18,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.38),
                        accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // ── Subtle secondary glow — bottom left ──────────────────────
              Positioned(
                bottom: -16,
                left: -10,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.14),
                        accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // ── Content ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + eyebrow
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.38),
                              width: 1,
                            ),
                          ),
                          child: Icon(card.icon, size: 16, color: accent),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            card.eyebrow,
                            style: TextStyle(
                              color: accent.withValues(alpha: 0.88),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Title
                    Text(
                      card.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Chips — accent-tinted pills
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: card.chips
                          .map(
                            (c) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.30),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                c.label,
                                style: TextStyle(
                                  color: accent.withValues(alpha: 0.92),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Utility
// ─────────────────────────────────────────────────────────────────────────────

String _cleanPlaceName(String raw) {
  final lower = raw.toLowerCase();
  if (lower.contains('core spot')) {
    return raw
        .replaceAll(
          RegExp(r'\bcore\s*spot\b', caseSensitive: false),
          'Öne Çıkan Nokta',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
  return raw;
}
