import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';

class ConsentSettingsScreen extends ConsumerStatefulWidget {
  const ConsentSettingsScreen({super.key});

  @override
  ConsumerState<ConsentSettingsScreen> createState() =>
      _ConsentSettingsScreenState();
}

class _ConsentSettingsScreenState extends ConsumerState<ConsentSettingsScreen> {
  bool _loading = true;
  bool _analyticsEnabled = false;
  bool _personalizedAdsEnabled = false;
  bool _policyAccepted = false;
  String? _updatedAt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await ref.read(localCacheProvider).getConsentPreferences();
    if (!mounted) return;
    setState(() {
      _analyticsEnabled = prefs['analytics_enabled'] == true;
      _personalizedAdsEnabled = prefs['personalized_ads_enabled'] == true;
      _policyAccepted = prefs['policy_accepted'] == true;
      _updatedAt = prefs['updated_at'] as String?;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await ref.read(localCacheProvider).setConsentPreferences(
      analyticsEnabled: _analyticsEnabled,
      personalizedAdsEnabled: _personalizedAdsEnabled,
      policyAccepted: _policyAccepted,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gizlilik tercihleriniz kaydedildi.')),
    );
    await _load();
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$day.$month.$year $hour:$min';
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Gizlilik ve Veri Tercihleri')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 16, color: Color(0xFF0C4A6E)),
                    SizedBox(width: 6),
                    Text(
                      'Verileriniz sizin kontrolünüzde',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF0C4A6E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Aşağıdaki tercihleri istediğiniz zaman değiştirebilirsiniz. '
                  'Temel hizmet işlevleri için veri işleme her zaman aktiftir.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: Color(0xFF0C4A6E),
                  ),
                ),
                if (_updatedAt != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 12, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        'Son güncelleme: ${_formatDate(_updatedAt)}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Policy acceptance
          _ConsentTile(
            value: _policyAccepted,
            title: 'Gizlilik politikasını ve kullanım şartlarını okudum',
            subtitle:
                'Gizlilik Politikası, Kullanım Şartları ve Sponsorlu İçerik kurallarını okudum ve kabul ediyorum.',
            icon: Icons.description_outlined,
            onChanged: (v) => setState(() => _policyAccepted = v),
          ),
          const SizedBox(height: 10),

          // Analytics
          _ConsentTile(
            value: _analyticsEnabled,
            title: 'Kullanım analitiği',
            subtitle:
                'Uygulama kalitesini artırmak için anonim kullanım verileri toplanabilir. '
                'Kimliğiniz bu verilerle ilişkilendirilmez.',
            icon: Icons.bar_chart_outlined,
            onChanged: (v) => setState(() => _analyticsEnabled = v),
          ),
          const SizedBox(height: 10),

          // Personalized ads
          _ConsentTile(
            value: _personalizedAdsEnabled,
            title: 'Kişiselleştirilmiş sponsorlu içerik',
            subtitle:
                'İlgi alanlarınıza göre hedeflenmiş sponsorlu önerilerin gösterilmesine izin veriyorum. '
                'Kapalıyken yalnızca konum/kategori bazlı bağlamsal içerik gösterilir.',
            icon: Icons.ads_click_outlined,
            onChanged: (v) => setState(() => _personalizedAdsEnabled = v),
          ),
          const SizedBox(height: 24),

          FilledButton(
            onPressed: _save,
            child: const Text('Tercihleri Kaydet'),
          ),
          const SizedBox(height: 10),

          // Link to full privacy policy
          OutlinedButton.icon(
            onPressed: () => context.push('/legal?doc=privacy'),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Gizlilik Politikasını Görüntüle'),
          ),
        ],
      ),
    );
  }
}

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onChanged,
  });

  final bool value;
  final String title;
  final String subtitle;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        title: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF475569)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
      ),
    );
  }
}
