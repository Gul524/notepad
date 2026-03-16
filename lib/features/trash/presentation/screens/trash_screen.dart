import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notepad/features/notes/presentation/providers/note_providers.dart';
import 'package:notepad/features/tasks/presentation/providers/task_providers.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(deletedNotesProvider);
    final tasks = ref.watch(deletedTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trash & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Deleted Notes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          notes.when(
            data: (items) {
              if (items.isEmpty) {
                return const ListTile(title: Text('No deleted notes.'));
              }
              return Column(
                children: items
                    .map(
                      (item) => ListTile(
                        title: Text(
                          item.title.isEmpty ? 'Untitled note' : item.title,
                        ),
                        trailing: TextButton(
                          onPressed: () async {
                            await ref
                                .read(notesProvider.notifier)
                                .restore(item.id);
                            ref.invalidate(deletedNotesProvider);
                          },
                          child: const Text('Restore'),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) =>
                const ListTile(title: Text('Unable to load deleted notes.')),
          ),
          const SizedBox(height: 16),
          Text('Deleted Tasks', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          tasks.when(
            data: (items) {
              if (items.isEmpty) {
                return const ListTile(title: Text('No deleted tasks.'));
              }
              return Column(
                children: items
                    .map(
                      (item) => ListTile(
                        title: Text(item.title),
                        trailing: TextButton(
                          onPressed: () async {
                            await ref
                                .read(tasksProvider.notifier)
                                .restore(item.id);
                            ref.invalidate(deletedTasksProvider);
                          },
                          child: const Text('Restore'),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) =>
                const ListTile(title: Text('Unable to load deleted tasks.')),
          ),
        ],
      ),
    );
  }
}
