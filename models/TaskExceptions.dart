class TaskAlreadyExistsException implements Exception {
  final String taskTitle;

  TaskAlreadyExistsException({required this.taskTitle});

  @override
  String toString() =>
      'La tâche "$taskTitle" existe déjà. Veuillez choisir un autre titre.';
}

class InvalidPriorityException implements Exception {
  final String taskTitle;

  InvalidPriorityException({required this.taskTitle});

  @override
  String toString() =>
      'La tâche "$taskTitle" a une priorité invalide. Veuillez choisir une priorité valide: 1, 2 ou 3.';
}

class InvalidDateFormatException implements Exception {
  @override
  String toString() =>
      'La tâche a un format de date invalide. Veuillez utiliser le format jj/mm/aa.';
}
