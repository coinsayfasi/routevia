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
    if (_initialized) {
      await refreshRegistration();
      return;
    }
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('allow_notifications')
            .eq('id', user.id)
            .maybeSingle();
        if (profile != null && profile['allow_notifications'] == false) {
          await FirebaseMessaging.instance.unsubscribeFromTopic('blog');
          _initialized = true;
          return;
        }
      }

      // Request permission (iOS + Android 13+)
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        _initialized = true;
        return;
      }

      // Blog/duyuru bildirimleri: token oluştur → topic'e abone ol → kayıt et
      // sıralaması refreshRegistration() içinde kontrollü retry ile yapılıyor.
      // (İlk kurulumda token hazır olmadan subscribe SERVICE_NOT_AVAILABLE
      // atıp init'i düşürmesin diye erken subscribe kaldırıldı.)
      await refreshRegistration();

      // Re-register when token refreshes
      _tokenSub = FirebaseMessaging.instance.onTokenRefresh.listen((
        newToken,
      ) async {
        try {
          await FirebaseMessaging.instance.subscribeToTopic('blog');
          await _registerToken(newToken);
        } catch (e) {
          debugPrint('[Push] token refresh registration error: $e');
        }
      }, onError: (e) => debugPrint('[Push] token refresh error: $e'));
      _initialized = true;
    } catch (e) {
      debugPrint('[Push] init error: $e');
    }
  }

  Future<void> refreshRegistration() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('allow_notifications')
            .eq('id', user.id)
            .maybeSingle();
        if (profile != null && profile['allow_notifications'] == false) {
          await FirebaseMessaging.instance.unsubscribeFromTopic('blog');
          return;
        }
      } catch (e) {
        debugPrint(
          '[Push] preference check failed, registration continues: $e',
        );
      }
    }

    const waits = <Duration>[
      Duration.zero,
      Duration(seconds: 2),
      Duration(seconds: 8),
    ];
    for (var attempt = 0; attempt < waits.length; attempt++) {
      if (waits[attempt] != Duration.zero) {
        await Future<void>.delayed(waits[attempt]);
      }
      try {
        // İlk kurulumda topic aboneliğinden önce FCM installation/token
        // oluşturulmalı; aksi halde Android SERVICE_NOT_AVAILABLE döndürebilir.
        final token = await FirebaseMessaging.instance.getToken();
        if (token == null || token.isEmpty) {
          throw StateError('FCM token is empty');
        }
        await FirebaseMessaging.instance.subscribeToTopic('blog');
        await _registerToken(token);
        debugPrint('[Push] blog topic subscribed');
        return;
      } catch (e) {
        debugPrint(
          '[Push] registration attempt ${attempt + 1}/${waits.length} failed: $e',
        );
      }
    }
  }

  Future<void> setEnabled(bool enabled) async {
    final messaging = FirebaseMessaging.instance;
    if (!enabled) {
      await messaging.unsubscribeFromTopic('blog');
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('user_push_tokens')
            .update({'enabled': false})
            .eq('user_id', user.id);
      }
      return;
    }

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;
    await refreshRegistration();
  }

  Future<void> _registerToken(String token) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return; // Not logged in yet — will retry on next init
      await Supabase.instance.client.functions.invoke(
        'register_push_token',
        body: {'token': token, 'platform': Platform.isIOS ? 'ios' : 'android'},
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
