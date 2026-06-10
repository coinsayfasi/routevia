import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n.dart';
import '../../core/theme.dart';
import '../../core/widgets/place_pexels_image.dart';
import '../../data/providers.dart';
import '../../models/trip_models.dart';

// ─── Category styling (minimal copy from map_screen) ──────────────────────────

const _catColors = <String, Color>{
  'museum':     Color(0xFF1565C0),
  'historical': Color(0xFFF57F17),
  'nature':     Color(0xFF2E7D32),
  'beach':      Color(0xFF0097A7),
  'viewpoint':  Color(0xFF00897B),
  'food':       Color(0xFFD84315),
  'cafe':       Color(0xFF6D4C41),
  'lodging':    Color(0xFF7B1FA2),
  'activity':   Color(0xFF283593),
  'market':     Color(0xFFC2185B),
  'tour':       Color(0xFFE65100),
  'waterfall':  Color(0xFF0288D1),
  'canyon':     Color(0xFF4527A0),
};

const _catLabels = <String, String>{
  'museum':     'Müze',
  'historical': 'Tarihi',
  'nature':     'Doğa',
  'beach':      'Plaj',
  'viewpoint':  'Manzara',
  'food':       'Yemek',
  'cafe':       'Kafe',
  'lodging':    'Konaklama',
  'activity':   'Aktivite',
  'market':     'Pazar',
  'tour':       'Tur',
  'waterfall':  'Şelale',
  'canyon':     'Kanyon',
};

Color _catColor(String cat) => _catColors[cat] ?? const Color(0xFF78909C);
String _catLabel(String cat) => _catLabels[cat] ?? cat;

// ─── Screen ───────────────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  List<PlaceModel> _results = [];
  bool _loading = false;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus the search bar when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
        _searched = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String query) async {
    if (!mounted) return;
    final results = await ref.read(repositoryProvider).searchPlaces(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
      _searched = true;
    });
  }

  void _openPlace(PlaceModel place) {
    _focusNode.unfocus();
    context.push('/place', extra: place);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RouteviaColors.background,
      appBar: AppBar(
        backgroundColor: RouteviaColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: const Color(0x14000000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: RouteviaColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onChanged,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            color: RouteviaColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: context.tr('Yer, şehir, kategori ara…', 'Search place, city, category…'),
            hintStyle: const TextStyle(
              color: RouteviaColors.textSecondary,
              fontSize: 15,
            ),
            border: InputBorder.none,
            isDense: true,
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 20),
              color: RouteviaColors.textSecondary,
              onPressed: () {
                _controller.clear();
                _onChanged('');
              },
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: RouteviaColors.teal,
        ),
      );
    }

    if (!_searched) {
      return _buildEmptyState();
    }

    if (_results.isEmpty) {
      return _buildNoResults();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: _results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _PlaceResultCard(
        place: _results[i],
        onTap: () => _openPlace(_results[i]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.travel_explore_rounded,
            size: 64,
            color: RouteviaColors.teal.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('Türkiye\'nin her köşesini keşfet', 'Explore every corner of Turkey'),
            style: const TextStyle(
              color: RouteviaColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('Yer adı yazarak arama yap', 'Type a place name to search'),
            style: const TextStyle(
              color: RouteviaColors.textTertiary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: RouteviaColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('Sonuç bulunamadı', 'No results found'),
            style: const TextStyle(
              color: RouteviaColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('Farklı bir kelime dene', 'Try a different keyword'),
            style: const TextStyle(
              color: RouteviaColors.textTertiary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Result Card ──────────────────────────────────────────────────────────────

class _PlaceResultCard extends StatelessWidget {
  const _PlaceResultCard({required this.place, required this.onTap});

  final PlaceModel place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final catColor = _catColor(place.category);
    final catLabel = _catLabel(place.category);

    return Material(
      color: RouteviaColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // ── Thumbnail ──────────────────────────────────────────────
            SizedBox(
              width: 96,
              height: 88,
              child: PlacePexelsImage(
                placeName: place.name,
                provinceName: place.provinceName ?? '',
                category: place.category,
                fit: BoxFit.cover,
                fallbackWidget: Container(
                  color: catColor.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.image_outlined,
                    color: catColor.withValues(alpha: 0.5),
                    size: 28,
                  ),
                ),
              ),
            ),
            // ── Info ───────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RouteviaColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (place.provinceName != null && place.provinceName!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: RouteviaColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            place.provinceName!,
                            style: const TextStyle(
                              color: RouteviaColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            catLabel,
                            style: TextStyle(
                              color: catColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (place.shortSummary.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        place.shortSummary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: RouteviaColors.textTertiary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right_rounded,
                color: RouteviaColors.textTertiary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
