import 'package:flutter/foundation.dart';

class BillingCatalog {
  static const targetMonthlyPriceLabel = '49,99 TL / ay';
  static const targetYearlyPriceLabel = '500 TL / yil';
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
