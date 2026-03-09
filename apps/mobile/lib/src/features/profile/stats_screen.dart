import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error_utils.dart';
import '../../core/premium_gate.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _stats = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ref.read(repositoryProvider).getUserStats();
      if (!mounted) return;
      setState(() {
        _stats = data;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pro = isPro(ref);

    return Scaffold(
      appBar: AppBar(title: const Text('Gezgin İstatistikleri')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 40, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF475569))),
                        const SizedBox(height: 16),
                        FilledButton(
                            onPressed: _load, child: const Text('Tekrar Dene')),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
                  children: [
                    // ── Summary Cards ──────────────────────────────────
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _StatCard(
                          icon: Icons.place,
                          label: 'Check-in',
                          value: '${_stats['checkins'] ?? 0}',
                        ),
                        _StatCard(
                          icon: Icons.favorite,
                          label: 'Favori',
                          value: '${_stats['favorites'] ?? 0}',
                        ),
                        _StatCard(
                          icon: Icons.rate_review,
                          label: 'Yorum',
                          value: '${_stats['reviews'] ?? 0}',
                        ),
                        _StatCard(
                          icon: Icons.map,
                          label: 'Gezi',
                          value: '${_stats['trips'] ?? 0}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Cities & Top City ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: RouteviaColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_city,
                              color: RouteviaColors.navyLight, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_stats['cities_visited'] ?? 0} il ziyaret edildi',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                if (_stats['top_city'] != null)
                                  Text(
                                    'En çok: ${_stats['top_city']}',
                                    style: const TextStyle(
                                        color: RouteviaColors.textSecondary),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Category Breakdown (Pro only detailed) ─────────
                    if (!pro) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: RouteviaColors.border),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.lock_outline,
                                color: RouteviaColors.textTertiary, size: 32),
                            const SizedBox(height: 8),
                            const Text(
                              'Detaylı kategori dağılımı ve gelişmiş istatistikler Pro ile açılır.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: RouteviaColors.textSecondary,
                                  height: 1.45),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => showPremiumGate(context,
                                  feature: 'Detaylı istatistikler'),
                              child: const Text("Pro'yu Keşfet"),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Kategori Dağılımı',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 17),
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryBreakdown(),
                    ],
                  ],
                ),
    );
  }

  static const _categoryLabels = <String, String>{
    'historical': 'Tarihi',
    'nature': 'Doğa',
    'food': 'Yeme & İçme',
    'restaurant': 'Restoran',
    'cafe': 'Kafe',
    'museum': 'Müze',
    'beach': 'Plaj',
    'park': 'Park',
    'shopping': 'Alışveriş',
    'accommodation': 'Konaklama',
    'entertainment': 'Eğlence',
    'sport': 'Spor',
    'religious': 'Dini Mekan',
    'viewpoint': 'Seyir Noktası',
    'waterfall': 'Şelale',
    'lake': 'Göl',
    'mountain': 'Dağ',
    'village': 'Köy',
    'thermal': 'Termal',
    'other': 'Diğer',
  };

  String _categoryLabel(String key) =>
      _categoryLabels[key.toLowerCase()] ?? key;

  Widget _buildCategoryBreakdown() {
    final raw = _stats['category_breakdown'];
    if (raw is! Map || raw.isEmpty) {
      return const Text(
        'Henüz yeterli veri yok.',
        style: TextStyle(color: RouteviaColors.textSecondary),
      );
    }
    final breakdown = Map<String, dynamic>.from(raw);
    final total =
        breakdown.values.fold<int>(0, (s, v) => s + ((v as num?)?.toInt() ?? 0));
    if (total == 0) {
      return const Text(
        'Henüz yeterli veri yok.',
        style: TextStyle(color: RouteviaColors.textSecondary),
      );
    }

    final sorted = breakdown.entries.toList()
      ..sort((a, b) =>
          ((b.value as num?)?.toInt() ?? 0).compareTo((a.value as num?)?.toInt() ?? 0));

    final colors = [
      RouteviaColors.teal,
      RouteviaColors.navyLight,
      RouteviaColors.amber,
      RouteviaColors.rose,
      const Color(0xFF7C3AED),
      const Color(0xFF0891B2),
      const Color(0xFFDB2777),
      const Color(0xFF65A30D),
    ];

    return Column(
      children: [
        for (var i = 0; i < sorted.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[i % colors.length],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _categoryLabel(sorted[i].key),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${sorted[i].value}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ((sorted[i].value as num?)?.toInt() ?? 0) / total,
                      minHeight: 8,
                      backgroundColor: RouteviaColors.border,
                      color: colors[i % colors.length],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.sizeOf(context).width - 44) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RouteviaColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: RouteviaColors.navyLight, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: RouteviaColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
