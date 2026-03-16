import 'package:notepad/features/tasks/domain/entities/task_item.dart';

abstract class TaskRepository {
  Future<List<TaskItem>> getAll({bool includeDeleted = false});
  Future<void> save(TaskItem task);
  Future<void> softDelete(String id);
  Future<void> restore(String id);
  Future<void> deletePermanently(String id);
}
