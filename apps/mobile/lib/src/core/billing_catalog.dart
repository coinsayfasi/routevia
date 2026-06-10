import 'package:flutter/foundation.dart';

class BillingCatalog {
  // Aylık "pahalı çapa" → yıllık kelepir algısı. Yıllık = ~4 ay bedava (~%37).
  static const targetMonthlyPriceLabel = '39,99 TL / ay';
  static const targetYearlyPriceLabel = '299,88 TL / yıl';

  /// Store'da tanımlı introductory offer (ücretsiz deneme) gün sayısı.
  /// Paywall'da öne çıkarmak için kullanılır; gerçek deneme App Store
  /// Connect / Play Console abonelik teklifinde tanımlanır.
  static const trialDays = 7;

  // RevenueCat public SDK keys (client-side, not secret).
  // Override at build time with --dart-define=REVENUECAT_ANDROID_KEY=... if needed.
  static const revenueCatAndroidKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_KEY',
    defaultValue: 'goog_ONadPOUwUlJgPbUZBNYnGWrOXID',
  );
  static const revenueCatIosKey = String.fromEnvironment(
    'REVENUECAT_IOS_KEY',
    defaultValue: 'appl_gUNzxrVaJkVSdckKHKOkGzYdKWK',
  );
  static const _defaultMonthlyProductId = String.fromEnvironment(
    'IAP_PRO_MONTHLY',
    defaultValue: 'routevia_pro_monthly',
  );
  static const _defaultYearlyProductId = String.fromEnvironment(
    'IAP_PRO_YEARLY',
    defaultValue: 'routevia_pro_yearly',
  );
  static const _androidMonthlyProductId = String.fromEnvironment(
    'IAP_ANDROID_PRO_MONTHLY',
    defaultValue: 'routevia_pro_monthly',
  );
  static const _androidYearlyProductId = String.fromEnvironment(
    'IAP_ANDROID_PRO_YEARLY',
    defaultValue: 'routevia_pro_yearly',
  );
  static const _iosMonthlyProductId = String.fromEnvironment(
    'IAP_IOS_PRO_MONTHLY',
    defaultValue: 'routevia_pro_monthly',
  );
  static const _iosYearlyProductId = String.fromEnvironment(
    'IAP_IOS_PRO_YEARLY',
    defaultValue: 'routevia_pro_yearly',
  );
  static const entitlementPro = 'routevia_pro';

  static String get proMonthlyProductId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _iosMonthlyProductId;
      case TargetPlatform.android:
        return _androidMonthlyProductId;
      default:
        return _defaultMonthlyProductId;
    }
  }

  static String get proYearlyProductId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _iosYearlyProductId;
      case TargetPlatform.android:
        return _androidYearlyProductId;
      default:
        return _defaultYearlyProductId;
    }
  }

  static Set<String> get storeProductIds {
    final ids = <String>{_defaultMonthlyProductId, _defaultYearlyProductId};
    ids.add(_androidMonthlyProductId);
    ids.add(_androidYearlyProductId);
    ids.add(_iosMonthlyProductId);
    ids.add(_iosYearlyProductId);
    return ids;
  }

  static const knownProducts = {
    _defaultMonthlyProductId: {
      'entitlement_key': entitlementPro,
      'label': 'Routevia Pro Aylik',
      'target_price': targetMonthlyPriceLabel,
    },
    _defaultYearlyProductId: {
      'entitlement_key': entitlementPro,
      'label': 'Routevia Pro Yillik',
      'target_price': targetYearlyPriceLabel,
    },
  };
}
