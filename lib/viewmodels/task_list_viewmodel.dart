/// ============================================================================
/// CONCEPT: ViewModel (ChangeNotifier + Provider)
/// ============================================================================
///
/// In MVVM, the VIEWMODEL is the bridge between the View (UI) and the Model
/// (data). It:
///   1. Holds the UI STATE (list of tasks, current filter, loading flag, etc.)
///   2. Exposes METHODS the View calls (addTask, deleteTask, toggleStatus)
///   3. NOTIFIES the View when state changes (via `notifyListeners()`)
///
/// The View never talks to the database. It only talks to the ViewModel.
/// The ViewModel never builds widgets. It only manages data and state.
///
/// KEY FLUTTER/DART CONCEPTS DEMONSTRATED:
///   - ChangeNotifier (the base class for ViewModels in Provider)
///   - notifyListeners() (tells Provider to rebuild listening widgets)
///   - Getters for exposing read-only state
///   - Computed properties (filtered lists derived from the main list)
///   - Error handling with try/catch
///   - Enum for filter state

import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/database_service.dart';

/// Defines which subset of tasks the user is viewing.
enum TaskFilter {
  all,
  pending,
  completed,
}

/// ============================================================================
/// TaskListViewModel — manages the state for the home screen's task list.
/// ============================================================================
///
/// Extends `ChangeNotifier` which gives us `notifyListeners()`.
/// When we call `notifyListeners()`, every widget using
/// `context.watch<TaskListViewModel>()` rebuilds automatically.
class TaskListViewModel extends ChangeNotifier {
  /// The service that handles database operations.
  /// The ViewModel depends on the Service, NOT on sqflite directly.
  final DatabaseService _databaseService;

  /// Constructor — takes the service as a parameter (dependency injection).
  ///
  /// CONCEPT: DEPENDENCY INJECTION
  /// Instead of creating `DatabaseService()` inside this class, we receive
  /// it from outside. This makes the ViewModel testable — in tests, you can
  /// pass a mock service instead of a real database.
  TaskListViewModel({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  // ---------------------------------------------------------------------------
  // STATE — private fields with public getters
  // ---------------------------------------------------------------------------
  // Convention: private `_field` + public getter `field`.
  // The View can READ state but cannot SET it directly.
  // Only the ViewModel's methods can change state.

  /// The complete list of tasks from the database.
  List<Task> _tasks = [];

  /// Whether we're currently loading from the database.
  bool _isLoading = false;

  /// Any error message to display (null = no error).
  String? _errorMessage;

  /// The currently active filter (all / pending / completed).
  TaskFilter _currentFilter = TaskFilter.all;

  /// The current search query (empty string = no search).
  String _searchQuery = '';

  // PUBLIC GETTERS — the View reads these to build the UI.

  /// Returns the filtered + searched subset of tasks.
  /// This is a COMPUTED PROPERTY — it derives its value from other state.
  List<Task> get tasks {
    List<Task> filtered;

    // Step 1: Apply status filter.
    switch (_currentFilter) {
      case TaskFilter.pending:
        filtered = _tasks.where((t) => !t.isCompleted).toList();
      case TaskFilter.completed:
        filtered = _tasks.where((t) => t.isCompleted).toList();
      case TaskFilter.all:
        filtered = List.of(_tasks);
    }

    // Step 2: Apply search query (if any).
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        return t.title.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TaskFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;

  /// Quick stats for the UI.
  int get totalCount => _tasks.length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;

  // ---------------------------------------------------------------------------
  // METHODS — the View calls these in response to user actions
  // ---------------------------------------------------------------------------

  /// Loads all tasks from the database. Called once when the screen opens.
  ///
  /// CONCEPT: ASYNC/AWAIT
  /// Database operations return Futures. `await` pauses execution until the
  /// Future completes, without blocking the UI thread.
  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Tell the View to show a loading spinner.

    try {
      _tasks = await _databaseService.getAllTasks();
    } catch (e) {
      _errorMessage = 'Failed to load tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners(); // Tell the View to rebuild with the new data.
    }
  }

  /// Adds a new task to the database and refreshes the list.
  Future<bool> addTask({
    required String title,
    required String description,
    Priority priority = Priority.medium,
    DateTime? dueDate,
  }) async {
    try {
      final task = Task.create(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );

      await _databaseService.insertTask(task);
      await loadTasks(); // Refresh the list from the database.
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add task: $e';
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing task.
  Future<bool> updateTask(Task updatedTask) async {
    try {
      await _databaseService.updateTask(updatedTask);
      await loadTasks();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update task: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes a task by its id.
  Future<bool> deleteTask(int id) async {
    try {
      await _databaseService.deleteTask(id);
      await loadTasks();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete task: $e';
      notifyListeners();
      return false;
    }
  }

  /// Toggles a task between pending ↔ completed.
  ///
  /// CONCEPT: COPYSWITH
  /// Instead of mutating the task, we create a new copy with the status flipped.
  Future<void> toggleTaskStatus(Task task) async {
    final newStatus =
        task.isCompleted ? TaskStatus.pending : TaskStatus.completed;
    final updated = task.copyWith(status: newStatus);

    await updateTask(updated);
  }

  /// Sets the filter and notifies the View to rebuild.
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Updates the search query and notifies the View.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clears any displayed error.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
