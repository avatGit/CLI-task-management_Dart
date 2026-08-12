import 'dart:convert';
import 'dart:io';
import '../interfaces/task_repository.dart';
import '../models/Task.dart';
import '../models/TaskExceptions.dart';

class TaskManager implements TaskRepository {
  Future<List<Task>> _readTasks(File file) async {
    final List<Task> emptyList = [];
    final String fileContent = file.readAsStringSync();
    if (!fileContent.trim().isNotEmpty) {
      return emptyList;
    }
    final List<dynamic> taskList = jsonDecode(fileContent) as List<dynamic>;
    final tasks = taskList
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();

    var maxId = tasks.fold<int>(
      0,
      (current, task) => task.id > current ? task.id : current,
    );

    var migrated = false;

    for (var i = 0; i < tasks.length; i++) {
      if (tasks[i].id <= 0) {
        maxId++;
        tasks[i] = tasks[i].withId(maxId);
        migrated = true;
      }
    }

    if (migrated) {
      _writeTasks(file, tasks);
    }

    return tasks;
  }

  void _writeTasks(File file, List<Task> tasks) {
    final taskJson = tasks.map((task) => task.tojson()).toList();
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    file.writeAsStringSync(encoder.convert(taskJson));
  }

  @override
  Future<void> addTask(Task newTask, File file) async {
    print('Function Ajouter tache');
    final tasks = await _readTasks(file);
    print('Json file read.');
    final nextId =
        tasks.fold<int>(
          0,
          (current, task) => task.id > current ? task.id : current,
        ) +
        1;
    final taskToSave = newTask.id > 0 ? newTask : newTask.withId(nextId);

    bool taskExist = tasks.any((task) => task.title == taskToSave.title);
    if (taskExist) {
      throw TaskAlreadyExistsException(taskTitle: taskToSave.title);
    }

    try {
      tasks.add(taskToSave);
      _writeTasks(file, tasks);
      print("*" * 30);
      print("* Tache ajouté avec succes! *");
      print("*" * 30);
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<List<Task>> listAll(String sortBy, File file) async {
    final tasks = await _readTasks(file);
    if (sortBy == 'priority') {
      tasks.sort((a, b) => a.priority.compareTo(b.priority));
    } else if (sortBy == 'createdAt') {
      tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return tasks;
  }

  @override
  Future<void> deleteTask(int id, File file) async {
    final tasks = await _readTasks(file);
    final remaining = tasks.where((task) => task.id != id).toList();

    if (remaining.length == tasks.length) {
      throw Exception('Aucune tache trouvée avec l\'id $id.');
    }

    _writeTasks(file, remaining);
  }

  @override
  Future<String> markAsDone(int id, File file) async {
    final tasks = await _readTasks(file);

    final index = tasks.indexWhere((task) => task.id == id);
    if (index < 0) {
      throw Exception('Aucune tache trouvée avec l\'id $id.');
    }

    tasks[index] = tasks[index].withDone();
    _writeTasks(file, tasks);

    final message = '* Tache marquée comme terminée. *';
    print('*' * 32);
    print(message);
    print('*' * 32);
    return message;
  }
}
