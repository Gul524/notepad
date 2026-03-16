import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notepad/features/settings/presentation/providers/settings_provider.dart';
import 'package:notepad/features/trash/presentation/screens/trash_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<ThemeMode>(
            initialValue: settings.themeMode,
            decoration: const InputDecoration(labelText: 'Theme mode'),
            items: ThemeMode.values
                .map(
                  (item) =>
                      DropdownMenuItem(value: item, child: Text(item.name)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                notifier.setThemeMode(value);
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<double>(
            initialValue: settings.fontScale,
            decoration: const InputDecoration(labelText: 'Font size'),
            items: const [
              DropdownMenuItem(value: 0.9, child: Text('Small')),
              DropdownMenuItem(value: 1.0, child: Text('Medium')),
              DropdownMenuItem(value: 1.15, child: Text('Large')),
            ],
            onChanged: (value) {
              if (value != null) {
                notifier.setFontScale(value);
              }
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: settings.notificationsEnabled,
            onChanged: notifier.setNotifications,
            title: const Text('Notifications'),
            subtitle: const Text(
              'Enable notifications to get reminder alerts on time.',
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Test notification button'),
            subtitle: const Text(
              'Reminder test flow placeholder for local notification service.',
            ),
            trailing: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reminder service wiring is the next step.'),
                  ),
                );
              },
              child: const Text('Test'),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Secure Vault'),
            subtitle: const Text(
              'Biometric vault architecture is ready for local_auth wiring.',
            ),
            trailing: const Icon(Icons.lock_outline_rounded),
          ),
          const Divider(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Trash & Restore'),
            subtitle: const Text(
              'Restore notes or tasks deleted in the last 7 days.',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrashScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
