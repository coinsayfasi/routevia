import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/error_utils.dart';
import '../../core/constants.dart';
import '../../core/i18n.dart';
import '../../core/widgets/trip_com_card.dart';
import '../../data/journey_recorder.dart';
import '../../data/providers.dart';
import '../../models/trip_models.dart';
import '../../models/journey_progress.dart';
import '../../models/journey_track.dart';
import 'journey_log_screen.dart';

// ─── Kategori Türkçe etiket haritası ────────────────────────────────────────
String _categoryTr(String cat) =>
    const {
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
    }[cat] ??
    cat;

class DayPlanScreen extends ConsumerStatefulWidget {
  const DayPlanScreen({super.key, required this.plan});

  final TripPlan plan;

  @override
  ConsumerState<DayPlanScreen> createState() => _DayPlanScreenState();
}

class _DayPlanScreenState extends ConsumerState<DayPlanScreen> {
  int _selectedDay = 1;
  bool _sharing = false;
  bool _optimizing = false;
  late TripPlan _plan;
  JourneyProgress _journey = JourneyProgress();
  bool _progressReady = false;
  bool _progressSaving = false;
  final Map<String, bool> _checkingStops = {};
  bool _celebrationShown = false;

  // Gezi günlüğü kaydı ortak servistedir; günlük haritası da canlı dinler.
  late final JourneyRecorder _recorder;

  // Konfeti animasyonu (dialog içinde kendi controller'ı var, bu sınıfta gerek yok)

  @override
  void initState() {
    super.initState();
    _plan = widget.plan;
    _recorder = ref.read(journeyRecorderProvider);
    if (_plan.daysPlan.isNotEmpty) {
      _selectedDay = _plan.daysPlan.first.dayNumber;
    }
    unawaited(_loadProgress());
    unawaited(_recorder.load(_plan.tripId, _selectedDay));
    // Aktif gezi olarak kaydet
    unawaited(ref.read(localCacheProvider).setActivePlan(_plan.toMap()));
  }

  @override
  void dispose() {
    // Gün planından çıkınca bu gezinin kaydı durur (arka planda sessizce sürmez).
    if (_recorder.recording && _recorder.tripId == _plan.tripId) {
      unawaited(_recorder.stop());
    }
    super.dispose();
  }

