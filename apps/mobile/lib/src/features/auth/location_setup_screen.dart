import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/providers.dart';

class LocationSetupScreen extends ConsumerStatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  ConsumerState<LocationSetupScreen> createState() =>
      _LocationSetupScreenState();
}

class _LocationSetupScreenState extends ConsumerState<LocationSetupScreen> {
  List<Map<String, dynamic>> _provinces = const [];
  List<Map<String, dynamic>> _districts = const [];
  String? _provinceSlug;
  String? _districtId;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(repositoryProvider);
    final cache = ref.read(localCacheProvider);
    try {
      final provinces = await repo.listProvinces();
      final prefProvince = await cache.getPreferredProvinceSlug();
      final selectedProvince =
          prefProvince ?? provinces.firstOrNull?['slug'] as String?;
      final districts = selectedProvince == null
          ? const <Map<String, dynamic>>[]
          : await repo.listDistrictsByProvinceSlug(selectedProvince);
      final prefDistrict = await cache.getPreferredDistrictId();
      if (!mounted) return;
      setState(() {
        _provinces = provinces;
        _provinceSlug = selectedProvince;
        _districts = districts;
        _districtId = districts.any((d) => d['id'] == prefDistrict)
            ? prefDistrict
            : districts.firstOrNull?['id'] as String?;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _onProvinceChanged(String slug) async {
    final repo = ref.read(repositoryProvider);
    setState(() {
      _provinceSlug = slug;
      _districts = const [];
      _districtId = null;
    });
    try {
      final districts = await repo.listDistrictsByProvinceSlug(slug);
      if (!mounted) return;
      setState(() {
        _districts = districts;
        _districtId = districts.firstOrNull?['id'] as String?;
      });
    } catch (_) {}
  }

  Future<void> _saveAndContinue() async {
    final provinceSlug = _provinceSlug;
    if (provinceSlug == null) return;
    setState(() => _saving = true);
    try {
      final cache = ref.read(localCacheProvider);
      await cache.setLocationSetupSkipped(false);
      await cache.setPreferredProvinceSlug(provinceSlug);
      await cache.setPreferredDistrictId(_districtId);

      final district = _districts.firstWhere(
        (d) => d['id'] == _districtId,
        orElse: () => <String, dynamic>{},
      );
      final lat = (district['lat'] as num?)?.toDouble();
      final lng = (district['lng'] as num?)?.toDouble();

      if (!mounted) return;
      if (lat != null && lng != null) {
        context.go(
          '/map-explore',
          extra: {'lat': lat, 'lng': lng, 'province_slug': provinceSlug},
        );
      } else {
        context.go('/home');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _skipForNow() async {
    setState(() => _saving = true);
    try {
      final cache = ref.read(localCacheProvider);
      await cache.setLocationSetupSkipped(true);
      await cache.setPreferredProvinceSlug(null);
      await cache.setPreferredDistrictId(null);
      if (!mounted) return;
      context.go('/home');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _selectedProvinceName {
    if (_provinceSlug == null) return 'İl Seç';
    return _provinces.firstWhere(
              (p) => p['slug'] == _provinceSlug,
              orElse: () => <String, dynamic>{},
            )['name']
            as String? ??
        _provinceSlug!;
  }

  String get _selectedDistrictName {
    if (_districtId == null || _districts.isEmpty) return 'İlçe Seç';
    return _districts.firstWhere(
              (d) => d['id'] == _districtId,
              orElse: () => <String, dynamic>{},
            )['name']
            as String? ??
        _districtId!;
  }

  Future<void> _openProvincePicker() async {
    if (_provinces.isEmpty) return;
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => _ProvincePickerSheet(
        provinces: _provinces,
        selectedSlug: _provinceSlug,
      ),
    );
    if (selected != null && selected != _provinceSlug) {
      await _onProvinceChanged(selected);
    }
  }

  Future<void> _openDistrictPicker() async {
    if (_districts.isEmpty) return;
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) =>
          _DistrictPickerSheet(districts: _districts, selectedId: _districtId),
    );
    if (!mounted) return;
    if (selected != null) {
      setState(() => _districtId = selected == '__all__' ? null : selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RouteviaColors.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(RouteviaColors.teal),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: RouteviaColors.textSecondary,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero section
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                RouteviaColors.teal,
                                RouteviaColors.tealDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Başlangıç\nŞehrini Seç',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 30,
                            letterSpacing: -0.5,
                            height: 1.1,
                            color: RouteviaColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Konum izni olmadan da devam edebilirsin. Top Picks ve WOW Plan bu bölgeye göre hazırlanır.',
                          style: TextStyle(
                            color: RouteviaColors.textSecondary,
                            fontSize: 14.5,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Province selector
                        const Text(
                          'İl',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: RouteviaColors.textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _SelectorButton(
                          label: _selectedProvinceName,
                          icon: Icons.location_city_rounded,
                          onTap: _provinces.isNotEmpty
                              ? _openProvincePicker
                              : null,
                          hasValue: _provinceSlug != null,
                        ),
                        const SizedBox(height: 16),

                        // District selector
                        const Text(
                          'İlçe',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: RouteviaColors.textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _SelectorButton(
                          label: _selectedDistrictName,
                          icon: Icons.map_outlined,
                          onTap: _districts.isNotEmpty
                              ? _openDistrictPicker
                              : null,
                          hasValue: _districtId != null,
                          disabled: _districts.isEmpty,
                          hint: _provinceSlug == null
                              ? 'Önce il seçin'
                              : _districts.isEmpty
                              ? 'Yükleniyor...'
                              : null,
                        ),
                        const SizedBox(height: 40),

                        // Info card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: RouteviaColors.teal.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: RouteviaColors.teal.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: RouteviaColors.teal,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Seçimin daha sonra ayarlardan değiştirilebilir.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: RouteviaColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Buttons
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: (_provinceSlug == null || _saving)
                                ? null
                                : _saveAndContinue,
                            style: FilledButton.styleFrom(
                              backgroundColor: RouteviaColors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 17),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Bu İlçe ile Başla',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _saving ? null : _skipForNow,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: const BorderSide(
                                color: RouteviaColors.border,
                                width: 1.2,
                              ),
                            ),
                            child: const Text(
                              'Şimdilik Geç',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: RouteviaColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selector Button
// ─────────────────────────────────────────────────────────────────────────────

class _SelectorButton extends StatelessWidget {
  const _SelectorButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.hasValue = false,
    this.disabled = false,
    this.hint,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool hasValue;
  final bool disabled;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: disabled
              ? RouteviaColors.surfaceVariant
              : RouteviaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasValue && !disabled
                ? RouteviaColors.teal.withValues(alpha: 0.5)
                : RouteviaColors.border,
            width: hasValue && !disabled ? 1.5 : 1.2,
          ),
          boxShadow: disabled
              ? null
              : [
                  const BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: hasValue && !disabled
                  ? RouteviaColors.teal
                  : RouteviaColors.textTertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: hint != null
                  ? Text(
                      hint!,
                      style: const TextStyle(
                        color: RouteviaColors.textTertiary,
                        fontSize: 15,
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        color: hasValue
                            ? RouteviaColors.textPrimary
                            : RouteviaColors.textTertiary,
                        fontWeight: hasValue
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontSize: 15,
                      ),
                    ),
            ),
            Icon(
              Icons.expand_more_rounded,
              size: 20,
              color: disabled
                  ? RouteviaColors.textTertiary
                  : RouteviaColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Province Picker Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ProvincePickerSheet extends StatefulWidget {
  const _ProvincePickerSheet({
    required this.provinces,
    required this.selectedSlug,
  });

  final List<Map<String, dynamic>> provinces;
  final String? selectedSlug;

  @override
  State<_ProvincePickerSheet> createState() => _ProvincePickerSheetState();
}

class _ProvincePickerSheetState extends State<_ProvincePickerSheet> {
  late List<Map<String, dynamic>> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.provinces;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.provinces
          : widget.provinces
                .where((p) => (p['name'] as String).toLowerCase().contains(q))
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'İl Seç',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: RouteviaColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'İl ara...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _filtered = widget.provinces);
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Sonuç bulunamadı',
                      style: TextStyle(color: RouteviaColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    controller: scrollCtrl,
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final p = _filtered[i];
                      final slug = p['slug'] as String;
                      final name = p['name'] as String;
                      final isSelected = slug == widget.selectedSlug;
                      return ListTile(
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? RouteviaColors.teal
                                : RouteviaColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: RouteviaColors.teal,
                              )
                            : null,
                        onTap: () => Navigator.of(ctx).pop(slug),
                        selected: isSelected,
                        selectedTileColor: RouteviaColors.teal.withValues(
                          alpha: 0.05,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// District Picker Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _DistrictPickerSheet extends StatefulWidget {
  const _DistrictPickerSheet({
    required this.districts,
    required this.selectedId,
  });

  final List<Map<String, dynamic>> districts;
  final String? selectedId;

  @override
  State<_DistrictPickerSheet> createState() => _DistrictPickerSheetState();
}

class _DistrictPickerSheetState extends State<_DistrictPickerSheet> {
  late List<Map<String, dynamic>> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.districts;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.districts
          : widget.districts
                .where((d) => (d['name'] as String).toLowerCase().contains(q))
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'İlçe Seç',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: RouteviaColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'İlçe ara...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _filtered = widget.districts);
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: _filtered.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  final isSelected = widget.selectedId == null;
                  return ListTile(
                    title: const Text(
                      'Tüm İl',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: RouteviaColors.teal,
                          )
                        : null,
                    onTap: () => Navigator.of(ctx).pop('__all__'),
                    selected: isSelected,
                    selectedTileColor: RouteviaColors.teal.withValues(
                      alpha: 0.05,
                    ),
                  );
                }
                final d = _filtered[i - 1];
                final id = d['id'] as String;
                final name = d['name'] as String;
                final isSelected = id == widget.selectedId;
                return ListTile(
                  title: Text(
                    name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? RouteviaColors.teal
                          : RouteviaColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: RouteviaColors.teal,
                        )
                      : null,
                  onTap: () => Navigator.of(ctx).pop(id),
                  selected: isSelected,
                  selectedTileColor: RouteviaColors.teal.withValues(
                    alpha: 0.05,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
