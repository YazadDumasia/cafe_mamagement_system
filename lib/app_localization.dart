import 'dart:async';
import 'dart:convert';
import 'package:cafe_mamagement_system/utils/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_config/config/language_preferences.dart' as language_preferences;
import 'model/language_model/language_model.dart' as language_model;

class AppLocalizations {
  AppLocalizations(this.locale, this.language);
  final Locale? locale;
  language_model.LanguageModel? language;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Map<String, String>? _localizedStrings;

  Future<bool> load() async {
    final String jsonString = await rootBundle.loadString(
      'assets/locale/${language!.file}',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String? translate(String key, {Map<String, String>? params}) {
    if (_localizedStrings == null) {
      Constants.debugLog(AppLocalizations, 'Please check json file path.');
      return null;
    }

    if (!_localizedStrings!.containsKey(key)) {
      Constants.debugLog(AppLocalizations, 'String key is not found: $key');
      return null;
    }

    String translated = _localizedStrings![key]!;

    // Replace params like ${tableName} with actual values
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        translated = translated.replaceAll('\${$paramKey}', paramValue);
      });
    }

    return translated;
  }

  static String getCurrentLanguageCode(BuildContext context) {
    final AppLocalizations? appLocalizations = AppLocalizations.of(context);

    if (appLocalizations != null) {
      final String? currentLanguageCode = appLocalizations.locale?.languageCode;
      return currentLanguageCode ??
          'en'; // Default to "en" if the language code is not available
    } else {
      return 'en'; // Default to "en" if AppLocalizations instance is not available
    }
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate(this.languages);
  final List<language_model.LanguageModel> languages;

  @override
  bool isSupported(Locale locale) {
    return languages
        .map((language) => language.code)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final String languageCode =
        await language_preferences.LanguagePreferences.getLanguageCode();
    final language_model.LanguageModel language = languages.firstWhere(
      (language) => language.code == languageCode,
      orElse: () => languages.firstWhere((language) => language.code == 'en'),
    );

    final AppLocalizations localizations = AppLocalizations(locale, language);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

//
// AppLocalizations.of(context).translate('Key_name'),
