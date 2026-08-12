import 'dart:convert';
import 'dart:io';

class JsonStorage {
  final File file;

  JsonStorage(this.file);

  Future<List<Map<String, dynamic>>> readJsonList() async {
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('[]');
    }

    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      return [];
    }

    final decoded = jsonDecode(content) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> writeJsonList(List<Map<String, dynamic>> list) async {
    final encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(list));
  }
}
