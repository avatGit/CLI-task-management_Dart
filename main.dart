import 'dart:io';

import 'models/Task.dart';
import './repositories/TaskManager.dart';

class Menu {
  static dynamic menu(File file) {
    final manager = TaskManager();
    print('=' * 10);
    print(' ' * 3 + '||    GESTIONNAIRE DE GESTION   ||');
    print('=' * 0);
    print(' ' * 7 + 'Menu');
    print(' ' * 5 + '-' * 7);
    print('\t1. Ajouter une tache');
    print('\t2. Lister les taches');
    print('\t3. Supprimer une tache');
    print('\t4. Marquer une tache completé');
    print('\t5. Quitter');
    stdout.write('Veuillez choisir une option (1-5): ');
    String? choice = stdin.readLineSync();

    if (choice == '1') {
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
          String priority = "Haute";
          break;
        case "2":
          String priority = "Moyenne";
          break;
        case "3":
          String priority = "Basse";
          break;
        default:
          print("Priorité invalide. Veuillez choisir entre 1, 2 ou 3.");
      }
      stdout.write('Veuillez saisir le delai (optionnelle) (jj/mm/aa/): ');
      String delai = stdin.readLineSync() ?? "Pas de delai";
      DateTime? deadLine;
      if (delai.contains('/')) {
        deadLine = convertToDate(delai);
      }

      Task newTask = Task(title: title, priority: priority, deadLine: deadLine);

      manager.addTask(newTask, file);
    }
  }

  static DateTime convertToDate(String dateStr) {
    var re = RegExp(
      r'^'
      r'(?<day>[0-9]{1,2})'
      r'(?<month>[0-9]{1,2})'
      r'(?<year>[0-9]{4,})'
      r'$',
    );

    var match = re.firstMatch(dateStr);
    if (match == null) {
      throw FormatException(
        'Format de la date non reconnu. Suivre ce format: jj/mm/aa',
      );
    }
    var dateTime = DateTime(
      int.parse(match.namedGroup('year')!),
      int.parse(match.namedGroup('month')!),
      int.parse(match.namedGroup('day')!),
    );
    return dateTime;
  }
}

void main() async {
  File file = File('tasks.json');
  if (file.exists() == false) {
    file = new File('./tasks.json');
  }
  /* on doit matcher avec les priority string. "1" --> "low" et print Basse a l'utilisateur */

  if (await file.exists()) {
    try {
      Menu.menu(file);
    } catch (e) {
      print('Erreur: $e');
    }
  }
}
