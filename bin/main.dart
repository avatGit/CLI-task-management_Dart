import 'dart:io';

import 'package:cli_task_management_app/cli_task_manager.dart';

Future<void> main() async {
  final file = File('tasks.json');

  if (!await file.exists()) {
    await file.create(recursive: true);
    await file.writeAsString('[]');
  }

  final runner = CliRunner(file: file);
  await runner.run();
}
