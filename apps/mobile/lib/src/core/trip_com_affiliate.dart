/// Trip.com affiliate URL generator.
/// Alliance ID and SID are hardcoded public affiliate identifiers (not secrets).
abstract final class TripComAffiliate {
  static const _base = 'https://tr.trip.com';
  static const _aid = '1094387';
  static const _sid = '2209817';
  static const _sub1 = 'ce25e6a055764cd69c32413fa-721552';

  static String _params([String? extra]) {
    final buf = StringBuffer('allianceid=$_aid&SID=$_sid&trip_sub1=$_sub1&locale=tr-TR');
    if (extra != null && extra.isNotEmpty) {
      buf.write('&$extra');
    }
    return buf.toString();
  }

  /// Hotels list for a given city / district.
  /// [location] is the destination name (e.g. "Kapadokya", "Ürgüp").
  static Uri hotels({required String location, String? checkIn, String? checkOut}) {
    final city = Uri.encodeComponent(location.trim());
    final extra = StringBuffer('city=$city');
    if (checkIn != null) extra.write('&checkin=$checkIn');
    if (checkOut != null) extra.write('&checkout=$checkOut');
    return Uri.parse('$_base/hotels/list?${_params(extra.toString())}');
  }

  /// One-way flight search to a destination city.
  static Uri flights({required String toCity, String? fromCity}) {
    final to = Uri.encodeComponent(toCity.trim());
    final extra = StringBuffer('acity=$to');
    if (fromCity != null && fromCity.isNotEmpty) {
      extra.write('&dcity=${Uri.encodeComponent(fromCity.trim())}');
    }
    return Uri.parse('$_base/flights/?${_params(extra.toString())}');
  }

  /// Car rentals in a city.
  static Uri cars({required String location}) {
    final city = Uri.encodeComponent(location.trim());
    return Uri.parse('$_base/cars/?city=$city&${_params()}');
  }

  /// Generic Trip.com homepage with affiliate params.
  static Uri home() => Uri.parse('$_base/?${_params()}');

  /// Best city name to use for Trip.com search:
  /// prefers districtName when it's meaningful, else provinceName.
  static String locationLabel({
    String? provinceName,
    String? districtName,
  }) {
    if (districtName != null &&
        districtName.trim().isNotEmpty &&
        !districtName.toLowerCase().contains('merkez')) {
      return districtName.trim();
    }
    return provinceName?.trim() ?? 'Türkiye';
  }
}
