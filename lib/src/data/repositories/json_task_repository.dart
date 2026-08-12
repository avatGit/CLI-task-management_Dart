import '../../domain/models/task.dart';
import '../../core/exceptions/task_exceptions.dart';
import '../datasources/json_storage.dart';
import '../../domain/repositories/repository.dart';

class JsonTaskRepository implements Repository<Task> {
  final JsonStorage storage;

  JsonTaskRepository(this.storage);

  @override
  Future<void> addTask(Task newTask) async {
    final taskList = await _readTasks();
    final nextId = taskList.fold<int>(
            0, (current, task) => task.id > current ? task.id : current) +
        1;
    final taskToSave = newTask.id > 0 ? newTask : newTask.withId(nextId);

    if (taskList.any((task) => task.title == taskToSave.title)) {
      throw TaskAlreadyExistsException(taskTitle: taskToSave.title);
    }

    taskList.add(taskToSave);
    await _writeTasks(taskList);
  }

  @override
  Future<void> deleteTask(int id) async {
    final taskList = await _readTasks();
    final remaining = taskList.where((task) => task.id != id).toList();
    if (remaining.length == taskList.length) {
      throw TaskNotFoundException(taskId: id);
    }
    await _writeTasks(remaining);
  }

  @override
  Future<List<Task>> listAll(String sortBy) async {
    final tasks = await _readTasks();
    if (sortBy == 'priority') {
      tasks.sort((a, b) => a.priority.compareTo(b.priority));
    } else {
      tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return tasks;
  }

  @override
  Future<String> markAsDone(int id) async {
    final tasks = await _readTasks();
    final index = tasks.indexWhere((task) => task.id == id);
    if (index < 0) {
      throw TaskNotFoundException(taskId: id);
    }

    tasks[index] = tasks[index].withDone();
    await _writeTasks(tasks);
    return '* Tache marquée comme terminée. *';
  }

  Future<List<Task>> _readTasks() async {
    final raw = await storage.readJsonList();
    final tasks = raw.map((json) => Task.fromJson(json)).toList();
    return tasks;
  }

  Future<void> _writeTasks(List<Task> tasks) async {
    await storage.writeJsonList(tasks.map((task) => task.toJson()).toList());
  }
}
