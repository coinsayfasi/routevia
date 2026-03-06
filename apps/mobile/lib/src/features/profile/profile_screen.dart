import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _entitlements = const [];
  List<Map<String, dynamic>> _features = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = ref.read(repositoryProvider);
    try {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
      final p = isLoggedIn ? await repo.getMyProfile() : null;
      final e = isLoggedIn
          ? await repo.getEntitlements()
          : <Map<String, dynamic>>[];
      List<Map<String, dynamic>> f = const [];
      try {
        f = await repo.getPremiumFeatures();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _error = null;
        _profile = p;
        _entitlements = e;
        _features = f;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    final email = Supabase.instance.client.auth.currentUser?.email ?? 'Misafir';
    final premiumActive = _entitlements.any(
      (e) => (e['entitlement_key'] as String?) == 'pro_preview_7d',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
              children: [
                if (!isLoggedIn)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hesabınla giriş yap',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Profil, kaydetme ve premium özellikleri için oturum açman gerekiyor.',
                          style: TextStyle(color: RouteviaColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        FilledButton(
                          onPressed: () => context.go('/auth'),
                          child: const Text('Giriş Ekranına Git'),
                        ),
                      ],
                    ),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Profil verisi yüklenemedi: $_error',
                      style: const TextStyle(color: Color(0xFFB42318)),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B1F3A), Color(0xFF133E75)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile?['display_name']?.toString() ??
                            'Routevia Kullanici',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: premiumActive
                              ? const Color(0xFF14532D)
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          premiumActive ? 'PRO aktif' : 'Ucretsiz plan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _InfoTile(
                  icon: Icons.travel_explore,
                  title: 'Tercih Modu',
                  value: (_profile?['pref_pace'] as String?) ?? 'medium',
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.card_giftcard,
                  title: 'Davet Kodu',
                  value: (_profile?['referral_code'] as String?) ?? '-',
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: RouteviaColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Baglanti Durumu',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Supabase: ${AppConstants.hasSupabaseConfig ? "Ayarli" : "Eksik"}',
                        style: const TextStyle(
                          color: RouteviaColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Oturum: ${isLoggedIn ? "Acik" : "Misafir"}',
                        style: const TextStyle(
                          color: RouteviaColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Premium tablosu: ${_features.isNotEmpty ? "Erisildi" : "Veri yok"}',
                        style: const TextStyle(
                          color: RouteviaColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: RouteviaColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Premium Ozellikler',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      ..._features
                          .where((f) => f['enabled'] == true)
                          .map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '• ${f['feature_key']}'
                                '${f['premium_only'] == true ? ' (Premium)' : ''}',
                                style: const TextStyle(
                                  color: RouteviaColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yenile'),
                ),
                const SizedBox(height: 10),
                if (isLoggedIn)
                  FilledButton.icon(
                    onPressed: _signOut,
                    style: FilledButton.styleFrom(
                      backgroundColor: RouteviaColors.rose,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cikis Yap'),
                  ),
              ],
            ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RouteviaColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: RouteviaColors.navyLight),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: RouteviaColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
