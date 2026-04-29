/// ============================================================================
/// CONCEPT: App Entry Point — Provider Setup & Dependency Injection
/// ============================================================================
///
/// `main.dart` is the entry point of every Flutter app. The `main()` function
/// is the first thing Dart executes.
///
/// This file does three things:
///   1. Ensures Flutter is initialized (`WidgetsFlutterBinding.ensureInitialized`)
///   2. Sets up Provider (dependency injection for ViewModels)
///   3. Launches the app with `runApp()`
///
/// KEY FLUTTER/DART CONCEPTS DEMONSTRATED:
///   - main() function — app entry point
///   - WidgetsFlutterBinding.ensureInitialized()
///   - MultiProvider — registers multiple ViewModels
///   - ChangeNotifierProvider — creates and provides a ViewModel
///   - runApp() — inflates the root widget and attaches it to the screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'viewmodels/task_list_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';

/// The entry point. Dart calls this function first.
void main() {
  // ---------------------------------------------------------------------------
  // CONCEPT: WidgetsFlutterBinding.ensureInitialized()
  // ---------------------------------------------------------------------------
  // Must be called before `runApp()` if you do any async work before running
  // the app (like initializing a database, loading shared preferences, etc.).
  //
  // It sets up the binding between the Flutter engine and the framework.
  // Without it, calling platform channels (like sqflite) before runApp would crash.
  WidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // CONCEPT: runApp()
  // ---------------------------------------------------------------------------
  // Takes a widget and makes it the root of the widget tree.
  // Everything on screen is a descendant of this widget.
  runApp(
    // -------------------------------------------------------------------------
    // CONCEPT: MultiProvider — Dependency Injection
    // -------------------------------------------------------------------------
    // Provider is Flutter's recommended way to pass data down the widget tree
    // WITHOUT manually passing it through every constructor.
    //
    // `MultiProvider` lets you register multiple providers in one place.
    // Every widget below this point can access these ViewModels via
    // `context.read<T>()` or `context.watch<T>()`.
    //
    // How it works:
    //   1. `ChangeNotifierProvider` creates the ViewModel instance.
    //   2. It makes the instance available to all descendant widgets.
    //   3. When the ViewModel calls `notifyListeners()`, Provider rebuilds
    //      only the widgets that are watching it.
    //   4. When the widget tree is disposed, Provider automatically disposes
    //      the ViewModel (calls its `dispose()` method).
    MultiProvider(
      providers: [
        // Creates TaskListViewModel and makes it available app-wide.
        ChangeNotifierProvider(
          create: (_) => TaskListViewModel(),
        ),

        // Creates ThemeViewModel and makes it available app-wide.
        ChangeNotifierProvider(
          create: (_) => ThemeViewModel(),
        ),
      ],

      // The child is the rest of the app — it can access both ViewModels.
      child: const TaskManagerApp(),
    ),
  );
}
