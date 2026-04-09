import '../../utils/components/local_keys_enum.dart';
import '../../utils/components/local_manager.dart';

class LanguagePreferences {
  // static const String _key = 'user_language';

  static Future<String> getLanguageCode() async {
    final String? data = LocalManager.instance.getStringValue(
      key: PreferencesKeys.userLanguage,
    );
    return data ?? 'en';
  }

  static Future<void> setLanguageCode(String languageCode) async {
    await LocalManager.instance.setStringValue(
      key: PreferencesKeys.userLanguage,
      value: languageCode,
    );
  }
}
