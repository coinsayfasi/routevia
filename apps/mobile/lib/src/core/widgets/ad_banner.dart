import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ad_service.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  int _loadToken = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _initAd();
    }
  }

  Future<void> _initAd() async {
    if (_isLoading || _bannerAd != null) return;

    _isLoading = true;
    _isLoaded = false;
    final token = ++_loadToken;
    final screenWidth = MediaQuery.of(context).size.width;
    BannerAd? pendingAd;
    var loadedBeforeAssignment = false;
    final ad = await AdService().createAdaptiveBannerAd(
      screenWidth: screenWidth,
      onLoaded: () {
        final isCurrentAd =
            mounted &&
            token == _loadToken &&
            pendingAd != null &&
            identical(_bannerAd, pendingAd);
        if (isCurrentAd) {
          setState(() => _isLoaded = true);
        } else {
          loadedBeforeAssignment = true;
        }
      },
    );
    if (!mounted || token != _loadToken) {
      ad?.dispose();
      return;
    }
    _isLoading = false;
    if (ad == null) return;

    pendingAd = ad;
    setState(() {
      _bannerAd = ad;
      _isLoaded = loadedBeforeAssignment;
    });
  }

  @override
  void dispose() {
    _loadToken++;
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null || !_isLoaded) return const SizedBox.shrink();

    // Klavye açılınca reklamı GİZLE ama ağaçtan ÇIKARMA. AdWidget'ı ağaçtan
    // söküp tekrar eklemek google_mobile_ads'te platform view re-attach
    // hatasına ("AdWidget requires Ad to be loaded before...") yol açıyor;
    // Offstage element'i mount tutar, platform view canlı kalır → çökme yok.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hidden = bottomInset > 80;

    return Offstage(
      offstage: hidden,
      child: Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        // Aynı reklam örneği için sabit key → element/platform view kimliği
        // korunur, reklam değişmediği sürece AdWidget yeniden yaratılmaz.
        child: AdWidget(key: ValueKey(_bannerAd), ad: _bannerAd!),
      ),
    );
  }
}
