/// ============================================================================
/// CONCEPT: App Configuration — MaterialApp, Routes, Theme Binding
/// ============================================================================
///
/// This file configures the MaterialApp widget — the root of every Flutter app.
/// It wires together theming, navigation routes, and the initial screen.
///
/// KEY FLUTTER/DART CONCEPTS DEMONSTRATED:
///   - MaterialApp configuration
///   - Named routes with `routes` map
///   - ThemeData binding (light + dark themes)
///   - ThemeMode from ViewModel (reactive theme switching)
///   - context.watch in the widget tree root

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/theme_viewmodel.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/add_edit_task_screen.dart';
import 'views/screens/task_detail_screen.dart';

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the ThemeViewModel so the entire app rebuilds when theme changes.
    final themeVm = context.watch<ThemeViewModel>();

    return MaterialApp(
      // App title (shown in the OS task switcher).
      title: 'Task Manager',

      // Disable the debug banner in the top-right corner.
      debugShowCheckedModeBanner: false,

      // THEMING — connect our custom themes and the ViewModel's mode.
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeVm.themeMode,

      // -----------------------------------------------------------------------
      // CONCEPT: Named Routes
      // -----------------------------------------------------------------------
      // Named routes let you navigate with `Navigator.pushNamed(context, '/add-task')`
      // instead of manually constructing MaterialPageRoute objects.
      //
      // Advantages:
      //   - Routes are defined in one place (easy to see the full app structure).
      //   - Route names are constants → no typos.
      //   - Deep linking and URL handling become easier.
      //
      // The `initialRoute` is the first screen shown when the app starts.
      initialRoute: Routes.home,

      routes: {
        Routes.home: (context) => const HomeScreen(),
        Routes.addTask: (context) => const AddEditTaskScreen(),
        Routes.editTask: (context) => const AddEditTaskScreen(),
        Routes.taskDetail: (context) => const TaskDetailScreen(),
      },
    );
  }
}
