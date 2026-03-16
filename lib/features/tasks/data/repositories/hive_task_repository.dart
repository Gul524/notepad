import 'package:hive/hive.dart';
import 'package:notepad/features/tasks/domain/entities/task_item.dart';
import 'package:notepad/features/tasks/domain/repositories/task_repository.dart';

class HiveTaskRepository implements TaskRepository {
  HiveTaskRepository(this._box);

  final Box<Map> _box;

  @override
  Future<List<TaskItem>> getAll({bool includeDeleted = false}) async {
    final tasks = _box.values.map(TaskItem.fromMap).toList();
    final filtered = includeDeleted
        ? tasks
        : tasks.where((item) => !item.isDeleted).toList();
    filtered.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
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
    return filtered;
  }

  @override
  Future<void> save(TaskItem task) async {
    await _box.put(task.id, task.toMap());
  }

  @override
  Future<void> softDelete(String id) async {
    final existing = _box.get(id);
    if (existing == null) {
      return;
    }
    final task = TaskItem.fromMap(existing);
    await save(
      task.copyWith(deletedAt: DateTime.now(), updatedAt: DateTime.now()),
    );
  }

  @override
  Future<void> restore(String id) async {
    final existing = _box.get(id);
    if (existing == null) {
      return;
    }
    final task = TaskItem.fromMap(existing);
    await save(task.copyWith(clearDeletedAt: true, updatedAt: DateTime.now()));
  }

  @override
  Future<void> deletePermanently(String id) async {
    await _box.delete(id);
  }
}
