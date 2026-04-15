import 'dart:math' as math;
import 'package:cafe_mamagement_system/utils/components/global.dart'as global;
import 'package:cafe_mamagement_system/utils/components/local_keys_enum.dart'as pk;
import 'package:cafe_mamagement_system/utils/components/platform_utils.dart' as pu;
import 'package:shared_preferences/shared_preferences.dart' as sp;

import '../../model/translator_language/translator_language.dart' as tlasm;

class Constants {
  static Map<String, String> hashMap = <String, String>{};
  static const String kValidHexPattern = r'^#?[0-9a-fA-F]{1,8}';

  static void debugLog(Type? classObject, String? message) {
    pu.PlatformUtils.debugLog(classObject, message);
  }

  static String? getValueFromKey(
    String? internetString,
    String? startInternetString,
    String? appendInternetString,
    String? defaultString, {
    required Type? classObject,
  }) {
    if (internetString == null || internetString.isEmpty) {
      return defaultString.toString();
    } else {
      if (Constants.hashMap.isEmpty) {
        return defaultString.toString();
      } else {
        if (Constants.hashMap.containsKey(
          internetString.toString().trim().toLowerCase(),
        )) {
          final String str =
              (startInternetString ?? '') +
              Constants.hashMap[internetString.toLowerCase()]!.toString() +
              (appendInternetString ?? '');
          return str;
        } else {
          Constants.debugLog(
            classObject ?? Constants,
            'String Not Found:$internetString',
          );
          return defaultString.toString().trim();
        }
      }
    }
  }

static Future<bool> isFirstTime(String? str) async {
  final prefs = await sp.SharedPreferences.getInstance();
  final key = str ?? pk.PreferencesKeys.commonFirstTime.toString();

  // 1. Get the current value, default to true if null
  final isFirst = prefs.getBool(key) ?? true;

  // 2. If it's the first time, update the value to false in the background
  if (isFirst) {
    // We don't necessarily need to 'await' this if we want a faster UI response
    await prefs.setBool(key, false);
  }

  return isFirst;
}

  static int? randomNumberGenerator(int? min, int? max) {
    final int randomise = min! + math.Random().nextInt(max! - min);
    Constants.debugLog(Constants, 'randomNumberMinMax:$randomise');
    if (randomise >= min && randomise <= max) {
      return randomise;
    } else {
      return randomNumberGenerator(min, max);
    }
  }

    static List<tlasm.TranslatorLanguageModel> languages = global.jsonLanguagesData
      .map((data) => tlasm.TranslatorLanguageModel.fromJson(data))
      .toList();

}
