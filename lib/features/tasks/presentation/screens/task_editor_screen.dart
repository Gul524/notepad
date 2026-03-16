import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notepad/features/tasks/domain/entities/task_item.dart';
import 'package:notepad/features/tasks/presentation/providers/task_providers.dart';

class TaskEditorScreen extends ConsumerStatefulWidget {
  const TaskEditorScreen({super.key, this.task});

  final TaskItem? task;

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
  late TaskPriority _priority;
  late RepeatRule _repeatRule;
  DateTime? _dueAt;
  DateTime? _reminderAt;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _detailsController = TextEditingController(text: task?.details ?? '');
    _priority = task?.priority ?? TaskPriority.medium;
    _repeatRule = task?.repeatRule ?? RepeatRule.none;
    _dueAt = task?.dueAt;
    _reminderAt = task?.reminderAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'Task title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _detailsController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(hintText: 'Details (optional)'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<TaskPriority>(
            initialValue: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: TaskPriority.values
                .map(
                  (item) =>
                      DropdownMenuItem(value: item, child: Text(item.name)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _priority = value);
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<RepeatRule>(
            initialValue: _repeatRule,
            decoration: const InputDecoration(labelText: 'Repeat'),
            items: RepeatRule.values
                .map(
                  (item) =>
                      DropdownMenuItem(value: item, child: Text(item.name)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _repeatRule = value);
              }
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Due date/time'),
            subtitle: Text(
              _dueAt == null
                  ? 'Not set'
                  : DateFormat('MMM d, h:mm a').format(_dueAt!),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.event_outlined),
              onPressed: _pickDueAt,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reminder'),
            subtitle: Text(
              _reminderAt == null
                  ? 'Not set'
                  : DateFormat('MMM d, h:mm a').format(_reminderAt!),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.notifications_active_outlined),
              onPressed: _pickReminderAt,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: const Text('Save Task')),
        ],
      ),
    );
  }

  Future<void> _pickDueAt() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
      initialDate: _dueAt ?? now,
    );
    if (date == null || !mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueAt ?? now),
    );
    if (time == null) {
      return;
    }
    setState(() {
      _dueAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickReminderAt() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
      initialDate: _reminderAt ?? _dueAt ?? now,
    );
    if (date == null || !mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt ?? _dueAt ?? now),
    );
    if (time == null) {
      return;
    }
    setState(() {
      _reminderAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please add a task title')));
      return;
    }

    final notifier = ref.read(tasksProvider.notifier);
    if (widget.task == null) {
      await notifier.addTask(
        title: title,
        details: _detailsController.text.trim(),
        priority: _priority,
        dueAt: _dueAt,
        reminderAt: _reminderAt,
        repeatRule: _repeatRule,
      );
    } else {
      await notifier.updateTask(
        widget.task!.copyWith(
          title: title,
          details: _detailsController.text.trim(),
          priority: _priority,
          repeatRule: _repeatRule,
          dueAt: _dueAt,
          reminderAt: _reminderAt,
        ),
      );
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task saved')));
    Navigator.pop(context);
  }
}
