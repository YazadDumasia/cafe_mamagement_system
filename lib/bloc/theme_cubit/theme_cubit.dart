import '../../utils/components/local_keys_enum.dart';
import '../../utils/components/local_manager.dart';
import 'theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(themeMode: ThemeMode.light));

  /// Toggles the current brightness between light and dark.
  Future<void> toggleTheme(bool? isDarkMode) async {
    if (isDarkMode == true) {
      await LocalManager.instance.setBoolValue(
        key: PreferencesKeys.appEnableDarkTheme,
        value: true,
      );
      emit(ThemeState(themeMode: ThemeMode.dark));
    } else {
      await LocalManager.instance.setBoolValue(
        key: PreferencesKeys.appEnableDarkTheme,
        value: false,
      );
      emit(ThemeState(themeMode: ThemeMode.light));
    }
  }

  Future<void> loadTheme() async {
    final bool isDarkMode = LocalManager.instance.getBoolValue(
      key: PreferencesKeys.appEnableDarkTheme,
    );
    final ThemeMode theme = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    emit(ThemeState(themeMode: theme));
  }

  Future<void> themeSelector(ThemeMode? themeMode) async {
    if (themeMode == ThemeMode.dark) {
      await LocalManager.instance.setBoolValue(
        key: PreferencesKeys.appEnableDarkTheme,
        value: true,
      );
      emit(ThemeState(themeMode: ThemeMode.dark));
    } else if (themeMode == ThemeMode.light) {
      await LocalManager.instance.setBoolValue(
        key: PreferencesKeys.appEnableDarkTheme,
        value: false,
      );
      emit(ThemeState(themeMode: ThemeMode.light));
    } else if (themeMode == ThemeMode.system) {
      await LocalManager.instance.setBoolValue(
        key: PreferencesKeys.appEnableDarkTheme,
        value: false,
      );
      emit(ThemeState(themeMode: ThemeMode.system));
    } else {
      await LocalManager.instance.setBoolValue(
        key: PreferencesKeys.appEnableDarkTheme,
        value: false,
      );
      emit(ThemeState(themeMode: ThemeMode.light));
    }
  }
}
