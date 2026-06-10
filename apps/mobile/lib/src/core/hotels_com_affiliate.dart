/// Hotels.com affiliate URL generator via CJ (Commission Junction).
/// Publisher: Aycan Merve Gunes (7928432) — Alliance link ID: 13829415.
/// The CJ tracking URL is a public affiliate identifier, not a secret.
abstract final class HotelsComAffiliate {
  static const _cjBase = 'https://www.kqzyfj.com/click-101726669-13829415';

  /// Hotel search for a given city via CJ deep link.
  /// Falls back to Hotels.com ME homepage when [location] is empty.
  static Uri hotels({required String location}) {
    final city = location.trim();
    if (city.isEmpty) return Uri.parse(_cjBase);
    final deep = Uri.encodeComponent(
      'https://www.hotels.com/search?destination=$city',
    );
    return Uri.parse('$_cjBase?url=$deep');
  }

  /// Hotels.com ME homepage with affiliate tracking.
  static Uri home() => Uri.parse(_cjBase);
}
