/// ============================================================================
/// CONCEPT: Service Layer (Data Access / Repository)
/// ============================================================================
///
/// In MVVM, the SERVICE (or Repository) layer sits between the ViewModel and
/// the actual data source (SQLite, REST API, Firebase, etc.).
///
/// The ViewModel never talks to the database directly. It calls methods on
/// this service. This separation means you can swap SQLite for an API later
/// without changing a single line in the ViewModel.
///
/// KEY FLUTTER/DART CONCEPTS DEMONSTRATED:
///   - Singleton pattern (one database connection for the whole app)
///   - async / await (all DB operations are asynchronous)
///   - Late initialization (`late final`)
///   - sqflite usage (open, create table, CRUD)
///   - Private constructor (`DatabaseService._()`)

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../models/task.dart';

class DatabaseService {
  // ---------------------------------------------------------------------------
  // SINGLETON PATTERN
  // ---------------------------------------------------------------------------
  // Only one instance of DatabaseService should exist in the app.
  // Why? Because opening multiple database connections wastes resources
  // and can cause locking issues.
  //
  // How it works:
  //   1. Private constructor `_()` prevents `DatabaseService()` from outside.
  //   2. Static `_instance` holds the single instance.
  //   3. `factory` constructor returns that same instance every time.

  /// The single, shared instance.
  static final DatabaseService _instance = DatabaseService._();

  /// Private constructor — cannot be called from outside this file.
  DatabaseService._();

  /// Factory constructor — always returns the same `_instance`.
  /// Usage: `final db = DatabaseService();` ← looks normal, but it's a singleton.
  factory DatabaseService() => _instance;

  // ---------------------------------------------------------------------------
  // DATABASE SETUP
  // ---------------------------------------------------------------------------

  /// Holds the database connection once opened. Nullable until initialized.
  Database? _database;

  /// Name and version of our SQLite database file.
  static const String _dbName = 'tasks.db';
  static const int _dbVersion = 1;

  /// Getter that lazily initializes the database on first access.
  ///
  /// CONCEPT: LAZY INITIALIZATION
  /// The database is not opened when the app starts. It's opened the first
  /// time any code calls `database`. This avoids slowing down app startup.
  Future<Database> get database async {
    // If already opened, return immediately.
    if (_database != null) return _database!;

    // Otherwise, open it (only happens once).
    _database = await _initDatabase();
    return _database!;
  }

  /// Opens (or creates) the SQLite database file.
  Future<Database> _initDatabase() async {
    // `getApplicationDocumentsDirectory()` returns a platform-specific path:
    //   - iOS: NSDocumentDirectory
    //   - Android: AppData directory
    final documentsDir = await getApplicationDocumentsDirectory();

    // `join` from the `path` package safely combines path segments.
    final dbPath = join(documentsDir.path, _dbName);

    // `openDatabase` opens an existing DB or creates a new one.
    // `onCreate` runs only the very first time (when the file doesn't exist).
    return openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _createTable,
    );
  }

  /// Creates the `tasks` table. Runs once when the database is first created.
  ///
  /// CONCEPT: SQL + sqflite
  /// sqflite uses raw SQL strings. The `id` column uses `INTEGER PRIMARY KEY
  /// AUTOINCREMENT` so SQLite automatically assigns unique ids.
  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        priority INTEGER NOT NULL DEFAULT 1,
        status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL,
        due_date TEXT
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // CRUD OPERATIONS
  // ---------------------------------------------------------------------------
  // CRUD = Create, Read, Update, Delete — the four basic database operations.
  // Each method is `async` because database I/O should never block the UI.

  /// CREATE — inserts a new task and returns its auto-generated id.
  Future<int> insertTask(Task task) async {
    final db = await database;

    // `db.insert` converts the Map to an INSERT statement.
    // `conflictAlgorithm` tells SQLite what to do if there's a conflict
    // (e.g., duplicate primary key). `replace` overwrites the old row.
    return db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// READ ALL — returns every task, newest first.
  Future<List<Task>> getAllTasks() async {
    final db = await database;

    // `db.query` returns a List<Map<String, dynamic>>.
    // We convert each Map into a Task using our factory constructor.
    final maps = await db.query('tasks', orderBy: 'created_at DESC');

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  /// READ ONE — returns a single task by its id, or null if not found.
  Future<Task?> getTaskById(int id) async {
    final db = await database;

    final maps = await db.query(
      'tasks',
      where: 'id = ?',       // `?` is a placeholder to prevent SQL injection.
      whereArgs: [id],        // The actual value replaces the `?`.
    );

    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  /// UPDATE — modifies an existing task. Returns the number of rows affected.
  Future<int> updateTask(Task task) async {
    final db = await database;

    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// DELETE — removes a task by its id. Returns the number of rows deleted.
  Future<int> deleteTask(int id) async {
    final db = await database;

    return db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// SEARCH — finds tasks whose title or description contains the query.
  ///
  /// CONCEPT: SQL LIKE operator for text search.
  /// The `%` wildcards match any characters before and after the query.
  Future<List<Task>> searchTasks(String query) async {
    final db = await database;

    final maps = await db.query(
      'tasks',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  /// Closes the database connection. Call this when the app is shutting down.
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
