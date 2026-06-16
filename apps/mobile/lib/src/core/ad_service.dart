import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  factory AdService() => _instance;
  AdService._internal();
  static final AdService _instance = AdService._internal();

  static const Duration _appOpenFrequencyLimit = Duration(hours: 4);

  // ── Ad Unit IDs (override via --dart-define for production) ──────────────

  static const _bannerAndroid = String.fromEnvironment(
    'ADMOB_BANNER_ANDROID',
    defaultValue: 'ca-app-pub-7579691213276550/7396429509',
  );
  static const _bannerIos = String.fromEnvironment(
    'ADMOB_BANNER_IOS',
    defaultValue: 'ca-app-pub-7579691213276550/4902273895',
  );
  static const _interstitialAndroid = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ANDROID',
    defaultValue: 'ca-app-pub-7579691213276550/9916091149',
  );
  static const _interstitialIos = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_IOS',
    defaultValue: 'ca-app-pub-7579691213276550/2938309744',
  );
  static const _rewardedAndroidProd = String.fromEnvironment(
    'ADMOB_REWARDED_ANDROID',
    defaultValue: 'ca-app-pub-7579691213276550/4408279793',
  );
  static const _rewardedIosProd = String.fromEnvironment(
    'ADMOB_REWARDED_IOS',
    defaultValue: 'ca-app-pub-7579691213276550/2420185360',
  );
  static const _appOpenAndroidProd = String.fromEnvironment(
    'ADMOB_APP_OPEN_ANDROID',
    defaultValue: 'ca-app-pub-7579691213276550/5605811395',
  );
  static const _appOpenIosProd = String.fromEnvironment(
    'ADMOB_APP_OPEN_IOS',
    defaultValue: 'ca-app-pub-7579691213276550/8794022024',
  );

  // Google test IDs used when production IDs are not supplied.
  static const _rewardedAndroidTest = 'ca-app-pub-3940256099942544/5224354917';
  static const _rewardedIosTest = 'ca-app-pub-3940256099942544/1712485313';
  static const _appOpenAndroidTest = 'ca-app-pub-3940256099942544/9257395921';
  static const _appOpenIosTest = 'ca-app-pub-3940256099942544/5575463023';

  // ── State ─────────────────────────────────────────────────────────────────

  bool _initialized = false;
  bool _isPremium = false;
  bool _personalizedAds = false;
  bool _rewardedLoading = false;
  bool _appOpenLoading = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;
  DateTime? _lastInterstitialShown;
  DateTime? _lastAppOpenShown;

  void setPremium(bool value) => _isPremium = value;
  void setPersonalizedAds(bool value) => _personalizedAds = value;

  // ── Ad unit ID resolvers ──────────────────────────────────────────────────

  String get bannerAdUnitId =>
      Platform.isAndroid ? _bannerAndroid : _bannerIos;

  String get interstitialAdUnitId =>
      Platform.isAndroid ? _interstitialAndroid : _interstitialIos;

  String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      return _rewardedAndroidProd.isEmpty ? _rewardedAndroidTest : _rewardedAndroidProd;
    }
    return _rewardedIosProd.isEmpty ? _rewardedIosTest : _rewardedIosProd;
  }

  String get _appOpenAdUnitId {
    if (Platform.isAndroid) {
      return _appOpenAndroidProd.isEmpty ? _appOpenAndroidTest : _appOpenAndroidProd;
    }
    return _appOpenIosProd.isEmpty ? _appOpenIosTest : _appOpenIosProd;
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized || kDebugMode) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    _loadInterstitial();
    _loadRewardedAd();
    _loadAppOpenAd();
  }

  // ── Banner / Adaptive Banner ──────────────────────────────────────────────

  BannerAd? createBannerAd({required void Function() onLoaded}) {
    if (_isPremium || !_initialized) return null;
    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: _adRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed: $error');
          ad.dispose();
        },
      ),
    );
    ad.load();
    return ad;
  }

  Future<BannerAd?> createAdaptiveBannerAd({
    required double screenWidth,
    required void Function() onLoaded,
  }) async {
    if (_isPremium || !_initialized) return null;
    final adSize = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
      screenWidth.truncate(),
    );
    if (adSize == null) return null;
    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: _adRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Adaptive banner failed: $error');
          ad.dispose();
        },
      ),
    );
    ad.load();
    return ad;
  }

  // ── Interstitial ──────────────────────────────────────────────────────────

  void _loadInterstitial() {
    if (_isPremium) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: _adRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial load failed: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialIfAllowed() {
    if (_isPremium) return;
    final now = DateTime.now();
    if (_lastInterstitialShown != null &&
        now.difference(_lastInterstitialShown!).inMinutes < 3) {
      return;
    }
    final ad = _interstitialAd;
    if (ad == null) {
      _loadInterstitial();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
      },
    );
    ad.show();
    _lastInterstitialShown = now;
  }

  // ── Rewarded ──────────────────────────────────────────────────────────────

  void _loadRewardedAd() {
    if (_isPremium || _rewardedLoading) return;
    _rewardedLoading = true;
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: _adRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedLoading = false;
          _rewardedAd?.dispose();
          _rewardedAd = ad;
          debugPrint('[AdService] REWARDED LOADED');
        },
        onAdFailedToLoad: (error) {
          _rewardedLoading = false;
          _rewardedAd = null;
          debugPrint('[AdService] REWARDED FAILED: $error');
        },
      ),
    );
  }

  bool get isRewardedReady => _rewardedAd != null && _initialized;

  /// Shows the rewarded ad. [onRewarded] fires only when the user earns the reward.
  Future<void> showRewardedAd({required void Function() onRewarded}) async {
    if (!_initialized) return;
    final ad = _rewardedAd;
    if (ad == null) {
      _loadRewardedAd();
      return;
    }
    _rewardedAd = null;
    bool rewarded = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
        if (rewarded) onRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
        debugPrint('[AdService] REWARDED SHOW FAILED: $error');
      },
    );
    await ad.show(
      onUserEarnedReward: (_, reward) {
        rewarded = true;
        debugPrint('[AdService] REWARDED EARNED: ${reward.type} x${reward.amount}');
      },
    );
  }

  // ── App Open ──────────────────────────────────────────────────────────────

  void _loadAppOpenAd() {
    if (_isPremium || _appOpenLoading) return;
    _appOpenLoading = true;
    AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: _adRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoading = false;
          _appOpenAd?.dispose();
          _appOpenAd = ad;
          debugPrint('[AdService] APP OPEN LOADED');
        },
        onAdFailedToLoad: (error) {
          _appOpenLoading = false;
          _appOpenAd = null;
          debugPrint('[AdService] APP OPEN FAILED: $error');
        },
      ),
    );
  }

  Future<void> showAppOpenIfAvailable() async {
    if (!_initialized || _isPremium) return;
    final now = DateTime.now();
    if (_lastAppOpenShown != null &&
        now.difference(_lastAppOpenShown!) < _appOpenFrequencyLimit) {
      return;
    }
    final ad = _appOpenAd;
    if (ad == null) {
      _loadAppOpenAd();
      return;
    }
    _appOpenAd = null;
    _lastAppOpenShown = now;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadAppOpenAd();
        debugPrint('[AdService] APP OPEN SHOW FAILED: $error');
      },
    );
    await ad.show();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  AdRequest _adRequest() {
    if (_personalizedAds) return const AdRequest();
    return const AdRequest(extras: {'npa': '1'});
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}
