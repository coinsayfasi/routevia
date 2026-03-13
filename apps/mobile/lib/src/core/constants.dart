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
  static const privacyPolicyUrl =
      'https://legal.routevia.tabserve.com.tr/privacy/';
  static const termsUrl = 'https://legal.routevia.tabserve.com.tr/terms/';
  static const adsPolicyUrl = 'https://legal.routevia.tabserve.com.tr/ads/';
  static const businessApplyUrl =
      'https://legal.routevia.tabserve.com.tr/business/';
  static const communityGuidelinesUrl =
      'https://legal.routevia.tabserve.com.tr/community/';
  static const accountDeletionUrl =
      'https://legal.routevia.tabserve.com.tr/account-deletion/';
  static const authCallbackUrl =
      'https://legal.routevia.tabserve.com.tr/auth-callback/';
  static const _legalFallbackBase =
      'https://cdn.jsdelivr.net/gh/coinsayfasi/routevia@main/site';
  static const supportEmail = 'routevia@tabserve.com.tr';
  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.yunusgunes.routevia';
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
      '/privacy/' || '/privacy' => 'privacy/index.html',
      '/terms/' || '/terms' => 'terms/index.html',
      '/ads/' || '/ads' => 'ads/index.html',
      '/community/' || '/community' => 'community/index.html',
      '/account-deletion/' || '/account-deletion' =>
        'account-deletion/index.html',
      '/business/' || '/business' => 'business/index.html',
      _ => 'index.html',
    };
    return <Uri>[
      primary,
      Uri.parse('$_legalFallbackBase/$path'),
    ];
  }
}
