import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

class FirebaseRuntime {
  FirebaseRuntime._();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    try {
      await Firebase.initializeApp();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _initialized = true;
    } catch (error, stack) {
      debugPrint('[firebase] init skipped: $error');
      debugPrintStack(stackTrace: stack);
      _initialized = false;
    }
  }

  static Future<void> registerPushIfAllowed() async {
    if (!_initialized || kIsWeb) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('allow_notifications')
          .eq('id', user.id)
          .maybeSingle();
      if (profile != null && profile['allow_notifications'] == false) return;

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: Platform.isIOS,
      );
      final authorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!authorized) return;

      Future<void> upsertToken(String token) async {
        final accessToken =
            Supabase.instance.client.auth.currentSession?.accessToken;
        if (accessToken == null || accessToken.isEmpty) return;
        await Supabase.instance.client.functions.invoke(
          'register_push_token',
          headers: {'Authorization': 'Bearer $accessToken'},
          body: {
            'token': token,
            'platform': Platform.isIOS ? 'ios' : 'android',
          },
        );
      }

      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await upsertToken(token);
      }
      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        if (token.isEmpty) return;
        try {
          await upsertToken(token);
        } catch (_) {}
      });
    } catch (error) {
      debugPrint('[firebase] push registration skipped: $error');
    }
  }

  static Future<void> recordError(
    Object error,
    StackTrace stack, {
    bool fatal = false,
  }) async {
    if (!_initialized) return;
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        fatal: fatal,
      );
    } catch (_) {}
  }
}
