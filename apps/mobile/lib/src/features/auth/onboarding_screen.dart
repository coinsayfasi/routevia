import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.prefillReferralCode});

  final String? prefillReferralCode;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final Set<String> _tags = {'Doğa', 'Yeme-İçme'};
  String _pace = 'Orta';
  bool _allowLocation = false;
  bool _allowNotifications = false;
  final TextEditingController _refController = TextEditingController();
  bool _saving = false;

  static const _allTags = [
    'Tarih',
    'Müze',
    'Doğa',
    'Plaj',
    'Manzara',
    'Yeme-İçme',
    'Aile',
    'Macera',
    'Gece',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.prefillReferralCode != null) {
      _refController.text = widget.prefillReferralCode!;
    }
  }

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  List<String> _prefTagsBackend() {
    const map = {
      'Tarih': 'history',
      'Müze': 'museum',
      'Doğa': 'nature',
      'Plaj': 'beach',
      'Manzara': 'sunset',
      'Yeme-İçme': 'food',
      'Aile': 'family',
      'Macera': 'adventure',
      'Gece': 'nightlife',
    };
    return _tags.map((e) => map[e] ?? e.toLowerCase()).toList();
  }

  String _prefPaceBackend() {
    switch (_pace) {
      case 'Yavaş':
        return 'slow';
      case 'Hızlı':
        return 'fast';
      default:
        return 'medium';
    }
  }

  Future<void> _askLocation() async {
    final permission = await Geolocator.requestPermission();
    final granted =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
    setState(() => _allowLocation = granted);
  }

  Future<void> _complete() async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(repositoryProvider);
      final refCode = _refController.text.trim();

      await repo.completeOnboarding(
        prefTags: _prefTagsBackend(),
        prefPace: _prefPaceBackend(),
        allowLocation: _allowLocation,
        allowNotifications: _allowNotifications,
      );

      if (refCode.isNotEmpty) {
        await repo.redeemReferral(refCode);
      }

      if (!mounted) return;
      if (_allowLocation) {
        context.go('/home');
      } else {
        context.go('/location-setup');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Onboarding tamamlanamadı: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoş Geldin'),
        leading: _step > 0
            ? IconButton(
                onPressed: () => setState(() => _step -= 1),
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        actions: [
          TextButton(
            onPressed: _saving ? null : _complete,
            child: const Text('Geç'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              LinearProgressIndicator(value: (_step + 1) / 4),
              const SizedBox(height: 16),
              Expanded(child: _buildStep()),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _step == 0
                          ? null
                          : () => setState(() => _step -= 1),
                      child: const Text('Geri'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving
                          ? null
                          : _step == 3
                          ? _complete
                          : () => setState(() => _step += 1),
                      child: Text(_step == 3 ? 'Başla' : 'Devam'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Türkiye Seyahat Asistanı',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 14),
            ListTile(
              leading: Icon(Icons.star),
              title: Text('Top Picks'),
              subtitle: Text(
                'Bulunduğun yerde en güçlü noktalar anında gelsin.',
              ),
            ),
            ListTile(
              leading: Icon(Icons.auto_awesome),
              title: Text('WOW Plan'),
              subtitle: Text('1 tıkla gün gün rota ve saatlik plan oluştur.'),
            ),
            ListTile(
              leading: Icon(Icons.bolt),
              title: Text('Şimdi Ne Yapayım?'),
              subtitle: Text('Anlık durumuna göre net öneri al.'),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İlgi Alanların',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text('Sana özel öneriler için birkaç seçim yap.'),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allTags
                  .map(
                    (t) => FilterChip(
                      label: Text(t),
                      selected: _tags.contains(t),
                      onSelected: (on) {
                        setState(() {
                          if (on) {
                            _tags.add(t);
                          } else {
                            _tags.remove(t);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('Varsayılan Tempo'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Yavaş', label: Text('Yavaş')),
                ButtonSegment(value: 'Orta', label: Text('Orta')),
                ButtonSegment(value: 'Hızlı', label: Text('Hızlı')),
              ],
              selected: {_pace},
              onSelectionChanged: (v) => setState(() => _pace = v.first),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _refController,
              decoration: const InputDecoration(
                labelText: 'Davet Kodu (Opsiyonel)',
                hintText: 'Örn: AB12CD34',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konum İzni',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yakınındaki en iyi yerleri göstermek ve rota çizmek için konum izni istiyoruz.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _askLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Konum İznini Ver'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() => _allowLocation = false),
              icon: const Icon(Icons.location_city),
              label: const Text('İl/İlçe ile devam et'),
            ),
            const SizedBox(height: 12),
            Text(
              _allowLocation
                  ? 'Konum izni açık. Harita otomatik yakınında açılacak.'
                  : 'Konum izni olmadan da devam edebilirsin. İl/ilçe seçimi ile çalışır.',
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bildirimler (Opsiyonel)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gün batımı hatırlatması ve yakınındaki Top Picks için bildirim al.',
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _allowNotifications,
              onChanged: (v) => setState(() => _allowNotifications = v),
              title: const Text('Bildirimleri aç'),
              subtitle: const Text('İstersen sonradan kapatabilirsin.'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hazırsın. Devam ederek kişiselleştirmeyi kaydedeceğiz.',
            ),
          ],
        );
    }
  }
}
