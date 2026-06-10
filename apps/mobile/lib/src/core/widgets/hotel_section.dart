import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../trip_com_affiliate.dart';

// ── Curated hotel data per province slug ─────────────────────────────────────

class _Hotel {
  const _Hotel({
    required this.name,
    required this.rating,
    required this.score,
    required this.district,
    required this.priceMin,
    required this.priceMax,
    required this.stars,
    required this.imageColor,
    required this.imageIcon,
  });

  final String name;
  final double rating; // 4.5
  final String score; // "9.2"
  final String district;
  final int priceMin;
  final int priceMax;
  final int stars;
  final Color imageColor;
  final IconData imageIcon;
}

const _hotels = <String, List<_Hotel>>{
  'istanbul': [
    _Hotel(name: 'The Marmara Pera', rating: 4.8, score: '9.4', district: 'Beyoğlu', priceMin: 3200, priceMax: 5800, stars: 5, imageColor: Color(0xFF1A3A5C), imageIcon: Icons.location_city),
    _Hotel(name: 'Sura Hagia Sophia', rating: 4.7, score: '9.1', district: 'Sultanahmet', priceMin: 2800, priceMax: 4200, stars: 5, imageColor: Color(0xFF2C4A7C), imageIcon: Icons.museum),
    _Hotel(name: 'Vault Karaköy', rating: 4.6, score: '8.9', district: 'Karaköy', priceMin: 2100, priceMax: 3500, stars: 4, imageColor: Color(0xFF0D2137), imageIcon: Icons.hotel),
  ],
  'antalya': [
    _Hotel(name: 'Rixos Downtown', rating: 4.9, score: '9.6', district: 'Muratpaşa', priceMin: 4500, priceMax: 8000, stars: 5, imageColor: Color(0xFF1565A0), imageIcon: Icons.beach_access),
    _Hotel(name: 'Calista Luxury Resort', rating: 4.8, score: '9.4', district: 'Belek', priceMin: 6000, priceMax: 12000, stars: 5, imageColor: Color(0xFF0288D1), imageIcon: Icons.pool),
    _Hotel(name: 'Villa Romana Hotel', rating: 4.5, score: '9.0', district: 'Kaleiçi', priceMin: 1800, priceMax: 3200, stars: 4, imageColor: Color(0xFF0277BD), imageIcon: Icons.villa),
  ],
  'izmir': [
    _Hotel(name: 'Mövenpick İzmir', rating: 4.8, score: '9.3', district: 'Konak', priceMin: 2800, priceMax: 4800, stars: 5, imageColor: Color(0xFF00695C), imageIcon: Icons.business),
    _Hotel(name: 'Kordon Hotel', rating: 4.6, score: '9.0', district: 'Alsancak', priceMin: 2200, priceMax: 3800, stars: 4, imageColor: Color(0xFF00796B), imageIcon: Icons.hotel),
    _Hotel(name: 'Alacati Tas Hotel', rating: 4.9, score: '9.7', district: 'Alaçatı', priceMin: 3500, priceMax: 6500, stars: 5, imageColor: Color(0xFF004D40), imageIcon: Icons.villa),
  ],
  'nevsehir': [
    _Hotel(name: 'Museum Hotel Cappadocia', rating: 4.9, score: '9.8', district: 'Ürgüp', priceMin: 8000, priceMax: 15000, stars: 5, imageColor: Color(0xFF4A148C), imageIcon: Icons.landscape),
    _Hotel(name: 'Yunak Evleri', rating: 4.8, score: '9.5', district: 'Ürgüp', priceMin: 5000, priceMax: 9000, stars: 5, imageColor: Color(0xFF6A1B9A), imageIcon: Icons.villa),
    _Hotel(name: 'Argos In Cappadocia', rating: 4.9, score: '9.6', district: 'Uçhisar', priceMin: 6500, priceMax: 12000, stars: 5, imageColor: Color(0xFF7B1FA2), imageIcon: Icons.hotel),
  ],
  'mugla': [
    _Hotel(name: 'Mandarin Oriental Bodrum', rating: 4.9, score: '9.7', district: 'Bodrum', priceMin: 12000, priceMax: 25000, stars: 5, imageColor: Color(0xFF006064), imageIcon: Icons.beach_access),
    _Hotel(name: 'Hillside Beach Club', rating: 4.8, score: '9.4', district: 'Fethiye', priceMin: 5000, priceMax: 10000, stars: 5, imageColor: Color(0xFF00838F), imageIcon: Icons.pool),
    _Hotel(name: 'Lykia World Ölüdeniz', rating: 4.7, score: '9.2', district: 'Ölüdeniz', priceMin: 4000, priceMax: 8000, stars: 5, imageColor: Color(0xFF0097A7), imageIcon: Icons.villa),
  ],
  'trabzon': [
    _Hotel(name: 'Zorlu Grand Hotel', rating: 4.7, score: '9.1', district: 'Ortahisar', priceMin: 2200, priceMax: 4000, stars: 5, imageColor: Color(0xFF1B5E20), imageIcon: Icons.business),
    _Hotel(name: 'Novotel Trabzon', rating: 4.5, score: '8.8', district: 'Ortahisar', priceMin: 1800, priceMax: 3200, stars: 4, imageColor: Color(0xFF2E7D32), imageIcon: Icons.hotel),
    _Hotel(name: 'Wyndham Trabzon', rating: 4.6, score: '9.0', district: 'Ortahisar', priceMin: 2000, priceMax: 3800, stars: 4, imageColor: Color(0xFF388E3C), imageIcon: Icons.hotel),
  ],
  'mardin': [
    _Hotel(name: 'Reyhani Kasrı', rating: 4.9, score: '9.8', district: 'Merkez', priceMin: 4500, priceMax: 8000, stars: 5, imageColor: Color(0xFF4E342E), imageIcon: Icons.villa),
    _Hotel(name: 'Erdoba Evleri', rating: 4.8, score: '9.5', district: 'Merkez', priceMin: 3500, priceMax: 6000, stars: 5, imageColor: Color(0xFF5D4037), imageIcon: Icons.home),
    _Hotel(name: 'Zinciriye Hotel', rating: 4.7, score: '9.2', district: 'Merkez', priceMin: 2800, priceMax: 5000, stars: 4, imageColor: Color(0xFF6D4C41), imageIcon: Icons.hotel),
  ],
  'ankara': [
    _Hotel(name: 'Sheraton Ankara', rating: 4.7, score: '9.2', district: 'Çankaya', priceMin: 3000, priceMax: 5500, stars: 5, imageColor: Color(0xFFB71C1C), imageIcon: Icons.business),
    _Hotel(name: 'JW Marriott Ankara', rating: 4.8, score: '9.4', district: 'Çankaya', priceMin: 3500, priceMax: 6000, stars: 5, imageColor: Color(0xFFC62828), imageIcon: Icons.hotel),
    _Hotel(name: 'Crowne Plaza Ankara', rating: 4.6, score: '9.0', district: 'Yenimahalle', priceMin: 2500, priceMax: 4500, stars: 5, imageColor: Color(0xFFD32F2F), imageIcon: Icons.hotel),
  ],
  'bursa': [
    _Hotel(name: 'Almira Hotel Bursa', rating: 4.7, score: '9.2', district: 'Osmangazi', priceMin: 2200, priceMax: 4000, stars: 5, imageColor: Color(0xFF1A237E), imageIcon: Icons.business),
    _Hotel(name: 'Kervansaray Bursa', rating: 4.6, score: '8.9', district: 'Osmangazi', priceMin: 1800, priceMax: 3200, stars: 4, imageColor: Color(0xFF283593), imageIcon: Icons.hotel),
    _Hotel(name: 'Kitapçı Konağı', rating: 4.8, score: '9.4', district: 'Osmangazi', priceMin: 2800, priceMax: 4800, stars: 4, imageColor: Color(0xFF303F9F), imageIcon: Icons.villa),
  ],
  'gaziantep': [
    _Hotel(name: 'Sirehan Hotel', rating: 4.8, score: '9.5', district: 'Şahinbey', priceMin: 3000, priceMax: 5500, stars: 5, imageColor: Color(0xFFE65100), imageIcon: Icons.villa),
    _Hotel(name: 'Tilmen Hotel', rating: 4.6, score: '9.0', district: 'Şahinbey', priceMin: 2200, priceMax: 4000, stars: 4, imageColor: Color(0xFFF4511E), imageIcon: Icons.hotel),
    _Hotel(name: 'Hampton by Hilton', rating: 4.7, score: '9.1', district: 'Şehitkamil', priceMin: 2500, priceMax: 4500, stars: 4, imageColor: Color(0xFFBF360C), imageIcon: Icons.hotel),
  ],
};

