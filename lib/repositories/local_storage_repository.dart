import 'package:hive_flutter/hive_flutter.dart';
import '../models/storage.dart';
import 'storage_repository.dart';

class LocalStorageRepository implements StorageRepository {
  final Box<Storage> _box = Hive.box<Storage>('storages');

  @override
  Future<List<Storage>> getAll() async {
    return _box.values.toList();
  }

  @override
  Future<void> add(Storage storage) async {
    await _box.add(storage);
  }

  @override
  Future<void> delete(Storage storage) async {
    await storage.delete();
  }
}
