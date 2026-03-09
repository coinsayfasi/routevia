import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/error_utils.dart';
import '../../data/providers.dart';
import '../../models/trip_models.dart';

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

  @override
  void initState() {
    super.initState();
    _plan = widget.plan;
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
      return 'Sunset';
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
    try {
      final repo = ref.read(repositoryProvider);
      final token = await repo.createShareToken(_plan.tripId);
      final highlights = _plan.daysPlan
          .expand((d) => d.stops)
          .take(3)
          .map((s) => s.place.name)
          .join(', ');
      final text =
          '${_plan.province.name} • ${_plan.days} Günlük WOW Plan\n'
          'Öne çıkanlar: $highlights\n'
          'Aç: routevia://share/$token\n'
          'Web: https://routevia.app/share/$token';
      final imageFile = await _buildShareCardImage(
        title: '${_plan.days} Günlük WOW Plan',
        subtitle: _plan.province.name,
        highlights: highlights,
      );
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          files: imageFile == null ? null : [XFile(imageFile.path)],
        ),
      );
      await repo.logAppEvent(
        'plan_shared',
        payload: {'trip_id': _plan.tripId, 'token': token},
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _optimizeToday() async {
    if (_optimizing) return;
    setState(() => _optimizing = true);
    try {
      final out = await ref.read(repositoryProvider).optimizeTripPlanV2(plan: _plan);
      final optimized = out['plan'] as TripPlan? ?? _plan;
      final premiumUsed = out['premium_used'] == true;
      if (!mounted) return;
      setState(() => _plan = optimized);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            premiumUsed
                ? 'Bugün optimize edildi (Premium).'
                : 'Bugün optimize edildi (Temel mod).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e))),
      );
    } finally {
      if (mounted) setState(() => _optimizing = false);
    }
  }

  Future<File?> _buildShareCardImage({
    required String title,
    required String subtitle,
    required String highlights,
  }) async {
    try {
      const width = 1080.0;
      const height = 1350.0;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final bgPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF081426), Color(0xFF0B1F3A), Color(0xFF0E7490)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(const Rect.fromLTWH(0, 0, width, height));
      canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), bgPaint);

      final titlePainter = TextPainter(
        text: TextSpan(
          text: 'Routevia',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 64,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width - 120);
      titlePainter.paint(canvas, const Offset(60, 70));

      final p2 = TextPainter(
        text: TextSpan(
          text: subtitle,
          style: const TextStyle(
            color: Color(0xFFBAE6FD),
            fontSize: 44,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width - 120);
      p2.paint(canvas, const Offset(60, 180));

      final p3 = TextPainter(
        text: TextSpan(
          text: title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 52,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width - 120);
      p3.paint(canvas, const Offset(60, 280));

      final p4 = TextPainter(
        text: TextSpan(
          text: 'Öne çıkanlar: $highlights',
          style: const TextStyle(color: Colors.white70, fontSize: 34),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 6,
        ellipsis: '…',
      )..layout(maxWidth: width - 120);
      p4.paint(canvas, const Offset(60, 430));

      final p5 = TextPainter(
        text: const TextSpan(
          text: 'Türkiye Seyahat Asistanı',
          style: TextStyle(color: Color(0xFF99F6E4), fontSize: 30),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width - 120);
      p5.paint(canvas, const Offset(60, height - 110));

      final picture = recorder.endRecording();
      final image = await picture.toImage(width.toInt(), height.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return null;
      final file = File('${Directory.systemTemp.path}/routevia_plan_card.png');
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      return file;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final day = _plan.daysPlan.firstWhere(
      (d) => d.dayNumber == _selectedDay,
      orElse: () => _plan.daysPlan.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Plan Zaman Çizelgesi'),
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
                Text(
                  '${_plan.province.name} • Gün ${day.dayNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${day.stops.length} durak • ${_plan.transportMode} • ${_plan.pace}',
                  style: const TextStyle(color: Colors.white70),
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
                Chip(
                  label: Text(_districtScopeLabel(_plan.districtStrict)),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: _plan.daysPlan
                  .map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('Gün ${d.dayNumber}'),
                        selected: _selectedDay == d.dayNumber,
                        onSelected: (_) =>
                            setState(() => _selectedDay = d.dayNumber),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              itemCount: day.stops.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final stop = day.stops[index];
                final slot = _slotLabel(stop, index);
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.go('/place', extra: stop.place),
                  child: Ink(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${stop.orderIndex}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'stop',
                                style: TextStyle(fontSize: 11),
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
                                  Chip(label: Text(stop.place.category)),
                                  Chip(label: Text('${stop.durationMin} dk')),
                                  Chip(label: Text(stop.transportMode)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stop.place.shortSummary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                ),
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
