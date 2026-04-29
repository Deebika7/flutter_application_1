/// ============================================================================
/// CONCEPT: The View Layer — Home Screen
/// ============================================================================
///
/// In MVVM, the VIEW is responsible ONLY for:
///   1. Building the widget tree (what the user sees)
///   2. Reading state from the ViewModel
///   3. Calling ViewModel methods in response to user actions
///
/// The View does NOT contain business logic, database calls, or data
/// manipulation. All of that lives in the ViewModel.
///
/// KEY FLUTTER/DART CONCEPTS DEMONSTRATED:
///   - StatefulWidget + initState lifecycle
///   - context.watch<T>() — rebuilds when ViewModel changes
///   - context.read<T>() — reads ViewModel once (for calling methods)
///   - ListView.builder — efficient scrollable list
///   - Dismissible — swipe-to-delete gesture
///   - AnimatedSwitcher — smooth widget transitions
///   - SnackBar — temporary feedback messages
///   - SearchBar integration
///   - Navigator.pushNamed — named route navigation
///   - FloatingActionButton
///   - SafeArea — respects device notches and system bars

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/task_list_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../models/task.dart';
import '../../utils/constants.dart';
import '../widgets/task_card.dart';
import '../widgets/filter_chips.dart';
import '../widgets/empty_state.dart';

