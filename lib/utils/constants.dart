/// ============================================================================
/// CONCEPT: App-Wide Constants
/// ============================================================================
///
/// Centralize magic values (strings, sizes, durations) in one place.
/// This prevents typos, makes refactoring easier, and keeps the codebase DRY
/// (Don't Repeat Yourself).
///
/// KEY DART CONCEPTS DEMONSTRATED:
///   - `abstract class` with only `static const` members (no instantiation)
///   - Organizing constants by category

import 'package:flutter/material.dart';
import '../models/task.dart';

/// Route names for Navigator. Using constants prevents typos like '/hom' vs '/home'.
abstract class Routes {
  static const String home = '/';
  static const String addTask = '/add-task';
  static const String editTask = '/edit-task';
  static const String taskDetail = '/task-detail';
}

/// Animation durations used throughout the app.
abstract class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
}

/// Padding and spacing values. Using a consistent scale keeps the UI uniform.
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Maps each Priority to a color and icon for the UI.
/// This is better than scattering switch statements across widgets.
abstract class PriorityStyles {
  static Color color(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
    }
  }

  static IconData icon(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Icons.arrow_downward;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.arrow_upward;
    }
  }
}
