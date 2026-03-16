import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:notepad/features/tasks/data/repositories/hive_task_repository.dart';
import 'package:notepad/features/tasks/domain/entities/task_item.dart';
import 'package:notepad/features/tasks/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => HiveTaskRepository(Hive.box<Map>('tasks_box')),
);

final tasksProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<TaskItem>>>(
      (ref) => TasksNotifier(ref.read(taskRepositoryProvider)),
    );

final deletedTasksProvider = FutureProvider<List<TaskItem>>(
  (ref) => ref
      .read(taskRepositoryProvider)
      .getAll(includeDeleted: true)
      .then((all) => all.where((item) => item.isDeleted).toList()),
);

class TasksNotifier extends StateNotifier<AsyncValue<List<TaskItem>>> {
  TasksNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final TaskRepository _repository;
  final _id = const Uuid();

  Future<void> load() async {
    state = const AsyncValue.loading();
    final tasks = await _repository.getAll();
    state = AsyncValue.data(tasks);
  }

  Future<void> addTask({
    required String title,
    String details = '',
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueAt,
    DateTime? reminderAt,
    RepeatRule repeatRule = RepeatRule.none,
  }) async {
    final now = DateTime.now();
    final task = TaskItem(
      id: _id.v4(),
      title: title,
      details: details,
      priority: priority,
      repeatRule: repeatRule,
      isCompleted: false,
      dueAt: dueAt,
      reminderAt: reminderAt,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.save(task);
    await load();
  }

  Future<void> updateTask(TaskItem task) async {
    await _repository.save(task.copyWith(updatedAt: DateTime.now()));
    await load();
  }

  Future<void> toggleComplete(TaskItem task) async {
    await _repository.save(
      task.copyWith(isCompleted: !task.isCompleted, updatedAt: DateTime.now()),
    );
    await load();
  }

  Future<void> softDelete(String id) async {
    await _repository.softDelete(id);
    await load();
  }

  Future<void> restore(String id) async {
    await _repository.restore(id);
    await load();
  }
}
