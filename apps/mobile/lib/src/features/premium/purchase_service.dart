import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/billing_catalog.dart';

class PurchaseService {
  static bool _configured = false;

  static Future<void> configure() async {
    if (_configured) return;
    final apiKey = defaultTargetPlatform == TargetPlatform.iOS
        ? BillingCatalog.revenueCatIosKey
        : BillingCatalog.revenueCatAndroidKey;
    if (apiKey.isEmpty) {
      debugPrint('[PurchaseService] RevenueCat API key eksik — IAP devre dışı');
      return;
    }
    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _configured = true;
    } catch (e) {
      debugPrint('[PurchaseService] configure hatası: $e');
    }
  }

  static Future<void> ensureConfigured() async {
    if (!_configured) await configure();
  }

  static Future<void> loginUser(String userId) async {
    if (!_configured) return;
    await Purchases.logIn(userId);
  }

  static Future<void> logoutUser() async {
    if (!_configured) return;
    await Purchases.logOut();
  }

  static Future<CustomerInfo> getCustomerInfo() async {
    await ensureConfigured();
    if (!_configured) throw StateError('RevenueCat not configured');
    return await Purchases.getCustomerInfo();
  }

  static Future<Offerings?> getOfferings() async {
    await ensureConfigured();
    if (!_configured) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('[PurchaseService] getOfferings hata: $e');
      return null;
    }
  }

  static Future<CustomerInfo> purchasePackage(Package package) async {
    await ensureConfigured();
    return await Purchases.purchasePackage(package);
  }

  static Future<CustomerInfo> restorePurchases() async {
    await ensureConfigured();
    return await Purchases.restorePurchases();
  }

  static bool hasPro(CustomerInfo info) {
    return info.entitlements.active.containsKey(BillingCatalog.entitlementPro);
  }

  static DateTime? proExpiryDate(CustomerInfo info) {
    final entitlement = info.entitlements.active[BillingCatalog.entitlementPro];
    if (entitlement == null) return null;
    final expStr = entitlement.expirationDate;
    if (expStr == null) return null;
    return DateTime.tryParse(expStr);
  }

  /// Server-side entitlement doğrulama + Supabase sync.
  ///
  /// Önce rc_sync_entitlement Edge Function'ı çağırır — bu fonksiyon RevenueCat
  /// REST API (secret key) üzerinden aboneliği doğrular ve user_entitlements
  /// tablosuna güvenli şekilde yazar. Ağ hatası veya RC key eksikliği durumunda
  /// client-side doğrulanmış CustomerInfo'ya göre doğrudan yazar (fallback).
  static Future<void> syncEntitlementToSupabase(
    SupabaseClient client,
    CustomerInfo info,
  ) async {
    final session = client.auth.currentSession;
    if (session == null) return;
    if (!hasPro(info)) return;

    // Önce server-side doğrulama dene (en güvenli yol)
    try {
      await client.functions.invoke(
        'rc_sync_entitlement',
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
        body: {},
      );
      debugPrint('[PurchaseService] RC server verification başarılı');
      return;
    } catch (e) {
      debugPrint('[PurchaseService] RC server verification başarısız, fallback: $e');
    }

    // Fallback: RevenueCat SDK zaten doğruladı, client'ın bilgisiyle yaz
    final expiry = proExpiryDate(info);
    if (expiry == null) return;
    try {
      await client.from('user_entitlements').upsert({
        'user_id': session.user.id,
        'entitlement_key': BillingCatalog.entitlementPro,
        'expires_at': expiry.toIso8601String(),
      }, onConflict: 'user_id,entitlement_key');
    } catch (e) {
      debugPrint('[PurchaseService] Supabase fallback sync hata: $e');
    }
  }
}
