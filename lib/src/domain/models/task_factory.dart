import 'package:cli_task_management_app/src/domain/models/standard_task.dart';
import 'package:cli_task_management_app/src/domain/models/urgent_task.dart';
import 'package:cli_task_management_app/src/domain/models/task.dart';

Task createTaskFromJson(Map<String, dynamic> json) {
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
