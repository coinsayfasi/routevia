import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

import 'core/theme.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/location_setup_screen.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/auth/reset_password_screen.dart';
import 'features/admin/admin_screen.dart';
import 'features/day_plan/day_plan_screen.dart';
import 'features/home/home_screen.dart';
import 'features/home/fethiye_hub_screen.dart';
import 'features/home/local_hub_screen.dart';
import 'features/map/map_screen.dart';
import 'features/map/trend_map_screen.dart';
import 'features/place/place_detail_screen.dart';
import 'features/legal/consent_settings_screen.dart';
import 'features/legal/legal_screen.dart';
import 'features/premium/premium_screen.dart';
import 'features/profile/my_content_screen.dart';
import 'features/profile/saved_places_screen.dart';
import 'features/profile/stats_screen.dart';
import 'features/saved_import/saved_import_screen.dart';
import 'features/shell/main_tabs_screen.dart';
import 'features/shared/deep_link_resolver_screen.dart';
import 'features/shared/share_token_route_screen.dart';
import 'features/shared/shared_trip_screen.dart';
import 'features/trips/community_post_detail_screen.dart';
import 'features/trips/community_post_editor_screen.dart';
import 'data/providers.dart';
import 'models/community_post_models.dart';
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
          state.fullPath == '/trips' ||
          state.fullPath == '/community-post' ||
          state.fullPath == '/community-post-editor' ||
          state.fullPath == '/saved-import' ||
          state.fullPath == '/saved-places';

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
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
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
      GoRoute(
        path: '/admin',
        builder: (context, state) => const _AdminRouteGuard(),
      ),
      GoRoute(path: '/trips', redirect: (context, state) => '/home?tab=1'),
      GoRoute(
        path: '/community-post-editor',
        builder: (context, state) => CommunityPostEditorScreen(
          initialPost: state.extra as CommunityPostModel?,
        ),
      ),
      GoRoute(
        path: '/community-post',
        redirect: (context, state) =>
            state.extra is CommunityPostModel ? null : '/trips',
        builder: (context, state) {
          final post = state.extra as CommunityPostModel;
          return CommunityPostDetailScreen(postId: post.id, initialPost: post);
        },
      ),
      GoRoute(path: '/eco', redirect: (context, state) => '/home?tab=2'),
      GoRoute(path: '/suggest', redirect: (context, state) => '/home?tab=3'),
      GoRoute(path: '/profile', redirect: (context, state) => '/home?tab=4'),
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
      GoRoute(
        path: '/saved-places',
        builder: (context, state) => const SavedPlacesScreen(),
      ),
      GoRoute(
        path: '/my-content',
        builder: (context, state) => const MyContentScreen(),
      ),
      GoRoute(
        path: '/consent',
        builder: (context, state) => const ConsentSettingsScreen(),
      ),
      GoRoute(
        path: '/legal',
        builder: (context, state) => LegalScreen(
          documentId: state.uri.queryParameters['doc'] ?? 'privacy',
        ),
      ),
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
            initialPlaceId: extra['place_id'] as String?,
            initialProvinceSlug: extra['province_slug'] as String?,
            initialDistrictId: extra['district_id'] as String?,
            initialDistrictSlug: extra['district_slug'] as String?,
            initialDistrictName: extra['district_name'] as String?,
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
  StreamSubscription<AuthState>? _authSub;
  bool _handledInitialLink = false;

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(appLocaleProvider.notifier).load());
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      final router = ref.read(appRouterProvider);

      if (data.event == AuthChangeEvent.initialSession) {
        return;
      }

      if (data.event == AuthChangeEvent.passwordRecovery) {
        router.go('/reset-password');
        return;
      }

      // On explicit sign-out or session loss, redirect to auth from any screen
      // except screens that are already public (auth, onboarding, share, ref, reset-password)
      if (data.event == AuthChangeEvent.signedOut) {
        final uri = router.routerDelegate.currentConfiguration.uri;
        final path = uri.path;
        final publicPaths = {
          '/auth',
          '/onboarding',
          '/reset-password',
          '/location-setup',
        };
        final isPublic =
            publicPaths.contains(path) ||
            path.startsWith('/share/') ||
            path.startsWith('/ref/') ||
            path.startsWith('/place/') ||
            path.startsWith('/plan/');
        if (!isPublic) {
          router.go('/auth');
        }
        return;
      }
    });
    try {
      _appLinks = AppLinks();
      _consumeInitialLink();
      _uriSub = _appLinks!.uriLinkStream.listen(
        (uri) {
          _handleIncomingUri(uri);
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

  Future<void> _consumeInitialLink() async {
    if (_appLinks == null || _handledInitialLink) return;
    try {
      final initialUri = await _appLinks!.getInitialLink();
      if (initialUri == null) return;
      _handledInitialLink = true;
      await _handleIncomingUri(initialUri);
    } catch (error, stackTrace) {
      debugPrint('[app_links] initial link failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _handleIncomingUri(Uri uri) async {
    if (!mounted) return;
    // Auth callbacks from magic links carry tokens in the fragment or query
    final isAuthCb =
        uri.host == 'auth-callback' ||
        (uri.path.isNotEmpty && uri.path.contains('auth-callback'));
    if (isAuthCb) {
      // Detect password recovery type before consuming the URL
      final fragment = uri.fragment; // e.g. type=recovery&access_token=...
      final queryType = uri.queryParameters['type'];
      final isRecovery =
          fragment.contains('type=recovery') || queryType == 'recovery';
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      } catch (e) {
        debugPrint('[auth] getSessionFromUrl error: $e');
      }
      if (!mounted) return;
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && isRecovery) {
        ref.read(appRouterProvider).go('/reset-password');
      } else {
        ref.read(appRouterProvider).go(session != null ? '/home' : '/auth');
      }
      return;
    }
    final router = ref.read(appRouterProvider);
    final path = (uri.scheme == 'routevia' && uri.host.isNotEmpty)
        ? '/${uri.host}${uri.path}'
        : (uri.path.isEmpty ? '/home' : uri.path);
    final query = uri.query.isEmpty ? '' : '?${uri.query}';
    router.go('$path$query');
  }

  @override
  void dispose() {
    _uriSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(appLocaleProvider);
    return MaterialApp.router(
      title: 'Routevia',
      theme: buildRouteviaTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

class _AdminRouteGuard extends ConsumerWidget {
  const _AdminRouteGuard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/auth');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<bool>(
      future: ref.read(repositoryProvider).isCurrentUserAdmin(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data != true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/home');
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        return const AdminScreen();
      },
    );
  }
}
