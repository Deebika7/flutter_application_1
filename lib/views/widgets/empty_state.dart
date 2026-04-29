/// ============================================================================
/// CONCEPT: Empty State Widget
/// ============================================================================
///
/// A placeholder shown when there are no tasks to display. Good UX always
/// provides feedback rather than showing a blank screen.
///
/// KEY FLUTTER/DART CONCEPTS DEMONSTRATED:
///   - Conditional rendering based on state
///   - Column layout with centering
///   - Icon widget with custom size and color
///   - Theme-aware text styling

import 'package:flutter/material.dart';

import '../../viewmodels/task_list_viewmodel.dart';
import '../../utils/constants.dart';

class EmptyState extends StatelessWidget {
  final TaskFilter filter;
  final bool isSearching;

  const EmptyState({
    super.key,
    required this.filter,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Choose the right message based on the current state.
    final (icon, title, subtitle) = _content();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// CONCEPT: Dart 3 RECORDS
  /// A record `(IconData, String, String)` returns multiple values
  /// without needing a separate class. Destructured with `final (a, b, c)`.
  (IconData, String, String) _content() {
    if (isSearching) {
      return (
        Icons.search_off,
        'No results',
        'Try a different search term.',
      );
    }

    switch (filter) {
      case TaskFilter.pending:
        return (
          Icons.check_circle_outline,
          'All caught up!',
          'No pending tasks. Enjoy the moment.',
        );
      case TaskFilter.completed:
        return (
          Icons.assignment_outlined,
          'Nothing completed yet',
          'Complete a task to see it here.',
        );
      case TaskFilter.all:
        return (
          Icons.add_task,
          'No tasks yet',
          'Tap the + button to create your first task.',
        );
    }
  }
}
