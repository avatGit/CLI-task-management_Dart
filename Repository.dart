import 'dart:io';

abstract class Repository<T> {
  Future<void> addTask(T newTask, File file);
  //List<T> listAll(String sortBy, File file);
  //String delete(Object task, File file);
  //String markAsDone(Object task, File file);
}
