import '../models/storage.dart';

abstract class StorageRepository {
  Future<List<Storage>> getAll();
  Future<void> add(Storage storage);
  Future<void> delete(Storage storage);
}
