import 'package:notepad/features/notes/domain/entities/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getAll({bool includeDeleted = false});
  Future<void> save(Note note);
  Future<void> softDelete(String id);
  Future<void> restore(String id);
  Future<void> deletePermanently(String id);
}
