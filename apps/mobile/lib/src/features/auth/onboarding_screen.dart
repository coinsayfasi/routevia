import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n.dart';
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
      if (refCode.isNotEmpty &&
          !RegExp(r'^[A-Z0-9]{8}$').hasMatch(refCode.toUpperCase())) {
        throw Exception(
          context.tr(
            'Davet kodu 8 karakterli olmalı.',
            'Invite code must be 8 characters.',
          ),
        );
      }
      if (refCode.isNotEmpty) {
        final isValid = await repo.validateReferralCode(refCode);
        if (!mounted) return;
        if (!isValid) {
          throw Exception(
            context.tr(
              'Davet kodu geçersiz veya bulunamadı.',
              'Invite code is invalid or was not found.',
            ),
          );
        }
      }

      Future<void> completeOnboardingFlow() async {
        await repo.completeOnboarding(
          prefTags: _prefTagsBackend(),
          prefPace: _prefPaceBackend(),
          allowLocation: _allowLocation,
          allowNotifications: _allowNotifications,
        );
      }

      try {
        await completeOnboardingFlow();
      } catch (error) {
        final raw = error.toString().toLowerCase();
        if (raw.contains('invalid jwt') || raw.contains('unauthorized')) {
          await repo.client.auth.refreshSession();
          await completeOnboardingFlow();
        } else {
          rethrow;
        }
      }

      // Mark onboarding as completed locally so home screen doesn't re-redirect
      // even if the remote profile read returns stale data.
      await ref.read(localCacheProvider).setOnboardingCompleted(true);

      if (refCode.isNotEmpty) {
        try {
          await repo.redeemReferral(refCode);
        } catch (error) {
          final raw = error.toString().toLowerCase();
          if (raw.contains('invalid jwt') || raw.contains('unauthorized')) {
            await repo.client.auth.refreshSession();
            await repo.redeemReferral(refCode);
          } else {
            rethrow;
          }
        }
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
      ).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Tercihler kaydedilemedi, lütfen tekrar dene.',
              'Preferences could not be saved, please try again.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Hoş Geldin', 'Welcome')),
        leading: _step > 0
            ? IconButton(
                onPressed: () => setState(() => _step -= 1),
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        actions: [
          TextButton(
            onPressed: _saving ? null : _complete,
            child: Text(context.tr('Geç', 'Skip')),
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
                      child: Text(context.tr('Geri', 'Back')),
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
                      child: Text(
                        _step == 3
                            ? context.tr('Başla', 'Start')
                            : context.tr('Devam', 'Continue'),
                      ),
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
          children: [
            Text(
              context.tr('Türkiye Seyahat Asistanı', 'Turkey Travel Assistant'),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.star),
              title: Text('Top Picks'),
              subtitle: Text(
                context.tr(
                  'Bulunduğun yerde en güçlü noktalar anında gelsin.',
                  'See the strongest spots around you instantly.',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: Text('WOW Plan'),
              subtitle: Text(
                context.tr(
                  '1 tıkla gün gün rota ve saatlik plan oluştur.',
                  'Create a day-by-day route and hourly plan in one tap.',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bolt),
              title: Text(context.tr('Şimdi Ne Yapayım?', 'What Should I Do Now?')),
              subtitle: Text(
                context.tr(
                  'Anlık durumuna göre net öneri al.',
                  'Get a clear suggestion based on your current situation.',
                ),
              ),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('İlgi Alanların', 'Your Interests'),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(context.tr('Sana özel öneriler için birkaç seçim yap.', 'Choose a few options for more personal suggestions.')),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allTags
                  .map(
                    (t) => FilterChip(
                      label: Text(t),
                      selected: _tags.contains(t),
                      showCheckmark: false,
                      selectedColor: const Color(0xFF0B3B68),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: _tags.contains(t)
                            ? const Color(0xFF0B3B68)
                            : const Color(0xFFD7E0EA),
                      ),
                      labelStyle: TextStyle(
                        color: _tags.contains(t)
                            ? Colors.white
                            : const Color(0xFF16324F),
                        fontWeight: FontWeight.w600,
                      ),
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
            Text(context.tr('Varsayılan Tempo', 'Default Pace')),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'Yavaş', label: Text(context.tr('Yavaş', 'Slow'))),
                ButtonSegment(value: 'Orta', label: Text(context.tr('Orta', 'Medium'))),
                ButtonSegment(value: 'Hızlı', label: Text(context.tr('Hızlı', 'Fast'))),
              ],
              selected: {_pace},
              onSelectionChanged: (v) => setState(() => _pace = v.first),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _refController,
              maxLength: 8,
              decoration: InputDecoration(
                labelText: context.tr('Davet Kodu (Opsiyonel)', 'Invite Code (Optional)'),
                hintText: context.tr('Örn: AB12CD34', 'Ex: AB12CD34'),
                counterText: '',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('Konum İzni', 'Location Permission'),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                'Yakınındaki en iyi yerleri göstermek ve rota çizmek için konum izni istiyoruz.',
                'We ask for location permission to show the best nearby places and build routes.',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _askLocation,
              icon: const Icon(Icons.my_location),
              label: Text(context.tr('Konum İznini Ver', 'Allow Location')),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() => _allowLocation = false),
              icon: const Icon(Icons.location_city),
              label: Text(context.tr('İl/İlçe ile devam et', 'Continue with city/district')),
            ),
            const SizedBox(height: 12),
            Text(
              _allowLocation
                  ? context.tr(
                      'Konum izni açık. Harita otomatik yakınında açılacak.',
                      'Location access is enabled. The map will open near you automatically.',
                    )
                  : context.tr(
                      'Konum izni olmadan da devam edebilirsin. İl/ilçe seçimi ile çalışır.',
                      'You can continue without location access. The app will work with city/district selection.',
                    ),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('Bildirimler (Opsiyonel)', 'Notifications (Optional)'),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                'Gün batımı hatırlatması ve yakınındaki Top Picks için bildirim al.',
                'Receive notifications for sunset reminders and nearby Top Picks.',
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _allowNotifications,
              onChanged: (v) => setState(() => _allowNotifications = v),
              title: Text(context.tr('Bildirimleri aç', 'Enable notifications')),
              subtitle: Text(context.tr('İstersen sonradan kapatabilirsin.', 'You can disable this later.')),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr(
                'Hazırsın. Devam ederek kişiselleştirmeyi kaydedeceğiz.',
                'You are ready. Continuing will save your personalization settings.',
              ),
            ),
          ],
        );
    }
  }
}
