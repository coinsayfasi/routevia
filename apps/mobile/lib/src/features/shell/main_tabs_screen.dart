import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ad_service.dart';
import '../../core/i18n.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
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

  static const _tabPaths = <String>[
    '/home?tab=0',
    '/home?tab=1',
    '/home?tab=2',
    '/home?tab=3',
    '/home?tab=4',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
    _pages = List<Widget?>.filled(5, null);
    _pages[_currentIndex] = _buildPage(_currentIndex);
    // Lazy-init AdService after 2s to avoid slowing first frame
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      AdService().init();
    });
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
    context.go(_tabPaths[index]);
  }

  @override
  Widget build(BuildContext context) {
    // Sync premium state with AdService on every rebuild
    final premiumAsync = ref.watch(premiumStateProvider);
    final pro = premiumAsync.valueOrNull?.isPro ?? false;
    AdService().setPremium(pro);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: List<Widget>.generate(
          _pages.length,
          (index) => _pages[index] ?? const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: SafeArea(
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
                  label: context.tr('Kesfet', 'Explore'),
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
                  label: context.tr('Katki', 'Contribute'),
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
    );
  }
}
