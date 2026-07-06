import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/billing_catalog.dart';
import '../../core/constants.dart';
import '../../core/error_utils.dart';
import '../../core/i18n.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import 'purchase_service.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _loading = true;
  bool _purchaseBusy = false;
  Offerings? _offerings;
  String? _billingNote;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    Offerings? offerings;

    await PurchaseService.getOfferings()
        .then((o) => offerings = o)
        .catchError((_) => null);

    if (!mounted) return;
    setState(() {
      _offerings = offerings;
      _loading = false;
    });
  }

  /// Yıllık planın aylığa kıyasla yüzde tasarrufu (ör. %37). Rozet için.
  int? _annualSavingsPercent(Package annual, Package? monthly) {
    if (monthly == null) return null;
    final annualPrice = annual.storeProduct.price;
    final monthlyPrice = monthly.storeProduct.price;
    if (monthlyPrice <= 0) return null;
    final fullYear = monthlyPrice * 12;
    final pct = ((fullYear - annualPrice) / fullYear * 100).round();
    return pct > 0 ? pct : null;
  }

  /// Yıllık planın aya bölünmüş eşdeğeri (ör. "ayda ~25 TL").
  String? _annualPerMonthLabel(Package annual) {
    final price = annual.storeProduct.price;
    if (price <= 0) return null;
    final perMonth = (price / 12);
    final cur = annual.storeProduct.priceString.replaceAll(RegExp(r'[\d.,\s]'), '').trim();
    final num = perMonth.toStringAsFixed(2).replaceAll('.', ',');
    final body = cur.isEmpty ? '$num/ay' : '$cur$num/ay';
    return context.tr('ayda yalnızca $body', 'just $body/mo');
  }

  Future<void> _openSupport() async {
    final uri = Uri.parse('mailto:${AppConstants.supportEmail}?subject=Routevia%20Premium');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _buy(Package package) async {
    setState(() {
      _purchaseBusy = true;
      _billingNote = null;
    });
    try {
      final info = await PurchaseService.purchasePackage(package);
      final client = ref.read(supabaseClientProvider);
      await PurchaseService.syncEntitlementToSupabase(client, info);
      ref.read(premiumStateProvider.notifier).refresh();
      if (!mounted) return;
      setState(() => _billingNote = context.tr('Premium aktif edildi!', 'Premium activated!'));
    } on PlatformException catch (e) {
      if (!mounted) return;
      // Kullanıcı satın almadan vazgeçtiyse hata gösterme — sessizce kapat.
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        setState(() => _billingNote = null);
        return;
      }
      setState(() => _billingNote = friendlyError(e));
    } catch (e) {
      if (!mounted) return;
      setState(() => _billingNote = friendlyError(e));
    } finally {
      if (mounted) setState(() => _purchaseBusy = false);
    }
  }

  Future<void> _restore() async {
    setState(() {
      _purchaseBusy = true;
      _billingNote = null;
    });
    try {
      final info = await PurchaseService.restorePurchases();
      final client = ref.read(supabaseClientProvider);
      await PurchaseService.syncEntitlementToSupabase(client, info);
      ref.read(premiumStateProvider.notifier).refresh();
      if (!mounted) return;
      final hasPro = PurchaseService.hasPro(info);
      setState(() => _billingNote = hasPro
          ? context.tr('Satın alma geri yüklendi!', 'Purchase restored!')
          : context.tr('Aktif abonelik bulunamadı.', 'No active subscription found.'));
    } catch (e) {
      if (!mounted) return;
      setState(() => _billingNote = friendlyError(e));
    } finally {
      if (mounted) setState(() => _purchaseBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final premiumAsync = ref.watch(premiumStateProvider);
    final premium = premiumAsync.valueOrNull;
    // Treat loading state as potentially pro to avoid briefly enabling purchase
    final isPro = premium?.isPro ?? false;
    final premiumLoading = premiumAsync.isLoading;

    final currentOffering = _offerings?.current;
    final packages = currentOffering?.availablePackages ?? [];
    final monthly = packages.where((p) => p.packageType == PackageType.monthly).firstOrNull;
    final annual = packages.where((p) => p.packageType == PackageType.annual).firstOrNull;
    final displayPackages = [annual, monthly].whereType<Package>().toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Routevia Pro')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
              children: [
                // ── Hero ──────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0B1F3A), Color(0xFF133E75)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.workspace_premium, color: RouteviaColors.amber, size: 32),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('Routevia Pro',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)),
                          ),
                          if (isPro)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF14532D),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(context.tr('Aktif', 'Active'),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isPro
                            ? context.tr(
                                'Premium erişimin aktif.${premium?.expiresAt != null ? ' Bitiş: ${premium?.expiresAt?.day}.${premium?.expiresAt?.month}.${premium?.expiresAt?.year}' : ''}',
                                'Your premium access is active.${premium?.expiresAt != null ? ' Expires: ${premium?.expiresAt?.day}.${premium?.expiresAt?.month}.${premium?.expiresAt?.year}' : ''}',
                              )
                            : context.tr('Sınırsız plan, trend harita, offline paketler ve daha fazlası.', 'Unlimited plans, trend map, offline packs and more.'),
                        style: const TextStyle(color: Colors.white70, height: 1.5),
                      ),
                      if (!isPro) ...[
                        const SizedBox(height: 14),
                        // ── Sosyal kanıt ──
                        Row(
                          children: [
                            const Icon(Icons.star, color: RouteviaColors.amber, size: 15),
                            const Icon(Icons.star, color: RouteviaColors.amber, size: 15),
                            const Icon(Icons.star, color: RouteviaColors.amber, size: 15),
                            const Icon(Icons.star, color: RouteviaColors.amber, size: 15),
                            const Icon(Icons.star, color: RouteviaColors.amber, size: 15),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.tr(
                                  'Binlerce gezgin Routevia Pro ile keşfediyor',
                                  'Thousands of travelers explore with Routevia Pro',
                                ),
                                style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Billing Note ──────────────────────────────────────────
                if (_billingNote != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20, color: Color(0xFF0369A1)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_billingNote!, style: const TextStyle(height: 1.45))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Feature List ──────────────────────────────────────────
                Text(context.tr('Özellik Karşılaştırması', 'Feature Comparison'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 12),
                ..._buildFeatureRows(context).map((row) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: RouteviaColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(row.icon, size: 20, color: RouteviaColors.navyLight),
                          const SizedBox(width: 10),
                          Expanded(child: Text(row.label, style: const TextStyle(fontWeight: FontWeight.w600))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(row.free,
                                style: const TextStyle(fontSize: 12, color: RouteviaColors.textSecondary)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(row.pro,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF166534), fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),

                // ── Plans or Active Membership ─────────────────────────
                if (premiumLoading) ...[
                  const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  )),
                ] else if (isPro) ...[
                  // ── Active membership card ────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBBF7D0), width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF166534), size: 22),
                            const SizedBox(width: 8),
                            Text(context.tr('Aktif Üyelik', 'Active Subscription'),
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF166534))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          () {
                            final exp = premium?.expiresAt;
                            if (exp == null) return context.tr('Pro erişiminiz aktif.', 'Your Pro access is active.');
                            return context.tr(
                              'Pro erişiminiz ${exp.day}.${exp.month}.${exp.year} tarihine kadar aktif.',
                              'Your Pro access is active until ${exp.day}.${exp.month}.${exp.year}.',
                            );
                          }(),
                          style: const TextStyle(color: RouteviaColors.textSecondary, height: 1.45),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _openSupport,
                          icon: const Icon(Icons.mail_outline, size: 18),
                          label: Text(context.tr('Destek / Abonelik Yönetimi', 'Support / Subscription Management')),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text(context.tr('Planlar', 'Plans'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                  const SizedBox(height: 12),
                  if (displayPackages.isNotEmpty) ...[
                    ...displayPackages.map((package) {
                      final isAnnual = package.packageType == PackageType.annual;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isAnnual ? RouteviaColors.tealDark : RouteviaColors.border,
                            width: isAnnual ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        isAnnual ? context.tr('Yıllık Plan', 'Annual Plan') : context.tr('Aylık Plan', 'Monthly Plan'),
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                      ),
                                      if (isAnnual) ...[
                                        const SizedBox(width: 8),
                                        Builder(builder: (_) {
                                          final pct = _annualSavingsPercent(package, monthly);
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: RouteviaColors.tealDark,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                                pct != null
                                                    ? context.tr('%$pct İNDİRİM', '$pct% OFF')
                                                    : context.tr('En İyi', 'Best Value'),
                                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                          );
                                        }),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    package.storeProduct.priceString,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700, color: RouteviaColors.tealDark, fontSize: 18),
                                  ),
                                  if (isAnnual)
                                    Builder(builder: (_) {
                                      final perMonth = _annualPerMonthLabel(package);
                                      if (perMonth == null) return const SizedBox.shrink();
                                      return Text(perMonth,
                                          style: const TextStyle(fontSize: 12.5, color: RouteviaColors.textSecondary, fontWeight: FontWeight.w600));
                                    }),
                                ],
                              ),
                            ),
                            FilledButton(
                              onPressed: _purchaseBusy ? null : () => _buy(package),
                              child: _purchaseBusy
                                  ? const SizedBox(width: 18, height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text(context.tr('Ücretsiz Başla', 'Start Free')),
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    // Fallback fiyat kartları (store bağlı değilse)
                    _fallbackPriceCard(context.tr('Yıllık Plan', 'Annual Plan'), BillingCatalog.targetYearlyPriceLabel, true),
                    const SizedBox(height: 12),
                    _fallbackPriceCard(context.tr('Aylık Plan', 'Monthly Plan'), BillingCatalog.targetMonthlyPriceLabel, false),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, color: Color(0xFFD97706), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              context.tr(
                                'Store bağlantısı kuruluyor. Yakında satın alma aktif olacak.',
                                'Store connection being established. Purchase will be available soon.',
                              ),
                              style: const TextStyle(height: 1.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // ── Restore + Support ───────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _purchaseBusy ? null : _restore,
                          icon: const Icon(Icons.restore, size: 18),
                          label: Text(context.tr('Geri Yükle', 'Restore Purchase')),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openSupport,
                          icon: const Icon(Icons.mail_outline, size: 18),
                          label: Text(context.tr('Destek', 'Support')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // ── Subscription Disclosure ──────────────────────────────
                  // Apple 3.1.2 zorunlu (iOS), Google Play Billing (Android)
                  Text(
                    defaultTargetPlatform == TargetPlatform.android
                        ? context.tr(
                            'Ödeme, satın alma onayında Google Play hesabınızdan tahsil edilir. Abonelik, mevcut dönemin bitiminden en az 24 saat önce iptal edilmediği sürece otomatik olarak yenilenir. Yenileme ücreti, mevcut dönem bitiminden 24 saat öncesinde hesabınızdan alınır. Abonelikler satın alma sonrasında Google Play > Abonelikler üzerinden yönetilebilir ve iptal edilebilir.',
                            'Payment will be charged to your Google Play account at confirmation of purchase. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period. Renewal is charged within 24 hours prior to the end of the current period. Subscriptions may be managed and cancelled in Google Play > Subscriptions after purchase.',
                          )
                        : context.tr(
                            'Ödeme, satın alma onayında Apple ID hesabınızdan tahsil edilir. Abonelik, mevcut dönemin bitiminden en az 24 saat önce iptal edilmediği sürece otomatik olarak yenilenir. Yenileme ücreti, mevcut dönem bitiminden 24 saat öncesinde hesabınızdan alınır. Abonelikler satın alma sonrasında Hesap Ayarları üzerinden yönetilebilir ve otomatik yenileme kapatılabilir.',
                            'Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period. Renewal is charged within 24 hours prior to the end of the current period. Subscriptions may be managed and auto-renewal turned off in Account Settings after purchase.',
                          ),
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), height: 1.5),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _fallbackPriceCard(String title, String price, bool highlight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? RouteviaColors.tealDark : RouteviaColors.border,
          width: highlight ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text(price,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: RouteviaColors.tealDark, fontSize: 18)),
              ],
            ),
          ),
          OutlinedButton(onPressed: null, child: Text(context.tr('Yakında', 'Coming Soon'))),
        ],
      ),
    );
  }

}

