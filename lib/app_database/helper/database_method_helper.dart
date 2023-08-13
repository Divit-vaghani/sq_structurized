abstract class DBHelperMethod<T> {
  Future<int> insert(T data);
  Future<int> insertAll(List<T> data);
  Future<int> update(T data);
  Future<int> delete({int? data});
  Future<List<T>> query();
}
