import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

/// Singleton CacheManager with a 15-second HTTP timeout.
///
/// iOS fix: NSURLSession has no default timeout, so image requests hang
/// forever without this. Android's HttpURLConnection has implicit ~30-60s
/// timeouts which is why images work there but not on iOS.
class AppCacheManager {
  AppCacheManager._();

  static const _key = 'routeviaImages';

  static final CacheManager instance = CacheManager(
    Config(
      _key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 300,
      fileService: HttpFileService(httpClient: _TimeoutHttpClient()),
    ),
  );
}

class _TimeoutHttpClient extends http.BaseClient {
  final _inner = http.Client();
  static const _timeout = Duration(seconds: 15);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _inner.send(request).timeout(_timeout);
}
