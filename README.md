# Application CLI de gestion de tâches

Une application Dart en ligne de commande pour gérer des tâches avec persistance locale au format JSON.

## Fonctionnalités

- Ajouter une tâche avec un titre, une priorité et un délai optionnel
- Lister les tâches triées par date de création ou par priorité
- Marquer une tâche comme terminée
- Supprimer une tâche
- Persister les tâches dans `tasks.json`

## Architecture

- `main.dart` contient le menu CLI et l’interaction utilisateur
- `models/` contient les modèles métier et les exceptions personnalisées
- `repositories/` contient l’implémentation du gestionnaire de tâches
- `interfaces/` contient l’interface explicite du dépôt de tâches
- `test/` contient les tests unitaires

## Démarrage

```bash
cd "c:\Users\s\Documents\CLI task management app"
dart pub get
dart run main.dart
```

## Exécution des tests

```bash
dart test
```
