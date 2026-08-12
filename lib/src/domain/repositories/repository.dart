abstract class Repository<T> {
  Future<void> addTask(T newTask);
  Future<List<T>> listAll(String sortBy);
  Future<void> deleteTask(int id);
  Future<String> markAsDone(int id);
}
