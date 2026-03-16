import 'package:flutter/material.dart';
import 'package:notepad/features/home/presentation/screens/home_dashboard_screen.dart';
import 'package:notepad/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:notepad/features/notes/presentation/screens/notes_screen.dart';
import 'package:notepad/features/settings/presentation/screens/settings_screen.dart';
import 'package:notepad/features/tasks/presentation/screens/task_editor_screen.dart';
import 'package:notepad/features/tasks/presentation/screens/tasks_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = const [
      HomeDashboardScreen(),
      NotesScreen(),
      TasksScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_index]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openQuickCapture(context),
        icon: const Icon(Icons.add),
        label: const Text('Quick Capture'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_alt_outlined),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Future<void> _openQuickCapture(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.sticky_note_2_outlined),
                title: const Text('New Note'),
                subtitle: const Text('Capture a thought instantly'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.task_alt_outlined),
                title: const Text('New Task'),
                subtitle: const Text('Add a task in seconds'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TaskEditorScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