  Future<void> _toggleRecording(int day, bool on) async {
    if (!on) {
      await _recorder.stop();
      return;
    }
    final result = await _recorder.start(_plan.tripId, day);
    if (!mounted) return;
    final message = switch (result) {
      RecorderStartResult.serviceDisabled => context.tr(
        'Rota kaydı için cihazın konum servisini aç.',
        'Turn on location services to record your route.',
      ),
      RecorderStartResult.permissionDenied => context.tr(
        'Konum izni olmadan rota kaydedilemez. Günlük, gezdiğin durakları yine gösterir.',
        'Your route cannot be recorded without location permission. The log still shows your visited stops.',
      ),
      RecorderStartResult.started => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    unawaited(
      ref
          .read(repositoryProvider)
          .logAppEvent('journey_track_started', payload: {'day': day})
          .catchError((_) {}),
    );
  }

  void _openJourneyLog(TripDay day) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            JourneyLogScreen(plan: _plan, day: day, progress: _journey),
      ),
    );
  }

  // Tüm planın tamamlanıp tamamlanmadığını kontrol eder
  bool get _allDaysCompleted {
    if (_plan.daysPlan.isEmpty) return false;
    return _plan.daysPlan.every(
      (day) =>
          day.stops.isNotEmpty &&
          day.stops.every((s) => _journey.resolved(day.dayNumber, s.place.id)),
    );
  }

  String _districtScopeLabel(bool? strict) {
    if (strict == null) {
      return 'İlçe kilidi: otomatik';
    }
    return strict ? 'İlçe kilidi: açık' : 'İlçe kilidi: esnek';
  }

  String _slotLabel(TripStop stop, int index) {
    final t = stop.arrivalTime;
    final hh = int.tryParse(t.split(':').first) ?? 12;
    final cat = stop.place.category;
    final tags = stop.place.tags.map((e) => e.toLowerCase()).toSet();

    if (tags.contains('sunset') || stop.place.bestTime == 'sunset') {
      return 'Gün Batımı';
    }
    if ((cat == 'food' || cat == 'cafe') && hh <= 15) {
      return 'Öğle';
    }
    if ((cat == 'food' || cat == 'cafe') && hh >= 18) {
      return 'Akşam Yemeği';
    }
    if (hh < 12) {
      return 'Sabah';
    }
    if (hh < 17) {
      return 'Öğleden Sonra';
    }
    if (index == 0) {
      return 'Başlangıç';
    }
    return 'Akşam';
  }

  Future<void> _sharePlan() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    final highlights = _plan.daysPlan
        .expand((d) => d.stops)
        .take(3)
        .map((s) => s.place.name)
        .join(', ');
    try {
      final repo = ref.read(repositoryProvider);
      final token = await repo.createShareToken(_plan.tripId);
      final text =
          '${_plan.province.name} • ${_plan.days} Günlük WOW Plan\n'
          'Öne çıkanlar: $highlights\n'
          'Aç: routevia://share/$token\n'
          'Paylaşım kodu: $token\n'
          'Uygulamayı indir: ${Platform.isIOS ? AppConstants.appStoreUrl : AppConstants.playStoreUrl}';
      await SharePlus.instance.share(ShareParams(text: text));
      await repo.logAppEvent(
        'plan_shared',
        payload: {'trip_id': _plan.tripId, 'token': token},
      );
    } catch (e) {
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          text:
              '${_plan.province.name} • ${_plan.days} Günlük WOW Plan\n'
              'Öne çıkanlar: $highlights\n'
              'Uygulamayı indir: ${Platform.isIOS ? AppConstants.appStoreUrl : AppConstants.playStoreUrl}',
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Paylaşım bağlantısı üretilemedi. Genel paylaşım açıldı.',
              'Could not create a share link. Opened general sharing instead.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _openNavigation(TripStop stop) async {
    final lat = stop.place.lat;
    final lng = stop.place.lng;
    if (lat == null || lng == null) return;
    final name = Uri.encodeComponent(stop.place.name);
    final url = Platform.isIOS
        ? 'https://maps.apple.com/?daddr=$lat,$lng&q=$name'
        : 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (opened) {
      unawaited(
        ref
            .read(repositoryProvider)
            .logAppEvent(
              'trip_navigation_started',
              payload: {'trip_id': _plan.tripId, 'day': _selectedDay},
            )
            .catchError((_) {}),
      );
    }
  }

  Future<void> _optimizeToday() async {
    if (_optimizing) return;
    final selected = _plan.daysPlan.firstWhere(
      (d) => d.dayNumber == _selectedDay,
    );
    if (!_progressReady || _journey.startedDays.contains(selected.dayNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Başladığın günün sırası korunuyor. Optimizasyonu geziye başlamadan kullan.',
              'The order of a day you have started is kept. Optimize before starting the trip.',
            ),
          ),
        ),
      );
      return;
    }
    setState(() => _optimizing = true);
    try {
      final out = await ref
          .read(repositoryProvider)
          .optimizeTripPlanV2(plan: _plan, dayNumber: _selectedDay);
      final optimized = out['plan'] as TripPlan? ?? _plan;
      final saved = out['saved_minutes'] as int? ?? 0;
      final estimated = out['estimated'] == true;
      if (!mounted) return;
      await ref
          .read(localCacheProvider)
          .saveJourneyProgress(optimized.tripId, _journey);
      if (!mounted) return;
      setState(() => _plan = optimized);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved > 0
                ? context.tr(
                    '${estimated ? 'Tahmini yol süresiyle' : 'Yol sürelerine göre'} $saved dakika daha kısa rota.',
                    '${estimated ? 'Using estimated travel times' : 'Using road travel times'}: a route $saved min shorter.',
                  )
                : context.tr(
                    'Bu gün için daha kısa bir sıra bulunamadı. Süreler ${estimated ? 'tahmini' : 'yol verisine dayalı'}.',
                    'No shorter order found for this day. Times are ${estimated ? 'estimated' : 'based on road data'}.',
                  ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    } finally {
      if (mounted) setState(() => _optimizing = false);
    }
  }

  Future<void> _loadProgress() async {
    try {
      final progress = await ref
          .read(localCacheProvider)
          .readJourneyProgress(_plan.tripId);
      if (mounted) {
        setState(() {
          _journey = progress;
          _progressReady = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _progressReady = true);
    }
  }

  Future<void> _saveProgress(JourneyProgress next) async {
    if (!_progressReady || _progressSaving || _optimizing) return;
    setState(() => _progressSaving = true);
    try {
      await ref
          .read(localCacheProvider)
          .saveJourneyProgress(_plan.tripId, next);
      if (!mounted) return;
      setState(() => _journey = next);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                'Gezi ilerlemesi kaydedilemedi. Tekrar dene.',
                'Could not save trip progress. Try again.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _progressSaving = false);
    }
  }

  Future<void> _toggleCheckin(String placeId) async {
    final status = _journey.status(_selectedDay, placeId);
    await _saveProgress(
      _journey.mark(
        _selectedDay,
        placeId,
        status == 'visited' ? null : 'visited',
      ),
    );
    if (mounted &&
        _allDaysCompleted &&
        !_celebrationShown &&
        _journey.stops.values.any((v) => v == 'visited')) {
      setState(() => _celebrationShown = true);
      await _showCelebration();
    }
  }

  String _daySummary(TripDay day) {
    final travel = day.travelMinutes ?? 0;
    final total =
        travel + day.stops.fold<int>(0, (sum, stop) => sum + stop.durationMin);
    final budget = day.budgetMinutes;
    return context.tr(
      '${day.stops.length} durak • $total dk toplam • $travel dk yol'
          '${day.durationEstimated ? ' (tahmini)' : ''}'
          '${budget != null ? ' • $budget dk içinde' : ''}',
      '${day.stops.length} stops • $total min total • $travel min travel'
          '${day.durationEstimated ? ' (estimated)' : ''}'
          '${budget != null ? ' • within $budget min' : ''}',
    );
  }

  String _clock(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  Future<void> _navigateReturn(TripDay day) async {
    final back = day.returnPlan;
    if (back == null) return;
    final url = Platform.isIOS
        ? 'https://maps.apple.com/?daddr=${back.lat},${back.lng}&dirflg=${_plan.transportMode == 'car' ? 'd' : 'w'}'
        : 'https://www.google.com/maps/dir/?api=1&destination=${back.lat},${back.lng}&travelmode=${_plan.transportMode == 'car' ? 'driving' : 'walking'}';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Widget _journeyCard(TripDay day) {
    final next = _journey.nextStop(day);
    final started = _journey.startedDays.contains(day.dayNumber);
    final back = day.returnPlan;
    final recorder = ref.watch(journeyRecorderProvider);
    final track = recorder.isFor(_plan.tripId, day.dayNumber)
        ? recorder.track
        : JourneyTrack();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              started
                  ? (next == null
                        ? context.tr(
                            'Günün durakları tamamlandı',
                            "Today's stops are done",
                          )
                        : context.tr('Sıradaki durak', 'Next stop'))
                  : context.tr(
                      'Kendi hızında keşfet',
                      'Explore at your own pace',
                    ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              started && next != null
                  ? next.place.name
                  : started
                  ? context.tr(
                      'Gezdiklerin ve atladıkların bu cihazda saklandı.',
                      'Visited and skipped stops are saved on this device.',
                    )
                  : context.tr(
                      'Geziyi başlat; gezdiğin yerleri işaretleyerek sıradaki durağa geç.',
                      'Start the trip and mark places as visited to move to the next stop.',
                    ),
            ),
            if (!_progressReady) const LinearProgressIndicator(),
            if (!started)
              FilledButton.icon(
                onPressed: !_progressReady || _progressSaving || _optimizing
                    ? null
                    : () => _saveProgress(_journey.start(day.dayNumber)),
                icon: const Icon(Icons.play_arrow),
                label: Text(context.tr('Geziye başla', 'Start trip')),
              ),
            if (started && next != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilledButton.icon(
                    onPressed: () => _openNavigation(next),
                    icon: const Icon(Icons.navigation),
                    label: Text(context.tr('Yol tarifi', 'Directions')),
                  ),
                  OutlinedButton.icon(
                    onPressed: _progressSaving
                        ? null
                        : () => _toggleCheckin(next.place.id),
                    icon: const Icon(Icons.check),
                    label: Text(context.tr('Gezdim', 'Visited')),
                  ),
                  TextButton(
                    onPressed: _progressSaving
                        ? null
                        : () => _saveProgress(
                            _journey.mark(
                              day.dayNumber,
                              next.place.id,
                              'skipped',
                            ),
                          ),
                    child: Text(context.tr('Bu durağı atla', 'Skip this stop')),
                  ),
                ],
              ),
            ],
            if (started) ...[
              const Divider(height: 24),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: recorder.isRecordingFor(_plan.tripId, day.dayNumber),
                onChanged: (on) => _toggleRecording(day.dayNumber, on),
                title: Text(context.tr('Rotamı kaydet', 'Record my route')),
                subtitle: Text(
                  track.hasTrack
                      ? context.tr(
                          '${track.distanceKm.toStringAsFixed(1)} km kaydedildi · yalnızca uygulama açıkken',
                          '${track.distanceKm.toStringAsFixed(1)} km recorded · only while the app is open',
                        )
                      : context.tr(
                          'GPS izi yalnızca bu cihazda saklanır; uygulama açıkken kaydedilir.',
                          'Your GPS track stays on this device and is recorded while the app is open.',
                        ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _openJourneyLog(day),
                icon: const Icon(Icons.auto_stories_outlined),
                label: Text(context.tr('Gezi günlüğü', 'Trip log')),
              ),
            ],
            if (back != null) ...[
              const Divider(height: 24),
              Text(
                context.tr(
                  'Dönüş: ${back.label} • ${_clock(back.deadline)}',
                  'Return: ${back.label} • ${_clock(back.deadline)}',
                ),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                context.tr(
                  '${back.arrival == null ? '' : 'Planlanan varış ${_clock(back.arrival!)} • '}${back.bufferMinutes} dk zaman payı',
                  '${back.arrival == null ? '' : 'Planned arrival ${_clock(back.arrival!)} • '}${back.bufferMinutes} min buffer',
                ),
              ),
              Text(
                context.tr(
                  'Plan ${back.deadline.day}.${back.deadline.month}.${back.deadline.year} için hazırlandı; canlı varış takibi değildir.',
                  'Planned for ${back.deadline.day}.${back.deadline.month}.${back.deadline.year}; this is not live arrival tracking.',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextButton.icon(
                onPressed: () => _navigateReturn(day),
                icon: const Icon(Icons.keyboard_return),
                label: Text(context.tr('Dönüş yolunu aç', 'Open return route')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showCelebration() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CelebrationDialog(
        provinceName: _plan.province.name,
        totalStops: _plan.daysPlan.fold<int>(0, (s, d) => s + d.stops.length),
        onShare: () {
          Navigator.of(ctx).pop();
          _sharePlan();
        },
        onDone: () async {
          Navigator.of(ctx).pop();
          await ref.read(localCacheProvider).clearActivePlan();
          if (mounted) {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          }
        },
      ),
    );
  }

  Future<void> _finishTrip() async {
    await ref.read(localCacheProvider).clearActivePlan();
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // GUARD: Plan boşsa güvenli boş ekran göster
    if (_plan.daysPlan.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Günlük Plan')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_busy, size: 56, color: Color(0xFFCBD5E1)),
              SizedBox(height: 16),
              Text(
                'Bu plan için henüz durak oluşturulmadı.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    final day = _plan.daysPlan.firstWhere(
      (d) => d.dayNumber == _selectedDay,
      orElse: () => _plan.daysPlan.first,
    );

    // Bugünkü tamamlanma yüzdesi
    final dayStopCount = day.stops.length;
    final dayCheckedCount = dayStopCount > 0
        ? day.stops
              .where((s) => _journey.resolved(day.dayNumber, s.place.id))
              .length
        : 0;
    final dayProgress = dayStopCount > 0 ? dayCheckedCount / dayStopCount : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Günlük Plan',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: _optimizing ? null : _optimizeToday,
            icon: _optimizing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_fix_high),
            tooltip: 'Bugünü optimize et',
          ),
          IconButton(
            onPressed: _sharing ? null : _sharePlan,
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.push('/map', extra: _plan);
              }
            },
            icon: const Icon(Icons.map_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          if (day.travelMinutes != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                _daySummary(day),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          // ── Başlık kartı ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B1F3A), Color(0xFF0E385E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_plan.province.name} • Gün ${day.dayNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // Tamamlanma rozeti
                    if (dayStopCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: dayProgress >= 1.0
                              ? const Color(0xFF166534)
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$dayCheckedCount/$dayStopCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${day.stops.length} durak • ${_plan.transportMode} • ${_plan.pace}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                // İlerleme çubuğu
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: dayProgress,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      dayProgress >= 1.0
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFF38BDF8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(
                    _plan.radiusUsedKm == null
                        ? 'Plan menzili: otomatik'
                        : 'Plan menzili: ${_plan.radiusUsedKm} km',
                  ),
                ),
                Chip(label: Text(_districtScopeLabel(_plan.districtStrict))),
              ],
            ),
          ),
          // ── Gün seçici + "Gezini Bitir" ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _plan.daysPlan
                          .map(
                            (d) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text('Gün ${d.dayNumber}'),
                                selected: _selectedDay == d.dayNumber,
                                onSelected: (_) {
                                  setState(() => _selectedDay = d.dayNumber);
                                  unawaited(
                                    _recorder.load(_plan.tripId, d.dayNumber),
                                  );
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: _finishTrip,
                    icon: const Icon(Icons.done_all, size: 16),
                    label: const Text('Bitir'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      side: const BorderSide(color: Color(0xFF64748B)),
                      foregroundColor: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // ── Durak listesi ─────────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
              itemCount: day.stops.length + 2,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, itemIndex) {
                if (itemIndex == 0) return _journeyCard(day);
                final index = itemIndex - 1;
                if (index == day.stops.length) {
                  return TripComCard(provinceName: _plan.province.name);
                }
                final stop = day.stops[index];
                final slot = _slotLabel(stop, index);
                final isChecked =
                    _journey.status(day.dayNumber, stop.place.id) == 'visited';
                final isSkipped =
                    _journey.status(day.dayNumber, stop.place.id) == 'skipped';
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.push('/place', extra: stop.place),
                  child: Ink(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isChecked ? const Color(0xFFF0FDF4) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isChecked
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isChecked
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              isChecked
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      size: 20,
                                      color: Color(0xFF166534),
                                    )
                                  : Text(
                                      '${stop.orderIndex}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                              const SizedBox(height: 2),
                              Text(
                                isChecked ? '✓' : 'durak',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isChecked
                                      ? const Color(0xFF166534)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      stop.place.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    stop.arrivalTime.substring(0, 5),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  Chip(label: Text(slot)),
                                  Chip(
                                    label: Text(
                                      _categoryTr(stop.place.category),
                                    ),
                                  ),
                                  Chip(label: Text('${stop.durationMin} dk')),
                                ],
                              ),
                              if (isSkipped)
                                TextButton.icon(
                                  onPressed: _progressSaving
                                      ? null
                                      : () => _saveProgress(
                                          _journey.mark(
                                            day.dayNumber,
                                            stop.place.id,
                                            null,
                                          ),
                                        ),
                                  icon: const Icon(Icons.undo),
                                  label: Text(
                                    context.tr(
                                      'Atlandı · Geri al',
                                      'Skipped · Undo',
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 32,
                                      child: OutlinedButton.icon(
                                        onPressed: () => _openNavigation(stop),
                                        icon: const Icon(
                                          Icons.navigation_rounded,
                                          size: 15,
                                        ),
                                        label: const Text('Buraya Git'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFF0B3B68),
                                          ),
                                          foregroundColor: const Color(
                                            0xFF0B3B68,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: SizedBox(
                                      height: 32,
                                      child: Builder(
                                        builder: (context) {
                                          final isChecking =
                                              _checkingStops[stop.place.id] ==
                                              true;
                                          return OutlinedButton.icon(
                                            onPressed:
                                                isChecking ||
                                                    !_progressReady ||
                                                    _progressSaving
                                                ? null
                                                : () => _toggleCheckin(
                                                    stop.place.id,
                                                  ),
                                            icon: isChecking
                                                ? const SizedBox(
                                                    width: 13,
                                                    height: 13,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : Icon(
                                                    isChecked
                                                        ? Icons
                                                              .check_circle_rounded
                                                        : Icons.flag_outlined,
                                                    size: 15,
                                                  ),
                                            label: Text(
                                              isChecked
                                                  ? 'Gidildi ✓'
                                                  : 'Gezdim',
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              textStyle: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              side: BorderSide(
                                                color: isChecked
                                                    ? const Color(0xFF166534)
                                                    : const Color(0xFF374151),
                                              ),
                                              foregroundColor: isChecked
                                                  ? const Color(0xFF166534)
                                                  : const Color(0xFF374151),
                                              backgroundColor: isChecked
                                                  ? const Color(0xFFDCFCE7)
                                                  : null,
                                            ),
                                          );
                                        },
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

// ─── Kutlama Dialogu ─────────────────────────────────────────────────────────

class _CelebrationDialog extends StatefulWidget {
  const _CelebrationDialog({
    required this.provinceName,
    required this.totalStops,
    required this.onShare,
    required this.onDone,
  });

  final String provinceName;
  final int totalStops;
  final VoidCallback onShare;
  final VoidCallback onDone;

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  final _rng = math.Random();
  late List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(40, (_) => _ConfettiParticle(rng: _rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Konfeti alanı
              SizedBox(
                height: 120,
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, _) => CustomPaint(
                    painter: _ConfettiPainter(
                      particles: _particles,
                      progress: _ctrl.value,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              const Text('🎉', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              const Text(
                'Gezi Tamamlandı!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B1F3A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.provinceName} gezinde ${widget.totalStops} durağı'
                ' tamamladın. Harika bir gezi olmuştur! 🏆',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF475569), height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onShare,
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Paylaş'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: widget.onDone,
                      icon: const Icon(Icons.home_rounded, size: 16),
                      label: const Text('Ana Sayfa'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0B3B68),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Konfeti Parçacığı ────────────────────────────────────────────────────────

class _ConfettiParticle {
  _ConfettiParticle({required math.Random rng})
    : x = rng.nextDouble(),
      startY = -0.1 - rng.nextDouble() * 0.3,
      speed = 0.4 + rng.nextDouble() * 0.6,
      size = 5.0 + rng.nextDouble() * 7,
      color = _kConfettiColors[rng.nextInt(_kConfettiColors.length)],
      rotationSpeed = (rng.nextDouble() - 0.5) * 8;

  final double x;
  final double startY;
  final double speed;
  final double size;
  final Color color;
  final double rotationSpeed;
}

const _kConfettiColors = [
  Color(0xFFFF6B6B),
  Color(0xFFFFD93D),
  Color(0xFF6BCB77),
  Color(0xFF4D96FF),
  Color(0xFFFF922B),
  Color(0xFFCC5DE8),
  Color(0xFF20C997),
];

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.particles, required this.progress});

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = p.startY + progress * p.speed;
      if (y < 0 || y > 1.1) continue;
      final px = p.x * size.width;
      final py = y * size.height;
      final rotation = progress * p.rotationSpeed;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rotation);
      final paint = Paint()
        ..color = p.color.withValues(alpha: (1 - progress * 0.6).clamp(0, 1));
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
