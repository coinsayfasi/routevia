import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error_utils.dart';
import '../../core/theme.dart';
import '../../core/widgets/safe_network_image.dart';
import '../../data/providers.dart';
import '../../models/trip_models.dart';

class SavedPlacesScreen extends ConsumerStatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  ConsumerState<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends ConsumerState<SavedPlacesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _favorites = const [];
  List<Map<String, dynamic>> _checkins = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(repositoryProvider);
      final results = await Future.wait([
        repo.listSavedPlaces(type: 'favorite'),
        repo.listSavedPlaces(type: 'checkin'),
      ]);
      if (!mounted) return;
      setState(() {
        _favorites = results[0];
        _checkins = results[1];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatSavedAt(dynamic raw) {
    final dt = DateTime.tryParse(raw?.toString() ?? '');
    if (dt == null) return 'Yakında eklendi';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'museum':
        return 'Müze';
      case 'historical':
        return 'Tarih';
      case 'nature':
        return 'Doğa';
      case 'food':
        return 'Lezzet';
      case 'cafe':
        return 'Kafe';
      case 'beach':
        return 'Sahil';
      case 'viewpoint':
        return 'Manzara';
      default:
        return category.isEmpty ? 'Yer' : category;
    }
  }

  Widget _buildList(List<Map<String, dynamic>> items, {required String emptyTitle}) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bookmark_border_rounded,
                size: 40,
                color: RouteviaColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                emptyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: RouteviaColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final row = items[index];
          final place = row['place'] as PlaceModel;
          final imageUrl = place.media.isEmpty ? null : place.media.first.publicUrl;
          final districtLine = place.shortSummary.trim().isEmpty
              ? 'Kaydedilen yer'
              : place.shortSummary.trim();
          final trustScore = place.routeviaScore.clamp(0, 100).round();
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/place', extra: place),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: RouteviaColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A0F172A),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: SizedBox(
                      height: 172,
                      width: double.infinity,
                      child: imageUrl == null || imageUrl.isEmpty
                          ? Container(
                              color: const Color(0xFFE2E8F0),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.photo_camera_back_outlined,
                                size: 36,
                                color: Color(0xFF64748B),
                              ),
                            )
                          : SafeNetworkImage(url: imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                place.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                  color: RouteviaColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF3),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: const Color(0xFFA6F4C5)),
                              ),
                              child: Text(
                                '$trustScore / 100',
                                style: const TextStyle(
                                  color: Color(0xFF027A48),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          districtLine,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: RouteviaColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _MetaChip(
                              icon: Icons.sell_outlined,
                              label: _categoryLabel(place.category),
                            ),
                            _MetaChip(
                              icon: Icons.calendar_today_outlined,
                              label: _formatSavedAt(row['saved_at']),
                            ),
                            if ((place.stats?.reviewCount ?? 0) > 0)
                              _MetaChip(
                                icon: Icons.reviews_outlined,
                                label: '${place.stats!.reviewCount} yorum',
                              ),
                            if ((place.stats?.checkinsCount ?? 0) > 0)
                              _MetaChip(
                                icon: Icons.place_outlined,
                                label: '${place.stats!.checkinsCount} check-in',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaydedilen Yerlerim'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Favoriler'),
            Tab(text: 'Check-inler'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 40,
                          color: Color(0xFFB42318),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: RouteviaColors.textSecondary),
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
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(
                      _favorites,
                      emptyTitle: 'Henüz favori eklemedin. Beğendiğin yerleri burada toplayacağız.',
                    ),
                    _buildList(
                      _checkins,
                      emptyTitle: 'Henüz check-in yapmadın. Gittiğin yerler burada görünecek.',
                    ),
                  ],
                ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RouteviaColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: RouteviaColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: RouteviaColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
