class Task {
  final String title;
  final List<String> priority;
  final DateTime deadLine;
  final bool isDone;

  Task({
    required this.title,
    this.priority = const ['low', 'medium', 'high'],
    this.isDone = false,
    DateTime? deadLine,
  }) : deadLine = deadLine ?? DateTime.now();

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] as String,
      priority: json['priority'] as List<String>,
      deadLine: DateTime.parse(json['deadLine'] as String),
      isDone: json['isDone'] as bool,
    );
  }

  Map<String, dynamic> tojson() {
    return {
      'title': title,
      'priority': priority,
      'deadLine': deadLine.toIso8601String(),
      'isDone': isDone,
    };
  }
}
