// lib/screens/storage_list_screen.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/storage.dart';
import 'zones_screen.dart';

class StorageListScreen extends StatefulWidget {
  const StorageListScreen({super.key});

  @override
  State<StorageListScreen> createState() => _StorageListScreenState();
}

class _StorageListScreenState extends State<StorageListScreen> {
  final storageBox = Hive.box<Storage>('storages');

  void _addOrEditStorage({Storage? storage}) {
    final nameController = TextEditingController(text: storage?.name ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(storage == null ? 'Добавить склад' : 'Редактировать склад'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Название склада'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              if (storage != null) {
                storage.name = name;
                storage.save();
              } else {
                final newStorage = Storage(
                  id: UniqueKey().toString(),
                  name: name,
                  createdAt: DateTime.now(),
                );
                storageBox.add(newStorage);
              }

              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _deleteStorage(Storage storage) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить склад?'),
        content: const Text('Все зоны и вещи внутри будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await storage.delete();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои склады'),
        leading: IconButton(
          icon: const Text('<'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: storageBox.listenable(),
        builder: (context, Box<Storage> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('Нет складов'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final storage = box.getAt(index)!;
              return ListTile(
                title: Text(storage.name),
                subtitle: Text('Создан: ${storage.createdAt}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ZonesScreen(storage: storage)),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => _addOrEditStorage(storage: storage),
                      child: const Text('✏'),
                    ),
                    TextButton(
                      onPressed: () => _deleteStorage(storage),
                      child: const Text('❌'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditStorage(),
        child: const Text('+'),
      ),
    );
  }
}
