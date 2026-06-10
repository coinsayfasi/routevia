import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ad_service.dart';
import '../../core/i18n.dart';
import '../../core/widgets/ad_banner.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../models/trip_models.dart';
import '../contribute/suggestion_screen.dart';
import '../eco/eco_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../trips/trips_screen.dart';

class MainTabsScreen extends ConsumerStatefulWidget {
  const MainTabsScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends ConsumerState<MainTabsScreen> {
  late int _currentIndex;
  late final List<Widget?> _pages;
  TripPlan? _activePlan;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
    _pages = List<Widget?>.filled(5, null);
    _pages[_currentIndex] = _buildPage(_currentIndex);
    // ATT permission (iOS only) → then AdService init
    unawaited(_requestAttAndInitAds());
    // Aktif gezi planı varsa sticky bar'ı göster
    unawaited(_loadActivePlan());
  }

  Future<void> _requestAttAndInitAds() async {
    // iOS 14+ — ATT dialog must appear before any ad SDK initialization.
    // On non-iOS platforms skip straight to ad init.
    if (Platform.isIOS) {
      try {
        // Small delay so the first frame is rendered before the system dialog.
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          final result =
              await AppTrackingTransparency.requestTrackingAuthorization();
          AdService().setPersonalizedAds(result == TrackingStatus.authorized);
        } else {
          AdService()
              .setPersonalizedAds(status == TrackingStatus.authorized);
        }
      } catch (e) {
        debugPrint('[ATT] request failed: $e');
      }
    }
    if (!mounted) return;
    AdService().init();
  }

  Future<void> _loadActivePlan() async {
    try {
      final raw = await ref.read(localCacheProvider).getActivePlan();
      if (raw == null || !mounted) return;
      final plan = TripPlan.fromMap(raw);
      setState(() => _activePlan = plan);
    } catch (_) {
      // Sessizce yoksay — sticky bar kritik değil
    }
  }

  void _dismissActivePlan() {
    setState(() => _activePlan = null);
    unawaited(ref.read(localCacheProvider).clearActivePlan());
  }

  @override
  void didUpdateWidget(covariant MainTabsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex.clamp(0, 4);
      _pages[_currentIndex] ??= _buildPage(_currentIndex);
    }
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const TripsScreen();
      case 2:
        return const EcoScreen();
      case 3:
        return const SuggestionScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  void _onTap(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
      _pages[index] ??= _buildPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sync premium state with AdService on every rebuild.
    // During loading, treat as pro to avoid ad flash for paying users.
    final premiumAsync = ref.watch(premiumStateProvider);
    final pro = premiumAsync.valueOrNull?.isPro ?? false;
    AdService().setPremium(pro);
    final showAd = !premiumAsync.isLoading && !pro;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: List<Widget>.generate(
          _pages.length,
          (index) => _pages[index] ?? const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Aktif Gezi Sticky Bar ──────────────────────────────────────
          if (_activePlan != null)
            _ActiveTripBar(
              plan: _activePlan!,
              onTap: () {
                context.push('/day-plan', extra: _activePlan);
              },
              onDismiss: _dismissActivePlan,
            ),
          if (showAd) const AdBannerWidget(),
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF061126), Color(0xFF0B1F3A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              indicatorColor: RouteviaColors.teal.withValues(alpha: 0.26),
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                (states) => TextStyle(
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                (states) => IconThemeData(
                  color: states.contains(WidgetState.selected)
                      ? RouteviaColors.tealLight
                      : Colors.white70,
                ),
              ),
            ),
            child: NavigationBar(
              height: 72,
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTap,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.explore_outlined),
                  selectedIcon: const Icon(Icons.explore),
                  label: context.tr('Keşfet', 'Explore'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.route_outlined),
                  selectedIcon: const Icon(Icons.route),
                  label: context.tr('Rotalar', 'Routes'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.eco_outlined),
                  selectedIcon: const Icon(Icons.eco),
                  label: context.tr('Eko', 'Eco'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.add_location_alt_outlined),
                  selectedIcon: const Icon(Icons.add_location_alt),
                  label: context.tr('Katkı', 'Contribute'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: context.tr('Profil', 'Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }
}

// ─── Aktif Gezi Sticky Bar ────────────────────────────────────────────────────

class _ActiveTripBar extends StatelessWidget {
  const _ActiveTripBar({
    required this.plan,
    required this.onTap,
    required this.onDismiss,
  });

  final TripPlan plan;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final totalStops = plan.daysPlan.fold<int>(0, (s, d) => s + d.stops.length);
    final firstStop = plan.daysPlan.isNotEmpty && plan.daysPlan.first.stops.isNotEmpty
        ? plan.daysPlan.first.stops.first.place.name
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0B3B68), Color(0xFF0E4F8A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x330B3B68),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.route, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${plan.province.name} • ${context.tr('Aktif Gezi', 'Active Trip')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '$totalStops ${context.tr('durak', 'stop')}${firstStop.isNotEmpty ? " • $firstStop..." : ""}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('Devam Et →', 'Continue →'),
              style: const TextStyle(
                color: Color(0xFF7DD3FC),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close_rounded,
                color: Colors.white.withValues(alpha: 0.6),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
