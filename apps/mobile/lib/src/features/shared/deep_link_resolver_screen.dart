import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';

class DeepLinkResolverScreen extends ConsumerStatefulWidget {
  const DeepLinkResolverScreen({
    super.key,
    required this.kind,
    required this.value,
  });

  final String kind;
  final String value;

  @override
  ConsumerState<DeepLinkResolverScreen> createState() =>
      _DeepLinkResolverScreenState();
}

class _DeepLinkResolverScreenState
    extends ConsumerState<DeepLinkResolverScreen> {
  String _message = 'Bağlantı işleniyor...';

  @override
  void initState() {
    super.initState();
    Future.microtask(_resolve);
  }

  Future<void> _resolve() async {
    try {
      final repo = ref.read(repositoryProvider);
      if (widget.kind == 'place') {
        final place = await repo.fetchPlaceDetail(widget.value);
        if (!mounted) return;
        context.go('/place', extra: place);
        return;
      }

      if (widget.kind == 'ref') {
        final code = widget.value.trim().toUpperCase();
        final session = repo.client.auth.currentSession;
        if (session == null) {
          await ref.read(localCacheProvider).setPendingReferralCode(code);
          if (!mounted) return;
          context.go('/auth');
          return;
        }
        await repo.redeemReferral(code);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Davet kodu uygulandı. 7 günlük Pro davet erişimi aktif.',
            ),
          ),
        );
        ref.invalidate(premiumStateProvider);
        context.go('/home?tab=0');
        return;
      }

      if (widget.kind == 'plan') {
        if (!mounted) return;
        setState(() {
          _message =
              'Bu bağlantı plan kimliği içeriyor. Güvenlik nedeniyle plan detayı için paylaşım tokenı gerekir.\nPaylaşılan linkte /share/<token> kullan.';
        });
        return;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = 'Bağlantı açılamadı: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bağlantı')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(_message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/home?tab=0'),
                child: const Text('Ana Sayfaya Dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
