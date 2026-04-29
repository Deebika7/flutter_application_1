/// ============================================================================
/// CONCEPT: ChoiceChip — Material Selection Widget
/// ============================================================================
///
/// A row of filter chips (All / Pending / Completed) that lets the user
/// filter the task list. Only one chip is selected at a time.
///
/// KEY FLUTTER/DART CONCEPTS DEMONSTRATED:
///   - ChoiceChip (Material Design selection chip)
///   - Callback functions for parent communication
///   - List.map with .toList() to generate widgets from data
///   - Padding and layout with Row

import 'package:flutter/material.dart';

import '../../viewmodels/task_list_viewmodel.dart';
import '../../utils/constants.dart';

class FilterChipsRow extends StatelessWidget {
  final TaskFilter currentFilter;
  final int totalCount;
  final int pendingCount;
  final int completedCount;
  final ValueChanged<TaskFilter> onFilterChanged;

  const FilterChipsRow({
    super.key,
    required this.currentFilter,
    required this.totalCount,
    required this.pendingCount,
    required this.completedCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),

      /// CONCEPT: SingleChildScrollView for horizontal scrolling
      /// Wrapping a Row in a horizontal SingleChildScrollView prevents
      /// overflow on narrow screens. The chips scroll if they don't fit.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip(
              context,
              label: 'All ($totalCount)',
              filter: TaskFilter.all,
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildChip(
              context,
              label: 'Pending ($pendingCount)',
              filter: TaskFilter.pending,
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildChip(
              context,
              label: 'Completed ($completedCount)',
              filter: TaskFilter.completed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required TaskFilter filter,
  }) {
    final isSelected = currentFilter == filter;

    /// CONCEPT: ChoiceChip
    /// Like a radio button but styled as a Material chip.
    /// `selected` highlights the chip, `onSelected` fires on tap.
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onFilterChanged(filter),
    );
  }
}
