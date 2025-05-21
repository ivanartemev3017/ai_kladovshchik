import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/storage.dart';
import 'zones_screen.dart';
import '../widgets/background_wrapper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
		  backgroundColor: Colors.black87,
		  foregroundColor: Colors.white,
          title: Text(AppLocalizations.of(context)!.goToStorages),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ValueListenableBuilder(
          valueListenable: storageBox.listenable(),
          builder: (context, Box<Storage> box, _) {
            if (box.isEmpty) {
              return const Center(
                child: Text(
                  'Нет складов',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                final storage = box.getAt(index)!;
                return Card(
                  color: Colors.black54,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: ListTile(
                    title: Text(
                      storage.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Создан: ${storage.createdAt.toString().split(".")[0]}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ZonesScreen(storage: storage),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _addOrEditStorage(storage: storage),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteStorage(storage),
                        ),
                      ],
                    ),
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
      ),
    );
  }
}
