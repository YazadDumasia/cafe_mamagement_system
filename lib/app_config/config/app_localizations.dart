import 'dart:async';
import 'dart:convert';
import 'package:cafe_mamagement_system/utils/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'language_preferences.dart' as language_preferences;
import '../../model/language_model/language_model.dart' as language_model;

class AppLocalizations {
  AppLocalizations(this.locale, this.language);

  final Locale? locale;
  language_model.LanguageModel? language;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Map<String, dynamic>? _localizedStrings;

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

  String translate(String key, {Map<String, String>? params, String? track}) {
    if (_localizedStrings == null) {
      Constants.debugLog(AppLocalizations, "Localization file not loaded");
      return key;
    }

    dynamic current = _localizedStrings;

    // 1) Track provided: search inside track section
    if (track != null && track.isNotEmpty) {
      if (current is Map<String, dynamic> && current.containsKey(track)) {
        final trackMap = current[track];

        if (trackMap is Map<String, dynamic> && trackMap.containsKey(key)) {
          String translated = trackMap[key].toString();

          if (params != null) {
            params.forEach((paramKey, paramValue) {
              translated = translated.replaceAll('\${$paramKey}', paramValue);
            });
          }

          return translated;
        }
      }

      Constants.debugLog(
        AppLocalizations,
        "Missing key: $key in track: $track",
      );
      return key;
    }

    // 2) No track: search root first
    if (current is Map<String, dynamic> && current.containsKey(key)) {
      String translated = current[key].toString();

      if (params != null) {
        params.forEach((paramKey, paramValue) {
          translated = translated.replaceAll('\${$paramKey}', paramValue);
        });
      }

      return translated;
    }

    // 3) No track: search inside all sections (common, recipes, login_page etc.)
    if (current is Map<String, dynamic>) {
      for (final entry in current.entries) {
        final value = entry.value;

        if (value is Map<String, dynamic> && value.containsKey(key)) {
          String translated = value[key].toString();

          if (params != null) {
            params.forEach((paramKey, paramValue) {
              translated = translated.replaceAll('\${$paramKey}', paramValue);
            });
          }

          return translated;
        }
      }
    }

    Constants.debugLog(
      AppLocalizations,
      "Missing key: $key (searched all tracks)",
    );
    return key;
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
  bool shouldReload(AppLocalizationsDelegate old) => true;
}

extension LocalizationExt on BuildContext {
  String? tr(String key, {Map<String, String>? params, String? track}) {
    return AppLocalizations.of(
          this,
        )?.translate(key, params: params, track: track);
  }
}

// context.tr("common.common_back", track:"common");

//
// AppLocalizations.of(context).translate('Key_name'),
