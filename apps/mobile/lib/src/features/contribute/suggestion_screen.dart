import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/providers.dart';

class SuggestionScreen extends ConsumerStatefulWidget {
  const SuggestionScreen({super.key});

  @override
  ConsumerState<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends ConsumerState<SuggestionScreen> {
  final _name = TextEditingController();
  final _note = TextEditingController();
  final _source = TextEditingController();
  final _tags = TextEditingController();

  List<Map<String, dynamic>> _provinces = const [];
  List<Map<String, dynamic>> _districts = const [];
  String? _provinceSlug;
  String? _districtSlug;
  String _category = 'historical';
  bool _loading = false;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(repositoryProvider);
    final provinces = await repo.listProvinces();
    if (!mounted) return;
    setState(() {
      _provinces = provinces;
      _provinceSlug = provinces.firstOrNull?['slug'] as String?;
    });
    if (_provinceSlug != null) {
      final d = await repo.listDistrictsByProvinceSlug(_provinceSlug!);
      if (!mounted) return;
      setState(() {
        _districts = d;
        _districtSlug = d.firstOrNull?['slug'] as String?;
      });
    }
  }

  Future<void> _pickLocation() async {
    try {
      await Geolocator.requestPermission();
      final p = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _position = p);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_provinceSlug == null ||
        _name.text.trim().isEmpty ||
        _note.text.trim().isEmpty) {
      _toast('Il, isim ve not zorunlu.');
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await ref
          .read(repositoryProvider)
          .submitPlaceSuggestion(
            provinceSlug: _provinceSlug!,
            districtSlug: _districtSlug,
            suggestedName: _name.text.trim(),
            suggestedCategory: _category,
            shortNote: _note.text.trim(),
            suggestedTags: _tags.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            lat: _position?.latitude,
            lng: _position?.longitude,
            sourceUrl: _source.text.trim().isEmpty ? null : _source.text.trim(),
          );
      _toast('Gonderildi: ${result['suggestion']?['id'] ?? ''}');
      _name.clear();
      _note.clear();
      _source.clear();
      _tags.clear();
      setState(() => _position = null);
    } catch (e) {
      _toast('Gonderilemedi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    _source.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yer Oner')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _provinceSlug,
            decoration: const InputDecoration(labelText: 'Il'),
            items: _provinces
                .map(
                  (p) => DropdownMenuItem<String>(
                    value: p['slug'] as String,
                    child: Text(p['name'] as String),
                  ),
                )
                .toList(),
            onChanged: (v) async {
              if (v == null) return;
              final d = await ref
                  .read(repositoryProvider)
                  .listDistrictsByProvinceSlug(v);
              if (!mounted) return;
              setState(() {
                _provinceSlug = v;
                _districts = d;
                _districtSlug = d.firstOrNull?['slug'] as String?;
              });
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _districtSlug,
            decoration: const InputDecoration(labelText: 'Ilce (opsiyonel)'),
            items: _districts
                .map(
                  (d) => DropdownMenuItem<String>(
                    value: d['slug'] as String,
                    child: Text(d['name'] as String),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _districtSlug = v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Mekan adi'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Kategori'),
            items: const [
              'museum',
              'historical',
              'nature',
              'beach',
              'viewpoint',
              'market',
              'mall',
              'cafe',
              'food',
              'activity',
              'lodging',
            ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v ?? 'historical'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            maxLength: 240,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Neden eklenmeli? (<=240)',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _tags,
            decoration: const InputDecoration(
              labelText: 'Etiketler (virgulle)',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _source,
            decoration: const InputDecoration(
              labelText: 'Kaynak URL (opsiyonel)',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickLocation,
            icon: const Icon(Icons.my_location),
            label: Text(
              _position == null
                  ? 'Konumu Ekle (opsiyonel)'
                  : 'Konum: ${_position!.latitude.toStringAsFixed(4)}, ${_position!.longitude.toStringAsFixed(4)}',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: Text(_loading ? 'Gonderiliyor...' : 'Oneriyi Gonder'),
          ),
        ],
      ),
    );
  }
}
