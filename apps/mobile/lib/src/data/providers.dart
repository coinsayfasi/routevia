import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/billing_catalog.dart';
import '../features/premium/purchase_service.dart';
import 'local_cache.dart';
import 'routevia_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
final localCacheProvider = Provider<LocalCache>((ref) => LocalCache());
final repositoryProvider = Provider<RouteviaRepository>(
  (ref) => RouteviaRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(localCacheProvider),
  ),
);

// ── Premium State ────────────────────────────────────────────────────────────

class PremiumState {
  const PremiumState({
    this.isPro = false,
    this.expiresAt,
    this.entitlements = const [],
    this.features = const [],
    this.dailyPlanCount = 0,
  });

  final bool isPro;
  final DateTime? expiresAt;
  final List<Map<String, dynamic>> entitlements;
  final List<Map<String, dynamic>> features;
  final int dailyPlanCount;

  bool get canGeneratePlan => isPro || dailyPlanCount < 3;
  int get remainingPlans => isPro ? -1 : (3 - dailyPlanCount).clamp(0, 3);
}

class PremiumStateNotifier extends AsyncNotifier<PremiumState> {
  @override
  Future<PremiumState> build() => _fetch();

  Future<PremiumState> _fetch() async {
    final repo = ref.read(repositoryProvider);
    final cache = ref.read(localCacheProvider);

    List<Map<String, dynamic>> entitlements = const [];
    List<Map<String, dynamic>> features = const [];
    bool isAdminUser = false;
    if (Supabase.instance.client.auth.currentSession != null) {
      // Run all three independent network calls in parallel
      final results = await Future.wait([
        repo.getEntitlements().catchError((_) => const <Map<String, dynamic>>[]),
        repo.getPremiumFeatures().catchError((_) => const <Map<String, dynamic>>[]),
        repo.isCurrentUserAdmin().catchError((_) => false),
      ]);
      entitlements = results[0] as List<Map<String, dynamic>>;
      features = results[1] as List<Map<String, dynamic>>;
      isAdminUser = results[2] as bool;
    }

    DateTime? latestExpiry;
    bool isPro = isAdminUser; // Admin her zaman pro
    final now = DateTime.now().toUtc();

    // Supabase entitlements (admin grants, vs.)
    for (final e in entitlements) {
      final key = e['entitlement_key'] as String?;
      if (key == BillingCatalog.entitlementPro) {
        final ex = DateTime.tryParse((e['expires_at'] as String?) ?? '');
        if (ex != null && ex.isAfter(now)) {
          isPro = true;
          if (latestExpiry == null || ex.isAfter(latestExpiry)) {
            latestExpiry = ex;
          }
        }
      }
    }

    // RevenueCat entitlements (gerçek satın alma)
    try {
      final customerInfo = await PurchaseService.getCustomerInfo();
      if (PurchaseService.hasPro(customerInfo)) {
        isPro = true;
        final rcExpiry = PurchaseService.proExpiryDate(customerInfo);
        if (rcExpiry != null && (latestExpiry == null || rcExpiry.isAfter(latestExpiry))) {
          latestExpiry = rcExpiry;
        }
      }
    } catch (_) {}

    final dailyCount = await cache.getDailyPlanCount();

    return PremiumState(
      isPro: isPro,
      expiresAt: latestExpiry,
      entitlements: entitlements,
      features: features,
      dailyPlanCount: dailyCount,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final premiumStateProvider =
    AsyncNotifierProvider<PremiumStateNotifier, PremiumState>(
  PremiumStateNotifier.new,
);

class AppLocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  Future<void> load() async {
    final code = await ref.read(localCacheProvider).getPreferredLanguageCode();
    state = _localeFromCode(code);
  }

  Future<void> setLanguageCode(String code) async {
    final normalized = code.trim().toLowerCase();
    await ref.read(localCacheProvider).setPreferredLanguageCode(normalized);
    state = _localeFromCode(normalized);
  }

  Locale? _localeFromCode(String? code) {
    switch ((code ?? '').trim().toLowerCase()) {
      case 'tr':
        return const Locale('tr');
      case 'en':
        return const Locale('en');
      default:
        return null;
    }
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale?>(
  AppLocaleNotifier.new,
);
