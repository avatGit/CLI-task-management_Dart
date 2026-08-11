import 'dart:io';

abstract class Repository<T> {
  Future<void> addTask(T newTask, File file);
  Future<List<T>> listAll(String sortBy, File file);
  Future<void> deleteTask(int id, File file);
  Future<String> markAsDone(int id, File file);
}
