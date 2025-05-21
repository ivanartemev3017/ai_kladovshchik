import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/storage.dart';
import 'models/zone.dart';
import 'models/item.dart'; // 👈 добавили
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Hive
  await Hive.initFlutter();

  // Регистрация всех адаптеров
  Hive.registerAdapter(StorageAdapter());
  Hive.registerAdapter(ZoneAdapter());
  Hive.registerAdapter(ItemAdapter()); // 👈 новый адаптер

  // Открытие всех коробок (хранилищ)
  await Hive.openBox<Storage>('storages');
  await Hive.openBox<Zone>('zones');
  await Hive.openBox<Item>('items'); // 👈 новая коробка

  // Запуск приложения
  runApp(const App());
}
