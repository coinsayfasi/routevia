import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../models/trip_models.dart';
import '../../core/widgets/safe_network_image.dart';

// Reuse same category styling from map_screen
class _CatStyle {
  const _CatStyle(this.color, this.icon, this.label);
  final Color color;
  final IconData icon;
  final String label;
}

const _catStyles = <String, _CatStyle>{
  'museum': _CatStyle(Color(0xFF1565C0), Icons.museum, 'Müze'),
  'historical': _CatStyle(Color(0xFFF57F17), Icons.account_balance, 'Tarihi'),
  'nature': _CatStyle(Color(0xFF2E7D32), Icons.park, 'Doğa'),
  'beach': _CatStyle(Color(0xFF0097A7), Icons.beach_access, 'Plaj'),
  'viewpoint': _CatStyle(Color(0xFF00897B), Icons.panorama, 'Manzara'),
  'food': _CatStyle(Color(0xFFD84315), Icons.restaurant, 'Yemek'),
  'cafe': _CatStyle(Color(0xFF6D4C41), Icons.coffee, 'Kafe'),
  'lodging': _CatStyle(Color(0xFF7B1FA2), Icons.hotel, 'Konaklama'),
  'activity': _CatStyle(Color(0xFF283593), Icons.directions_run, 'Aktivite'),
  'market': _CatStyle(Color(0xFFC2185B), Icons.shopping_bag, 'Pazar/Çarşı'),
  'tour': _CatStyle(Color(0xFFE65100), Icons.tour, 'Tur'),
  'waterfall': _CatStyle(Color(0xFF0288D1), Icons.water_drop, 'Şelale'),
  'canyon': _CatStyle(Color(0xFF4527A0), Icons.terrain, 'Kanyon'),
};

_CatStyle _styleOf(String cat) =>
    _catStyles[cat] ?? const _CatStyle(Color(0xFF78909C), Icons.place, 'Diğer');

