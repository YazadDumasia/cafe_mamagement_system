import '../../database/database_helper.dart';
import 'local_keys_enum.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalManager {
  LocalManager._init() {
    SharedPreferences.getInstance().then((value) => _preferences = value);
  }
  SharedPreferences? _preferences;

  static final LocalManager _instance = LocalManager._init();

  static LocalManager get instance => _instance;

  static Future preferencesInit() async {
    _instance._preferences = await SharedPreferences.getInstance();
  }

  Future<void> clearAll() async {
    final String? userLanguage = getStringValue(
      key: PreferencesKeys.USER_LANGUAGE,
    );
    await DatabaseHelper.instance.clearDatabase();
    await _preferences!.clear();
    await DefaultCacheManager().emptyCache();
    await setStringValue(
      key: PreferencesKeys.USER_LANGUAGE,
      value: userLanguage,
    );
    await setBoolValue(
      key: PreferencesKeys.APP_ENABLE_DARK_THEME,
      value: false,
    );
    await setBoolValue(key: PreferencesKeys.IS_FIRST_APP, value: false);
    await setBoolValue(key: PreferencesKeys.IS_LOGGED_IN, value: false);
    await setBoolValue(key: PreferencesKeys.COMMON_FIRST_TIME, value: false);
    await setBoolValue(
      key: PreferencesKeys.APP_ENABLE_DARK_THEME,
      value: false,
    );
  }

  Future<void> clearAllSaveFirst() async {
    if (_preferences != null) {
      // bool theme_flag=getBoolValue(PreferencesKeys.APP_ENABLE_DARK_THEME);
      final String? userLanguage = getStringValue(
        key: PreferencesKeys.USER_LANGUAGE,
      );
      await _preferences!.clear();
      await DefaultCacheManager().emptyCache();
      await setStringValue(
        key: PreferencesKeys.USER_LANGUAGE,
        value: userLanguage,
      );
      await setBoolValue(key: PreferencesKeys.IS_FIRST_APP, value: true);
      await setBoolValue(key: PreferencesKeys.IS_LOGGED_IN, value: false);
      await setBoolValue(key: PreferencesKeys.COMMON_FIRST_TIME, value: false);
      await setBoolValue(
        key: PreferencesKeys.APP_ENABLE_DARK_THEME,
        value: false,
      );
    }
  }

  Future<void> setStringValue({
    required PreferencesKeys key,
    required String? value,
  }) async {
    await _preferences!.setString(key.toString(), value ?? '');
  }

  String? getStringValue({required PreferencesKeys key}) =>
      _preferences?.getString(key.toString()) ?? '';

  Future<void> setIntValue({required PreferencesKeys key, int? value}) async {
    await _preferences!.setInt(key.toString(), value ?? 0);
  }

  int? getIntValue({required PreferencesKeys key}) =>
      _preferences?.getInt(key.toString());

  Future<void> setDoubleValue({
    required PreferencesKeys key,
    required double? value,
  }) async {
    await _preferences!.setDouble(key.toString(), value ?? 0.0);
  }

  double? getDoubleValue({required PreferencesKeys key}) =>
      _preferences?.getDouble(key.toString());

  Future<void> setBoolValue({
    required PreferencesKeys key,
    required bool value,
  }) async {
    await _preferences!.setBool(key.toString(), value);
  }

  bool getBoolValue({required PreferencesKeys? key}) =>
      _preferences?.getBool(key.toString()) ?? false;

  bool get isLoggedIn => getBoolValue(key: PreferencesKeys.IS_LOGGED_IN);

  set isLoggedIn(bool value) =>
      setBoolValue(key: PreferencesKeys.IS_LOGGED_IN, value: value);
}

//await LocalManager.instance.setStringValue(
//   key: PreferencesKeys.USER_NAME,
//   value: "John Doe",
// );
