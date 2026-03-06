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

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
