import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';

class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _trips = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ref.read(repositoryProvider).listMyTrips();
    if (!mounted) return;
    setState(() {
      _trips = data;
      _loading = false;
    });
  }

  Future<void> _shareTrip(String tripId) async {
    final token = await ref.read(repositoryProvider).createShareToken(tripId);
    if (!mounted) return;

    final link = 'routevia://share/$token';
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Share Link'),
        content: SelectableText(link),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Trips')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _trips.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final t = _trips[index];
                final province = (t['provinces'] as Map?) ?? const {};
                return ListTile(
                  title: Text(
                    '${province['name'] ?? 'Province'} • ${t['days']} days',
                  ),
                  subtitle: Text(
                    '${t['transport_mode']} • ${t['pace']} • ${t['persona_mode']}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareTrip(t['id'] as String),
                  ),
                );
              },
            ),
    );
  }
}
