import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/error_utils.dart';
import '../../data/providers.dart';
import '../../models/trip_models.dart';

class TrendMapScreen extends ConsumerStatefulWidget {
  const TrendMapScreen({super.key, this.provinceSlug});

  final String? provinceSlug;

  @override
  ConsumerState<TrendMapScreen> createState() => _TrendMapScreenState();
}

class _TrendMapScreenState extends ConsumerState<TrendMapScreen> {
  final MapController _mapController = MapController();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const [];
  LatLng _center = const LatLng(39.9255, 32.8663);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(repositoryProvider);
      final items = await repo.getTrendMapItems(
        provinceSlug: widget.provinceSlug,
        limit: 220,
      );
      if (!mounted) return;
      LatLng center = _center;
      if (items.isNotEmpty) {
        final first = items.first;
        center = LatLng(
          (first['lat'] as num?)?.toDouble() ?? _center.latitude,
          (first['lng'] as num?)?.toDouble() ?? _center.longitude,
        );
      }
      setState(() {
        _items = items;
        _center = center;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _scoreColor(double score) {
    if (score >= 75) return const Color(0xFFB91C1C);
    if (score >= 55) return const Color(0xFFEA580C);
    if (score >= 35) return const Color(0xFF0284C7);
    return const Color(0xFF475569);
  }

  double _circleRadius(double score) {
    final normalized = (score.clamp(0, 100)) / 100;
    return 14 + (normalized * 32);
  }

  @override
  Widget build(BuildContext context) {
    final points = _items
        .where((x) => x['lat'] != null && x['lng'] != null)
        .map((x) {
          final score = (x['trend_score'] as num?)?.toDouble() ?? 0;
          final color = _scoreColor(score);
          final place = PlaceModel.fromMap({
            'id': x['id'],
            'name': x['name'],
            'slug': x['id'],
            'category': x['category'] ?? 'activity',
            'short_summary': '${x['district'] ?? x['city'] ?? ''}',
            'best_time': 'day',
            'duration_min': 60,
            'lat': x['lat'],
            'lng': x['lng'],
            'tags': const [],
            'source_kind': 'curated',
            'media': const [],
          });
          return (
            point: LatLng(
              (x['lat'] as num).toDouble(),
              (x['lng'] as num).toDouble(),
            ),
            score: score,
            color: color,
            place: place,
          );
        })
        .toList();

    final circles = points
        .map(
          (p) => CircleMarker(
            point: p.point,
            radius: _circleRadius(p.score),
            useRadiusInMeter: false,
            color: p.color.withValues(alpha: 0.20),
            borderStrokeWidth: 1.4,
            borderColor: p.color.withValues(alpha: 0.62),
          ),
        )
        .toList();

    final markers = [...points]..sort((a, b) => (b.score).compareTo(a.score));
    final topInteractive = markers.take(36).map((p) {
      return Marker(
        point: p.point,
        width: 34,
        height: 34,
        child: GestureDetector(
          onTap: () => context.push('/place', extra: p.place),
          child: Container(
            decoration: BoxDecoration(
              color: p.color.withValues(alpha: 0.90),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.8),
            ),
            child: Center(
              child: Text(
                p.score.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trend Harita'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(initialCenter: _center, initialZoom: 9),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.routevia.mobile',
                    ),
                    CircleLayer(circles: circles),
                    MarkerLayer(markers: topInteractive),
                  ],
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Heat katmani aktif. Kirmizi daha yuksek trend skoru. Toplam: ${_items.length} nokta',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
