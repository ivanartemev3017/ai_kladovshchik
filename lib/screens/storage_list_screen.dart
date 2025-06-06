import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/storage.dart';
import 'zones_screen.dart';
import '../widgets/background_wrapper.dart';
import 'package:ai_kladovshchik/l10n/app_localizations.dart';

class StorageListScreen extends StatefulWidget {
  const StorageListScreen({super.key});

  @override
  State<StorageListScreen> createState() => _StorageListScreenState();
}

class _StorageListScreenState extends State<StorageListScreen> {
  final storageBox = Hive.box<Storage>('storages');
  List<Storage> storages = [];

  void _addOrEditStorage({Storage? storage}) {
    final nameController = TextEditingController(text: storage?.name ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          storage == null
              ? AppLocalizations.of(context)!.addStorage
              : AppLocalizations.of(context)!.editStorage,
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.storageName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
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
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _deleteStorage(Storage storage) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteStorageTitle),
        content: Text(AppLocalizations.of(context)!.deleteStorageMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.delete),
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
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.noStorages,
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }
			storages = box.values.toList();
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
                      '${AppLocalizations.of(context)!.createdAt}: ${storage.createdAt.toString().split(".")[0]}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ZonesScreen(storage: storage, storages: storages,),
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
