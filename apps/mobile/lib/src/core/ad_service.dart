import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  factory AdService() => _instance;
  AdService._internal();
  static final AdService _instance = AdService._internal();

  // ── Ad Unit IDs ──────────────────────────────────────────────────────────
  // Override via --dart-define for production builds.

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

  String get bannerAdUnitId =>
      Platform.isAndroid ? _bannerAndroid : _bannerIos;

  String get interstitialAdUnitId =>
      Platform.isAndroid ? _interstitialAndroid : _interstitialIos;

  // ── State ────────────────────────────────────────────────────────────────

  bool _initialized = false;
  bool _isPremium = false;
  bool _personalizedAds = false;
  InterstitialAd? _interstitialAd;
  DateTime? _lastInterstitialShown;

  void setPremium(bool value) => _isPremium = value;
  void setPersonalizedAds(bool value) => _personalizedAds = value;

  // ── Init ─────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized || kDebugMode) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    _loadInterstitial();
  }

  // ── Banner ───────────────────────────────────────────────────────────────

  BannerAd? createBannerAd({required void Function() onLoaded}) {
    if (_isPremium) return null;

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

  // ── Interstitial ─────────────────────────────────────────────────────────

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

  // ── Helpers ──────────────────────────────────────────────────────────────

  AdRequest _adRequest() {
    if (_personalizedAds) return const AdRequest();
    return const AdRequest(
      extras: {'npa': '1'},
    );
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
