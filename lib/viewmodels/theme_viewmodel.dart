/// ============================================================================
/// CONCEPT: Multiple ViewModels + Theme Switching
/// ============================================================================
///
/// Each ViewModel should manage ONE concern. This ViewModel manages the
/// app's theme mode (light/dark). It's separate from TaskListViewModel
/// because theming is a cross-cutting concern — not specific to tasks.
///
/// KEY FLUTTER/DART CONCEPTS DEMONSTRATED:
///   - ThemeMode enum (system, light, dark)
///   - Separate ViewModel per concern (Single Responsibility Principle)
///   - ChangeNotifier for reactive theme updates

import 'package:flutter/material.dart';

class ThemeViewModel extends ChangeNotifier {
  /// Current theme mode. Defaults to system (follows device settings).
  ThemeMode _themeMode = ThemeMode.system;

  /// Public getter — the View reads this to set `MaterialApp.themeMode`.
  ThemeMode get themeMode => _themeMode;

  /// Convenience getters for the UI (e.g., to show the correct icon).
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Cycles through: system → light → dark → system.
  void toggleTheme() {
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  /// Sets a specific theme mode directly.
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Returns the icon to display for the current theme mode.
  IconData get themeIcon {
    switch (_themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  /// Returns a label for the current theme mode (for tooltips, etc.).
  String get themeLabel {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'System theme';
      case ThemeMode.light:
        return 'Light theme';
      case ThemeMode.dark:
        return 'Dark theme';
    }
  }
}
