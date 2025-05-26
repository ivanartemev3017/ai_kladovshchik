import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/storage.dart';
import 'models/zone.dart';
import 'models/item.dart';
import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('⚠️ Firebase уже инициализирован: $e');
  }

  await Hive.initFlutter();
  Hive.registerAdapter(StorageAdapter());
  Hive.registerAdapter(ZoneAdapter());
  Hive.registerAdapter(ItemAdapter());

  await Hive.openBox<Storage>('storages');
  await Hive.openBox<Zone>('zones');
  await Hive.openBox<Item>('items');

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const App(),
    ),
  );
}
