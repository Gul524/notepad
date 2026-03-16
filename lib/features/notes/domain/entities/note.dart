class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.tags,
    required this.colorValue,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String title;
  final String content;
  final NoteType type;
  final List<String> tags;
  final int colorValue;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Note copyWith({
    String? id,
    String? title,
    String? content,
    NoteType? type,
    List<String>? tags,
    int? colorValue,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      colorValue: colorValue ?? this.colorValue,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.name,
      'tags': tags,
      'colorValue': colorValue,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<dynamic, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      type: NoteTypeX.fromRaw((map['type'] as String?) ?? ''),
      tags: ((map['tags'] as List?) ?? const []).cast<String>(),
      colorValue: (map['colorValue'] as int?) ?? 0xFF6366F1,
      isPinned: (map['isPinned'] as bool?) ?? false,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      deletedAt: DateTime.tryParse(map['deletedAt'] as String? ?? ''),
    );
  }
}

enum NoteType { plain, checklist }

extension NoteTypeX on NoteType {
  static NoteType fromRaw(String raw) {
    return NoteType.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => NoteType.plain,
    );
  }
}
