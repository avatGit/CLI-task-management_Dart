import 'dart:io';

void main() async {
  File file = File('tasks.json');

  stdout.write("Titre de la tache: ");
  String title = stdin.readLineSync() ?? "Tache sans titre";

  stdout.write("""
Priotité de la tache:
1- Basse
2- Moyenne
3- Haute
Choisir une priorité: """);
  String? priorityInput = stdin.readLineSync();

  /* on doit matcher avec les priority string. "1" --> "low" et print Basse a l'utilisateur */

  if (await file.exists()) {
    try {} catch (e) {}
  }
}
