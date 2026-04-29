/// ============================================================================
/// CONCEPT: Reusable Custom Widget (StatelessWidget)
/// ============================================================================
///
/// This is a reusable widget that displays a single task as a card.
/// It's extracted into its own file because:
///   1. It keeps the home screen clean and readable.
///   2. It can be reused in other screens (e.g., search results).
///   3. It follows the "composition over inheritance" principle.
///
/// KEY FLUTTER/DART CONCEPTS DEMONSTRATED:
///   - StatelessWidget (no internal state — everything comes from props)
///   - Callback functions as props (onTap, onToggleStatus)
///   - const constructors (enables compile-time optimizations)
///   - AnimatedContainer (implicit animation)
///   - Checkbox widget
///   - Theme.of(context) for dynamic theming
///   - String interpolation with DateFormat

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/task.dart';
import '../../utils/constants.dart';
import 'priority_badge.dart';

/// ============================================================================
/// TaskCard — a StatelessWidget
/// ============================================================================
///
/// CONCEPT: STATELESSWIDGET
/// A StatelessWidget has no mutable state. Its appearance is entirely
/// determined by the data passed in (the constructor parameters).
/// When the parent rebuilds with new data, this widget rebuilds too.
///
/// Use StatelessWidget when:
///   - The widget only displays data, it doesn't manage its own state.
///   - All data comes from outside (parent widget or Provider).
class TaskCard extends StatelessWidget {
  /// The task data to display.
  final Task task;

  /// Called when the user taps the card (navigates to detail screen).
  ///
  /// CONCEPT: CALLBACK FUNCTIONS AS PROPS
  /// Instead of handling navigation inside this widget, we let the parent
  /// decide what happens on tap. This makes TaskCard reusable — different
  /// screens can pass different onTap behaviors.
  final VoidCallback onTap;

  /// Called when the user taps the checkbox.
  final VoidCallback onToggleStatus;

  /// CONCEPT: CONST CONSTRUCTOR
  /// `const` means this widget can be created at compile time if all
  /// parameters are also const. This is a performance optimization —
  /// Flutter can skip rebuilding const widgets.
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // -------------------------------------------------------------------------
    // CONCEPT: AnimatedContainer
    // -------------------------------------------------------------------------
    // An IMPLICIT ANIMATION. Unlike explicit animations (which need an
    // AnimationController), implicit animations just animate automatically
    // when their properties change.
    //
    // Here, when a task's `isCompleted` changes, the opacity animates
    // smoothly from 1.0 to 0.6 (or vice versa).
    return AnimatedContainer(
      duration: AppDurations.medium,
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),

      child: Card(
        // Reduce opacity for completed tasks → visual feedback.
        color: task.isCompleted
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
            : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                // -----------------------------------------------------------
                // CHECKBOX — toggles task completion
                // -----------------------------------------------------------
                /// CONCEPT: Checkbox
                /// A Material checkbox with a circular shape (custom via `shape`).
                /// `onChanged` fires when the user taps it.
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => onToggleStatus(),
                  shape: const CircleBorder(),
                ),

                // -----------------------------------------------------------
                // TASK INFO (title, description, metadata)
                // -----------------------------------------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title — with strikethrough if completed.
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      // Description preview — just the first line.
                      Text(
                        task.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      // Metadata row: priority badge + due date.
                      Row(
                        children: [
                          PriorityBadge(priority: task.priority),
                          if (task.dueDate != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat.MMMd().format(task.dueDate!),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow indicating the card is tappable.
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
