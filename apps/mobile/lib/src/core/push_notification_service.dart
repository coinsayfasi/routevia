import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles FCM token registration and push notification setup.
/// Call [init] once after Firebase is initialized (in app.dart or main.dart).
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  bool _initialized = false;
  StreamSubscription<String>? _tokenSub;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      // Request permission (iOS)
      if (Platform.isIOS) {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      }

      // Get and register the initial token
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _registerToken(token);
      }

      // Re-register when token refreshes
      _tokenSub = FirebaseMessaging.instance.onTokenRefresh.listen(
        (newToken) => _registerToken(newToken),
        onError: (e) => debugPrint('[Push] token refresh error: $e'),
      );
    } catch (e) {
      debugPrint('[Push] init error: $e');
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return; // Not logged in yet — will retry on next init
      await Supabase.instance.client.functions.invoke(
        'register_push_token',
        body: {
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
      );
      debugPrint('[Push] token registered');
    } catch (e) {
      debugPrint('[Push] token registration failed: $e');
    }
  }

  void dispose() {
    _tokenSub?.cancel();
    _tokenSub = null;
    _initialized = false;
  }
}
