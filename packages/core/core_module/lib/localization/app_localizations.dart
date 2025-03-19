import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'translations/en_translations.dart';
import 'translations/es_translations.dart';

/// Supported locales for the app
const List<Locale> supportedLocales = [
  Locale('en', 'US'), // English
  Locale('es', 'ES'), // Spanish
];

/// Localization delegates for the app
const List<LocalizationsDelegate<dynamic>> localizationDelegates = [
  // AppLocalizations delegate
  AppLocalizations.delegate,
  // Built-in localization delegates
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Application localizations provider
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  /// Get current instance from BuildContext
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  /// Localizations delegate
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  /// Translation map based on locale
  late final Map<String, String> _localizedStrings;
  
  /// Initialize translations
  Future<bool> load() async {
    // Load the language JSON file
    _localizedStrings = _getTranslations(locale.languageCode);
    return true;
  }
  
  /// Get translation for a given key
  String translate(String key) {
    if (_localizedStrings.containsKey(key)) {
      return _localizedStrings[key]!;
    }
    // Return the key if no translation is found
    return key;
  }
  
  /// Get translations for a specific language code
  Map<String, String> _getTranslations(String languageCode) {
    switch (languageCode) {
      case 'en':
        return enTranslations;
      case 'es':
        return esTranslations;
      default:
        return enTranslations;
    }
  }
  
  /// Format a date according to locale
  String formatDate(DateTime date, {String? pattern}) {
    return DateFormat(pattern ?? 'dd/MM/yyyy', locale.languageCode).format(date);
  }
  
  /// Format currency according to locale
  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: locale.toString(), symbol: '\$').format(amount);
  }
}

/// Localizations delegate implementation
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
} 