// ─────────────────────────────────────────────────────────────────────
class PlaceDetailScreen extends ConsumerStatefulWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final PlaceModel place;

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  PlaceModel? _detail;
  PlaceStats? _stats;
  Map<String, dynamic>? _trustMetric;
  Map<String, dynamic>? _liveStatus;
  bool _posting = false;
  int _rating = 5;
  final Set<String> _flags = {};
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(repositoryProvider);
    try {
      final detail = await repo.fetchPlaceDetail(widget.place.id);
      if (!mounted) return;
      setState(() => _detail = detail);
    } catch (_) {
      setState(() => _detail = widget.place);
    }
    try {
      final stats = await repo.getPlaceStats(widget.place.id);
      if (!mounted) return;
      setState(() => _stats = stats);
    } catch (_) {}
    try {
      final trust = await repo.getPlaceTrustMetrics(widget.place.id);
      final live = await repo.getLiveStatusForPlaces([
        widget.place.id,
      ], hours: 6);
      if (!mounted) return;
      setState(() {
        _trustMetric = trust;
        _liveStatus = live[widget.place.id];
      });
    } catch (_) {}
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.length > 240) return;
    setState(() => _posting = true);
    try {
      final stats = await ref
          .read(repositoryProvider)
          .submitPlaceReview(
            placeId: widget.place.id,
            rating: _rating,
            flags: _flags.toList(),
            commentShort: comment,
          );
      if (!mounted) return;
      setState(() => _stats = stats);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Yorum kaydedildi.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Yorum kaydedilemedi: $e')));
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<void> _openNavigation() async {
    final p = _detail ?? widget.place;
    final lat = p.lat ?? 0;
    final lng = p.lng ?? 0;
    final apple = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng');
    final google = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    final geo = Uri.parse('geo:$lat,$lng');

    final targets = Platform.isIOS
        ? [apple, google, geo]
        : [geo, google, apple];
    for (final t in targets) {
      if (await canLaunchUrl(t)) {
        await launchUrl(t, mode: LaunchMode.externalApplication);
        return;
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Yol tarifi acilamadi.')));
  }

  Future<void> _sharePlace() async {
    final p = _detail ?? widget.place;
    final districtText = p.tags.isEmpty
        ? ''
        : ' - ${p.tags.take(2).join(", ")}';
    final text =
        '${p.name}$districtText\n'
        '${p.shortSummary}\n'
        'routevia://place/${p.id}';
    await SharePlus.instance.share(ShareParams(text: text));
    await ref
        .read(repositoryProvider)
        .logAppEvent('place_shared', payload: {'place_id': p.id});
  }

  Future<void> _signal(String type, {double? rating}) async {
    final session = ref.read(repositoryProvider).client.auth.currentSession;
    if (session == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-in ve favori icin giris yapmalisin.'),
        ),
      );
      context.push('/auth');
      return;
    }
    try {
      await ref
          .read(repositoryProvider)
          .submitUserSignal(
            placeId: widget.place.id,
            type: type,
            rating: rating,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            type == 'checkin'
                ? 'Check-in kaydedildi'
                : type == 'favorite'
                ? 'Favorilere eklendi'
                : 'Puan sinyali kaydedildi',
          ),
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  String _flagLabel(String f) {
    const map = {
      'crowded': 'Kalabalık',
      'family': 'Aile Dostu',
      'quiet': 'Sakin',
      'photo_spot': 'Fotoğraf Noktası',
      'budget': 'Bütçe Dostu',
      'sunset_worthy': 'Gün Batımı',
    };
    return map[f] ?? f;
  }

  @override
  Widget build(BuildContext context) {
    final place = _detail ?? widget.place;
    final images = place.media;
    final cat = _styleOf(place.category);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero image app bar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: RouteviaColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (images.isNotEmpty)
                    PageView(
                      children: images
                          .map(
                            (m) => SafeNetworkImage(
                              url: m.publicUrl,
                              fit: BoxFit.cover,
                            ),
                          )
                          .toList(),
                    )
                  else
                    Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.image,
                        size: 48,
                        color: Colors.white54,
                      ),
                    ),
                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                  // Category badge on image
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 48,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cat.color,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            cat.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Title on image
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Rating + duration row
                        Wrap(
                          spacing: 8,
                          children: [
                            if (place.effectiveRating > 0)
                              _infoBadge(
                                Icons.star,
                                '${place.effectiveRating.toStringAsFixed(1)}${place.effectiveRatingCount > 0 ? ' (${place.effectiveRatingCount})' : ''}',
                                const Color(0xFFFFD600),
                              ),
                            if (place.routeviaScore > 0)
                              _infoBadge(
                                Icons.verified,
                                'Routevia ${place.routeviaScore.toStringAsFixed(1)}',
                                RouteviaColors.accent,
                              ),
                            _infoBadge(
                              Icons.schedule,
                              '${place.durationMin} dk',
                              Colors.white70,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.share), onPressed: _sharePlace),
            ],
          ),

          // ── Content ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _openNavigation,
                        icon: const Icon(Icons.navigation, size: 18),
                        label: const Text('Yol Tarifi'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.place,
                      label: 'Check-in',
                      onTap: () => _signal('checkin'),
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.favorite_border,
                      label: 'Favori',
                      onTap: () => _signal('favorite'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8ECF0)),
                  ),
                  child: Text(
                    place.shortSummary,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),
                const SizedBox(height: 12),

                // Source attribution
                _SourceBadge(place: place),
                const SizedBox(height: 12),
                if (_trustMetric != null) ...[
                  _TrustCard(metric: _trustMetric!, live: _liveStatus),
                  const SizedBox(height: 12),
                ],

                // Stats row
                if (_stats != null) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_stats!.familyCount > 0)
                        _StatChip(
                          Icons.family_restroom,
                          'Aile Dostu',
                          _stats!.familyCount,
                        ),
                      if (_stats!.photoSpotCount > 0)
                        _StatChip(
                          Icons.camera_alt,
                          'Foto Noktası',
                          _stats!.photoSpotCount,
                        ),
                      if (_stats!.sunsetWorthyCount > 0)
                        _StatChip(
                          Icons.wb_twilight,
                          'Gün Batımı',
                          _stats!.sunsetWorthyCount,
                        ),
                      if (_stats!.crowdedCount > 0)
                        _StatChip(
                          Icons.groups,
                          'Kalabalık',
                          _stats!.crowdedCount,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Tags
                if (place.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: place.tags
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '#$t',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Content sections
                _SectionCard(
                  icon: Icons.history_edu,
                  title: 'Tarih',
                  items: place.historyBullets,
                  color: const Color(0xFFF57F17),
                ),
                _SectionCard(
                  icon: Icons.restaurant_menu,
                  title: 'Yeme / İçme',
                  items: place.eatDrinkBullets,
                  color: const Color(0xFFD84315),
                ),
                _SectionCard(
                  icon: Icons.lightbulb_outline,
                  title: 'İpuçları',
                  items: place.tipsBullets,
                  color: RouteviaColors.accent,
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Review section
                const Text(
                  'Değerlendirme Yap',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 12),

                // Rating dropdown
                DropdownButtonFormField<int>(
                  initialValue: _rating,
                  decoration: const InputDecoration(labelText: 'Puan'),
                  items: [5, 4, 3, 2, 1]
                      .map(
                        (r) =>
                            DropdownMenuItem(value: r, child: Text('$r / 5')),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _rating = v ?? 5),
                ),
                const SizedBox(height: 10),

                // Quick flags
                const Text(
                  'Hızlı Etiketler',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children:
                      [
                            'crowded',
                            'family',
                            'quiet',
                            'photo_spot',
                            'budget',
                            'sunset_worthy',
                          ]
                          .map(
                            (f) => FilterChip(
                              label: Text(_flagLabel(f)),
                              selected: _flags.contains(f),
                              onSelected: (on) => setState(() {
                                if (on) {
                                  _flags.add(f);
                                } else {
                                  _flags.remove(f);
                                }
                              }),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  maxLength: 240,
                  decoration: const InputDecoration(
                    labelText: 'Kısa yorum',
                    hintText: 'Manzara harika, akşamüstü gidin.',
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _posting ? null : _submitReview,
                  icon: Icon(
                    _posting ? Icons.hourglass_top : Icons.send,
                    size: 18,
                  ),
                  label: Text(_posting ? 'Kaydediliyor...' : 'Yorumu Kaydet'),
                ),

                // Community reviews
                if ((_stats?.recentReviews.length ?? 0) > 0) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Topluluk Yorumları',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...(List<PlaceReviewModel>.from(_stats!.recentReviews)..sort(
                        (a, b) => b.reviewerScore.compareTo(a.reviewerScore),
                      ))
                      .map(
                        (r) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8ECF0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ...List.generate(
                                    r.rating.clamp(0, 5),
                                    (_) => const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Color(0xFFF57F17),
                                    ),
                                  ),
                                  const Spacer(),
                                  _TrustBadge(level: r.trustLevel),
                                  const SizedBox(width: 8),
                                  if (r.createdAt != null)
                                    Text(
                                      '${r.createdAt!.day}.${r.createdAt!.month}.${r.createdAt!.year}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                ],
                              ),
                              if (r.commentShort.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(r.commentShort),
                              ],
                              if (r.flags.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 4,
                                  children: r.flags
                                      .map(
                                        (f) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE0F2FE),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            _flagLabel(f),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF0369A1),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                ] else ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8ECF0)),
                    ),
                    child: const Text(
                      'Henüz topluluk yorumu yok. İlk yorumu sen bırak!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

// ─── Action Button ──────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCBD5E1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: RouteviaColors.primary),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Source Badge ────────────────────────────────────────────────────
class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.place});
  final PlaceModel place;

  @override
  Widget build(BuildContext context) {
    final isOsm = place.sourceKind == 'osm';
    final label = isOsm
        ? 'OpenStreetMap Contributors'
        : place.sourceKind == 'open_license'
        ? 'Açık Lisans'
        : 'Routevia Curated';
    final icon = isOsm
        ? Icons.public
        : place.sourceKind == 'open_license'
        ? Icons.verified_user
        : Icons.verified;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: RouteviaColors.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Kaynak: $label',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          if (isOsm)
            GestureDetector(
              onTap: () => launchUrl(
                Uri.parse('https://www.openstreetmap.org/copyright'),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text(
                'Lisans',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0369A1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  const _TrustCard({required this.metric, required this.live});

  final Map<String, dynamic> metric;
  final Map<String, dynamic>? live;

  @override
  Widget build(BuildContext context) {
    final trust = (metric['trust_score'] as num?)?.toDouble() ?? 0;
    final spamRisk = (metric['spam_risk'] as num?)?.toDouble() ?? 0;
    final freshness = (metric['freshness_score'] as num?)?.toDouble() ?? 0;
    final signalQuality = (metric['signal_quality'] as num?)?.toDouble() ?? 0;
    final liveTags = ((live?['tag_labels'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, size: 18, color: Color(0xFF0369A1)),
              const SizedBox(width: 8),
              Text(
                'Routevia Trust ${trust.toStringAsFixed(1)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                'Spam riski ${(spamRisk * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: RouteviaColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Guncellik ${(freshness * 100).toStringAsFixed(0)}% • Sinyal kalitesi ${(signalQuality * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: RouteviaColors.textSecondary,
              fontSize: 12,
            ),
          ),
          if (liveTags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: liveTags
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    final label = switch (level) {
      'local_contributor' => 'Yerel',
      'verified_traveler' => 'Dogrulanmis',
      _ => 'Yeni',
    };
    final color = switch (level) {
      'local_contributor' => const Color(0xFF14532D),
      'verified_traveler' => const Color(0xFF075985),
      _ => const Color(0xFF64748B),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Section Card ───────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.items,
    required this.color,
  });

  final IconData icon;
  final String title;
  final List<String> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items
              .take(4)
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// ─── Stat Chip ──────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  const _StatChip(this.icon, this.label, this.count);
  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: RouteviaColors.primary),
          const SizedBox(width: 6),
          Text(
            '$label $count',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
