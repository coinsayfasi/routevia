import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error_utils.dart';
import '../../data/providers.dart';

class SavedImportScreen extends ConsumerStatefulWidget {
  const SavedImportScreen({super.key});

  @override
  ConsumerState<SavedImportScreen> createState() => _SavedImportScreenState();
}

class _SavedImportScreenState extends ConsumerState<SavedImportScreen> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _provinces = const [];
  String? _provinceId;
  String? _provinceSlug;
  bool _loading = false;
  List<Map<String, dynamic>> _results = const [];
  final Map<int, String?> _selectedByRow = {};

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    final list = await ref.read(repositoryProvider).listProvinces();
    if (!mounted) return;
    setState(() {
      _provinces = list;
      if (list.isNotEmpty) {
        _provinceId = list.first['id'] as String;
        _provinceSlug = list.first['slug'] as String;
      } else {
        _provinceId = null;
        _provinceSlug = null;
      }
    });
  }

  List<String> _items() => _controller.text
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _resolve() async {
    if (_provinceId == null) return;
    final items = _items();
    if (items.isEmpty) return;

    setState(() => _loading = true);
    try {
      final out = await ref
          .read(repositoryProvider)
          .resolveSavedItems(provinceId: _provinceId!, items: items);
      if (!mounted) return;
      setState(() {
        _results = out;
        _selectedByRow.clear();
        for (var i = 0; i < out.length; i++) {
          final row = out[i];
          final needs = row['needs_confirmation'] == true;
          final cands = (row['candidates'] as List?) ?? const [];
          if (!needs && cands.isNotEmpty) {
            _selectedByRow[i] = (cands.first as Map)['place_id'] as String;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _buildTripFromSaved() async {
    if (_provinceSlug == null) return;
    final mustInclude = _selectedByRow.values
        .whereType<String>()
        .toSet()
        .toList();
    if (mustInclude.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('En az bir yeri onayla.')));
      return;
    }

    setState(() => _loading = true);
    try {
      final trip = await ref
          .read(repositoryProvider)
          .generateTripPlan(
            provinceSlug: _provinceSlug!,
            days: 3,
            transportMode: 'transit',
            pace: 'medium',
            personaMode: 'photo',
            preferences: const ['sunset', 'food', 'museum'],
            mustIncludePlaceIds: mustInclude,
          );
      if (!mounted) return;
      context.push('/map', extra: trip);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Import')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _provinceId,
            decoration: const InputDecoration(labelText: 'Province'),
            items: _provinces
                .map(
                  (p) => DropdownMenuItem<String>(
                    value: p['id'] as String,
                    child: Text(p['name'] as String),
                  ),
                )
                .toList(),
            onChanged: (v) {
              final p = _provinces.firstWhere((e) => e['id'] == v);
              setState(() {
                _provinceId = v;
                _provinceSlug = p['slug'] as String;
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Links or Notes (one per line)',
              hintText: 'Efes\nhttps://ornek-link.com/...\nKordon gün batımı',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _resolve,
            child: Text(_loading ? 'Resolving...' : 'Resolve Saved Items'),
          ),
          const SizedBox(height: 16),
          ..._results.asMap().entries.map((entry) {
            final idx = entry.key;
            final row = entry.value;
            final item = row['item'] as String? ?? '';
            final needs = row['needs_confirmation'] == true;
            final candidates = (row['candidates'] as List?) ?? const [];

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...candidates.map((c) {
                      final cand = Map<String, dynamic>.from(c as Map);
                      final pid = cand['place_id'] as String;
                      final conf = ((cand['confidence'] as num?) ?? 0)
                          .toDouble();
                      final selected = _selectedByRow[idx] == pid;
                      return ListTile(
                        onTap: () => setState(() => _selectedByRow[idx] = pid),
                        leading: Icon(
                          selected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                        ),
                        title: Text(
                          '${cand['name']} (${(conf * 100).toStringAsFixed(0)}%)',
                        ),
                        subtitle: Text(
                          '${cand['category']} • ${cand['short_summary'] ?? ''}',
                        ),
                      );
                    }),
                    if (needs)
                      TextButton(
                        onPressed: () =>
                            setState(() => _selectedByRow[idx] = null),
                        child: const Text('None'),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _buildTripFromSaved,
            icon: const Icon(Icons.route),
            label: const Text('Build Trip from Saved'),
          ),
        ],
      ),
    );
  }
}
