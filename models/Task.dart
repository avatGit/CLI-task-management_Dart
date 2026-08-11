class Task {
  final int id;
  final String title;
  final String priority;
  final DateTime createdAt;
  final DateTime deadLine;
  final bool isDone;

  Task({
    int? id,
    required this.title,
    required this.priority,
    DateTime? createdAt,
    this.isDone = false,
    DateTime? deadLine,
  }) : id = id ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       deadLine = deadLine ?? DateTime.now();

  bool get isUrgent => priority.toLowerCase() == 'haute';

  Task withDone() {
    if (this is UrgentTask) {
      return UrgentTask(
        id: id,
        title: title,
        createdAt: createdAt,
        deadLine: deadLine,
        isDone: true,
      );
    }

    return Task(
      id: id,
      title: title,
      priority: priority,
      createdAt: createdAt,
      deadLine: deadLine,
      isDone: true,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    final title = json['title'] as String? ?? 'Tache sans titre';
    final priorityValue = json['priority'] as String? ?? 'Basse';
    final priority = priorityValue.toLowerCase();
    final createdAtString =
        json['createdAt'] as String? ??
        json['date'] as String? ??
        DateTime.now().toIso8601String();
    final createdAt = DateTime.tryParse(createdAtString) ?? DateTime.now();
    final deadLineString = json['deadLine'] as String? ?? '';
    final deadLine = DateTime.tryParse(deadLineString) ?? DateTime.now();
    final isDone = json['isDone'] as bool? ?? false;

    if (priority == 'haute') {
      return UrgentTask(
        id: id,
        title: title,
        createdAt: createdAt,
        deadLine: deadLine,
        isDone: isDone,
      );
    }

    return Task(
      id: id,
      title: title,
      priority: priorityValue,
      createdAt: createdAt,
      deadLine: deadLine,
      isDone: isDone,
    );
  }

  Map<String, dynamic> tojson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'deadLine': deadLine.toIso8601String(),
      'isDone': isDone,
    };
  }

  Task withId(int id) {
    if (this is UrgentTask) {
      return UrgentTask(
        id: id,
        title: title,
        createdAt: createdAt,
        deadLine: deadLine,
        isDone: isDone,
      );
    }

    return Task(
      id: id,
      title: title,
      priority: priority,
      createdAt: createdAt,
      deadLine: deadLine,
      isDone: isDone,
    );
  }
}

class UrgentTask extends Task {
  UrgentTask({
    int? id,
    required String title,
    DateTime? createdAt,
    DateTime? deadLine,
    bool isDone = false,
  }) : super(
         id: id,
         title: title,
         priority: 'Haute',
         createdAt: createdAt,
         deadLine: deadLine,
         isDone: isDone,
       );
}
