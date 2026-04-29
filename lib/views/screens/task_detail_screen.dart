/// ============================================================================
/// CONCEPT: Detail Screen — Reading Route Arguments, Chip Widgets
/// ============================================================================
///
/// This screen displays the full details of a single task.
/// It demonstrates reading data passed via route arguments and
/// building a rich, readable detail layout.
///
/// KEY FLUTTER/DART CONCEPTS DEMONSTRATED:
///   - ModalRoute.of(context).settings.arguments (reading route arguments)
///   - Chip / ActionChip widgets
///   - Card and ListTile for structured layouts
///   - Theme.of(context) for accessing current theme colors
///   - Navigator.pushNamed for edit navigation
///   - context.mounted check after async operations

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../viewmodels/task_list_viewmodel.dart';
import '../../utils/constants.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------------------
    // CONCEPT: Reading route arguments
    // -------------------------------------------------------------------------
    // When navigating with `Navigator.pushNamed(context, route, arguments: x)`,
    // the receiving screen reads `arguments` from `ModalRoute.of(context)`.
    final task = ModalRoute.of(context)!.settings.arguments as Task;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          // Edit button.
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit task',
            onPressed: () {
              Navigator.pushNamed(
                context,
                Routes.editTask,
                arguments: task,
              );
            },
          ),

          // Delete button.
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete task',
            onPressed: () => _confirmAndDelete(context, task),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------------------------
            // TITLE + STATUS BADGE
            // -----------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      // CONCEPT: TextDecoration — strikethrough for completed tasks.
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // CONCEPT: Chip widget — a compact element for labels/tags.
                Chip(
                  label: Text(task.isCompleted ? 'Done' : 'Pending'),
                  backgroundColor: task.isCompleted
                      ? Colors.green.withValues(alpha: 0.2)
                      : colorScheme.primaryContainer,
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // -----------------------------------------------------------------
            // INFO CARDS
            // -----------------------------------------------------------------
            // CONCEPT: Card + ListTile — a Material pattern for structured info.
            Card(
              child: Column(
                children: [
                  // Priority row.
                  ListTile(
                    leading: Icon(
                      PriorityStyles.icon(task.priority),
                      color: PriorityStyles.color(task.priority),
                    ),
                    title: const Text('Priority'),
                    trailing: Text(
                      task.priority.label,
                      style: TextStyle(
                        color: PriorityStyles.color(task.priority),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Divider(height: 1),

                  // Created date row.
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Created'),
                    trailing: Text(
                      DateFormat.yMMMd().add_jm().format(task.createdAt),
                    ),
                  ),

                  // Due date row (only shown if a due date is set).
                  if (task.dueDate != null) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.calendar_today,
                        color: _isDueOrOverdue(task.dueDate!)
                            ? colorScheme.error
                            : null,
                      ),
                      title: const Text('Due Date'),
                      trailing: Text(
                        DateFormat.yMMMd().format(task.dueDate!),
                        style: TextStyle(
                          color: _isDueOrOverdue(task.dueDate!)
                              ? colorScheme.error
                              : null,
                          fontWeight: _isDueOrOverdue(task.dueDate!)
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // -----------------------------------------------------------------
            // DESCRIPTION
            // -----------------------------------------------------------------
            Text(
              'Description',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  task.description,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // -----------------------------------------------------------------
            // TOGGLE STATUS BUTTON
            // -----------------------------------------------------------------
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _toggleAndPop(context, task),
                icon: Icon(
                  task.isCompleted
                      ? Icons.undo
                      : Icons.check_circle_outline,
                ),
                label: Text(
                  task.isCompleted
                      ? 'Mark as Pending'
                      : 'Mark as Completed',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: task.isCompleted
                      ? colorScheme.secondary
                      : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Checks if the due date is today or in the past (overdue).
  bool _isDueOrOverdue(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.compareTo(today) <= 0;
  }

  /// Toggle status and go back to the home screen.
  Future<void> _toggleAndPop(BuildContext context, Task task) async {
    await context.read<TaskListViewModel>().toggleTaskStatus(task);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  /// Confirm deletion, delete, and navigate back.
  Future<void> _confirmAndDelete(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<TaskListViewModel>().deleteTask(task.id!);

      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
