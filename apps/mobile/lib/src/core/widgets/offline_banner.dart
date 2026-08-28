import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Uygulama genelinde internet bağlantısı yoksa ekranın üstünde gösterilen
/// ince banner. Tam ekrana basmaz, kullanıcı akışını bozmaz.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  bool _offline = false;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  late final AnimationController _animCtrl;
  late final Animation<double> _heightAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);

    // İlk kontrol
    Connectivity().checkConnectivity().then(_handleResult);

    // Gerçek zamanlı izleme
    _sub = Connectivity().onConnectivityChanged.listen(_handleResult);
  }

  void _handleResult(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    if (!mounted) return;
    final wasOffline = _offline;
    setState(() => _offline = !hasConnection);
    if (_offline && !wasOffline) {
      _animCtrl.forward();
    } else if (!_offline && wasOffline) {
      _animCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizeTransition(
          sizeFactor: _heightAnim,
          alignment: const Alignment(-1.0, -1.0),
          child: Material(
            color: const Color(0xFFF59E0B),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'İnternet bağlantısı yok',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
