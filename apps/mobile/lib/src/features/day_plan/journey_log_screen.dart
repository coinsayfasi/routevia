import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/i18n.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../models/community_post_models.dart';
import '../../models/journey_progress.dart';
import '../../models/journey_track.dart';
import '../../models/trip_models.dart';

/// Günün gezi günlüğü: kaydedilen gerçek GPS izi ya da (iz yoksa) gezilen durakları
/// bağlayan ve açıkça "gerçek iz değil" diye etiketlenen çizgi.
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
  JourneyTrack? _track;

  @override
  void initState() {
    super.initState();
    ref
        .read(localCacheProvider)
        .readJourneyTrack(widget.plan.tripId, widget.day.dayNumber)
        .then((t) {
          if (mounted) setState(() => _track = t);
        })
        .catchError((_) {
          if (mounted) setState(() => _track = JourneyTrack());
        });
  }

  List<TripStop> get _visited => widget.day.stops
      .where(
        (s) =>
            widget.progress.status(widget.day.dayNumber, s.place.id) ==
                'visited' &&
            s.place.lat != null &&
            s.place.lng != null,
      )
      .toList();

  int get _skipped => widget.day.stops
      .where(
        (s) =>
            widget.progress.status(widget.day.dayNumber, s.place.id) ==
            'skipped',
      )
      .length;

  String _duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return h > 0
        ? context.tr('$h sa $m dk', '${h}h ${m}m')
        : context.tr('$m dk', '$m min');
  }

  Future<void> _share() async {
    final track = _track ?? JourneyTrack();
    final visited = _visited;
    final names = visited.map((s) => s.place.name).take(6).join(' → ');
    final stats = track.hasTrack
        ? context.tr(
            '${track.distanceKm.toStringAsFixed(1)} km, ${_duration(track.duration)}',
            '${track.distanceKm.toStringAsFixed(1)} km, ${_duration(track.duration)}',
          )
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
      relatedRouteId: widget.plan.tripId,
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
    if (confirmed != true) return;
    await ref
        .read(localCacheProvider)
        .deleteJourneyTrack(widget.plan.tripId, widget.day.dayNumber);
    if (mounted) setState(() => _track = JourneyTrack());
  }

  @override
  Widget build(BuildContext context) {
    final track = _track;
    final visited = _visited;
    final hasTrack = track?.hasTrack ?? false;
    final line = hasTrack
        ? track!.points.map((p) => LatLng(p.lat, p.lng)).toList()
        : visited.map((s) => LatLng(s.place.lat!, s.place.lng!)).toList();
    final all = [
      ...line,
      ...visited.map((s) => LatLng(s.place.lat!, s.place.lng!)),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr(
            '${widget.day.dayNumber}. gün günlüğü',
            'Day ${widget.day.dayNumber} log',
          ),
        ),
        actions: [
          if (hasTrack)
            IconButton(
              tooltip: context.tr('İzi sil', 'Delete track'),
              onPressed: _deleteTrack,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: track == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 300,
                    child: all.isEmpty
                        ? ColoredBox(
                            color: RouteviaColors.surfaceVariant,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  context.tr(
                                    'Henüz gezilen durak veya kayıtlı iz yok.',
                                    'No visited stops or recorded track yet.',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        : FlutterMap(
                            options: MapOptions(
                              initialCameraFit: all.length == 1
                                  ? null
                                  : CameraFit.coordinates(
                                      coordinates: all,
                                      padding: const EdgeInsets.all(36),
                                    ),
                              initialCenter: all.first,
                              initialZoom: 15,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                                          : StrokePattern.dashed(
                                              segments: const [10, 8],
                                            ),
                                    ),
                                  ],
                                ),
                              MarkerLayer(
                                markers: [
                                  for (var i = 0; i < visited.length; i++)
                                    Marker(
                                      point: LatLng(
                                        visited[i].place.lat!,
                                        visited[i].place.lng!,
                                      ),
                                      width: 30,
                                      height: 30,
                                      child: CircleAvatar(
                                        backgroundColor: RouteviaColors.amber,
                                        child: Text(
                                          '${i + 1}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
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
                            ? context.tr(
                                'Kaydettiğin gerçek GPS izi',
                                'Your recorded GPS track',
                              )
                            : context.tr(
                                'Gezdiğin durakları bağlayan çizgi — gerçek yürüme/sürüş izi değildir',
                                'Line connecting your visited stops — not an actual walking/driving track',
                              ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                        value: '${track.distanceKm.toStringAsFixed(1)} km',
                      ),
                      _Stat(
                        label: context.tr('Süre', 'Duration'),
                        value: _duration(track.duration),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: visited.isEmpty && !hasTrack ? null : _share,
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
