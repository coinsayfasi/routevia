import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

import 'core/theme.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/location_setup_screen.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/admin/admin_screen.dart';
import 'features/day_plan/day_plan_screen.dart';
import 'features/home/home_screen.dart';
import 'features/home/fethiye_hub_screen.dart';
import 'features/home/local_hub_screen.dart';
import 'features/map/map_screen.dart';
import 'features/map/trend_map_screen.dart';
import 'features/place/place_detail_screen.dart';
import 'features/saved_import/saved_import_screen.dart';
import 'features/shell/main_tabs_screen.dart';
import 'features/shared/deep_link_resolver_screen.dart';
import 'features/shared/share_token_route_screen.dart';
import 'features/shared/shared_trip_screen.dart';
import 'models/trip_models.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    errorBuilder: (context, state) => const HomeScreen(),
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthRoute = state.fullPath == '/auth';
      final isShareRoute = state.fullPath == '/share/:token';
      final needsAuth =
          state.fullPath == '/trips' || state.fullPath == '/saved-import';

      if (session == null && needsAuth) return '/auth';
      if (session != null && isAuthRoute) return '/home';
      if (session == null && isAuthRoute) return null;
      if (isShareRoute) return null;
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(path: '/auth-callback', redirect: (context, state) => '/auth'),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(
          prefillReferralCode: state.uri.queryParameters['ref'],
        ),
      ),
      GoRoute(
        path: '/location-setup',
        builder: (context, state) => const LocationSetupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final tabIndex =
              int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          return MainTabsScreen(initialIndex: tabIndex);
        },
      ),
      GoRoute(path: '/explore', redirect: (context, state) => '/home?tab=0'),
      GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
      GoRoute(path: '/trips', redirect: (context, state) => '/home?tab=1'),
      GoRoute(path: '/eco', redirect: (context, state) => '/home?tab=2'),
      GoRoute(path: '/suggest', redirect: (context, state) => '/home?tab=3'),
      GoRoute(path: '/profile', redirect: (context, state) => '/home?tab=4'),
      GoRoute(
        path: '/local-hub',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? const {};
          return LocalHubScreen(
            initialProvinceSlug: extra['province_slug'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/fethiye-hub',
        builder: (context, state) => const FethiyeHubScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) {
          final plan = state.extra as TripPlan?;
          return MapScreen(plan: plan);
        },
      ),
      GoRoute(
        path: '/trend-map',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? const {};
          return TrendMapScreen(
            provinceSlug: extra['province_slug'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/map-explore',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? const {};
          return MapScreen(
            plan: null,
            initialLat: (extra['lat'] as num?)?.toDouble(),
            initialLng: (extra['lng'] as num?)?.toDouble(),
            initialProvinceSlug: extra['province_slug'] as String?,
            initialDistrictId: extra['district_id'] as String?,
            initialDistrictSlug: extra['district_slug'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/day-plan',
        redirect: (context, state) => state.extra is TripPlan ? null : '/home',
        builder: (context, state) {
          final plan = state.extra as TripPlan;
          return DayPlanScreen(plan: plan);
        },
      ),
      GoRoute(
        path: '/place',
        redirect: (context, state) =>
            state.extra is PlaceModel ? null : '/home',
        builder: (context, state) {
          final place = state.extra as PlaceModel;
          return PlaceDetailScreen(place: place);
        },
      ),
      GoRoute(
        path: '/saved-import',
        builder: (context, state) => const SavedImportScreen(),
      ),
      GoRoute(
        path: '/shared',
        builder: (context, state) => const SharedTripScreen(),
      ),
      GoRoute(
        path: '/share/:token',
        builder: (context, state) =>
            ShareTokenRouteScreen(token: state.pathParameters['token'] ?? ''),
      ),
      GoRoute(
        path: '/place/:id',
        builder: (context, state) => DeepLinkResolverScreen(
          kind: 'place',
          value: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/plan/:id',
        builder: (context, state) => DeepLinkResolverScreen(
          kind: 'plan',
          value: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/ref/:code',
        builder: (context, state) => DeepLinkResolverScreen(
          kind: 'ref',
          value: state.pathParameters['code'] ?? '',
        ),
      ),
    ],
  );
});

class RouteviaApp extends ConsumerStatefulWidget {
  const RouteviaApp({super.key});

  @override
  ConsumerState<RouteviaApp> createState() => _RouteviaAppState();
}

class _RouteviaAppState extends ConsumerState<RouteviaApp> {
  AppLinks? _appLinks;
  StreamSubscription<Uri>? _uriSub;

  @override
  void initState() {
    super.initState();
    try {
      _appLinks = AppLinks();
      _uriSub = _appLinks!.uriLinkStream.listen(
        (uri) {
          if (!mounted) return;
          final router = ref.read(appRouterProvider);
          final path = (uri.scheme == 'routevia' && uri.host.isNotEmpty)
              ? '/${uri.host}${uri.path}'
              : (uri.path.isEmpty ? '/home' : uri.path);
          final query = uri.query.isEmpty ? '' : '?${uri.query}';
          router.go('$path$query');
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('[app_links] stream error: $error');
          debugPrintStack(stackTrace: stackTrace);
        },
      );
    } catch (error, stackTrace) {
      debugPrint('[app_links] init failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    _uriSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Routevia',
      theme: buildRouteviaTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
