import 'dart:io';

import '../domain/models/task.dart';
import '../domain/models/standard_task.dart';
import '../domain/models/urgent_task.dart';
import '../core/exceptions/task_exceptions.dart';
import '../data/datasources/json_storage.dart';
import '../data/repositories/json_task_repository.dart';

class CliRunner {
  final File file;
  late final JsonTaskRepository repository;

  CliRunner({required this.file}) {
    repository = JsonTaskRepository(JsonStorage(file));
  }

  Future<void> run() async {
    while (true) {
      _printMenu();
      stdout.write('Veuillez choisir une option (1-5): ');
      final choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          await _addTask();
          break;
        case '2':
          await _listTasks();
          break;
        case '3':
          await _deleteTask();
          break;
        case '4':
          await _markTaskDone();
          break;
        case '5':
          print('Au revoir !');
          return;
        default:
          print('Choix invalide. Veuillez entrer un nombre entre 1 et 5.');
      }
    }
  }

  void _printMenu() {
    print('=' * 70);
    print('||' + ' ' * 15 + '    GESTIONNAIRE DE GESTION   ' + ' ' * 21 + '||');
    print('=' * 70);
    print(' ' * 15 + '|' + ' ' * 13 + 'Menu' + ' ' * 15 + '|');
    print(' ' * 16 + '-' * 32);
    print('\t1. Ajouter une tache');
    print('\t2. Lister les taches');
    print('\t3. Supprimer une tache');
    print('\t4. Marquer une tache completé');
    print('\t5. Quitter');
  }

  Future<void> _addTask() async {
    print('*' * 70);
    print(' ' * 18 + '    Ajout d\'une tache  ');
    print('*' * 70);
    stdout.write('Titre de la tache: ');
    final title = stdin.readLineSync() ?? 'Tache sans titre';

    print('Veuillez choisir la Priorite de la tache');
    print('1- Haute\n2- Moyenne\n3- Basse\n');
    final priorityInput = stdin.readLineSync();
    late final String priority;
    switch (priorityInput) {
      case '1':
        priority = 'Haute';
        break;
      case '2':
        priority = 'Moyenne';
        break;
      case '3':
        priority = 'Basse';
        break;
      default:
        print(InvalidPriorityException(taskTitle: title));
        return;
    }

    stdout.write('Veuillez saisir le delai (optionnelle) (jj/mm/aa/): ');
    final delai = stdin.readLineSync() ?? '';
    DateTime? deadLine;

    if (delai.trim().isNotEmpty) {
      try {
        deadLine = _convertToDate(delai);
      } on InvalidDateFormatException catch (e) {
        print(e);
        return;
      }
    }

    final task = priority == 'Haute'
        ? UrgentTask(
            id: 0,
            title: title,
            createdAt: DateTime.now(),
            deadLine: deadLine,
          )
        : StandardTask(
            id: 0,
            title: title,
            priority: priority,
            createdAt: DateTime.now(),
            deadLine: deadLine,
          );

    await repository.addTask(task);
    print('*' * 30);
    print('* Tache ajoutée avec succes! *');
    print('*' * 30);
  }

  Future<void> _listTasks() async {
    print('*' * 70);
    print(' ' * 18 + '    Listes des taches ');
    print('*' * 70);
    print('Veuillez choisir le filtre a appliqué: ');
    print('1- Par Date de creation\n2- Par Priorité');
    stdout.write('Choisir un numero: ');
    final sortByInput = stdin.readLineSync();

    final tasks = await repository.listAll(
      sortByInput == '2' ? 'priority' : 'createdAt',
    );
    _printTaskTable(tasks);
  }

  Future<void> _deleteTask() async {
    final tasks = await repository.listAll('createdAt');
    if (tasks.isEmpty) {
      print('Aucune tache disponible pour la suppression.');
      return;
    }
    _printTaskTable(tasks);
    stdout.write('Entrez l\'id de la tache a supprimer: ');
    final idInput = stdin.readLineSync();
    final id = int.tryParse(idInput ?? '');

    if (id == null) {
      print('ID invalide. Entrez un nombre entier.');
      return;
    }

    try {
      await repository.deleteTask(id);
      print('*' * 20);
      print('* Tache supprimee. *');
      print('*' * 20);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _markTaskDone() async {
    final tasks = await repository.listAll('createdAt');
    if (tasks.isEmpty) {
      print('Aucune tache disponible.');
      return;
    }
    _printTaskTable(tasks);
    stdout.write('Veuillez Entrer l\'id de la tache a terminée: ');
    final idTask = stdin.readLineSync();
    final id = int.tryParse(idTask ?? '');
    if (id == null) {
      print('ID invalide. Veuillez entrer un nombre entier.');
      return;
    }

    try {
      final result = await repository.markAsDone(id);
      print(result);
    } catch (e) {
      print(e);
    }
  }

  void _printTaskTable(List<Task> tasks) {
    final separator = '-' * 105;
    print(separator);
    print(
      'ID'.padRight(4) +
          '| ' +
          'Titre'.padRight(26) +
          '| ' +
          'Priorite'.padRight(10) +
          '| ' +
          'Date'.padRight(19) +
          '| ' +
          'Delai'.padRight(15) +
          '| ' +
          'Completee'.padRight(10) +
          '|',
    );
    print(separator);
    for (final task in tasks) {
      final id = task.id.toString().padRight(4);
      final createdAt = _formatDateTime(task.createdAt).padRight(19);
      final deadline = task.deadLine == null
          ? 'Pas definie'.padRight(15)
          : _formatDateTime(task.deadLine!).padRight(15);
      final completed = task.isDone ? 'Oui'.padRight(10) : 'Non'.padRight(10);
      print(
        id +
            '| ' +
            task.title.padRight(26) +
            '| ' +
            task.priority.padRight(10) +
            '| ' +
            createdAt +
            '| ' +
            deadline +
            '| ' +
            completed +
            '|',
      );
    }
    print(separator);
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  DateTime _convertToDate(String dateStr) {
    final re = RegExp(
      r'^'
      r'(?<day>[0-9]{1,2})/'
      r'(?<month>[0-9]{1,2})/'
      r'(?<year>[0-9]{2,4})'
      r'$',
    );

    final match = re.firstMatch(dateStr.trim());
    if (match == null) {
      throw InvalidDateFormatException();
    }

    final day = int.parse(match.namedGroup('day')!);
    final month = int.parse(match.namedGroup('month')!);
    final year = match.namedGroup('year')!;
    final yearInt = year.length == 2 ? 2000 + int.parse(year) : int.parse(year);

    try {
      return DateTime(yearInt, month, day);
    } catch (_) {
      throw InvalidDateFormatException();
    }
  }
}
