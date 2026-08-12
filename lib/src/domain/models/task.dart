import 'standard_task.dart';
import 'urgent_task.dart';

abstract class Task {
  final int id;
  final String title;
  final String priority;
  final DateTime createdAt;
  final DateTime? deadLine;
  final bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.createdAt,
    this.deadLine,
    this.isDone = false,
  });

  bool get isUrgent => priority.toLowerCase() == 'haute';

  Task withDone();
  Task withId(int id);

  factory Task.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    final title = json['title'] as String? ?? 'Tache sans titre';
    final priorityValue = json['priority'] as String? ?? 'Basse';
    final createdAtString =
        json['createdAt'] as String? ?? DateTime.now().toIso8601String();
    final createdAt = DateTime.tryParse(createdAtString) ?? DateTime.now();
    final deadLineString = json['deadLine'] as String?;
    final deadLine =
        deadLineString != null ? DateTime.tryParse(deadLineString) : null;
    final isDone = json['isDone'] as bool? ?? false;

    if (priorityValue.toLowerCase() == 'haute') {
      return UrgentTask(
        id: id,
        title: title,
        createdAt: createdAt,
        deadLine: deadLine,
        isDone: isDone,
      );
    }

    return StandardTask(
      id: id,
      title: title,
      priority: priorityValue,
      createdAt: createdAt,
      deadLine: deadLine,
      isDone: isDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'deadLine': deadLine?.toIso8601String(),
      'isDone': isDone,
    };
  }
}
