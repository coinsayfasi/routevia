import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/core/constants.dart';
import 'src/data/local_cache.dart';

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
      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('Uncaught platform error: $error');
        debugPrintStack(stackTrace: stack);
        return true;
      };
      runApp(const ProviderScope(child: _BootstrapApp()));
    },
    (error, stack) {
      debugPrint('Uncaught zone error: $error');
      debugPrintStack(stackTrace: stack);
    },
  );
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp>
    with TickerProviderStateMixin {
  late Future<void> _bootstrapFuture;
  late AnimationController _glowController;
  late AnimationController _fadeController;
  late Animation<double> _glowAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _bootstrapFuture = _bootstrap();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _fadeController.dispose();
    super.dispose();
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
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      ).timeout(const Duration(seconds: 15));
    } catch (e) {
      if (e.toString().toLowerCase().contains('already initialized')) {
        debugPrint('[bootstrap] Supabase zaten başlatılmış, geçiliyor');
      } else {
        debugPrint('[bootstrap] Supabase fail: $e');
        rethrow;
      }
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF07162F),
                      Color(0xFF0B1F3A),
                      Color(0xFF123464),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                top: -120,
                right: -80,
                child: AnimatedBuilder(
                  animation: _glowAnim,
                  builder: (_, _) => Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color.fromRGBO(125, 211, 252, 0.14 * _glowAnim.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 176,
                  height: 176,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: const Color(0x55D7E5FF)),
                  ),
                  child: Image.asset('assets/branding/app_icon_1024.png'),
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 72,
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
