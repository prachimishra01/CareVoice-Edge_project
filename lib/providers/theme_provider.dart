import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider responsible for managing application theme mode (System, Light, Dark)
/// and persisting the user choice locally via SharedPreferences.
class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = 'carevoice_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isSystem => _themeMode == ThemeMode.system;
  bool get isLight => _themeMode == ThemeMode.light;
  bool get isDark => _themeMode == ThemeMode.dark;

  String get modeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Helper to determine if dark mode is active in current context
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Initialize and load stored theme preference from local storage
  Future<void> bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themePrefKey);
      if (savedMode == 'light') {
        _themeMode = ThemeMode.light;
      } else if (savedMode == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved theme preference: $e');
    }
  }

  /// Update the current ThemeMode and persist to SharedPreferences
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      switch (mode) {
        case ThemeMode.light:
          await prefs.setString(_themePrefKey, 'light');
          break;
        case ThemeMode.dark:
          await prefs.setString(_themePrefKey, 'dark');
          break;
        case ThemeMode.system:
          await prefs.setString(_themePrefKey, 'system');
          break;
      }
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Toggle between Light and Dark mode
  Future<void> toggleTheme(BuildContext context) async {
    final currentIsDark = isDarkMode(context);
    await setThemeMode(currentIsDark ? ThemeMode.light : ThemeMode.dark);
  }
}
