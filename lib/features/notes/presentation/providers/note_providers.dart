import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:notepad/features/notes/data/repositories/hive_note_repository.dart';
import 'package:notepad/features/notes/domain/entities/note.dart';
import 'package:notepad/features/notes/domain/repositories/note_repository.dart';
import 'package:uuid/uuid.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => HiveNoteRepository(Hive.box<Map>('notes_box')),
);

final notesProvider =
    StateNotifierProvider<NotesNotifier, AsyncValue<List<Note>>>(
      (ref) => NotesNotifier(ref.read(noteRepositoryProvider)),
    );

final deletedNotesProvider = FutureProvider<List<Note>>(
  (ref) => ref
      .read(noteRepositoryProvider)
      .getAll(includeDeleted: true)
      .then((all) => all.where((note) => note.isDeleted).toList()),
);

class NotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  NotesNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final NoteRepository _repository;
  final _id = const Uuid();

  Future<void> load() async {
    state = const AsyncValue.loading();
    final notes = await _repository.getAll();
    state = AsyncValue.data(notes);
  }

  Future<void> addNote({
    required String title,
    required String content,
    NoteType type = NoteType.plain,
    List<String> tags = const [],
    int colorValue = 0x336366F1,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _id.v4(),
      title: title,
      content: content,
      type: type,
      tags: tags,
      colorValue: colorValue,
      isPinned: false,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.save(note);
    await load();
  }

  Future<void> updateNote(Note note) async {
    await _repository.save(note.copyWith(updatedAt: DateTime.now()));
    await load();
  }

  Future<void> togglePin(Note note) async {
    await _repository.save(
      note.copyWith(isPinned: !note.isPinned, updatedAt: DateTime.now()),
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
