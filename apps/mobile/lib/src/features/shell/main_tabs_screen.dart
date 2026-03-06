import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
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
  }

  @override
  void didUpdateWidget(covariant MainTabsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex.clamp(0, 4);
    }
  }

  void _onTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    context.go(_tabPaths[index]);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      const TripsScreen(),
      const EcoScreen(),
      const SuggestionScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: pages),
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
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: 'Kesfet',
                ),
                NavigationDestination(
                  icon: Icon(Icons.route_outlined),
                  selectedIcon: Icon(Icons.route),
                  label: 'Rotalar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.eco_outlined),
                  selectedIcon: Icon(Icons.eco),
                  label: 'Eko',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_location_alt_outlined),
                  selectedIcon: Icon(Icons.add_location_alt),
                  label: 'Katki',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
