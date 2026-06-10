class AppConstants {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xfswonqskciufcnsehfc.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhmc3dvbnFza2NpdWZjbnNlaGZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE2OTk1OTMsImV4cCI6MjA4NzI3NTU5M30.OpKiTFeanXn8Do4QjhGkeefpew4cgdydSrYVRVj9dyo',
  );
  static const cacheBox = 'routevia_cache';
  static const useLlm = bool.fromEnvironment('USE_LLM', defaultValue: false);
  static const _legalPrimaryBase = 'https://legal.routevia.tabserve.com.tr';
  static const _legalFallbackBase =
      'https://cdn.jsdelivr.net/gh/coinsayfasi/routevia@main/site';
  static const privacyPolicyUrl = '$_legalPrimaryBase/privacy/';
  static const termsUrl = '$_legalPrimaryBase/terms/';
  static const adsPolicyUrl = '$_legalPrimaryBase/ads/';
  static const businessApplyUrl = '$_legalPrimaryBase/business/';
  static const communityGuidelinesUrl = '$_legalPrimaryBase/community/';
  static const accountDeletionUrl = '$_legalPrimaryBase/account-deletion/';
  static const authCallbackUrl = '$_legalPrimaryBase/auth-callback/';
  static const supportEmail = 'routevia@tabserve.com.tr';
  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.yunusgunes.routevia';
  static const appStoreUrl = String.fromEnvironment(
    'APP_STORE_URL',
    defaultValue: 'https://apps.apple.com/app/routevia/id6761003117',
  );
  static const adminAllowedEmails = String.fromEnvironment(
    'ADMIN_ALLOWED_EMAILS',
    defaultValue: '',
  );

  static List<String> get normalizedAdminAllowedEmails => adminAllowedEmails
      .split(',')
      .map((e) => e.trim().toLowerCase())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static List<Uri> legalUrlCandidates(String primaryUrl) {
    final primary = Uri.parse(primaryUrl);
    final path = switch (primary.path) {
      '/privacy/' ||
      '/privacy' ||
      '/privacy/index.html' => 'privacy/index.html',
      '/terms/' || '/terms' || '/terms/index.html' => 'terms/index.html',
      '/ads/' || '/ads' || '/ads/index.html' => 'ads/index.html',
      '/community/' ||
      '/community' ||
      '/community/index.html' => 'community/index.html',
      '/account-deletion/' ||
      '/account-deletion' ||
      '/account-deletion/index.html' => 'account-deletion/index.html',
      '/business/' ||
      '/business' ||
      '/business/index.html' => 'business/index.html',
      '/auth-callback/' ||
      '/auth-callback' ||
      '/auth-callback/index.html' => 'auth-callback/index.html',
      _ => 'index.html',
    };
    return <Uri>[primary, Uri.parse('$_legalFallbackBase/$path')];
  }
}
