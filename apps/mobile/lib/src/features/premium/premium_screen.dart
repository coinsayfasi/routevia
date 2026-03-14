import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:share_plus/share_plus.dart';
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
  final PurchaseService _purchaseService = PurchaseService();

  bool _loading = true;
  bool _purchaseBusy = false;
  List<ProductDetails> _products = const [];
  List<String> _notFoundProductIds = const [];
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  String? _billingNote;
  bool _storeAvailable = false;
  String? _referralCode;

  @override
  void initState() {
    super.initState();
    _purchaseSub = _purchaseService.purchaseStream.listen(_handlePurchases);
    _load();
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(repositoryProvider);
    try {
      final results = await Future.wait([
        _purchaseService.loadCatalog(),
        repo.getMyProfile(),
      ]);
      final catalog = results[0] as PurchaseCatalogState;
      final profile = results[1] as Map<String, dynamic>?;
      if (!mounted) return;
      setState(() {
        _products = catalog.products;
        _notFoundProductIds = catalog.notFoundIds;
        _storeAvailable = catalog.storeAvailable;
        _referralCode = profile?['referral_code'] as String?;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _billingNote = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openSupport() async {
    final uri = Uri.parse(
      'mailto:${AppConstants.supportEmail}?subject=Routevia%20Premium',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _buy(ProductDetails product) async {
    setState(() => _purchaseBusy = true);
    try {
      await _purchaseService.buy(product);
      if (!mounted) return;
      setState(() => _billingNote = context.tr('Store satin alma akisi baslatildi.', 'Store purchase flow started.'));
    } catch (e) {
      if (!mounted) return;
      setState(() => _billingNote = friendlyError(e));
    } finally {
      if (mounted) setState(() => _purchaseBusy = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _purchaseBusy = true);
    try {
      await _purchaseService.restore();
      if (!mounted) return;
      setState(() => _billingNote = context.tr('Restore istegi store tarafina gonderildi.', 'Restore request sent to the store.'));
    } catch (e) {
      if (!mounted) return;
      setState(() => _billingNote = friendlyError(e));
    } finally {
      if (mounted) setState(() => _purchaseBusy = false);
    }
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    if (purchases.isEmpty || !mounted) return;
    final repo = ref.read(repositoryProvider);
    final client = ref.read(supabaseClientProvider);
    for (final purchase in purchases) {
      await _purchaseService.complete(purchase);
      final payload = {
        'product_id': purchase.productID,
        'status': purchase.status.name,
        'transaction_date': purchase.transactionDate,
        'pending_complete_purchase': purchase.pendingCompletePurchase,
      };
      try {
        await repo.logAppEvent('billing_purchase_update', payload: payload);
      } catch (_) {}
      if (!mounted) return;
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          try {
            final result =
                await PurchaseService.verifyPurchase(client, purchase);
            if (result['ok'] == true) {
              ref.read(premiumStateProvider.notifier).refresh();
              setState(() {
                _billingNote = context.tr(
                  'Premium aktif edildi! Bitis: ${result['expires_at'] ?? '-'}',
                  'Premium activated! Expiry: ${result['expires_at'] ?? '-'}',
                );
              });
            } else {
              setState(() {
                _billingNote = context.tr(
                  'Dogrulama basarisiz: ${result['error'] ?? 'Bilinmeyen hata'}',
                  'Verification failed: ${result['error'] ?? 'Unknown error'}',
                );
              });
            }
          } catch (e) {
            setState(() {
              _billingNote = friendlyError(e);
            });
          }
          break;
        case PurchaseStatus.pending:
          setState(() => _billingNote = context.tr('Odeme islemi store tarafinda beklemede.', 'Payment is pending on the store side.'));
          break;
        case PurchaseStatus.error:
          setState(() => _billingNote = context.tr(
                'Store hata verdi: ${purchase.error?.message ?? "Bilinmeyen hata"}',
                'Store returned an error: ${purchase.error?.message ?? "Unknown error"}',
              ));
          break;
        case PurchaseStatus.canceled:
          setState(() => _billingNote = context.tr('Satin alma islemi iptal edildi.', 'Purchase was canceled.'));
          break;
      }
    }
  }

  Future<void> _shareReferral() async {
    if (_referralCode == null || _referralCode!.isEmpty) {
      try {
        final code = await ref.read(repositoryProvider).createReferralCode();
        if (!mounted) return;
        setState(() => _referralCode = code);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e))),
        );
        return;
      }
    }
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Routevia\'da gezilerini planla! Davet kodum: $_referralCode\n'
            'Uygulamada ac: routevia://ref/$_referralCode\n'
            'Kodun elle girisi: $_referralCode',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final premiumAsync = ref.watch(premiumStateProvider);
    final premium = premiumAsync.valueOrNull;
    final isPro = premium?.isPro ?? false;
    final storeReady = _storeAvailable && _products.isNotEmpty;
    final storeComingSoon = _storeAvailable && _products.isEmpty;
    final missingKnownProducts = _notFoundProductIds
        .where(BillingCatalog.storeProductIds.contains)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Routevia Pro')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
              children: [
                // ── Hero Card ──────────────────────────────────────────
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
                          const Icon(
                            Icons.workspace_premium,
                            color: RouteviaColors.amber,
                            size: 32,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Routevia Pro',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          if (isPro)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF14532D),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Aktif',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isPro
                            ? 'Premium erisimin aktif.${premium?.expiresAt != null ? ' Bitis: ${premium!.expiresAt!.day}.${premium.expiresAt!.month}.${premium.expiresAt!.year}' : ''}'
                            : storeReady
                            ? 'Sinirsiz plan, trend harita, offline paketler ve daha fazlasi.'
                            : 'Pro altyapisi hazir. Store acilana kadar davet ve destek akisi ile erisim verilebilir.',
                        style:
                            const TextStyle(color: Colors.white70, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Billing Note ───────────────────────────────────────
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
                        const Icon(Icons.info_outline,
                            size: 20, color: Color(0xFF0369A1)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_billingNote!,
                              style: const TextStyle(height: 1.45)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Feature Comparison ─────────────────────────────────
                Text(
                  context.tr('Ozellik Karsilastirmasi', 'Feature Comparison'),
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
                const SizedBox(height: 12),
                ..._featureRows.map(
                  (row) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: RouteviaColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(row.icon,
                            size: 20, color: RouteviaColors.navyLight),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(row.label,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            row.free,
                            style: const TextStyle(
                                fontSize: 12,
                                color: RouteviaColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            row.pro,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF166534),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Price Cards (from store or fallback) ───────────────
                if (storeReady) ...[
                  Text(
                    context.tr('Planlar', 'Plans'),
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  const SizedBox(height: 12),
                  ..._products.map(
                    (product) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: RouteviaColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.price,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: RouteviaColors.tealDark,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: (_purchaseBusy || isPro)
                                ? null
                                : () => _buy(product),
                            child: Text(isPro ? context.tr('Aktif', 'Active') : context.tr('Satin Al', 'Buy')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: RouteviaColors.border),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Routevia Pro Aylik',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                BillingCatalog.targetMonthlyPriceLabel,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: RouteviaColors.tealDark,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: null,
                          child: Text(context.tr('Store Bekleniyor', 'Store Pending')),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: RouteviaColors.border),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Routevia Pro Yillik',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                BillingCatalog.targetYearlyPriceLabel,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: RouteviaColors.tealDark,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: null,
                          child: Text(context.tr('Store Bekleniyor', 'Store Pending')),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule,
                            color: Color(0xFFD97706), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            !_storeAvailable
                                ? context.tr('Store su an erisilebilir degil. Bu asamada davet ve destek uzerinden Pro erisimi kullanilabilir.', 'Store is currently unavailable. During this phase, Pro can be accessed through invite and support flows.')
                                : storeComingSoon
                                ? context.tr('Store baglandi ancak Pro paketleri henuz yayinda degil. Kapali testte davet ve destek akisi aktif.', 'Store is connected but Pro products are not live yet. Invite and support flows remain active during closed testing.')
                                : context.tr('Pro paketleri henuz hazir degil.', 'Pro plans are not ready yet.'),
                            style: const TextStyle(height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (kDebugMode && missingKnownProducts.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        'Beklenen urun IDleri: ${missingKnownProducts.join(', ')}',
                        style: const TextStyle(
                          color: RouteviaColors.textSecondary,
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 12),

                // ── Restore + Support ──────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: (_purchaseBusy || !storeReady)
                            ? null
                            : _restorePurchases,
                        icon: const Icon(Icons.restore, size: 18),
                        label: Text(context.tr('Geri Yukle', 'Restore')),
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
                const SizedBox(height: 24),

                // ── Referral Section ───────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.card_giftcard,
                              color: Color(0xFF166534), size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Arkadasini Davet Et',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Davet kodunu paylas, arkadasin katildiginda ikiniz de 7 gun ucretsiz Pro erisimi kazanin.',
                        style: TextStyle(
                            color: RouteviaColors.textSecondary, height: 1.45),
                      ),
                      const SizedBox(height: 12),
                      if (_referralCode != null &&
                          _referralCode!.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Text(
                            _referralCode!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              letterSpacing: 3,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _shareReferral,
                          icon: const Icon(Icons.share, size: 18),
                          label: Text(
                            context.tr('Davet Kodunu Paylas', 'Share Invite Code'),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF166534),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

const _featureRows = <_FeatureRow>[
  _FeatureRow(Icons.map_outlined, 'Plan uretimi', '3/gun', 'Sinirsiz'),
  _FeatureRow(
    Icons.route_outlined,
    'Akilli gun akisi',
    'Temel',
    'Gelismis',
  ),
  _FeatureRow(
      Icons.local_fire_department, 'Trend harita', 'Kilitli', 'Acik'),
  _FeatureRow(Icons.offline_pin, 'Offline paketler', 'Kilitli', 'Acik'),
  _FeatureRow(Icons.tune, 'Gelismis filtreler', 'Kilitli', 'Acik'),
  _FeatureRow(Icons.bar_chart, 'Gezgin istatistikleri', 'Ozet', 'Detayli'),
];
