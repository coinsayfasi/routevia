import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import 'theme.dart';

/// Returns `true` when the user has an active Pro or preview entitlement.
bool isPro(WidgetRef ref) {
  final state = ref.watch(premiumStateProvider);
  return state.valueOrNull?.isPro ?? false;
}

/// Shows a modal bottom sheet prompting the user to upgrade to Pro.
void showPremiumGate(BuildContext context, {String? feature}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _PremiumGateSheet(feature: feature),
  );
}

class _PremiumGateSheet extends StatelessWidget {
  const _PremiumGateSheet({this.feature});

  final String? feature;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: RouteviaColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.workspace_premium,
              size: 48,
              color: RouteviaColors.amber,
            ),
            const SizedBox(height: 14),
            Text(
              feature != null
                  ? '$feature Pro ile kullanilabilir'
                  : 'Bu ozellik Routevia Pro ile acilir',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sinirsiz plan, trend harita, offline paketler, gezgin istatistikleri ve daha fazlasi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: RouteviaColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/premium');
                },
                child: const Text('Pro\'yu Kesfet'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Simdilik Degil'),
            ),
          ],
        ),
      ),
    );
  }
}
