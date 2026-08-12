# Application CLI de gestion de tâches

Une application Dart en ligne de commande pour gérer des tâches simples avec persistance locale au format JSON.

## Objectif du projet

Ce projet propose une structure CLI légère pour :
- créer des tâches avec un titre, une priorité et un délai optionnel,
- marquer des tâches comme terminées,
- lister et trier les tâches par date de création ou priorité,
- supprimer des tâches,
- stocker les tâches dans un fichier `tasks.json` local.

## Fonctionnalités

- Ajout de tâche avec titre, priorité (`Haute`, `Moyenne`, `Basse`) et délai optionnel.
- Liste des tâches triées par date ou par priorité.
- Marquage d’une tâche comme terminée.
- Suppression d’une tâche par ID.
- Stockage JSON dans `tasks.json`.
- Tests unitaires couvrant le modèle et la couche de stockage.

## Architecture du projet

- `bin/main.dart` : point d’entrée CLI.
- `lib/cli_task_manager.dart` : export public du package.
- `lib/src/presentation/cli_runner.dart` : logique de l’interface utilisateur.
- `lib/src/data/datasources/json_storage.dart` : lecture/écriture d’un tableau JSON.
- `lib/src/data/repositories/json_task_repository.dart` : gestion des tâches avec persistence.
- `lib/src/domain/models/task.dart` : modèle de base `Task`.
- `lib/src/domain/models/standard_task.dart` : tâche standard.
- `lib/src/domain/models/urgent_task.dart` : tâche urgente.
- `lib/src/core/exceptions/task_exceptions.dart` : exceptions métiers.
- `test/` : tests unitaires du dépôt et du modèle.

## Installation

```powershell
cd "c:\Users\s\Documents\CLI task management app"
dart pub get
```

## Exécution

```powershell
dart run bin/main.dart
```

Le programme crée automatiquement `tasks.json` si le fichier n’existe pas.

## Tests

```powershell
dart test
```

## Analyse statique

```powershell
dart analyze
```

## Notes

- Le projet utilise une architecture modulaire avec `bin/`, `lib/src/` et `test/`.
- Les anciens fichiers de structure plate ont été supprimés pour clarifier l’architecture.
