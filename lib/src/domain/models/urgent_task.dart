import 'task.dart';

class UrgentTask extends Task {
  UrgentTask({
    required int id,
    required String title,
    required DateTime createdAt,
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

  @override
  UrgentTask withDone() {
    return UrgentTask(
      id: id,
      title: title,
      createdAt: createdAt,
      deadLine: deadLine,
      isDone: true,
    );
  }

  @override
  UrgentTask withId(int id) {
    return UrgentTask(
      id: id,
      title: title,
      createdAt: createdAt,
      deadLine: deadLine,
      isDone: isDone,
    );
  }
}
