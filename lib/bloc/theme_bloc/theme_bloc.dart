import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/components/local_keys_enum.dart';
import '../../utils/components/local_manager.dart';
import 'package:flutter/material.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(themeMode: ThemeMode.light)) {
    //context.read<ThemeBloc>().add(ThemeLoadRequested());
    // context.read<ThemeBloc>().add(ThemeToggleRequested(true));
    // context.read<ThemeBloc>().add(ThemeSelected(ThemeMode.system));
    //final themeMode = context.read<ThemeBloc>().state.themeMode;
    on<ThemeEvent>((event, emit) {
      on<ThemeLoadRequested>(_onLoadTheme);
      on<ThemeToggleRequested>(_onToggleTheme);
      on<ThemeSelected>(_onThemeSelected);
    });
  }

  Future<void> _onLoadTheme(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final bool isDarkMode = LocalManager.instance.getBoolValue(
      key: PreferencesKeys.appEnableDarkTheme,
    );

    final ThemeMode theme = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    emit(ThemeState(themeMode: theme));
  }

  Future<void> _onToggleTheme(
    ThemeToggleRequested event,
    Emitter<ThemeState> emit,
  ) async {
    if (event.isDarkMode == true) {
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

  Future<void> _onThemeSelected(
    ThemeSelected event,
    Emitter<ThemeState> emit,
  ) async {
    if (event.themeMode == ThemeMode.dark) {
      await LocalManager.instance.setBoolValue(
        key: PreferencesKeys.appEnableDarkTheme,
        value: true,
      );
      emit(ThemeState(themeMode: ThemeMode.dark));
    } else if (event.themeMode == ThemeMode.light) {
      await LocalManager.instance.setBoolValue(
        key: PreferencesKeys.appEnableDarkTheme,
        value: false,
      );
      emit(ThemeState(themeMode: ThemeMode.light));
    } else if (event.themeMode == ThemeMode.system) {
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
