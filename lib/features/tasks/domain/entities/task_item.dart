enum TaskPriority { low, medium, high }

enum RepeatRule { none, daily, weekly }

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.details,
    required this.priority,
    required this.repeatRule,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.dueAt,
    this.reminderAt,
    this.deletedAt,
  });

  final String id;
  final String title;
  final String details;
  final TaskPriority priority;
  final RepeatRule repeatRule;
  final bool isCompleted;
  final DateTime? dueAt;
  final DateTime? reminderAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  TaskItem copyWith({
    String? id,
    String? title,
    String? details,
    TaskPriority? priority,
    RepeatRule? repeatRule,
    bool? isCompleted,
    DateTime? dueAt,
    DateTime? reminderAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDueAt = false,
    bool clearReminderAt = false,
    bool clearDeletedAt = false,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      details: details ?? this.details,
      priority: priority ?? this.priority,
      repeatRule: repeatRule ?? this.repeatRule,
      isCompleted: isCompleted ?? this.isCompleted,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      reminderAt: clearReminderAt ? null : (reminderAt ?? this.reminderAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'priority': priority.name,
      'repeatRule': repeatRule.name,
      'isCompleted': isCompleted,
      'dueAt': dueAt?.toIso8601String(),
      'reminderAt': reminderAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<dynamic, dynamic> map) {
    return TaskItem(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? '',
      details: (map['details'] as String?) ?? '',
      priority: TaskPriorityX.fromRaw((map['priority'] as String?) ?? ''),
      repeatRule: RepeatRuleX.fromRaw((map['repeatRule'] as String?) ?? ''),
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      dueAt: DateTime.tryParse(map['dueAt'] as String? ?? ''),
      reminderAt: DateTime.tryParse(map['reminderAt'] as String? ?? ''),
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

extension TaskPriorityX on TaskPriority {
  static TaskPriority fromRaw(String raw) {
    return TaskPriority.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => TaskPriority.medium,
    );
  }
}

extension RepeatRuleX on RepeatRule {
  static RepeatRule fromRaw(String raw) {
    return RepeatRule.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => RepeatRule.none,
    );
  }
}
