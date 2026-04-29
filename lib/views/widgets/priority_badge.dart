/// ============================================================================
/// CONCEPT: Small, Focused Reusable Widget
/// ============================================================================
///
/// A tiny widget that shows a colored badge for a task's priority level.
/// Demonstrates how to build small, composable UI pieces.
///
/// KEY FLUTTER/DART CONCEPTS DEMONSTRATED:
///   - Container + BoxDecoration for custom styling
///   - Passing enums as parameters
///   - Using utility classes (PriorityStyles) for consistent styling

import 'package:flutter/material.dart';

import '../../models/task.dart';
import '../../utils/constants.dart';

class PriorityBadge extends StatelessWidget {
  final Priority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = PriorityStyles.color(priority);

    /// CONCEPT: Container + BoxDecoration
    /// Container is one of Flutter's most versatile widgets. Combined with
    /// BoxDecoration, it can create rounded rectangles, circles, gradients,
    /// borders, shadows — almost any shape.
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        // withValues(alpha:) sets the opacity (0.0 = transparent, 1.0 = opaque).
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Shrink-wrap to content.
        children: [
          Icon(
            PriorityStyles.icon(priority),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
