/// ============================================================================
/// CONCEPT: Forms, Validation, and DatePicker
/// ============================================================================
///
/// This screen handles both ADDING a new task and EDITING an existing one.
/// It uses a single Form widget with validation, and communicates with
/// the ViewModel to persist changes.
///
/// KEY FLUTTER/DART CONCEPTS DEMONSTRATED:
///   - Form & GlobalKey<FormState> (form validation)
///   - TextFormField with validators
///   - TextEditingController (pre-filling fields for editing)
///   - showDatePicker (built-in Material date picker)
///   - DropdownButtonFormField (selecting from a list)
///   - Navigator.pop with result (returning data to the previous screen)
///   - ModalRoute.of(context).settings.arguments (receiving route arguments)
///   - Null-aware operators (?., ??, !)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../viewmodels/task_list_viewmodel.dart';
import '../../utils/constants.dart';

class AddEditTaskScreen extends StatefulWidget {
  const AddEditTaskScreen({super.key});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  // ---------------------------------------------------------------------------
  // CONCEPT: GlobalKey<FormState>
  // ---------------------------------------------------------------------------
  // A GlobalKey uniquely identifies a widget across the entire widget tree.
  // For forms, it lets us call `_formKey.currentState!.validate()` to
  // trigger all validators at once, and `.save()` to fire all `onSaved`.
  final _formKey = GlobalKey<FormState>();

  // Controllers for each text field. We need these to:
  //   1. Pre-fill values when editing an existing task.
  //   2. Clear fields after saving.
  //   3. Dispose them properly to avoid memory leaks.
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  /// The selected priority (defaults to medium).
  Priority _selectedPriority = Priority.medium;

  /// Optional due date. Null means "no due date set".
  DateTime? _selectedDueDate;

  /// The task being edited, or null if creating a new task.
  /// Set in `didChangeDependencies` from the route arguments.
  Task? _existingTask;

  /// Prevents reading route arguments more than once.
  bool _isInitialized = false;

  // ---------------------------------------------------------------------------
  // LIFECYCLE: initState — initialize controllers
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  // ---------------------------------------------------------------------------
  // LIFECYCLE: didChangeDependencies
  // ---------------------------------------------------------------------------
  /// Called after initState and whenever the dependencies change.
  /// We read route arguments HERE (not in initState) because
  /// `ModalRoute.of(context)` requires a fully-built context.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _isInitialized = true;

      // Read the task passed via Navigator.pushNamed arguments.
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is Task) {
        _existingTask = args;

        // Pre-fill the form with the existing task's data.
        _titleController.text = args.title;
        _descriptionController.text = args.description;
        _selectedPriority = args.priority;
        _selectedDueDate = args.dueDate;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // LIFECYCLE: dispose — clean up controllers
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _existingTask != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
      ),

      // BODY: The form lives inside a scrollable container.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---------------------------------------------------------------
                // TITLE FIELD
                // ---------------------------------------------------------------
                _buildTitleField(),
                const SizedBox(height: AppSpacing.md),

                // ---------------------------------------------------------------
                // DESCRIPTION FIELD
                // ---------------------------------------------------------------
                _buildDescriptionField(),
                const SizedBox(height: AppSpacing.md),

                // ---------------------------------------------------------------
                // PRIORITY DROPDOWN
                // ---------------------------------------------------------------
                _buildPriorityDropdown(),
                const SizedBox(height: AppSpacing.md),

                // ---------------------------------------------------------------
                // DUE DATE PICKER
                // ---------------------------------------------------------------
                _buildDueDatePicker(context),
                const SizedBox(height: AppSpacing.xl),

                // ---------------------------------------------------------------
                // SAVE BUTTON
                // ---------------------------------------------------------------
                _buildSaveButton(context, isEditing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET: Title text field with validation
  // ---------------------------------------------------------------------------
  Widget _buildTitleField() {
    /// CONCEPT: TextFormField
    /// Unlike a plain TextField, TextFormField integrates with the Form widget.
    /// It supports `validator` and `onSaved` callbacks that are triggered
    /// when you call `_formKey.currentState!.validate()` and `.save()`.
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Title',
        hintText: 'What needs to be done?',
        prefixIcon: Icon(Icons.title),
      ),
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next, // "Next" button on keyboard.

      /// CONCEPT: VALIDATORS
      /// Validators return null if the value is valid, or an error string
      /// if invalid. The error string is displayed below the field automatically.
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        if (value.trim().length < 3) {
          return 'Title must be at least 3 characters';
        }
        return null; // Valid!
      },
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET: Description text field
  // ---------------------------------------------------------------------------
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Add details about this task...',
        prefixIcon: Icon(Icons.notes),
        alignLabelWithHint: true,
      ),
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET: Priority dropdown
  // ---------------------------------------------------------------------------
  Widget _buildPriorityDropdown() {
    /// CONCEPT: DropdownButtonFormField
    /// A dropdown that integrates with Form (supports validation).
    /// `items` is a list of DropdownMenuItem, each with a `value` and display `child`.
    return DropdownButtonFormField<Priority>(
      value: _selectedPriority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        prefixIcon: Icon(Icons.flag),
      ),
      items: Priority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              Icon(
                PriorityStyles.icon(priority),
                color: PriorityStyles.color(priority),
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(priority.label),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedPriority = value);
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET: Due date picker
  // ---------------------------------------------------------------------------
  Widget _buildDueDatePicker(BuildContext context) {
    final dateText = _selectedDueDate != null
        ? DateFormat.yMMMd().format(_selectedDueDate!)
        : 'No due date';

    /// CONCEPT: GestureDetector + InkWell
    /// `InkWell` wraps a widget to make it tappable with a Material ripple effect.
    /// We use it here instead of a button because we want a custom-looking "field".
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _pickDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due Date',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dateText),
            if (_selectedDueDate != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => setState(() => _selectedDueDate = null),
                tooltip: 'Clear date',
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER: Show the Material date picker
  // ---------------------------------------------------------------------------
  /// CONCEPT: showDatePicker
  /// A built-in Flutter function that shows a calendar dialog.
  /// It returns a Future<DateTime?> — null if the user cancels.
  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  // ---------------------------------------------------------------------------
  // WIDGET: Save button
  // ---------------------------------------------------------------------------
  Widget _buildSaveButton(BuildContext context, bool isEditing) {
    return FilledButton.icon(
      onPressed: () => _saveTask(context, isEditing),
      icon: Icon(isEditing ? Icons.save : Icons.add_task),
      label: Text(isEditing ? 'Save Changes' : 'Create Task'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOGIC: Validate and save the task
  // ---------------------------------------------------------------------------
  Future<void> _saveTask(BuildContext context, bool isEditing) async {
    // Step 1: Run all validators. If any return an error string, this is false.
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<TaskListViewModel>();
    bool success;

    if (isEditing) {
      // UPDATE existing task using copyWith.
      final updated = _existingTask!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );
      success = await viewModel.updateTask(updated);
    } else {
      // CREATE new task.
      success = await viewModel.addTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );
    }

    // Step 2: If the widget is still mounted (user didn't navigate away),
    // pop back to the previous screen.
    if (success && context.mounted) {
      Navigator.pop(context, true); // `true` signals "something changed".
    }
  }
}
