import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../trip_com_affiliate.dart';
import '../hotels_com_affiliate.dart';

/// Affiliate card that shows hotel + flight buttons for a destination.
/// Drop this anywhere you have a city/district name.
class TripComCard extends StatelessWidget {
  const TripComCard({
    super.key,
    required this.provinceName,
    this.districtName,
    this.compact = false,
  });

  final String provinceName;
  final String? districtName;

  /// When true renders a slim horizontal chip row instead of a full card.
  final bool compact;

  String get _location => TripComAffiliate.locationLabel(
        provinceName: provinceName,
        districtName: districtName,
      );

  Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return compact ? _CompactRow(location: _location, open: _open) : _FullCard(location: _location, open: _open);
  }
}

// ── Full card ─────────────────────────────────────────────────────────────────

class _FullCard extends StatelessWidget {
  const _FullCard({required this.location, required this.open});

  final String location;
  final Future<void> Function(Uri) open;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A56DB).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.hotel, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Konakla & Keşfet',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '$location için en iyi fırsatlar',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.network(
                  'https://ak-d.tripcdn.com/images/trip-logo-white.png',
                  height: 22,
                  errorBuilder: (context, error, stack) => const Text(
                    'Trip.com',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.bed_outlined,
                    label: 'Otel Bul',
                    sublabel: location,
                    onTap: () => open(TripComAffiliate.hotels(location: location)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.flight_takeoff_outlined,
                    label: 'Uçuş Bul',
                    sublabel: "$location'a",
                    onTap: () => open(TripComAffiliate.flights(toCity: location)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.directions_car_outlined,
                    label: 'Araç Kirala',
                    sublabel: location,
                    onTap: () => open(TripComAffiliate.cars(location: location)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _HotelsComCompareRow(location: location, open: open),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade300, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Trip.com ile güvenli rezervasyon',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              sublabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Compact chip row ──────────────────────────────────────────────────────────

class _CompactRow extends StatelessWidget {
  const _CompactRow({required this.location, required this.open});

  final String location;
  final Future<void> Function(Uri) open;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const Text(
            'Trip.com',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A56DB),
            ),
          ),
          const SizedBox(width: 8),
          _Chip(
            icon: Icons.bed_outlined,
            label: 'Otel',
            onTap: () => open(TripComAffiliate.hotels(location: location)),
          ),
          const SizedBox(width: 6),
          _Chip(
            icon: Icons.flight_takeoff_outlined,
            label: 'Uçuş',
            onTap: () => open(TripComAffiliate.flights(toCity: location)),
          ),
          const SizedBox(width: 6),
          _Chip(
            icon: Icons.directions_car_outlined,
            label: 'Araç',
            onTap: () => open(TripComAffiliate.cars(location: location)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: const Color(0xFF1A56DB)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A56DB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hotels.com comparison row (inside TripComCard) ────────────────────────────

class _HotelsComCompareRow extends StatelessWidget {
  const _HotelsComCompareRow({required this.location, required this.open});

  final String location;
  final Future<void> Function(Uri) open;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => open(HotelsComAffiliate.hotels(location: location)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF003580),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.hotel_rounded, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Hotels.com\'da da karşılaştır — $location',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              color: Colors.white.withValues(alpha: 0.6),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
