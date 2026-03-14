import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/billing_catalog.dart';
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
      try {
        entitlements = await repo.getEntitlements();
      } catch (_) {}
      try {
        features = await repo.getPremiumFeatures();
      } catch (_) {}
      try {
        isAdminUser = await repo.isCurrentUserAdmin();
      } catch (_) {}
    }

    DateTime? latestExpiry;
    bool isPro = isAdminUser; // Admin her zaman pro
    final now = DateTime.now().toUtc();
    for (final e in entitlements) {
      final key = e['entitlement_key'] as String?;
      if (key == 'pro_preview_7d' || key == BillingCatalog.entitlementPro) {
        final ex = DateTime.tryParse((e['expires_at'] as String?) ?? '');
        if (ex != null && ex.isAfter(now)) {
          isPro = true;
          if (latestExpiry == null || ex.isAfter(latestExpiry)) {
            latestExpiry = ex;
          }
        }
      }
    }

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
