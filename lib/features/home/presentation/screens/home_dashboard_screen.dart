import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notepad/core/constants/app_strings.dart';
import 'package:notepad/core/theme/app_theme.dart';
import 'package:notepad/features/notes/presentation/providers/note_providers.dart';
import 'package:notepad/features/tasks/domain/entities/task_item.dart';
import 'package:notepad/features/tasks/presentation/providers/task_providers.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final tasks = ref.watch(tasksProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.appTagline,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        notes.when(
          data: (items) =>
              _metricCard(context, 'Notes', '${items.length} active'),
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) =>
              _metricCard(context, 'Notes', 'Unable to load'),
        ),
        const SizedBox(height: 12),
        tasks.when(
          data: (items) {
            final active = items.where((item) => !item.isCompleted).toList();
            return _metricCard(context, 'Tasks', '${active.length} pending');
          },
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) =>
              _metricCard(context, 'Tasks', 'Unable to load'),
        ),
        const SizedBox(height: 12),
        tasks.when(
          data: (items) => _todayFocusCard(context, items),
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _metricCard(BuildContext context, String title, String value) {
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _todayFocusCard(BuildContext context, List<TaskItem> tasks) {
    final list = tasks.where((item) => !item.isCompleted).toList();
    list.sort((a, b) {
      final aDue = a.dueAt;
      final bDue = b.dueAt;
      if (aDue == null && bDue == null) {
        return b.updatedAt.compareTo(a.updatedAt);
      }
      if (aDue == null) {
        return 1;
      }
      if (bDue == null) {
        return -1;
      }
      return aDue.compareTo(bDue);
    });

    final top = list.take(3).toList();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today Focus', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (top.isEmpty) const Text('You’re all clear for today.'),
          for (final task in top)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(task.title)),
                  if (task.dueAt != null)
                    Text(DateFormat('MMM d').format(task.dueAt!)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
