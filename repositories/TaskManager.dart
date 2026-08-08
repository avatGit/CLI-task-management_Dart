import 'dart:convert';
import 'dart:io';
import '../Repository.dart';
import '../models/Task.dart';

class TaskManager implements Repository<Task> {
  @override
  Future<void> addTask(Task newTask, File file) async {
    // On cree une list dynamique pour stocker les taches qui sont dans le fichier json
    List<dynamic> currentTask = [];
    // Lecture du fichier
    String fileContent = await file.readAsString();

    if (fileContent.trim().isNotEmpty) {
      currentTask = jsonDecode(fileContent) as List<dynamic>;
    }

    bool taskExist = currentTask.any((task) {
      /* Note: as est utilise pour dire au compiler: ceci est un Map. Il ne convertie pas automatiquement en Map */
      final Map<String, dynamic> taskMap = task as Map<String, dynamic>;
      return taskMap['title'].toString() == newTask.title;
    });

    if (taskExist) {
      throw Exception('Cette tache existe déja.');
    }
    // On convertie la tache en json pour l'ajouter dans le fichier
    currentTask.add(newTask.tojson());

    // Convertit la liste en String JSON avec une indentation
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String updatedJsonContent = encoder.convert(currentTask);

    await file.writeAsString(updatedJsonContent);
  }

  /*   @override
  List<String> listAll(String sortBy, File file) {}

  @override
  String delete(Object task, File file) {
    // Implementation for deleting a task
  }

  @override
  String markAsDone(Object task, File file) {
    // Implementation for marking a task as done
  } */
}
