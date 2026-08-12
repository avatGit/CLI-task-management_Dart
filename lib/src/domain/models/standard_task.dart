import 'task.dart';

class StandardTask extends Task {
  StandardTask({
    required int id,
    required String title,
    required String priority,
    required DateTime createdAt,
    DateTime? deadLine,
    bool isDone = false,
  }) : super(
          id: id,
          title: title,
          priority: priority,
          createdAt: createdAt,
          deadLine: deadLine,
          isDone: isDone,
        );

  @override
  StandardTask withDone() {
    return StandardTask(
      id: id,
      title: title,
      priority: priority,
      createdAt: createdAt,
      deadLine: deadLine,
      isDone: true,
    );
  }

  @override
  StandardTask withId(int id) {
    return StandardTask(
      id: id,
      title: title,
      priority: priority,
      createdAt: createdAt,
      deadLine: deadLine,
      isDone: isDone,
    );
  }
}
