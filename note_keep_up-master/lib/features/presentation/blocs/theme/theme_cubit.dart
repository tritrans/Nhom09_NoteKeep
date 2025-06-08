// ignore_for_file: unused_element

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences sharedPreferences;
  ThemeCubit({required this.sharedPreferences}) : super(ThemeInitial());

  void getCurrentThemeMode() async {
    final ThemeMode themeMode = await _getCachedThemeMode();
    final String fontFamily = await _getCachedFontFamily();
    emit(LoadedTheme(themeMode, fontFamily));
  }

  void themesChanged(AppThemes appThemes) async {
    final String fontFamily = await _getCachedFontFamily();
    emit(LoadedTheme(appThemes.mode, fontFamily));
    await _cacheThemeMode(appThemes.index);
  }

  void fontChanged(String fontFamily) async {
    final ThemeMode themeMode = await _getCachedThemeMode();
    emit(LoadedTheme(themeMode, fontFamily));
    await _cacheFontFamily(fontFamily);
  }

  Future<ThemeMode> _getCachedThemeMode() async {
    final int? cachedThemeModeIndex = sharedPreferences.getInt("Theme_Box");

    if (cachedThemeModeIndex != null) {
      return AppThemes.values[cachedThemeModeIndex].mode;
    } else {
      return AppThemes.values[2].mode;
    }
  }

  Future<String> _getCachedFontFamily() async {
    return sharedPreferences.getString("Font_Family") ?? "Roboto";
  }

  Future<void> _cacheThemeMode(int themeModeIndex) async {
    await sharedPreferences.setInt("Theme_Box", themeModeIndex);
  }

  Future<void> _cacheFontFamily(String fontFamily) async {
    await sharedPreferences.setString("Font_Family", fontFamily);
  }

  void setThemeMode(ThemeMode mode) {
    if (state is LoadedTheme) {
      final currentState = state as LoadedTheme;
      emit(LoadedTheme(mode, currentState.fontFamily));
    }
  }

  void setFontFamily(String fontFamily) {
    if (state is LoadedTheme) {
      final currentState = state as LoadedTheme;
      emit(LoadedTheme(currentState.themeMode, fontFamily));
    }
  }
}
