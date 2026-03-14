import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error_utils.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';

class EcoScreen extends ConsumerStatefulWidget {
  const EcoScreen({super.key});

  @override
  ConsumerState<EcoScreen> createState() => _EcoScreenState();
}

class _EcoScreenState extends ConsumerState<EcoScreen> {
  bool _loading = true;
  Map<String, dynamic> _eco = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ref.read(repositoryProvider).getEcoScore();
      if (!mounted) return;
      setState(() => _eco = data);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _eco = {
          'score': 0,
          'grade': 'D',
          'distance_km': 0.0,
          'co2_kg': 0.0,
          'saved_vs_car_kg': 0.0,
          'tips': [friendlyError(e)],
        };
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = (_eco['score'] as num?)?.toInt() ?? 0;
    final grade = (_eco['grade'] as String?) ?? '-';
    final distance = (_eco['distance_km'] as num?)?.toDouble() ?? 0;
    final co2 = (_eco['co2_kg'] as num?)?.toDouble() ?? 0;
    final saved = (_eco['saved_vs_car_kg'] as num?)?.toDouble() ?? 0;
    final tips = ((_eco['tips'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList();
    final modeKm = Map<String, dynamic>.from(
      (_eco['mode_breakdown_km'] as Map?) ?? const {},
    );
    final ecoActive = distance > 0 || modeKm.isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFFBF7), Color(0xFFF6FAFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: ecoActive
                            ? const Color(0xFFECFDF3)
                            : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: ecoActive
                              ? const Color(0xFFA6F4C5)
                              : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            ecoActive
                                ? Icons.verified_outlined
                                : Icons.hourglass_disabled_outlined,
                            color: ecoActive
                                ? const Color(0xFF027A48)
                                : const Color(0xFFB54708),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ecoActive
                                  ? 'Eko skor aktif. Son rotana gore canli hesaplandi.'
                                  : 'Eko skor hazir ama aktif veri yok. Once rota olusturup haritada ac.',
                              style: TextStyle(
                                color: ecoActive
                                    ? const Color(0xFF027A48)
                                    : const Color(0xFFB54708),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF07493F), Color(0xFF0B7A68)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Eko Skor',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Rota bazli karbon puani',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$score / 100',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Seviye: $grade',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.eco,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _MetricRow(
                      leftTitle: 'Toplam Mesafe',
                      leftValue: '${distance.toStringAsFixed(1)} km',
                      rightTitle: 'CO2 Tahmini',
                      rightValue: '${co2.toStringAsFixed(2)} kg',
                    ),
                    const SizedBox(height: 10),
                    _MetricRow(
                      leftTitle: 'Araca Gore Tasarruf',
                      leftValue: '${saved.toStringAsFixed(2)} kg',
                      rightTitle: 'Durum',
                      rightValue: saved > 0 ? 'Iyi' : 'N/A',
                    ),
                    const SizedBox(height: 16),
                    if (modeKm.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: RouteviaColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ulasim Dagilimi',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),
                            ...modeKm.entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(e.key.toUpperCase())),
                                    Text(
                                      '${(e.value as num).toStringAsFixed(1)} km',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: RouteviaColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Iyilestirme Onerileri',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          ...tips.map(
                            (t) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 3),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Color(0xFF166534),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(t)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Skoru Yenile'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.leftTitle,
    required this.leftValue,
    required this.rightTitle,
    required this.rightValue,
  });

  final String leftTitle;
  final String leftValue;
  final String rightTitle;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    Widget tile(String title, String value) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: RouteviaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: RouteviaColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        tile(leftTitle, leftValue),
        const SizedBox(width: 10),
        tile(rightTitle, rightValue),
      ],
    );
  }
}
