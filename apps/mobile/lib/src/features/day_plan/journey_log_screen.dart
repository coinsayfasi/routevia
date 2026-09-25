import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n.dart';
import '../../core/theme.dart';
import '../../data/journey_recorder.dart';
import '../../models/community_post_models.dart';
import '../../models/journey_progress.dart';
import '../../models/journey_track.dart';
import '../../models/trip_models.dart';

/// Günün gezi günlüğü. Kayıt açıksa iz, konum noktası ve istatistikler canlı güncellenir.
/// İz yoksa gezilen durakları bağlayan çizgi açıkça "gerçek iz değil" diye etiketlenir.
class JourneyLogScreen extends ConsumerStatefulWidget {
  const JourneyLogScreen({
    super.key,
    required this.plan,
    required this.day,
    required this.progress,
  });

  final TripPlan plan;
  final TripDay day;
  final JourneyProgress progress;

  @override
  ConsumerState<JourneyLogScreen> createState() => _JourneyLogScreenState();
}

class _JourneyLogScreenState extends ConsumerState<JourneyLogScreen> {
  final _map = MapController();
  bool _mapReady = false;
  bool _follow = true;
  Timer? _ticker;

  String get _trip => widget.plan.tripId;
  int get _dayNo => widget.day.dayNumber;

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(journeyRecorderProvider).load(_trip, _dayNo));
    // Kayıt sürerken süre, konum gelmese de güncel kalsın.
    _ticker = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted && ref.read(journeyRecorderProvider).recording) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  List<TripStop> get _visited => widget.day.stops
      .where(
        (s) =>
            widget.progress.status(_dayNo, s.place.id) == 'visited' &&
            s.place.lat != null &&
            s.place.lng != null,
      )
      .toList();

  int get _skipped => widget.day.stops
      .where((s) => widget.progress.status(_dayNo, s.place.id) == 'skipped')
      .length;

  String _duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return h > 0
        ? context.tr('$h sa $m dk', '${h}h ${m}m')
        : context.tr('$m dk', '$m min');
  }

  void _followTo(LatLng point) {
    if (!_follow || !_mapReady) return;
    try {
      final zoom = _map.camera.zoom < 15 ? 16.0 : _map.camera.zoom;
      _map.move(point, zoom);
    } catch (_) {}
  }

  Future<void> _toggleRecording(bool on) async {
    final recorder = ref.read(journeyRecorderProvider);
    if (!on) {
      await recorder.stop();
      return;
    }
    final result = await recorder.start(_trip, _dayNo);
    if (!mounted || result == RecorderStartResult.started) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == RecorderStartResult.serviceDisabled
              ? context.tr(
                  'Rota kaydı için cihazın konum servisini aç.',
                  'Turn on location services to record your route.',
                )
              : context.tr(
                  'Konum izni olmadan rota kaydedilemez.',
                  'Your route cannot be recorded without location permission.',
                ),
        ),
      ),
    );
  }

  Future<void> _share(JourneyTrack track) async {
    final visited = _visited;
    final names = visited.map((s) => s.place.name).take(6).join(' → ');
    final stats = track.hasTrack
        ? '${track.distanceKm.toStringAsFixed(1)} km, ${_duration(track.duration)}'
        : context.tr('${visited.length} durak', '${visited.length} stops');
    final draft = CommunityPostDraft(
      title: context.tr(
        '${widget.plan.province.name} gezi günlüğüm',
        'My ${widget.plan.province.name} trip log',
      ),
      summary: context.tr(
        'Bu rotayı gezdim: $stats.',
        'I explored this route: $stats.',
      ),
      body: names.isEmpty
          ? ''
          : context.tr('Durak sırası: $names', 'Stop order: $names'),
      city: widget.plan.province.name,
      relatedRouteId: _trip,
    );
    await context.push('/community-post-editor', extra: draft);
  }

  Future<void> _deleteTrack() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('İz silinsin mi?', 'Delete the track?')),
        content: Text(
          context.tr(
            'Bu güne ait kayıtlı GPS izi cihazdan kalıcı olarak silinecek.',
            "This day's recorded GPS track will be permanently deleted from the device.",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('Vazgeç', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.tr('Sil', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(journeyRecorderProvider).clear(_trip, _dayNo);
    }
  }

  Widget _liveBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: RouteviaColors.rose,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      context.tr('● CANLI', '● LIVE'),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final recorder = ref.watch(journeyRecorderProvider);
    final track = recorder.isFor(_trip, _dayNo)
        ? recorder.track
        : JourneyTrack();
    final live = recorder.isRecordingFor(_trip, _dayNo);
    final fix = live ? recorder.lastFix : null;
    final here = fix == null ? null : LatLng(fix.latitude, fix.longitude);

    ref.listen<JourneyRecorder>(journeyRecorderProvider, (_, next) {
      final f = next.lastFix;
      if (next.isRecordingFor(_trip, _dayNo) && f != null) {
        _followTo(LatLng(f.latitude, f.longitude));
      }
    });

    final visited = _visited;
    final hasTrack = track.hasTrack;
    final next = widget.progress.nextStop(widget.day);
    final nextPoint = live && next?.place.lat != null && next?.place.lng != null
        ? LatLng(next!.place.lat!, next.place.lng!)
        : null;
    final line = hasTrack
        ? track.points.map((p) => LatLng(p.lat, p.lng)).toList()
        : visited.map((s) => LatLng(s.place.lat!, s.place.lng!)).toList();
    final all = <LatLng>[
      ...line,
      ...visited.map((s) => LatLng(s.place.lat!, s.place.lng!)),
      ?nextPoint,
      ?here,
    ];

    final markers = <Marker>[
      for (var i = 0; i < visited.length; i++)
        Marker(
          point: LatLng(visited[i].place.lat!, visited[i].place.lng!),
          width: 30,
          height: 30,
          child: CircleAvatar(
            backgroundColor: RouteviaColors.amber,
            child: Text(
              '${i + 1}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      if (nextPoint != null)
        Marker(
          point: nextPoint,
          width: 36,
          height: 36,
          child: const Icon(
            Icons.flag_circle,
            size: 36,
            color: RouteviaColors.rose,
          ),
        ),
      if (here != null)
        Marker(
          point: here,
          width: 22,
          height: 22,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x551E88E5),
                  blurRadius: 10,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
        ),
    ];

    Widget map() => Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCameraFit: all.length < 2
                ? null
                : CameraFit.coordinates(
                    coordinates: all,
                    padding: const EdgeInsets.all(40),
                    maxZoom: 17,
                  ),
            initialCenter: all.last,
            initialZoom: 16,
            onMapReady: () => _mapReady = true,
            // Kullanıcı haritayı elle kaydırırsa takibi bırak.
            onPositionChanged: (_, hasGesture) {
              if (hasGesture && _follow) setState(() => _follow = false);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.yunusgunes.routevia',
            ),
            if (line.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: line,
                    strokeWidth: hasTrack ? 5 : 3,
                    color: hasTrack
                        ? RouteviaColors.teal
                        : RouteviaColors.textSecondary,
                    pattern: hasTrack
                        ? const StrokePattern.solid()
                        : StrokePattern.dashed(segments: const [10, 8]),
                  ),
                ],
              ),
            MarkerLayer(markers: markers),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(
                    Uri.parse('https://www.openstreetmap.org/copyright'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (live) Positioned(left: 10, top: 10, child: _liveBadge()),
        if (live && here != null && !_follow)
          Positioned(
            right: 10,
            bottom: 40,
            child: FloatingActionButton.small(
              heroTag: 'journey-follow',
              tooltip: context.tr('Beni takip et', 'Follow me'),
              onPressed: () {
                setState(() => _follow = true);
                _followTo(here);
              },
              child: const Icon(Icons.my_location),
            ),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('$_dayNo. gün günlüğü', 'Day $_dayNo log')),
        actions: [
          if (hasTrack)
            IconButton(
              tooltip: context.tr('İzi sil', 'Delete track'),
              onPressed: _deleteTrack,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 340,
              child: all.isEmpty
                  ? ColoredBox(
                      color: RouteviaColors.surfaceVariant,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            context.tr(
                              'Henüz gezilen durak veya kayıtlı iz yok. "Rotamı kaydet"i açarak başlayabilirsin.',
                              'No visited stops or recorded track yet. Turn on "Record my route" to start.',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  : map(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                hasTrack ? Icons.gps_fixed : Icons.timeline,
                size: 18,
                color: RouteviaColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hasTrack
                      ? (live
                            ? context.tr(
                                'Gerçek GPS izin canlı çiziliyor · kırmızı bayrak sıradaki durak',
                                'Your real GPS track is drawn live · red flag is the next stop',
                              )
                            : context.tr(
                                'Kaydettiğin gerçek GPS izi',
                                'Your recorded GPS track',
                              ))
                      : context.tr(
                          'Gezdiğin durakları bağlayan çizgi — gerçek yürüme/sürüş izi değildir',
                          'Line connecting your visited stops — not an actual walking/driving track',
                        ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: live,
            onChanged: _toggleRecording,
            title: Text(context.tr('Rotamı kaydet', 'Record my route')),
            subtitle: Text(
              context.tr(
                'Yalnızca uygulama açıkken kaydedilir; iz bu cihazda kalır.',
                'Recorded only while the app is open; the track stays on this device.',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Stat(
                label: context.tr('Gezilen', 'Visited'),
                value: '${visited.length}/${widget.day.stops.length}',
              ),
              _Stat(
                label: context.tr('Atlanan', 'Skipped'),
                value: '$_skipped',
              ),
              if (hasTrack) ...[
                _Stat(
                  label: context.tr('Mesafe', 'Distance'),
                  value: '${track.distanceKm.toStringAsFixed(2)} km',
                ),
                _Stat(
                  label: context.tr('Süre', 'Duration'),
                  value: _duration(
                    live
                        ? DateTime.now().difference(track.points.first.at)
                        : track.duration,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: visited.isEmpty && !hasTrack
                ? null
                : () => _share(track),
            icon: const Icon(Icons.ios_share),
            label: Text(
              context.tr('Toplulukta paylaş', 'Share with community'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              'Paylaşım yalnızca sen gönderirsen yapılır ve moderasyondan geçer. Ham GPS izin ve konumun paylaşılmaz; gönderi rumuzunla ve bu geziye bağlı olarak görünür.',
              'Nothing is shared unless you post it, and posts are moderated. Your raw GPS track and location are never shared; the post appears under your nickname, linked to this trip.',
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    width: 150,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: RouteviaColors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ],
    ),
  );
}