/// ============================================================================
/// HOME SCREEN — StatefulWidget
/// ============================================================================
///
/// CONCEPT: STATEFULWIDGET vs STATELESSWIDGET
///
/// Use StatefulWidget when the widget has its own LOCAL state that isn't
/// managed by Provider (e.g., a TextEditingController, animation controllers).
///
/// Use StatelessWidget when the widget only reads external state (from Provider).
///
/// This screen is StatefulWidget because it owns a TextEditingController
/// for the search bar and needs `initState` to trigger the initial data load.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Controller for the search text field.
  /// We need to create and dispose of this ourselves → StatefulWidget.
  final _searchController = TextEditingController();

  /// Whether the search bar is currently expanded/visible.
  bool _isSearching = false;

  // ---------------------------------------------------------------------------
  // LIFECYCLE: initState
  // ---------------------------------------------------------------------------
  /// Called once when this widget is first inserted into the widget tree.
  /// This is where you do one-time setup: load data, start animations, etc.
  ///
  /// IMPORTANT: You cannot use `context.read/watch` directly in initState
  /// because the widget isn't fully built yet. Use `addPostFrameCallback`
  /// to defer the call to after the first frame.
  @override
  void initState() {
    super.initState();

    // Schedule the data load for after the widget tree is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskListViewModel>().loadTasks();
    });
  }

  // ---------------------------------------------------------------------------
  // LIFECYCLE: dispose
  // ---------------------------------------------------------------------------
  /// Called when this widget is permanently removed from the tree.
  /// Always dispose controllers here to free resources and prevent memory leaks.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------------------
    // CONCEPT: context.watch<T>()
    // -------------------------------------------------------------------------
    // `watch` subscribes to the ViewModel. Whenever the ViewModel calls
    // `notifyListeners()`, this entire `build` method re-runs.
    //
    // Rule of thumb:
    //   - `watch` in the build method (to react to changes)
    //   - `read` in callbacks/methods (to call methods without subscribing)
    final viewModel = context.watch<TaskListViewModel>();
    final themeVm = context.watch<ThemeViewModel>();

    return Scaffold(
      // APPBAR — the top bar with title, search, and theme toggle.
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField(viewModel)
            : const Text('My Tasks'),
        actions: [
          // Search toggle button.
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? 'Close search' : 'Search tasks',
            onPressed: _toggleSearch,
          ),

          // Theme toggle button.
          IconButton(
            icon: Icon(themeVm.themeIcon),
            tooltip: themeVm.themeLabel,
            onPressed: themeVm.toggleTheme,
          ),
        ],
      ),

      // BODY — the main content area.
      body: Column(
        children: [
          // FILTER CHIPS — All / Pending / Completed.
          FilterChipsRow(
            currentFilter: viewModel.currentFilter,
            totalCount: viewModel.totalCount,
            pendingCount: viewModel.pendingCount,
            completedCount: viewModel.completedCount,
            onFilterChanged: viewModel.setFilter,
          ),

          // TASK LIST — takes the remaining vertical space.
          Expanded(
            child: _buildBody(viewModel),
          ),
        ],
      ),

      // FAB — the floating button to add a new task.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, Routes.addTask),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),

        /// CONCEPT: HERO ANIMATION
        /// The `heroTag` links this FAB to a matching Hero widget on
        /// the add-task screen. Flutter automatically animates the
        /// transition between them.
        heroTag: 'add_task_fab',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER: Build the search text field
  // ---------------------------------------------------------------------------
  Widget _buildSearchField(TaskListViewModel viewModel) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search tasks...',
        border: InputBorder.none,
        filled: false,
      ),
      // Called on every keystroke → updates the ViewModel's search query.
      onChanged: viewModel.setSearchQuery,
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER: Toggle search mode
  // ---------------------------------------------------------------------------
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        // Clear the search filter in the ViewModel too.
        context.read<TaskListViewModel>().setSearchQuery('');
      }
    });
  }

  // ---------------------------------------------------------------------------
  // HELPER: Build the main body (loading / error / empty / list)
  // ---------------------------------------------------------------------------
  Widget _buildBody(TaskListViewModel viewModel) {
    // LOADING STATE — show a centered spinner.
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ERROR STATE — show the error with a retry button.
    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: viewModel.loadTasks,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // EMPTY STATE — no tasks match the current filter.
    if (viewModel.tasks.isEmpty) {
      return EmptyState(
        filter: viewModel.currentFilter,
        isSearching: viewModel.searchQuery.isNotEmpty,
      );
    }

    // -------------------------------------------------------------------------
    // CONCEPT: AnimatedSwitcher
    // -------------------------------------------------------------------------
    // Wrapping the list in AnimatedSwitcher gives a fade transition when
    // the filter changes (because the key changes → old child fades out,
    // new child fades in).
    return AnimatedSwitcher(
      duration: AppDurations.medium,
      child: _buildTaskList(viewModel),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER: Build the scrollable task list
  // ---------------------------------------------------------------------------
  Widget _buildTaskList(TaskListViewModel viewModel) {
    final tasks = viewModel.tasks;

    // -------------------------------------------------------------------------
    // CONCEPT: ListView.builder
    // -------------------------------------------------------------------------
    // Unlike `ListView(children: [...])`, `.builder` lazily constructs items
    // only when they scroll into view. Essential for long lists — it keeps
    // memory usage constant regardless of list size.
    return ListView.builder(
      // Key changes when the filter changes → triggers AnimatedSwitcher.
      key: ValueKey(viewModel.currentFilter),
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: 80, // Extra padding so FAB doesn't cover the last item.
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        // -------------------------------------------------------------------
        // CONCEPT: Dismissible — swipe-to-delete gesture
        // -------------------------------------------------------------------
        // Wrap each item in `Dismissible` to enable swipe gestures.
        // `key` must be unique per item (we use the task's database id).
        return Dismissible(
          key: ValueKey(task.id),

          // Which direction(s) the user can swipe.
          direction: DismissDirection.endToStart,

          // The red background that appears behind the card as you swipe.
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),

          // CONFIRM DISMISS — ask the user before deleting.
          confirmDismiss: (direction) => _confirmDelete(context, task),

          // ON DISMISSED — delete the task from the database.
          onDismissed: (_) => _deleteTask(context, task),

          child: TaskCard(
            task: task,
            onTap: () => _navigateToDetail(context, task),
            onToggleStatus: () {
              context.read<TaskListViewModel>().toggleTaskStatus(task);
            },
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER: Confirm deletion with a dialog
  // ---------------------------------------------------------------------------
  /// CONCEPT: showDialog + AlertDialog
  /// Shows a modal dialog that returns a Future<bool?>.
  /// The `await` pauses until the user taps a button.
  Future<bool?> _confirmDelete(BuildContext context, Task task) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER: Delete and show a SnackBar
  // ---------------------------------------------------------------------------
  void _deleteTask(BuildContext context, Task task) {
    context.read<TaskListViewModel>().deleteTask(task.id!);

    /// CONCEPT: ScaffoldMessenger.of(context).showSnackBar
    /// SnackBar is a brief message shown at the bottom of the screen.
    /// It's the standard way to give lightweight feedback in Material Design.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${task.title}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Re-add the task (a simple undo mechanism).
            context.read<TaskListViewModel>().addTask(
                  title: task.title,
                  description: task.description,
                  priority: task.priority,
                  dueDate: task.dueDate,
                );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER: Navigate to the detail screen
  // ---------------------------------------------------------------------------
  /// CONCEPT: Navigator.pushNamed with ARGUMENTS
  /// Named routes are defined in app.dart. You pass data via `arguments`.
  /// The receiving screen reads them with `ModalRoute.of(context)`.
  void _navigateToDetail(BuildContext context, Task task) {
    Navigator.pushNamed(
      context,
      Routes.taskDetail,
      arguments: task,
    );
  }
}
