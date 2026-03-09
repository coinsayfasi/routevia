import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error_utils.dart';
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

  static const _categoryLabels = <String, String>{
    'museum': 'Müze',
    'historical': 'Tarihi',
    'nature': 'Doğa',
    'beach': 'Plaj',
    'viewpoint': 'Manzara',
    'market': 'Pazar / Çarşı',
    'mall': 'AVM',
    'cafe': 'Kafe',
    'food': 'Yeme-İçme',
    'activity': 'Aktivite',
    'lodging': 'Konaklama',
  };

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
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      _toast('Öneri göndermek için önce giriş yapmalısın.');
      context.push('/auth');
      return;
    }
    if (_provinceSlug == null ||
        _name.text.trim().isEmpty ||
        _note.text.trim().isEmpty) {
      _toast('Il, isim ve not zorunlu.');
      return;
    }

    setState(() => _loading = true);
    try {
      await ref
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
      _toast('Önerin alındı! İnceleme sürecine girdi.');
      _name.clear();
      _note.clear();
      _source.clear();
      _tags.clear();
      setState(() => _position = null);
    } catch (e) {
      _toast(friendlyError(e));
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oneri Akisi',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Buraya ekledigin yer once moderasyona duser. Dogrulanir, kategori ve konumu temizlenir, sonra yayina alinir.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
            decoration: const InputDecoration(
              labelText: 'Mekan adi',
              hintText: 'Ornek: Kayakoy Panorama Noktasi',
            ),
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
            ]
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(_categoryLabels[c] ?? c),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? 'historical'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            maxLength: 240,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Neden eklenmeli? (<=240)',
              hintText:
                  'Neyi ozel? Ne zaman gidilmeli? Kisa ve dogrulanabilir yaz.',
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['sunset', 'family', 'local', 'hidden_gem', 'photo']
                .map(
                  (tag) => ActionChip(
                    label: Text(tag),
                    onPressed: () {
                      final current = _tags.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                      if (current.contains(tag)) return;
                      current.add(tag);
                      _tags.text = current.join(', ');
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickLocation,
            icon: const Icon(Icons.my_location),
            label: Text(
              _position == null
                  ? 'Konumu Ekle (opsiyonel)'
                  : 'Konum: ${_position!.latitude.toStringAsFixed(4)}, ${_position!.longitude.toStringAsFixed(4)}',
            ),
          ),
          if (_position != null) ...[
            const SizedBox(height: 6),
            Text(
              'Konum eklendi. Admin doğrularsa yayın akışına hızlı girer.',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _source,
            decoration: const InputDecoration(
              labelText: 'Kaynak URL (opsiyonel)',
              hintText: 'Resmi site, harita linki veya lisanslı kaynak',
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _loading ? null : _submit,
            icon: const Icon(Icons.send),
            label: Text(_loading ? 'Gönderiliyor...' : 'Öneriyi Gönder'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
