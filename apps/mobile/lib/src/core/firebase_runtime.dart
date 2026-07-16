import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

/// Returns true if [error] is a transient network/IO error that should NOT
/// be treated as a fatal crash (tile aborts, socket resets, TLS handshakes).
bool _isNetworkError(Object error) {
  final msg = error.toString().toLowerCase();
  return error is SocketException ||
      error is HttpException ||
      msg.contains('clientexception') ||
      msg.contains('connection abort') ||
      msg.contains('connection reset') ||
      msg.contains('broken pipe') ||
      msg.contains('connection closed') ||
      msg.contains('handshakeexception') ||
      msg.contains('tlsexception') ||
      msg.contains('software caused') ||
      msg.contains('socketexception') ||
      msg.contains('network is unreachable') ||
      msg.contains('failed host lookup') ||
      msg.contains('connection timed out') ||
      msg.contains('invalid statuscode') ||
      msg.contains('tile.openstreetmap.org');
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
        if (_isNetworkError(details.exception)) {
          FirebaseCrashlytics.instance.recordFlutterError(
            details,
            fatal: false,
          );
        } else {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        }
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        final fatal = !_isNetworkError(error);
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
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
