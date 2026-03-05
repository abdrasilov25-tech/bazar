import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  final Map<String, String> _strings;

  const AppLocalizations._(this.locale, this._strings);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ru'),
    Locale('en'),
    Locale('kk'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String t(String key) => _strings[key] ?? key;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ru', 'en', 'kk'].contains(locale.languageCode.toLowerCase());

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final lang = locale.languageCode.toLowerCase();
    final path = 'assets/i18n/$lang.json';
    final jsonStr = await rootBundle.loadString(path);
    final Map<String, dynamic> data = json.decode(jsonStr) as Map<String, dynamic>;
    final map = data.map((key, value) => MapEntry(key, value.toString()));
    return AppLocalizations._(locale, map);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

