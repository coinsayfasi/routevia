import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';

Future<bool> launchLegalUrl(String primaryUrl) async {
  for (final uri in AppConstants.legalUrlCandidates(primaryUrl)) {
    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (opened) return true;
    } catch (_) {
      // Try next fallback URL.
    }
  }
  return false;
}
