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
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/locale/${language!.file}',
      );
      _localizedStrings = json.decode(jsonString);
      return true;
    } catch (e) {
      Constants.debugLog(
        AppLocalizations,
        "Error loading localization file: $e",
      );
      return false;
    }
  }

  String translate(String key, {Map<String, String>? params, String? track}) {
    if (_localizedStrings == null) {
      Constants.debugLog(AppLocalizations, "Localization file not loaded");
      return key;
    }

    String? translated;

    // 1) Handle track if provided
    if (track != null && track.isNotEmpty) {
      if (_localizedStrings!.containsKey(track)) {
        final trackData = _localizedStrings![track];
        if (trackData is Map<String, dynamic>) {
          // If key is 'common.common_back' and track is 'common',
          // we check for 'common_back' inside 'common'
          String subKey = key;
          if (key.startsWith('$track.')) {
            subKey = key.substring(track.length + 1);
          }

          if (trackData.containsKey(subKey)) {
            translated = trackData[subKey].toString();
          } else if (trackData.containsKey(key)) {
            translated = trackData[key].toString();
          }
        }
      }
    }

    // 2) If not found and key contains a dot, try parsing it as section.key
    if (translated == null && key.contains('.')) {
      final parts = key.split('.');
      if (parts.length >= 2) {
        final section = parts[0];
        final subKey = parts.sublist(1).join('.');
        if (_localizedStrings!.containsKey(section)) {
          final sectionData = _localizedStrings![section];
          if (sectionData is Map<String, dynamic> &&
              sectionData.containsKey(subKey)) {
            translated = sectionData[subKey].toString();
          }
        }
      }
    }

    // 3) Search root
    if (translated == null && _localizedStrings!.containsKey(key)) {
      translated = _localizedStrings![key].toString();
    }

    // 4) Search inside all sections
    if (translated == null) {
      for (final entry in _localizedStrings!.entries) {
        if (entry.value is Map<String, dynamic>) {
          final map = entry.value as Map<String, dynamic>;
          if (map.containsKey(key)) {
            translated = map[key].toString();
            break;
          }
        }
      }
    }

    if (translated == null) {
      Constants.debugLog(AppLocalizations, "Missing key: $key");
      return key;
    }

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        // Correct placeholder replacement: targets {paramKey} in the string
        translated = translated!.replaceAll('{$paramKey}', paramValue);
      });
    }

    return translated!;
  }

  static String getCurrentLanguageCode(BuildContext context) {
    final AppLocalizations? appLocalizations = AppLocalizations.of(context);

    if (appLocalizations != null) {
      final String? currentLanguageCode = appLocalizations.locale?.languageCode;
      return currentLanguageCode ?? 'en';
    } else {
      return 'en';
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

    // Attempt to match language code and country code if available
    language_model.LanguageModel? selectedLanguage;

    try {
      selectedLanguage = languages.firstWhere(
        (lang) =>
            lang.code == languageCode &&
            (lang.countryCode == null ||
                lang.countryCode == locale.countryCode),
      );
    } catch (_) {
      try {
        selectedLanguage = languages.firstWhere(
          (lang) => lang.code == languageCode,
        );
      } catch (_) {
        selectedLanguage = languages.firstWhere(
          (lang) => lang.code == 'en',
          orElse: () => languages.first,
        );
      }
    }

    final AppLocalizations localizations = AppLocalizations(
      locale,
      selectedLanguage,
    );
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