// ── Filter categories ─────────────────────────────────────────────────────────

enum _Category { all, budget, luxury, boutique }

extension _CategoryExt on _Category {
  String get label => switch (this) {
        _Category.all => 'Tümü',
        _Category.budget => 'Uygun Fiyat',
        _Category.luxury => 'Lüks',
        _Category.boutique => 'Butik',
      };

  bool matches(_Hotel hotel) => switch (this) {
        _Category.all => true,
        _Category.budget => hotel.priceMin < 2500,
        _Category.luxury => hotel.stars == 5 && hotel.priceMin >= 4000,
        _Category.boutique => hotel.imageIcon == Icons.villa || hotel.imageIcon == Icons.home,
      };
}

// ── Main widget ────────────────────────────────────────────────────────────────

class HotelSection extends StatefulWidget {
  const HotelSection({
    super.key,
    required this.provinceName,
    required this.provinceSlug,
    this.districtName,
  });

  final String provinceName;
  final String provinceSlug;
  final String? districtName;

  @override
  State<HotelSection> createState() => _HotelSectionState();
}

class _HotelSectionState extends State<HotelSection> {
  _Category _category = _Category.all;

  String get _location => TripComAffiliate.locationLabel(
        provinceName: widget.provinceName,
        districtName: widget.districtName,
      );

