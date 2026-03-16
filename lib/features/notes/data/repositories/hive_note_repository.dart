import 'package:hive/hive.dart';
import 'package:notepad/features/notes/domain/entities/note.dart';
import 'package:notepad/features/notes/domain/repositories/note_repository.dart';

class HiveNoteRepository implements NoteRepository {
  HiveNoteRepository(this._box);

  final Box<Map> _box;

  @override
  Future<List<Note>> getAll({bool includeDeleted = false}) async {
    final notes = _box.values.map(Note.fromMap).toList();
    final filtered = includeDeleted
        ? notes
        : notes.where((item) => !item.isDeleted).toList();
    filtered.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return filtered;
  }

  @override
  Future<void> save(Note note) async {
    await _box.put(note.id, note.toMap());
  }

  @override
  Future<void> softDelete(String id) async {
    final existing = _box.get(id);
    if (existing == null) {
      return;
    }
    final note = Note.fromMap(existing);
    await save(
      note.copyWith(deletedAt: DateTime.now(), updatedAt: DateTime.now()),
    );
  }

  @override
  Future<void> restore(String id) async {
    final existing = _box.get(id);
    if (existing == null) {
      return;
    }
    final note = Note.fromMap(existing);
    await save(note.copyWith(clearDeletedAt: true, updatedAt: DateTime.now()));
  }

  @override
  Future<void> deletePermanently(String id) async {
    await _box.delete(id);
  }
}
