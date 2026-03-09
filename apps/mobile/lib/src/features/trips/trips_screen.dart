import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/error_utils.dart';
import '../../data/providers.dart';
import '../../models/trip_models.dart';

class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _trips = const [];

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
      final data = await ref.read(repositoryProvider).listMyTrips();
      if (!mounted) return;
      setState(() {
        _trips = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(e);
        _loading = false;
      });
    }
  }

  Future<void> _shareTrip(String tripId) async {
    try {
      final token =
          await ref.read(repositoryProvider).createShareToken(tripId);
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          text:
              'Routevia\'da hazırladığım rotaya göz at!\nhttps://routevia.tabserve.com.tr/trip/$token',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e))),
      );
    }
  }

  Future<void> _openTrip(Map<String, dynamic> trip) async {
    final localPlan = trip['plan'];
    if (localPlan is Map) {
      if (!mounted) return;
      context.push('/map', extra: TripPlan.fromMap(Map<String, dynamic>.from(localPlan)));
      return;
    }

    final repo = ref.read(repositoryProvider);
    final remotePlan = await repo.getMyTripPlan(trip['id'] as String);
    if (!mounted) return;
    if (remotePlan != null) {
      context.push('/map', extra: remotePlan);
      return;
    }

    final cached = await repo.readCachedTrip();
    if (!mounted) return;
    if (cached != null && cached.tripId == trip['id']) {
      context.push('/map', extra: cached);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bu rota detayı cihazda yok. Yalnızca paylaşım bağlantısı kullanılabilir.'),
      ),
    );
  }

  static const _transportLabels = <String, String>{
    'car': 'Araç',
    'walk': 'Yürüyüş',
    'public': 'Toplu Taşıma',
    'mixed': 'Karma',
    'bicycle': 'Bisiklet',
    'motorcycle': 'Motosiklet',
  };

  static const _paceLabels = <String, String>{
    'slow': 'Yavaş',
    'moderate': 'Orta',
    'fast': 'Hızlı',
  };

  static const _personaLabels = <String, String>{
    'solo': 'Yalnız',
    'couple': 'Çift',
    'family': 'Aile',
    'friends': 'Arkadaş',
    'group': 'Grup',
  };

  String _label(Map<String, String> map, String? key) =>
      map[key?.toLowerCase() ?? ''] ?? (key ?? '');

  String _formatTripDate(String? raw) {
    final dt = DateTime.tryParse(raw ?? '');
    if (dt == null) return 'Bu cihazda saklandı';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  String _tripTitle(Map<String, dynamic> t) {
    if (t['title'] is String && (t['title'] as String).isNotEmpty) {
      return t['title'] as String;
    }
    final province = (t['province'] as Map?) ?? const {};
    final provinceName = province['name'] as String? ?? 'Rota';
    final days = t['days'];
    return '$provinceName • $days ${days == 1 ? 'gün' : 'gün'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gezilerim')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 40, color: Color(0xFFB42318)),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                )
              : _trips.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        children: const [
                          SizedBox(height: 160),
                          Center(
                            child: Text(
                              'Henüz kayıtlı rota yok.',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        itemCount: _trips.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                        itemBuilder: (context, index) {
                          final t = _trips[index];
                          final isLocal = (t['source'] as String?) == 'local';
                          final transport = _label(_transportLabels, t['transport_mode'] as String?);
                          final pace = _label(_paceLabels, t['pace'] as String?);
                          final persona = _label(_personaLabels, t['persona_mode'] as String?);
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _openTrip(t),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _tripTitle(t),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isLocal
                                              ? const Color(0xFFEFF6FF)
                                              : const Color(0xFFF0FDF4),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          isLocal ? 'Cihazda' : 'Hesapta',
                                          style: TextStyle(
                                            color: isLocal
                                                ? const Color(0xFF1D4ED8)
                                                : const Color(0xFF166534),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$transport • $pace • $persona',
                                    style: const TextStyle(color: Color(0xFF667085)),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _formatTripDate(t['created_at'] as String?),
                                    style: const TextStyle(
                                      color: Color(0xFF98A2B3),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => _openTrip(t),
                                        icon: const Icon(Icons.map_outlined, size: 18),
                                        label: const Text('Aç'),
                                      ),
                                      const SizedBox(width: 10),
                                      if (!isLocal)
                                        OutlinedButton.icon(
                                          onPressed: () => _shareTrip(t['id'] as String),
                                          icon: const Icon(Icons.share_outlined, size: 18),
                                          label: const Text('Paylaş'),
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
    );
  }
}
