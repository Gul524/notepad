import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notepad/features/tasks/domain/entities/task_item.dart';
import 'package:notepad/features/tasks/presentation/providers/task_providers.dart';
import 'package:notepad/features/tasks/presentation/screens/task_editor_screen.dart';

enum TaskFilter { today, upcoming, completed, all }

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  TaskFilter _filter = TaskFilter.today;

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: tasks.when(
        data: (items) {
          final filtered = _applyFilter(items);
          if (filtered.isEmpty) {
            return const Center(child: Text('You’re all clear for today.'));
          }

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: TaskFilter.values
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_label(item)),
                            selected: _filter == item,
                            onSelected: (_) => setState(() => _filter = item),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = filtered[index];
                    return Dismissible(
                      key: ValueKey(task.id),
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.check_circle_outline),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          await ref
                              .read(tasksProvider.notifier)
                              .toggleComplete(task);
                          HapticFeedback.lightImpact();
                          return false;
                        }
                        await ref
                            .read(tasksProvider.notifier)
                            .softDelete(task.id);
                        return true;
                      },
                      child: _TaskTile(task: task),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Unable to load tasks.')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskEditorScreen()),
          );
        },
        icon: const Icon(Icons.add_task),
        label: const Text('New Task'),
      ),
    );
  }

  List<TaskItem> _applyFilter(List<TaskItem> items) {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return items.where((task) {
      if (_filter == TaskFilter.all) {
        return true;
      }
      if (_filter == TaskFilter.completed) {
        return task.isCompleted;
      }
      if (_filter == TaskFilter.today) {
        if (task.isCompleted) {
          return false;
        }
        if (task.dueAt == null) {
          return false;
        }
        return task.dueAt!.isBefore(todayEnd.add(const Duration(seconds: 1)));
      }
      if (_filter == TaskFilter.upcoming) {
        if (task.isCompleted || task.dueAt == null) {
          return false;
        }
        return task.dueAt!.isAfter(todayEnd);
      }
      return true;
    }).toList();
  }

  String _label(TaskFilter filter) {
    return switch (filter) {
      TaskFilter.today => 'Today',
      TaskFilter.upcoming => 'Upcoming',
      TaskFilter.completed => 'Completed',
      TaskFilter.all => 'All',
    };
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskEditorScreen(task: task)),
        );
      },
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0x19FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x23FFFFFF)),
        ),
        child: Row(
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (_) =>
                  ref.read(tasksProvider.notifier).toggleComplete(task),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (task.dueAt != null)
                    Text(
                      'Due ${DateFormat('MMM d, h:mm a').format(task.dueAt!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            _PriorityBadge(priority: task.priority),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      TaskPriority.low => ('Low', Colors.green),
      TaskPriority.medium => ('Medium', Colors.orange),
      TaskPriority.high => ('High', Colors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