  List<_Hotel> get _curatedHotels =>
      _hotels[widget.provinceSlug] ?? _hotels['istanbul']!;

  Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildPlatformChips(),
        const SizedBox(height: 14),
        _buildHotelCards(),
        const SizedBox(height: 16),
        _buildTrustBadges(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  '$_location\'de Konaklama',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A56DB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Yeni',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _open(TripComAffiliate.hotels(location: _location)),
            child: const Text(
              'Tümünü Gör',
              style: TextStyle(
                color: Color(0xFF1A56DB),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformChips() {
    const chipColor = Color(0xFF1A56DB);
    return SizedBox(
      height: 36,
      child: ListView(
        padding: const EdgeInsets.only(left: 16),
        scrollDirection: Axis.horizontal,
        children: _Category.values.map((cat) {
          final selected = _category == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _category = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? chipColor : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected ? chipColor : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: chipColor.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Text(
                  cat.label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHotelCards() {
    final hotels = _curatedHotels.where(_category.matches).toList();
    return SizedBox(
      height: 290,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 16, right: 8),
        scrollDirection: Axis.horizontal,
        itemCount: hotels.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == hotels.length) return _buildSeeMoreCard();
          return _HotelCard(
            hotel: hotels[index],
            location: _location,
            onTap: () => _open(TripComAffiliate.hotels(location: _location)),
          );
        },
      ),
    );
  }

  Widget _buildSeeMoreCard() {
    return GestureDetector(
      onTap: () => _open(TripComAffiliate.hotels(location: _location)),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A56DB), Color(0xFF1E3A8A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tüm Otelleri\nGör',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Trip.com',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadges() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _TrustBadge(
            icon: Icons.verified_user_outlined,
            label: 'Güvenli\nRezarvasyon',
            sublabel: 'Partner siteler\nüzerinden',
          ),
          const SizedBox(width: 8),
          _TrustBadge(
            icon: Icons.sell_outlined,
            label: 'En İyi\nFiyatlar',
            sublabel: 'Karşılaştır,\nseç, kazan',
          ),
          const SizedBox(width: 8),
          _TrustBadge(
            icon: Icons.percent_outlined,
            label: 'Özel\nFırsatlar',
            sublabel: 'Sadece\nRoutevia\'da',
          ),
        ],
      ),
    );
  }
}

// ── Hotel card ────────────────────────────────────────────────────────────────

class _HotelCard extends StatelessWidget {
  const _HotelCard({
    required this.hotel,
    required this.location,
    required this.onTap,
  });

  final _Hotel hotel;
  final String location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Stack(
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: hotel.imageColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Center(
                    child: Icon(hotel.imageIcon, color: Colors.white.withValues(alpha: 0.35), size: 52),
                  ),
                ),
                // Trip.com badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Trip.com',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // Stars
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        hotel.stars.clamp(0, 5),
                        (_) => const Icon(Icons.star, color: Colors.amber, size: 9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF166534),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            hotel.score,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < hotel.rating.floor() ? Icons.star_rounded : Icons.star_border_rounded,
                              color: const Color(0xFFFBBF24),
                              size: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 11, color: Color(0xFF64748B)),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${hotel.district}, $location',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${hotel.priceMin.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} TL',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const TextSpan(
                                  text: ' / gece',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A56DB),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Fiyatları Gör',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Trust badge ───────────────────────────────────────────────────────────────

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.icon, required this.label, required this.sublabel});

  final IconData icon;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1A56DB)),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Color(0xFF0F172A),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
