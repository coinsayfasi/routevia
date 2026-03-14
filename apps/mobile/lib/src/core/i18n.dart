import 'package:flutter/widgets.dart';

extension RouteviaI18nX on BuildContext {
  bool get isEnglish => Localizations.localeOf(this).languageCode == 'en';

  String tr(String trText, String enText) => isEnglish ? enText : trText;
}
