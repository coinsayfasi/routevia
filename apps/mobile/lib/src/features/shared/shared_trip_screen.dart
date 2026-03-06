import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SharedTripScreen extends StatefulWidget {
  const SharedTripScreen({super.key});

  @override
  State<SharedTripScreen> createState() => _SharedTripScreenState();
}

class _SharedTripScreenState extends State<SharedTripScreen> {
  final _token = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    setState(() => _loading = true);
    try {
      if (!mounted) return;
      context.go('/share/${_token.text.trim()}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Trip bulunamadi: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open Shared Trip')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _token,
              decoration: const InputDecoration(labelText: 'Share Token'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loading ? null : _open,
              child: Text(_loading ? 'Yukleniyor...' : 'Open'),
            ),
          ],
        ),
      ),
    );
  }
}
