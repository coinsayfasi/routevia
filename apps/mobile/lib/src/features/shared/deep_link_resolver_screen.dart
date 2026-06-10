import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error_utils.dart';
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

  static final _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  Future<void> _resolve() async {
    try {
      final repo = ref.read(repositoryProvider);
      if (widget.kind == 'place') {
        if (!_uuidRegex.hasMatch(widget.value)) {
          if (!mounted) return;
          setState(() => _message = 'Geçersiz bağlantı formatı.');
          return;
        }
        final place = await repo.fetchPlaceDetail(widget.value);
        if (!mounted) return;
        context.go('/place', extra: place);
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
      setState(() => _message = friendlyError(e));
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
