import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/error_utils.dart';
import '../../core/i18n.dart';
import '../../core/theme.dart';
import '../../data/local_cache.dart';
import '../../data/providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _loading = true;
  bool _savingPace = false;
  String? _error;
  Map<String, dynamic>? _profile;
  Map<String, String> _visitedProvinces = const {};

  @override
  void initState() {
    super.initState();
    _load();
    _loadVisitedProvinces();
  }

  Future<void> _loadVisitedProvinces() async {
    final visited = await LocalCache().getVisitedProvinces();
    if (mounted) setState(() => _visitedProvinces = visited);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = ref.read(repositoryProvider);
    try {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
      final p = isLoggedIn ? await repo.getMyProfile() : null;
      if (!mounted) return;
      setState(() {
        _error = null;
        _profile = p;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    context.go('/auth');
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('Hesabımı Sil', 'Delete Account')),
        content: Text(ctx.tr(
          'Hesabın ve tüm verilerin kalıcı olarak silinecek. Bu işlem geri alınamaz.',
          'Your account and all data will be permanently deleted. This action cannot be undone.',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.tr('Vazgeç', 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(ctx.tr('Evet, Sil', 'Yes, delete')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await ref.read(repositoryProvider).deleteAccount();
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      context.go('/auth');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updatePace(String pace) async {
    if (_savingPace) return;
    final normalized = pace.trim().toLowerCase();
    setState(() => _savingPace = true);
    try {
      await ref
          .read(repositoryProvider)
          .updateProfilePreferences(prefPace: normalized);
      if (!mounted) return;
      setState(() {
        // Preserve all existing fields; only overwrite pref_pace
        _profile = _profile != null ? {..._profile!, 'pref_pace': normalized} : {'pref_pace': normalized};
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('Tercih modu güncellendi.', 'Preference updated.'))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    } finally {
      if (mounted) setState(() => _savingPace = false);
    }
  }

  String _paceLabel(String value, bool isEnglish) {
    switch (value.trim().toLowerCase()) {
      case 'slow':
        return isEnglish ? 'Slow' : 'Yavaş';
      case 'fast':
        return isEnglish ? 'Fast' : 'Hızlı';
      default:
        return isEnglish ? 'Medium' : 'Orta';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    final email = Supabase.instance.client.auth.currentUser?.email ?? context.tr('Misafir', 'Guest');
    final premiumState = ref.watch(premiumStateProvider).valueOrNull;
    final premiumActive = premiumState?.isPro ?? false;
    final premiumExpiry = premiumState?.expiresAt;

    return Scaffold(
      appBar: AppBar(title: Text(isEnglish ? 'Profile' : 'Profil')),
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
                        Text(
                          isEnglish
                              ? 'Sign in to your account'
                              : 'Hesabınla giriş yap',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isEnglish
                              ? 'You need to sign in for profile, saved items, and premium features.'
                              : 'Profil, kaydetme ve premium özellikleri için oturum açman gerekiyor.',
                          style: TextStyle(color: RouteviaColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        FilledButton(
                          onPressed: () => context.go('/auth'),
                          child: Text(
                            isEnglish ? 'Go to Sign In' : 'Giriş Ekranına Git',
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFB42318),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Color(0xFFB42318),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _load,
                            child: Text(context.tr('Tekrar Dene', 'Try Again')),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_visitedProvinces.isNotEmpty) ...[
                  _CityDiscoveryCard(
                    visitedProvinces: _visitedProvinces,
                    isEnglish: isEnglish,
                  ),
                  const SizedBox(height: 12),
                ],
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
                            context.tr('Routevia Kullanıcı', 'Routevia User'),
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
                      Row(
                        children: [
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
                              premiumActive ? context.tr('PRO aktif', 'PRO active') : context.tr('Ücretsiz plan', 'Free plan'),
                              // keep short labels in both locales
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (premiumActive && premiumExpiry != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${premiumExpiry.day}.${premiumExpiry.month}.${premiumExpiry.year}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: RouteviaColors.border),
                  ),
                  tileColor: Colors.white,
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: const Text('Routevia Pro'),
                  subtitle: Text(
                    premiumActive
                        ? (isEnglish
                              ? 'Your premium access is active'
                              : 'Premium erisimin aktif')
                        : (isEnglish
                              ? 'Unlimited plans, trend map, and more'
                              : 'Sinirsiz plan, trend harita ve daha fazlasi'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/premium'),
                ),
                if (premiumActive) ...[
                  const SizedBox(height: 10),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: RouteviaColors.border),
                    ),
                    tileColor: Colors.white,
                    leading: const Icon(Icons.manage_accounts_outlined),
                    title: Text(
                      isEnglish ? 'Manage Subscription' : 'Aboneligi Yonet',
                    ),
                    subtitle: Text(
                      isEnglish
                          ? 'Manage your subscription via the store'
                          : 'Play Store uzerinden aboneligini yonet',
                    ),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () {
                      final uri = Platform.isIOS
                          ? Uri.parse(
                              'https://apps.apple.com/account/subscriptions',
                            )
                          : Uri.parse(
                              'https://play.google.com/store/account/subscriptions',
                            );
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                  ),
                ],
                const SizedBox(height: 10),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: RouteviaColors.border),
                  ),
                  tileColor: Colors.white,
                  leading: const Icon(Icons.bar_chart_outlined),
                  title: Text(
                    isEnglish ? 'Traveler Stats' : 'Gezgin Istatistikleri',
                  ),
                  subtitle: Text(
                    isEnglish
                        ? 'Check-ins, favorites, reviews, and more'
                        : 'Check-in, favori, yorum ve daha fazlasi',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/stats'),
                ),
                const SizedBox(height: 10),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: RouteviaColors.border),
                  ),
                  tileColor: Colors.white,
                  leading: const Icon(Icons.bookmarks_outlined),
                  title: Text(
                    isEnglish ? 'Saved Places' : 'Favoriler ve Check-inler',
                  ),
                  subtitle: Text(
                    isEnglish
                        ? 'Your favorites and visited places in one list'
                        : 'Favorilerin ve gittigin yerler tek listede',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: isLoggedIn
                      ? () => context.push('/saved-places')
                      : null,
                ),
                const SizedBox(height: 10),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: RouteviaColors.border),
                  ),
                  tileColor: Colors.white,
                  leading: const Icon(Icons.collections_bookmark_outlined),
                  title: Text(
                    isEnglish
                        ? 'My Reviews and Photos'
                        : 'Yorumlarım ve Fotoğraflarım',
                  ),
                  subtitle: Text(
                    isEnglish
                        ? 'See your submitted content and moderation status'
                        : 'Gönderdiğin içerikleri ve moderasyon durumlarını gör',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: isLoggedIn ? () => context.push('/my-content') : null,
                ),
                const SizedBox(height: 10),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: RouteviaColors.border),
                  ),
                  tileColor: Colors.white,
                  leading: const Icon(Icons.language_outlined),
                  title: Text(isEnglish ? 'Language' : 'Dil'),
                  subtitle: Text(switch (ref
                      .watch(appLocaleProvider)
                      ?.languageCode) {
                    'en' => 'English',
                    'tr' => 'Turkce',
                    _ =>
                      isEnglish
                          ? 'Use system language'
                          : 'Sistem dilini kullan',
                  }),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value:
                          ref.watch(appLocaleProvider)?.languageCode ??
                          'system',
                      items: [
                        DropdownMenuItem(
                          value: 'system',
                          child: Text(isEnglish ? 'System' : 'Sistem'),
                        ),
                        const DropdownMenuItem(
                          value: 'tr',
                          child: Text('Turkce'),
                        ),
                        const DropdownMenuItem(
                          value: 'en',
                          child: Text('English'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        ref
                            .read(appLocaleProvider.notifier)
                            .setLanguageCode(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: RouteviaColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.travel_explore,
                        color: RouteviaColors.navyLight,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEnglish ? 'Travel Pace' : 'Tercih Modu',
                              style: const TextStyle(
                                color: RouteviaColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEnglish
                                  ? 'Affects planning density on future routes'
                                  : 'Yeni rotalarda plan yogunlugunu belirler',
                              style: const TextStyle(
                                color: RouteviaColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              ((_profile?['pref_pace'] as String?) ?? 'medium')
                                  .toLowerCase(),
                          items: [
                            DropdownMenuItem(
                              value: 'slow',
                              child: Text(_paceLabel('slow', isEnglish)),
                            ),
                            DropdownMenuItem(
                              value: 'medium',
                              child: Text(_paceLabel('medium', isEnglish)),
                            ),
                            DropdownMenuItem(
                              value: 'fast',
                              child: Text(_paceLabel('fast', isEnglish)),
                            ),
                          ],
                          onChanged: !isLoggedIn || _savingPace
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  _updatePace(value);
                                },
                        ),
                      ),
                      if (_savingPace) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
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
                      Text(
                        isEnglish
                            ? 'Policies and Legal'
                            : 'Politikalar ve Yasal',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      _ActionRow(
                        icon: Icons.privacy_tip_outlined,
                        title: isEnglish
                            ? 'Privacy Policy'
                            : 'Gizlilik Politikasi',
                        onTap: () => context.push('/legal?doc=privacy'),
                      ),
                      _ActionRow(
                        icon: Icons.description_outlined,
                        title: isEnglish ? 'Terms of Use' : 'Kullanim Sartlari',
                        onTap: () => context.push('/legal?doc=terms'),
                      ),
                      _ActionRow(
                        icon: Icons.campaign_outlined,
                        title: isEnglish
                            ? 'Ads and Sponsored Content'
                            : 'Reklam ve Sponsorlu Icerik',
                        onTap: () => context.push('/legal?doc=ads'),
                      ),
                      _ActionRow(
                        icon: Icons.groups_outlined,
                        title: isEnglish
                            ? 'Community Rules'
                            : 'Topluluk Kurallari',
                        onTap: () => context.push('/legal?doc=community'),
                      ),
                      _ActionRow(
                        icon: Icons.delete_outline,
                        title: isEnglish ? 'Account Deletion' : 'Hesap Silme',
                        onTap: () =>
                            context.push('/legal?doc=account-deletion'),
                      ),
                      _ActionRow(
                        icon: Icons.shield_outlined,
                        title: isEnglish
                            ? 'Consent and Tracking Settings'
                            : 'Consent ve Tracking Ayarlari',
                        onTap: () => context.push('/consent'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: Text(isEnglish ? 'Refresh' : 'Yenile'),
                ),
                const SizedBox(height: 10),
                if (isLoggedIn)
                  FilledButton.icon(
                    onPressed: _signOut,
                    style: FilledButton.styleFrom(
                      backgroundColor: RouteviaColors.rose,
                    ),
                    icon: const Icon(Icons.logout),
                    label: Text(isEnglish ? 'Sign Out' : 'Cikis Yap'),
                  ),
                if (isLoggedIn) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _deleteAccount,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB42318),
                      side: const BorderSide(color: Color(0xFFB42318)),
                    ),
                    icon: const Icon(Icons.delete_forever),
                    label: Text(isEnglish ? 'Delete Account' : 'Hesabimi Sil'),
                  ),
                ],
              ],
            ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// ── City Discovery Card ───────────────────────────────────────────────────────

// Famous Turkish provinces to suggest as "next" destination
const _suggestCandidates = [
  ('istanbul', 'İstanbul'),
  ('izmir', 'İzmir'),
  ('antalya', 'Antalya'),
  ('mugla', 'Muğla'),
  ('cappadocia', 'Kapadokya'),
  ('trabzon', 'Trabzon'),
  ('bursa', 'Bursa'),
  ('ankara', 'Ankara'),
  ('canakkale', 'Çanakkale'),
  ('konya', 'Konya'),
];

class _CityDiscoveryCard extends StatelessWidget {
  const _CityDiscoveryCard({
    required this.visitedProvinces,
    required this.isEnglish,
  });

  final Map<String, String> visitedProvinces;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    final count = visitedProvinces.length;
    final notVisited = _suggestCandidates
        .where((c) => !visitedProvinces.containsKey(c.$1))
        .toList();
    final nextName = notVisited.isNotEmpty ? notVisited.first.$2 : null;

    final title = isEnglish
        ? '$count ${count == 1 ? 'city' : 'cities'} explored'
        : '$count şehir keşfettin';
    final subtitle = nextName != null
        ? (isEnglish
            ? 'Next destination: $nextName'
            : 'Sıradaki hedef: $nextName')
        : (isEnglish
            ? 'You\'re an explorer! Keep going.'
            : 'Harika! Keşfetmeye devam et.');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '🗺️',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (visitedProvinces.length >= 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD600),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isEnglish ? 'Explorer 🏆' : 'Kaşif 🏆',
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
