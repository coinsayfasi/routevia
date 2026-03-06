import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../models/trip_models.dart';
import '../map/map_screen.dart';

class ShareTokenRouteScreen extends ConsumerStatefulWidget {
  const ShareTokenRouteScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<ShareTokenRouteScreen> createState() =>
      _ShareTokenRouteScreenState();
}

class _ShareTokenRouteScreenState extends ConsumerState<ShareTokenRouteScreen> {
  bool _loading = true;
  String? _error;
  TripPlan? _trip;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final trip = await ref
          .read(repositoryProvider)
          .getSharedTrip(widget.token);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
        _trip = trip;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_trip != null) {
      return MapScreen(plan: _trip!, readOnly: true);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Shared Trip')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Text(_error == null ? 'Opening...' : 'Failed: $_error'),
      ),
    );
  }
}
