# Flutter Task Manager — Learning Guide

A production-quality Task Manager app built with **MVVM architecture** and **Provider** to teach every core Flutter concept in one cohesive project.

---

## Project Structure (MVVM)

```
lib/
├── main.dart                              ← App entry point, Provider setup
├── app.dart                               ← MaterialApp config, routes, theme binding
│
├── models/                                ← MODEL — pure data, no Flutter dependency
│   └── task.dart                          ← Task class, Priority/TaskStatus enums
│
├── services/                              ← SERVICE — data access (database)
│   └── database_service.dart              ← SQLite CRUD via sqflite
│
├── viewmodels/                            ← VIEWMODEL — state + business logic
│   ├── task_list_viewmodel.dart           ← Task list state, filtering, search
│   └── theme_viewmodel.dart               ← Light/dark theme state
│
├── views/                                 ← VIEW — UI widgets (no business logic)
│   ├── screens/
│   │   ├── home_screen.dart               ← Main list with search, filter, swipe
│   │   ├── add_edit_task_screen.dart       ← Form with validation + date picker
│   │   └── task_detail_screen.dart         ← Full task details
│   └── widgets/
│       ├── task_card.dart                 ← Reusable task card component
│       ├── priority_badge.dart            ← Small priority label widget
│       ├── filter_chips.dart              ← All/Pending/Completed filter row
│       └── empty_state.dart               ← Placeholder when list is empty
│
└── utils/                                 ← Shared constants and configuration
    ├── app_theme.dart                     ← Light + dark ThemeData definitions
    └── constants.dart                     ← Route names, spacing, priority styles
```

---

## Flutter Concepts — Where Each One Lives

| # | Concept | File(s) | What to look for |
|---|---------|---------|-----------------|
| 1 | **StatelessWidget** | `task_card.dart`, `priority_badge.dart` | Widget with no mutable state |
| 2 | **StatefulWidget** | `home_screen.dart`, `add_edit_task_screen.dart` | Widget with controllers + lifecycle |
| 3 | **Widget Lifecycle** | `home_screen.dart` | `initState`, `dispose`, `didChangeDependencies` |
| 4 | **Provider + ChangeNotifier** | `task_list_viewmodel.dart`, `main.dart` | `notifyListeners()`, `context.watch/read` |
| 5 | **MVVM Architecture** | Entire project | Model → Service → ViewModel → View separation |
| 6 | **Named Routes** | `app.dart`, `constants.dart` | `routes: {}`, `Navigator.pushNamed` |
| 7 | **Route Arguments** | `task_detail_screen.dart` | `ModalRoute.of(context).settings.arguments` |
| 8 | **Forms & Validation** | `add_edit_task_screen.dart` | `Form`, `GlobalKey<FormState>`, `validator` |
| 9 | **TextFormField** | `add_edit_task_screen.dart` | Controllers, validators, decorations |
| 10 | **DropdownButtonFormField** | `add_edit_task_screen.dart` | Dropdown inside a Form |
| 11 | **showDatePicker** | `add_edit_task_screen.dart` | Built-in Material date picker |
| 12 | **SQLite (sqflite)** | `database_service.dart` | CRUD, SQL queries, parameterized queries |
| 13 | **Singleton Pattern** | `database_service.dart` | Private constructor, static instance, factory |
| 14 | **async / await** | `database_service.dart`, ViewModels | All DB operations are async |
| 15 | **ListView.builder** | `home_screen.dart` | Lazy list construction for performance |
| 16 | **Dismissible** | `home_screen.dart` | Swipe-to-delete gesture |
| 17 | **AnimatedSwitcher** | `home_screen.dart` | Fade animation between filter states |
| 18 | **AnimatedContainer** | `task_card.dart` | Implicit animation on property changes |
| 19 | **Theming (Material 3)** | `app_theme.dart`, `theme_viewmodel.dart` | `ColorScheme.fromSeed`, light/dark toggle |
| 20 | **SnackBar** | `home_screen.dart` | Toast-like feedback messages |
| 21 | **AlertDialog** | `home_screen.dart`, `task_detail_screen.dart` | Confirmation dialogs |
| 22 | **ChoiceChip** | `filter_chips.dart` | Material selection chips |
| 23 | **Card + ListTile** | `task_detail_screen.dart` | Structured info layout |
| 24 | **Enhanced Enums** | `task.dart` | Enums with fields and methods (Dart 2.17+) |
| 25 | **Dart Records** | `empty_state.dart` | Returning multiple values `(a, b, c)` |
| 26 | **Null Safety** | Everywhere | `?`, `!`, `??`, `?.` operators |
| 27 | **copyWith Pattern** | `task.dart` | Immutable object updates |
| 28 | **Factory Constructors** | `task.dart`, `database_service.dart` | `factory Task.fromMap(...)` |
| 29 | **Named Constructors** | `task.dart` | `Task.create(...)` |
| 30 | **const Constructors** | All widgets | `const MyWidget({super.key})` |
| 31 | **Dependency Injection** | `main.dart`, `task_list_viewmodel.dart` | Provider setup, constructor injection |
| 32 | **Serialization** | `task.dart` | `toMap()` / `fromMap()` |
| 33 | **FloatingActionButton** | `home_screen.dart` | FAB with extended label |
| 34 | **SafeArea** | `add_edit_task_screen.dart` | Respects notches and system bars |
| 35 | **Checkbox** | `task_card.dart` | Material checkbox with custom shape |
| 36 | **InkWell** | `task_card.dart`, `add_edit_task_screen.dart` | Tappable widget with ripple |
| 37 | **context.mounted** | `add_edit_task_screen.dart` | Async safety check before using context |

---

## How to Run

```bash
cd flutter_application_1
flutter pub get
flutter run
```

---

## MVVM Data Flow

```
User taps "Add Task"
        │
        ▼
   VIEW (Screen)          ← builds UI, captures input
        │
        │  calls viewModel.addTask(...)
        ▼
   VIEWMODEL              ← validates, creates Task model, calls service
        │
        │  calls databaseService.insertTask(task)
        ▼
   SERVICE                ← converts to Map, executes SQL INSERT
        │
        │  returns id
        ▼
   VIEWMODEL              ← calls loadTasks(), updates state, notifyListeners()
        │
        │  Provider detects change
        ▼
   VIEW                   ← rebuilds list with new task
```

---

## Packages Used

| Package | Purpose | Why this one |
|---------|---------|-------------|
| `provider` | State management | Official Flutter team recommendation |
| `sqflite` | Local SQLite database | Standard Flutter persistence solution |
| `path_provider` | Platform-specific directories | Required to locate the DB file |
| `path` | Path manipulation | Safe cross-platform path joining |
| `intl` | Date formatting | Standard i18n/l10n package |

---

## Key Patterns to Remember for Production

1. **ViewModel never imports Flutter widgets** — it only uses `foundation.dart` for `ChangeNotifier`
2. **Views never call database methods** — they only talk to ViewModels
3. **Models are plain Dart** — no Flutter imports, easily testable
4. **Use `context.watch` in build, `context.read` in callbacks** — this is the #1 Provider rule
5. **Always dispose controllers** — `TextEditingController`, `AnimationController`, etc.
6. **Check `context.mounted` after await** — prevents "setState after dispose" crashes
7. **Use `const` constructors** — Flutter skips rebuilding `const` widgets
