import 'dart:io';

import 'models/Task.dart';
import './repositories/TaskManager.dart';
import 'models/TaskExceptions.dart';

class Menu {
  static Future<void> menu(File file) async {
    final manager = TaskManager();

    while (true) {
      print('=' * 70);
      print(
        '||' + ' ' * 15 + '    GESTIONNAIRE DE GESTION   ' + ' ' * 21 + '||',
      );
      print('=' * 70);
      print(' ' * 15 + '|' + ' ' * 13 + 'Menu' + ' ' * 15 + '|');
      print(' ' * 16 + '-' * 32);
      print('\t1. Ajouter une tache');
      print('\t2. Lister les taches');
      print('\t3. Supprimer une tache');
      print('\t4. Marquer une tache completé');
      print('\t5. Quitter');
      stdout.write('Veuillez choisir une option (1-5): ');
      String? choice = stdin.readLineSync();

      if (choice == '5') {
        print('Au revoir !');
        break;
      }

      if (choice == '1') {
        print('*' * 70);
        print(' ' * 18 + '    Ajout d\'une tache  ');
        print('*' * 70);
        stdout.write("Titre de la tache: ");
        String title = stdin.readLineSync() ?? "Tache sans titre";
        print('Veuillez choisir la Priorite de la tache');
        print("""
1- Haute
2- Moyenne
3- Basse
""");
        String? priorityInput = stdin.readLineSync();
        String priority = "";
        switch (priorityInput) {
          case "1":
            priority = "Haute";
            break;
          case "2":
            priority = "Moyenne";
            break;
          case "3":
            priority = "Basse";
            break;
          default:
            throw InvalidPriorityException(taskTitle: title);
        }
        stdout.write('Veuillez saisir le delai (optionnelle) (jj/mm/aa/): ');
        String delai = stdin.readLineSync() ?? '';
        DateTime? deadLine;
        if (delai.trim().isNotEmpty) {
          try {
            deadLine = convertToDate(delai);
          } on InvalidDateFormatException catch (e) {
            print(e);
            continue;
          }
        }

        Task newTask;
        if (priority == 'Haute') {
          newTask = UrgentTask(title: title, deadLine: deadLine);
        } else {
          newTask = Task(title: title, priority: priority, deadLine: deadLine);
        }

        await manager.addTask(newTask, file);
      } else if (choice == '2') {
        print('*' * 70);
        print(' ' * 18 + '    Listes des taches ');
        print('*' * 70);
        print('Veuillez choisir le filtre a appliqué: ');
        print("""
1- Par Date de creation
2- Par Priorité""");
        stdout.write("Choisir un numero: ");
        String? sortByInput = stdin.readLineSync();
        List<Task> tasks;

        if (sortByInput == '2') {
          tasks = await manager.listAll('priority', file);
        } else {
          tasks = await manager.listAll('createdAt', file);
        }

        printTaskTable(tasks);
      } else if (choice == '3') {
        // SUPPRESSION DE TACHE
        final tasks = await manager.listAll('createdAt', file);
        if (tasks.isEmpty) {
          print('Aucune tache disponible pour la suppression.');
          continue;
        }

        printTaskTable(tasks);
        stdout.write('Entrez l\'id de la tache a supprimer: ');
        final idInput = stdin.readLineSync();
        final id = int.tryParse(idInput ?? '');

        if (id == null) {
          print('ID invalide. Entrez un nombre entier.');
          continue;
        }

        Task? taskToDelete;
        try {
          taskToDelete = tasks.firstWhere((task) => task.id == id);
        } catch (_) {
          taskToDelete = null;
        }

        if (taskToDelete == null) {
          print('Aucune tache trouvee avec l\'id $id.');
          continue;
        }

        stdout.write(
          'Confirmer suppression de "${taskToDelete.title}" ? (O/N): ',
        );
        final confirmation = stdin.readLineSync();
        if (confirmation?.toLowerCase() == 'o') {
          await manager.deleteTask(id, file);
          print("*" * 20);
          print('* Tache supprimee. *');
          print("*" * 20);
        } else {
          print("*" * 20);
          print('* Suppression annulee. *');
          print("*" * 20);
        }
      } else if (choice == '4') {
        final tasks = await manager.listAll('createdAt', file);
        if (tasks.isEmpty) {
          print('Aucune tache disponible.');
          continue;
        }
        printTaskTable(tasks);

        stdout.write("Veuillez Entrer l'id de la tache a terminée: ");
        final String? idTask = stdin.readLineSync();
        final int? id = int.tryParse(idTask ?? '');
        if (id != null) {
          try {
            final result = await manager.markAsDone(id, file);
            print(result);
          } catch (e) {
            print(e);
          }
        } else {
          print('ID invalide. Veuillez entrer un nombre entier.');
        }
      } else {
        print('Choix invalide. Veuillez entrer un nombre entre 1 et 5.');
      }
    }
  }

  /* AFFICHAGE DU TABLEAU CONTENANT LES TACHES */
  static void printTaskTable(List<Task> tasks) {
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
      final createdAt = formatDateTime(task.createdAt).padRight(19);
      final deadline = task.deadLine == task.createdAt
          ? 'Pas definie'.padRight(15)
          : formatDateTime(task.deadLine).padRight(15);
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

  static String formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  static DateTime convertToDate(String dateStr) {
    var re = RegExp(
      r'^'
      r'(?<day>[0-9]{1,2})/'
      r'(?<month>[0-9]{1,2})/'
      r'(?<year>[0-9]{2,4})'
      r'$',
    );

    var match = re.firstMatch(dateStr.trim());
    if (match == null) {
      throw InvalidDateFormatException();
    }

    final day = int.parse(match.namedGroup('day')!);
    final month = int.parse(match.namedGroup('month')!);
    var year = match.namedGroup('year')!;
    final yearInt = year.length == 2 ? 2000 + int.parse(year) : int.parse(year);

    try {
      return DateTime(yearInt, month, day);
    } catch (_) {
      throw InvalidDateFormatException();
    }
  }
}

void main() async {
  File file = File('tasks.json');

  if (!await file.exists()) {
    file = File('./tasks.json');
  }

  if (!await file.exists()) {
    await file.create(recursive: true);
    await file.writeAsString('[]');
  }

  /* on doit matcher avec les priority string. "1" --> "low" et print Basse a l'utilisateur */

  try {
    await Menu.menu(file);
  } catch (e, stackTrace) {
    print('Erreur: $e StackTrace: $stackTrace');
  }
}
