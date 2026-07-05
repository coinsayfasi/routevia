import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';

import 'core/ad_service.dart';
import 'core/proximity_notification_service.dart';
import 'core/push_notification_service.dart';
import 'features/premium/purchase_service.dart';
import 'core/widgets/offline_banner.dart';
import 'core/theme.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/verify_email_screen.dart';
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
import 'features/search/search_screen.dart';
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
      GoRoute(
        path: '/verify',
        builder: (context, state) =>
            VerifyEmailScreen(email: state.uri.queryParameters['email'] ?? ''),
      ),
      GoRoute(path: '/auth-callback', redirect: (context, state) => '/auth'),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
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
      GoRoute(
        path: '/community-post/:id',
        builder: (context, state) {
          final postId = state.pathParameters['id'] ?? '';
          return CommunityPostDetailScreen(postId: postId);
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
          final provinceSlug =
              extra['province_slug'] as String? ??
              state.uri.queryParameters['province_slug'];
          final eventId =
              extra['event_id'] as String? ??
              state.uri.queryParameters['event_id'];
          return LocalHubScreen(
            initialProvinceSlug: provinceSlug,
            initialEventId: eventId,
          );
        },
      ),
      GoRoute(
        path: '/fethiye-hub',
        builder: (context, state) => const FethiyeHubScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
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

class _RouteviaAppState extends ConsumerState<RouteviaApp>
    with WidgetsBindingObserver {
  AppLinks? _appLinks;
  StreamSubscription<Uri>? _uriSub;
  StreamSubscription<AuthState>? _authSub;
  StreamSubscription<RemoteMessage>? _pushOpenSub;
  bool _handledInitialLink = false;
  bool _handledInitialPush = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initNotifications());
    unawaited(ref.read(appLocaleProvider.notifier).load());
    // 90 günden eski Hive cache girdilerini sil — uygulama şişmesini önler
    unawaited(ref.read(localCacheProvider).evictStaleEntries());
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      final router = ref.read(appRouterProvider);

      if (data.event == AuthChangeEvent.initialSession) {
        return;
      }

      if (data.event == AuthChangeEvent.signedIn) {
        // Re-register FCM token now that a user session is available
        unawaited(PushNotificationService.instance.init().catchError((_) {}));
        // RC: kullanıcıyı tanıt — satın almaları tanıması için gerekli
        final userId = data.session?.user.id;
        if (userId != null) {
          unawaited(PurchaseService.loginUser(userId).catchError((_) {}));
        }
        return;
      }

      if (data.event == AuthChangeEvent.passwordRecovery) {
        router.go('/reset-password');
        return;
      }

      // On explicit sign-out or session loss, redirect to auth from any screen
      // except screens that are already public (auth, onboarding, share, ref, reset-password)
      if (data.event == AuthChangeEvent.signedOut) {
        // RC: kullanıcı bağlantısını kes — başka kullanıcı leak'ini önle
        unawaited(PurchaseService.logoutUser().catchError((_) {}));
        // Invalidate stale user-scoped provider state so re-login gets fresh data
        ref.invalidate(premiumStateProvider);
        // Aktif gezi planını temizle — farklı kullanıcı girişinde kirli state kalmasın
        unawaited(ref.read(localCacheProvider).clearActivePlan());

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
    _bindPushOpenHandlers();
  }

  /// Extracts a named parameter value from a URL fragment string like
  /// "access_token=xx&type=recovery&...". Returns null if not found.
  String? _extractParam(String fragment, String key) {
    if (fragment.isEmpty) return null;
    for (final part in fragment.split('&')) {
      final eq = part.indexOf('=');
      if (eq == -1) continue;
      if (Uri.decodeComponent(part.substring(0, eq)) == key) {
        return Uri.decodeComponent(part.substring(eq + 1));
      }
    }
    return null;
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
    // Auth callbacks from magic links carry tokens in the fragment or query.
    // Works for both Supabase implicit flow (access_token in fragment) and
    // PKCE flow (code in query string — forwarded as query by auth-callback page).
    final isAuthCb =
        uri.host == 'auth-callback' ||
        (uri.path.isNotEmpty && uri.path.contains('auth-callback'));
    if (isAuthCb) {
      // Detect link type BEFORE consuming the URL (getSessionFromUrl may clear params)
      final fragment = uri.fragment;
      final queryType = uri.queryParameters['type'];
      // type can arrive in either fragment (#type=recovery) or query (?type=recovery)
      final linkType = queryType ?? _extractParam(fragment, 'type') ?? '';
      final isRecovery = linkType == 'recovery';
      final isSignup = linkType == 'signup' || linkType == 'email_change';

      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      } catch (e) {
        debugPrint('[auth] getSessionFromUrl error: $e');
      }
      if (!mounted) return;

      final session = Supabase.instance.client.auth.currentSession;
      if (isRecovery && session != null) {
        // passwordRecovery session → go to reset screen
        ref.read(appRouterProvider).go('/reset-password');
        return;
      }
      if (session != null) {
        // Email verified (signup / email_change) or magic link — check onboarding
        if (isSignup) {
          final repo = ref.read(repositoryProvider);
          await repo.ensureProfile();
          if (!mounted) return;
          final profile = await repo.getMyProfile();
          final completed =
              (profile?['onboarding_completed'] as bool?) ?? false;
          if (!completed) {
            ref.read(appRouterProvider).go('/onboarding');
            return;
          }
        }
        ref.read(appRouterProvider).go('/home');
        return;
      }
      // No session after callback — send to auth screen
      ref.read(appRouterProvider).go('/auth');
      return;
    }
    final router = ref.read(appRouterProvider);
    final path = (uri.scheme == 'routevia' && uri.host.isNotEmpty)
        ? '/${uri.host}${uri.path}'
        : (uri.path.isEmpty ? '/home' : uri.path);
    final query = uri.query.isEmpty ? '' : '?${uri.query}';
    router.go('$path$query');
  }

  Future<void> _initNotifications() async {
    await ProximityNotificationService.instance.init();
    await ProximityNotificationService.instance.requestPermission();
    unawaited(PushNotificationService.instance.init().catchError((_) {}));
    unawaited(_runProximityCheck());
  }

  void _bindPushOpenHandlers() {
    _pushOpenSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      unawaited(_handlePushOpen(message));
    });
    unawaited(_consumeInitialPushMessage());
  }

  Future<void> _consumeInitialPushMessage() async {
    if (_handledInitialPush) return;
    _handledInitialPush = true;
    try {
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message == null) return;
      await _handlePushOpen(message);
    } catch (error, stackTrace) {
      debugPrint('[push] initial message failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _handlePushOpen(RemoteMessage message) async {
    if (!mounted) return;
    final data = message.data;
    final screen = data['screen']?.toString() ?? '';
    if (screen == 'local-hub') {
      final provinceSlug = data['province_slug']?.toString();
      final eventId = data['event_id']?.toString();
      final query = <String, String>{
        if (provinceSlug != null && provinceSlug.isNotEmpty)
          'province_slug': provinceSlug,
        if (eventId != null && eventId.isNotEmpty) 'event_id': eventId,
      };
      final uri = Uri(path: '/local-hub', queryParameters: query);
      ref.read(appRouterProvider).go(uri.toString());
      return;
    }
    final deepLink = data['deeplink']?.toString();
    if (deepLink != null && deepLink.isNotEmpty) {
      await _handleIncomingUri(Uri.parse(deepLink));
      return;
    }
    // Blog push'ları (gezi-blog workflow): dış URL'i tarayıcıda aç
    final url = data['url']?.toString();
    if (url != null && url.startsWith('http')) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _runProximityCheck() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      final repo = ref.read(repositoryProvider);
      final provinces = await repo.listProvinces();
      await ProximityNotificationService.instance.checkAndNotify(
        userLat: pos.latitude,
        userLng: pos.longitude,
        provinces: provinces,
      );
      await ProximityNotificationService.instance.checkWeatherAndNotify(
        userLat: pos.latitude,
        userLng: pos.longitude,
      );
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_runProximityCheck());
      unawaited(AdService().showAppOpenIfAvailable());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _uriSub?.cancel();
    _authSub?.cancel();
    _pushOpenSub?.cancel();
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
      builder: (context, child) =>
          OfflineBanner(child: child ?? const SizedBox.shrink()),
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
