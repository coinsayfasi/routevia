import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/core/constants.dart';
import 'src/core/firebase_runtime.dart';
import 'src/data/local_cache.dart';
import 'src/features/premium/purchase_service.dart';

Future<void> main() async {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
      };
      // PlatformDispatcher handler: set here as default; firebase_runtime
      // overwrites it later with Crashlytics. This fallback fires only
      // before Firebase is initialized.
      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('Uncaught platform error (pre-firebase): $error');
        return true;
      };
      runApp(const ProviderScope(child: _BootstrapApp()));
    },
    (error, stack) {
      debugPrint('Uncaught zone error: $error');
      debugPrintStack(stackTrace: stack);
      // Forward zone errors to Crashlytics as NON-fatal.
      // Network/tile connection aborts are expected on mobile — don't crash.
      unawaited(FirebaseRuntime.recordError(error, stack, fatal: false));
    },
  );
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late Future<void> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Hive – non-critical, fail silently
    try {
      await Hive.initFlutter().timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[bootstrap] Hive fail: $e');
    }

    // Session count – non-critical, fail silently
    try {
      await LocalCache().bumpSessionCount().timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[bootstrap] bumpSessionCount fail: $e');
    }

    // Supabase – CRITICAL: must succeed or show error screen
    if (!AppConstants.hasSupabaseConfig) {
      throw StateError(
        'SUPABASE_URL ve SUPABASE_ANON_KEY --dart-define ile verilmeli.',
      );
    }
    try {
      await FirebaseRuntime.initialize();
    } catch (e) {
      debugPrint('[bootstrap] Firebase fail: $e');
    }

    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          // Implicit flow: tokens arrive in URL fragment — no PKCE code
          // verifier needed. Reliable for mobile deep links.
          authFlowType: AuthFlowType.implicit,
        ),
      ).timeout(const Duration(seconds: 15));
    } catch (e) {
      if (e.toString().toLowerCase().contains('already initialized')) {
        debugPrint('[bootstrap] Supabase zaten başlatılmış, geçiliyor');
      } else {
        debugPrint('[bootstrap] Supabase fail: $e');
        rethrow;
      }
    }

    try {
      await PurchaseService.configure();
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        await PurchaseService.loginUser(session.user.id);
      }
    } catch (e) {
      debugPrint('[bootstrap] RevenueCat init fail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildSplash();
        }
        if (snapshot.hasError) {
          return _buildError(snapshot.error);
        }
        return const RouteviaApp();
      },
    );
  }

  Widget _buildSplash() {
    // Reuse the exact native splash image (splash_bg.png) as the Flutter splash
    // so the OS-splash → Flutter handoff is seamless (no flash/jump). No fade-in:
    // the first Flutter frame matches the native one pixel-for-pixel. Only a
    // subtle progress bar is overlaid to signal loading.
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: AssetImage('assets/branding/splash_bg.png'),
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              child: Center(
                child: SizedBox(
                  width: 132,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF64D1F4),
                    ),
                    backgroundColor: Color(0x334A6B97),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Object? error) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF060D1A),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB42318).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFB42318).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 48,
                    color: Color(0xFFB42318),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bağlantı Kurulamadı',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (!mounted) return;
                      setState(() => _bootstrapFuture = _bootstrap());
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00C2A8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Tekrar Dene',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
