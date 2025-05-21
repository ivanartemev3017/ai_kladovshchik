import 'screens/add_storage_screen.dart';
import 'package:flutter/material.dart';  // ← обязательно
import 'screens/home_screen.dart';       // ← путь должен совпадать
import 'screens/storage_list_screen.dart'; // ← путь тоже

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const HomeScreen(),
  '/storages': (context) => const StorageListScreen(),
  '/add-storage': (context) => const AddStorageScreen(),
};
