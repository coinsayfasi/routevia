import 'package:flutter/material.dart';
import '../../core/i18n.dart';
import '../../models/trip_models.dart';
import '../../models/return_plan.dart';

class QuickPlanChoice {
  const QuickPlanChoice(
    this.minutes,
    this.mode,
    this.returnPlan,
    this.requiredPlaceId,
  );
  final int minutes;
  final String mode;
  final ReturnPlan? returnPlan;
  final String? requiredPlaceId;
}

class QuickPlanSheet extends StatefulWidget {
  const QuickPlanSheet({
    super.key,
    required this.isPro,
    required this.onPro,
    this.lat,
    this.lng,
    this.savedPlaces = const [],
    this.candidates = const [],
  });
  final bool isPro;
  final VoidCallback onPro;
  final double? lat;
  final double? lng;
  final List<PlaceModel> savedPlaces;
  final List<PlaceModel> candidates;
  @override
  State<QuickPlanSheet> createState() => _QuickPlanSheetState();
}

class _QuickPlanSheetState extends State<QuickPlanSheet> {
  int _minutes = 120;
  String _mode = 'walk';
  bool _protectReturn = false;
  String? _destination;
  String? _required;
  TimeOfDay? _deadline;
  String? _error;

  bool get _hasOrigin => widget.lat != null && widget.lng != null;
  List<PlaceModel> get _saved =>
      widget.savedPlaces.where((p) => p.lat != null && p.lng != null).toList();

  void _submit() {
    ReturnPlan? returnPlan;
    if (_protectReturn) {
      final now = DateTime.now();
      final time = _deadline;
      if (_destination == null || time == null) {
        setState(
          () => _error = context.tr(
            'Dönüş noktası ve saatini seç.',
            'Choose a return point and time.',
          ),
        );
        return;
      }
      final deadline = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (!deadline.isAfter(now.add(const Duration(minutes: 15)))) {
        setState(
          () => _error = context.tr(
            'Bugün için en az 15 dakika ileride bir saat seç.',
            'Choose a time at least 15 minutes from now today.',
          ),
        );
        return;
      }
      final place = _saved.where((p) => p.id == _destination).firstOrNull;
      returnPlan = ReturnPlan(
        label: place?.name ?? context.tr('Başladığım nokta', 'Starting point'),
        lat: place?.lat ?? widget.lat!,
        lng: place?.lng ?? widget.lng!,
        deadline: deadline,
      );
    }
    Navigator.pop(
      context,
      QuickPlanChoice(
        _minutes,
        _mode,
        returnPlan,
        _protectReturn ? _required : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(
              'Bugün ne kadar vaktin var?',
              'How much time do you have?',
            ),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              for (final option in [
                (120, context.tr('2 saat', '2 hours')),
                (240, context.tr('Yarım gün', 'Half day')),
                (480, context.tr('Tam gün', 'Full day')),
              ])
                ChoiceChip(
                  label: Text(option.$2),
                  selected: _minutes == option.$1,
                  onSelected: (_) => setState(() => _minutes = option.$1),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final option in [
                (
                  'walk',
                  context.tr('Yürüyerek', 'Walking'),
                  Icons.directions_walk,
                ),
                (
                  'car',
                  context.tr('Arabayla', 'Driving'),
                  Icons.directions_car,
                ),
              ])
                ChoiceChip(
                  avatar: Icon(option.$3),
                  label: Text(option.$2),
                  selected: _mode == option.$1,
                  onSelected: (_) => setState(() => _mode = option.$1),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              context.tr(
                'Dönüş saatimi koru · Pro',
                'Protect my return time · Pro',
              ),
            ),
            subtitle: Text(
              context.tr(
                'Dönüş yolunu ve 15 dk zaman payını ayır.',
                'Include return travel and a 15 min buffer.',
              ),
            ),
            value: _protectReturn,
            onChanged: (value) {
              if (value && !widget.isPro) {
                widget.onPro();
                return;
              }
              setState(() {
                _protectReturn = value;
                _error = null;
                if (_hasOrigin) _destination ??= 'origin';
              });
            },
          ),
          if (_protectReturn) ...[
            DropdownButtonFormField<String>(
              initialValue: _destination,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: context.tr(
                  'Nereye döneceksin?',
                  'Where will you return?',
                ),
              ),
              items: [
                if (_hasOrigin)
                  DropdownMenuItem(
                    value: 'origin',
                    child: Text(
                      context.tr('Başladığım nokta', 'Starting point'),
                    ),
                  ),
                ..._saved.map(
                  (p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _destination = v),
            ),
            if (!_hasOrigin && _saved.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  context.tr(
                    'Konumunu aç veya dönüş yerini önce favorilerine kaydet.',
                    'Enable location or save your return point to favorites first.',
                  ),
                ),
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(
                _deadline == null
                    ? context.tr(
                        'Bugünkü dönüş saatini seç',
                        'Choose today’s return time',
                      )
                    : _deadline!.format(context),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      _deadline ??
                      TimeOfDay.fromDateTime(
                        DateTime.now().add(const Duration(hours: 3)),
                      ),
                );
                if (time != null && mounted) setState(() => _deadline = time);
              },
            ),
            if (widget.candidates.isNotEmpty)
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: context.tr(
                    'Mutlaka görmek istiyorum (isteğe bağlı)',
                    'Must-see stop (optional)',
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text(context.tr('Tercihim yok', 'No preference')),
                  ),
                  ...widget.candidates.map(
                    (p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (v) =>
                    setState(() => _required = v == '' ? null : v),
              ),
          ],
          const SizedBox(height: 12),
          Text(
            _protectReturn
                ? context.tr(
                    'Plan seçtiğin süreyi ve dönüş saatini birlikte gözetir. Varış saati tahminidir; canlı trafik dahil değildir.',
                    'The plan respects both your time budget and return deadline. Arrival is estimated; live traffic is not included.',
                  )
                : context.tr(
                    'Yol ve ziyaret süreleri dahil. Dönüş yolculuğu dahil değil.',
                    'Travel and visits included. Return travel is not included.',
                  ),
          ),
          if (!_hasOrigin)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                context.tr(
                  'Başlangıç: ilk durak. Oraya ulaşım süresi dahil değil.',
                  'Starts at the first stop. Travel to it is not included.',
                ),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.route),
              label: Text(context.tr('Rotamı oluştur', 'Create my route')),
            ),
          ),
        ],
      ),
    ),
  );
}
