import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final FlutterSecureStorage _storage;
  static const String _themeStorageKey = 'app_theme_mode';

  ThemeCubit({required FlutterSecureStorage storage})
      : _storage = storage,
        super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final savedTheme = await _storage.read(key: _themeStorageKey);
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            emit(ThemeMode.light);
            break;
          case 'dark':
            emit(ThemeMode.dark);
            break;
          case 'system':
          default:
            emit(ThemeMode.system);
            break;
        }
      }
    } catch (_) {
      emit(ThemeMode.system);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    try {
      String modeString;
      switch (mode) {
        case ThemeMode.light:
          modeString = 'light';
          break;
        case ThemeMode.dark:
          modeString = 'dark';
          break;
        case ThemeMode.system:
          modeString = 'system';
          break;
      }
      await _storage.write(key: _themeStorageKey, value: modeString);
    } catch (_) {}
  }

  Future<void> toggleTheme(Brightness currentBrightness) async {
    if (state == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      if (currentBrightness == Brightness.dark) {
        await setThemeMode(ThemeMode.light);
      } else {
        await setThemeMode(ThemeMode.dark);
      }
    }
  }
}
