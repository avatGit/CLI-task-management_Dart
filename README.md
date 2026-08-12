# CLI Task Management App

A simple Dart CLI application for managing tasks with local JSON persistence.

## Features

- Add task with title, priority, and optional deadline
- List tasks sorted by creation date or priority
- Mark task as done
- Delete task
- Persist tasks to `tasks.json`

## Architecture

- `main.dart` contains the CLI menu and user interaction
- `models/` contains domain models and custom exceptions
- `repositories/` contains the task repository implementation
- `interfaces/` contains the explicit task repository interface
- `test/` contains unit tests

## Getting Started

```bash
cd "c:\Users\s\Documents\CLI task management app"
dart pub get
dart run main.dart
```

## Running Tests

```bash
dart test
```
