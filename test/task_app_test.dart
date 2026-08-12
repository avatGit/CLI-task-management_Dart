import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../main.dart';
import '../models/Task.dart';
import '../models/TaskExceptions.dart';
import '../repositories/TaskManager.dart';

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
      expect(task.deadLine.year, equals(2026));
    });

    test('tojson et fromJson preservent les champs', () {
      final original = Task(
        id: 3,
        title: 'Roundtrip test',
        priority: 'Moyenne',
        createdAt: DateTime(2025, 1, 2, 3, 4),
        deadLine: DateTime(2025, 2, 3, 4, 5),
        isDone: true,
      );

      final json = original.tojson();
      final restored = Task.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.title, equals(original.title));
      expect(restored.priority, equals(original.priority));
      expect(restored.createdAt.toUtc(), equals(original.createdAt.toUtc()));
      expect(restored.deadLine.toUtc(), equals(original.deadLine.toUtc()));
      expect(restored.isDone, equals(original.isDone));
    });
  });

  group('Date validation', () {
    test('convertToDate prend en charge le format d\'annee court', () {
      final parsed = Menu.convertToDate('26/10/26');

      expect(parsed.year, equals(2026));
      expect(parsed.month, equals(10));
      expect(parsed.day, equals(26));
    });

    test('convertToDate leve une exception en cas de format invalide', () {
      expect(
        () => Menu.convertToDate('2026-10-26'),
        throwsA(isA<InvalidDateFormatException>()),
      );
    });
  });

  group('TaskManager', () {
    late Directory tempDir;
    late File tempFile;
    late TaskManager manager;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('task_manager_test');
      tempFile = File('${tempDir.path}${Platform.pathSeparator}tasks.json');
      tempFile.writeAsStringSync('[]');
      manager = TaskManager();
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('addTask enregistre de facon permanente une nouvelle tache', () async {
      final task = Task(
        title: 'Test add',
        priority: 'Basse',
        deadLine: DateTime(2026, 11, 1),
      );

      await manager.addTask(task, tempFile);
      final tasks = await manager.listAll('createdAt', tempFile);

      expect(tasks, hasLength(1));
      expect(tasks[0].title, equals('Test add'));
      expect(tasks[0].priority, equals('Basse'));
      expect(tasks[0].id, greaterThan(0));
    });

    test('listAll filtre par \'priority\' and "createdAt"', () async {
      final task1 = Task(title: 'A', priority: 'Moyenne');
      final task2 = Task(title: 'B', priority: 'Basse');
      final task3 = UrgentTask(title: 'C');

      await manager.addTask(task1, tempFile);
      await manager.addTask(task2, tempFile);
      await manager.addTask(task3, tempFile);

      final sortedByPriority = await manager.listAll('priority', tempFile);
      expect(sortedByPriority.map((t) => t.priority).toList(),
          equals(['Basse', 'Haute', 'Moyenne']));

      final sortedByCreatedAt = await manager.listAll('createdAt', tempFile);
      expect(sortedByCreatedAt, hasLength(3));
    });

    test('markAsDone met a jour le drapeau de completion de la tache',
        () async {
      final task = Task(title: 'Complete me', priority: 'Basse');
      await manager.addTask(task, tempFile);
      final tasksBefore = await manager.listAll('createdAt', tempFile);
      expect(tasksBefore.first.isDone, isFalse);

      final result = await manager.markAsDone(tasksBefore.first.id, tempFile);
      expect(result, contains('Tache marquée comme terminée'));

      final tasksAfter = await manager.listAll('createdAt', tempFile);
      expect(tasksAfter.first.isDone, isTrue);
    });

    test('deleteTask supprime la tache correcte', () async {
      final task1 = Task(title: 'Keep me', priority: 'Basse');
      final task2 = Task(title: 'Delete me', priority: 'Moyenne');
      await manager.addTask(task1, tempFile);
      await manager.addTask(task2, tempFile);

      final allTasks = await manager.listAll('createdAt', tempFile);
      expect(allTasks, hasLength(2));

      await manager.deleteTask(allTasks[1].id, tempFile);
      final remaining = await manager.listAll('createdAt', tempFile);
      expect(remaining, hasLength(1));
      expect(remaining.first.title, equals('Keep me'));
    });

    test('addTask lance TaskAlreadyExistsException pour doublon', () async {
      final task = Task(title: 'Duplicate', priority: 'Basse');
      await manager.addTask(task, tempFile);

      expect(
        () async => await manager.addTask(task, tempFile),
        throwsA(isA<TaskAlreadyExistsException>()),
      );
    });
  });
}
