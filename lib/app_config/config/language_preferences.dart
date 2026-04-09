import '../../utlis/utlis.dart' as utlis;

class LanguagePreferences {
  // static const String _key = 'user_language';

  static Future<String> getLanguageCode() async {
    final String? data = utlis.LocalManager.instance.getStringValue(
      key: utlis.PreferencesKeys.userLanguage,
    );
    return data ?? 'en';
  }

  static Future<void> setLanguageCode(String languageCode) async {
    await utlis.LocalManager.instance.setStringValue(
      key: utlis.PreferencesKeys.userLanguage,
      value: languageCode,
    );
  }
}
