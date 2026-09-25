import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/journey_track.dart';
import 'local_cache.dart';
import 'providers.dart';

enum RecorderStartResult { started, serviceDisabled, permissionDenied }

/// Konum izni/servis kontrolü ve konum akışı; testte sahtesi verilir.
class LocationSource {
  const LocationSource();

  Future<bool> serviceEnabled() => Geolocator.isLocationServiceEnabled();

  Future<bool> ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Ön plan akışı: arka plan konumu istenmez.
  Stream<Position> positions() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    ),
  );
}

/// Gezi günlüğü kaydı için tek kaynak: gün planı başlatır/durdurur, günlük haritası canlı dinler.
/// İz yalnız cihazda saklanır; hiçbir konum sunucuya gönderilmez.
class JourneyRecorder extends ChangeNotifier {
  JourneyRecorder(this._cache, {LocationSource source = const LocationSource()})
    : _source = source;

  final LocalCache _cache;
  final LocationSource _source;

  String? _tripId;
  int? _day;
  JourneyTrack _track = JourneyTrack();
  Position? _lastFix;
  StreamSubscription<Position>? _sub;
  int _unsaved = 0;
  bool _disposed = false;

  String? get tripId => _tripId;
  int? get day => _day;
  JourneyTrack get track => _track;

  /// Filtreden geçmese de son konum: "buradasın" noktası için.
  Position? get lastFix => _lastFix;
  bool get recording => _sub != null;

  bool isFor(String tripId, int day) => _tripId == tripId && _day == day;
  bool isRecordingFor(String tripId, int day) =>
      recording && isFor(tripId, day);

  /// Seçili günün kayıtlı izini yükler; başka bir gün kaydediliyorsa ona dokunmaz.
  Future<void> load(String tripId, int day) async {
    if (recording || isFor(tripId, day)) return;
    final t = await _cache.readJourneyTrack(tripId, day);
    if (recording || _disposed) return;
    _tripId = tripId;
    _day = day;
    _track = t;
    _lastFix = null;
    _notify();
  }

  Future<RecorderStartResult> start(String tripId, int day) async {
    if (isRecordingFor(tripId, day)) return RecorderStartResult.started;
    if (!await _source.serviceEnabled()) {
      return RecorderStartResult.serviceDisabled;
    }
    if (!await _source.ensurePermission()) {
      return RecorderStartResult.permissionDenied;
    }
    // Aynı anda tek gün kaydedilir.
    if (recording) await stop();
    if (!isFor(tripId, day)) {
      _track = await _cache.readJourneyTrack(tripId, day);
      _tripId = tripId;
      _day = day;
    }
    _track = _track.withRecording(true);
    _lastFix = null;
    _sub = _source.positions().listen(_onPosition, onError: (_) => stop());
    _notify();
    await _persist();
    return RecorderStartResult.started;
  }

  void _onPosition(Position pos) {
    _lastFix = pos;
    final next = _track.append(
      TrackPoint(pos.latitude, pos.longitude, pos.timestamp),
      accuracyMeters: pos.accuracy,
    );
    if (!identical(next, _track)) {
      _track = next;
      if (++_unsaved >= 5) unawaited(_persist());
    }
    _notify();
  }

  Future<void> stop() async {
    final sub = _sub;
    _sub = null;
    await sub?.cancel();
    _track = _track.withRecording(false);
    _notify();
    await _persist();
  }

  /// İz silinince bellekteki kopya da temizlenir.
  Future<void> clear(String tripId, int day) async {
    if (isRecordingFor(tripId, day)) await stop();
    await _cache.deleteJourneyTrack(tripId, day);
    if (isFor(tripId, day)) {
      _track = JourneyTrack();
      _lastFix = null;
      _notify();
    }
  }

  Future<void> _persist() async {
    final trip = _tripId;
    final day = _day;
    if (trip == null || day == null) return;
    _unsaved = 0;
    try {
      await _cache.saveJourneyTrack(trip, day, _track);
    } catch (_) {}
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    final sub = _sub;
    _sub = null;
    unawaited(sub?.cancel());
    super.dispose();
  }
}

final journeyRecorderProvider = ChangeNotifierProvider<JourneyRecorder>(
  (ref) => JourneyRecorder(ref.watch(localCacheProvider)),
);