class _FeatureRow {
  const _FeatureRow(this.icon, this.label, this.free, this.pro);
  final IconData icon;
  final String label;
  final String free;
  final String pro;
}

List<_FeatureRow> _buildFeatureRows(BuildContext context) => [
  _FeatureRow(Icons.map_outlined, context.tr('Günlük plan üretimi', 'Daily plan generation'), context.tr('3 plan/gün', '3 plans/day'), context.tr('Sınırsız', 'Unlimited')),
  _FeatureRow(Icons.local_fire_department, context.tr('Trend harita 🔥', 'Trend map 🔥'), context.tr('Kilitli', 'Locked'), context.tr('Açık', 'Open')),
  _FeatureRow(Icons.offline_pin, context.tr('Offline paketler', 'Offline packs'), context.tr('Kilitli', 'Locked'), context.tr('Açık', 'Open')),
  _FeatureRow(Icons.route_outlined, context.tr('Rota optimizasyonu', 'Route optimization'), context.tr('Temel', 'Basic'), context.tr('Gelişmiş', 'Advanced')),
  _FeatureRow(Icons.bar_chart, context.tr('Gezgin istatistikleri', 'Explorer stats'), context.tr('Özet', 'Summary'), context.tr('Detaylı', 'Detailed')),
  _FeatureRow(Icons.notifications_active, context.tr('Yakınlık bildirimleri', 'Proximity notifications'), context.tr('Kilitli', 'Locked'), context.tr('Açık', 'Open')),
  _FeatureRow(Icons.cloud_upload, context.tr('Fotoğraf yükleme', 'Photo upload'), context.tr('Kilitli', 'Locked'), context.tr('Açık', 'Open')),
];
