import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notepad/core/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<Map>('notes_box'),
    Hive.openBox<Map>('tasks_box'),
  ]);
  runApp(const ProviderScope(child: NoteFlowApp()));
}
