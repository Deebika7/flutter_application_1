/// ============================================================================
/// CONCEPT: Data Models & Enhanced Enums
/// ============================================================================
///
/// In MVVM, the MODEL layer represents your data and business rules.
/// Models are plain Dart classes — they know nothing about UI or databases.
///
/// KEY FLUTTER/DART CONCEPTS DEMONSTRATED:
///   - Enhanced enums (enums with fields and methods — Dart 2.17+)
///   - Immutable data classes (all fields are `final`)
///   - Named constructors (`Task.create`)
///   - Factory constructors (`Task.fromMap`)
///   - copyWith pattern (creates a modified copy without mutating the original)
///   - Null safety (nullable `id` for tasks not yet saved to DB)
///   - `toMap()` / `fromMap()` for serialization (used by the database layer)

/// ENHANCED ENUM — Dart 2.17+ lets enums have fields, constructors, and methods.
/// This replaces the old pattern of using constants + switch statements.
enum Priority {
  low(label: 'Low', value: 0),
  medium(label: 'Medium', value: 1),
  high(label: 'High', value: 2);

  /// Each enum member carries its own label and numeric value.
  final String label;
  final int value;

  /// Enums can have constructors (must be `const`).
  const Priority({required this.label, required this.value});

  /// Factory to convert a stored integer back into the enum.
  /// Example: Priority.fromValue(2) → Priority.high
  static Priority fromValue(int value) {
    return Priority.values.firstWhere(
      (p) => p.value == value,
      orElse: () => Priority.medium,
    );
  }
}

/// Simple enum — no extra fields needed, just named states.
enum TaskStatus {
  pending,
  completed,
}

/// ============================================================================
/// THE TASK MODEL
/// ============================================================================
///
/// This is a plain Dart class. It has:
///   - No dependency on Flutter, Provider, or any database package.
///   - Serialization methods (toMap / fromMap) so the Service layer can persist it.
///   - A copyWith method so the ViewModel can create modified copies immutably.
class Task {
  /// Nullable because a NEW task (not yet saved) has no id.
  /// SQLite assigns the id on insert.
  final int? id;

  final String title;
  final String description;
  final Priority priority;
  final TaskStatus status;

  /// Stored as ISO 8601 string in the database, parsed back into DateTime.
  final DateTime createdAt;
  final DateTime? dueDate;

  /// PRIMARY CONSTRUCTOR — used when all fields are known (e.g., from database).
  const Task({
    this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.dueDate,
  });

  /// NAMED CONSTRUCTOR — convenience for creating a brand-new task.
  /// Sets sensible defaults so callers don't have to repeat them.
  Task.create({
    required this.title,
    required this.description,
    this.priority = Priority.medium,
    this.dueDate,
  })  : id = null,
        status = TaskStatus.pending,
        createdAt = DateTime.now();

  /// FACTORY CONSTRUCTOR — rebuilds a Task from a Map (database row).
  /// `factory` means it doesn't always create a NEW instance; it can return
  /// an existing one. Here we use it because the logic is non-trivial.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      priority: Priority.fromValue(map['priority'] as int),
      status: (map['status'] as String) == 'completed'
          ? TaskStatus.completed
          : TaskStatus.pending,
      createdAt: DateTime.parse(map['created_at'] as String),
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
    );
  }

  /// Serializes to a Map for database insertion.
  /// Note: `id` is omitted — SQLite auto-generates it.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'priority': priority.value,
      'status': status == TaskStatus.completed ? 'completed' : 'pending',
      'created_at': createdAt.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
    };
  }

  /// COPYSWITH PATTERN — returns a new Task with some fields changed.
  /// This is how you "edit" immutable objects: create a modified copy.
  ///
  /// Example:
  ///   final updated = task.copyWith(title: 'New title');
  ///   // `task` is unchanged, `updated` has the new title.
  Task copyWith({
    int? id,
    String? title,
    String? description,
    Priority? priority,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  /// Convenience getter — reads better than `status == TaskStatus.completed`.
  bool get isCompleted => status == TaskStatus.completed;

  /// Override toString for easier debugging (shows up in print statements).
  @override
  String toString() => 'Task(id: $id, title: $title, status: $status)';
}
