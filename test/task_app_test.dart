import 'dart:io';

import 'package:test/test.dart';
import 'package:cli_task_management_app/src/core/exceptions/task_exceptions.dart';
import 'package:cli_task_management_app/src/data/datasources/json_storage.dart';
import 'package:cli_task_management_app/src/data/repositories/json_task_repository.dart';
import 'package:cli_task_management_app/src/domain/models/task.dart';
import 'package:cli_task_management_app/src/domain/models/standard_task.dart';
import 'package:cli_task_management_app/src/domain/models/urgent_task.dart';

void main() {
  group('Task model', () {
    test('fromJson retourne UrgentTask pour une priorité haute', () {
      final json = {
        'id': 7,
        'title': 'Test Urgent',
        'priority': 'Haute',
        'createdAt': DateTime(2026, 8, 11).toIso8601String(),
        'deadLine': DateTime(2026, 12, 31).toIso8601String(),
        'isDone': false,
      };

      final task = Task.fromJson(json);

      expect(task, isA<UrgentTask>());
      expect(task.isUrgent, isTrue);
      expect(task.priority, equals('Haute'));
      expect(task.deadLine?.year, equals(2026));
    });

    test('toJson et fromJson préservent les champs', () {
      final original = StandardTask(
        id: 3,
        title: 'Roundtrip test',
        priority: 'Moyenne',
        createdAt: DateTime(2025, 1, 2, 3, 4),
        deadLine: DateTime(2025, 2, 3, 4, 5),
        isDone: true,
      );

      final json = original.toJson();
      final restored = Task.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.title, equals(original.title));
      expect(restored.priority, equals(original.priority));
      expect(restored.createdAt.toUtc(), equals(original.createdAt.toUtc()));
      expect(restored.deadLine?.toUtc(), equals(original.deadLine?.toUtc()));
      expect(restored.isDone, equals(original.isDone));
    });
  });

  group('JsonTaskRepository', () {
    late Directory tempDir;
    late File tempFile;
    late JsonTaskRepository repository;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('task_manager_test');
      tempFile = File('${tempDir.path}${Platform.pathSeparator}tasks.json');
      tempFile.writeAsStringSync('[]');
      repository = JsonTaskRepository(JsonStorage(tempFile));
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('addTask enregistre une nouvelle tache', () async {
      final task = StandardTask(
        id: 0,
        title: 'Test add',
        priority: 'Basse',
        createdAt: DateTime.now(),
        deadLine: DateTime(2026, 11, 1),
      );

      await repository.addTask(task);
      final tasks = await repository.listAll('createdAt');

      expect(tasks, hasLength(1));
      expect(tasks[0].title, equals('Test add'));
      expect(tasks[0].priority, equals('Basse'));
      expect(tasks[0].id, greaterThan(0));
    });

    test('listAll trie par priorité et date', () async {
      final task1 = StandardTask(
        id: 0,
        title: 'A',
        priority: 'Moyenne',
        createdAt: DateTime(2026, 1, 1),
      );
      final task2 = StandardTask(
        id: 0,
        title: 'B',
        priority: 'Basse',
        createdAt: DateTime(2026, 1, 2),
      );
      final task3 = UrgentTask(
        id: 0,
        title: 'C',
        createdAt: DateTime(2026, 1, 3),
      );

      await repository.addTask(task1);
      await repository.addTask(task2);
      await repository.addTask(task3);

      final sortedByPriority = await repository.listAll('priority');
      expect(sortedByPriority.map((t) => t.priority).toList(),
          equals(['Basse', 'Haute', 'Moyenne']));

      final sortedByCreatedAt = await repository.listAll('createdAt');
      expect(
          sortedByCreatedAt.map((t) => t.createdAt).toList(),
          equals([
            DateTime(2026, 1, 1),
            DateTime(2026, 1, 2),
            DateTime(2026, 1, 3)
          ]));
    });

    test('markAsDone met à jour isDone', () async {
      final task = StandardTask(
        id: 0,
        title: 'Complete me',
        priority: 'Basse',
        createdAt: DateTime.now(),
      );
      await repository.addTask(task);
      final tasksBefore = await repository.listAll('createdAt');
      expect(tasksBefore.first.isDone, isFalse);

      final result = await repository.markAsDone(tasksBefore.first.id);
      expect(result, contains('Tache marquée comme terminée'));

      final tasksAfter = await repository.listAll('createdAt');
      expect(tasksAfter.first.isDone, isTrue);
    });

    test('deleteTask supprime la tache correcte', () async {
      final task1 = StandardTask(
        id: 0,
        title: 'Keep me',
        priority: 'Basse',
        createdAt: DateTime(2026, 1, 1),
      );
      final task2 = StandardTask(
        id: 0,
        title: 'Delete me',
        priority: 'Moyenne',
        createdAt: DateTime(2026, 1, 2),
      );
      await repository.addTask(task1);
      await repository.addTask(task2);

      final allTasks = await repository.listAll('createdAt');
      expect(allTasks, hasLength(2));

      await repository.deleteTask(allTasks[1].id);
      final remaining = await repository.listAll('createdAt');
      expect(remaining, hasLength(1));
      expect(remaining.first.title, equals('Keep me'));
    });

    test('addTask lance TaskAlreadyExistsException pour doublon', () async {
      final task = StandardTask(
        id: 0,
        title: 'Duplicate',
        priority: 'Basse',
        createdAt: DateTime.now(),
      );
      await repository.addTask(task);

      expect(
        () async => await repository.addTask(task),
        throwsA(isA<TaskAlreadyExistsException>()),
      );
    });
  });
}
