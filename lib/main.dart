import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/storage.dart';
import 'models/zone.dart';
import 'models/item.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(StorageAdapter());
  Hive.registerAdapter(ZoneAdapter());
  Hive.registerAdapter(ItemAdapter());

  await Hive.openBox<Storage>('storages');
  await Hive.openBox<Zone>('zones');
  await Hive.openBox<Item>('items');

  runApp(const App()); // 👈 именно сюда перенесём MaterialApp
}
