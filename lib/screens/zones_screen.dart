
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/storage.dart';
import '../models/zone.dart';
import 'items_screen.dart';

class ZonesScreen extends StatefulWidget {
  final Storage storage;
  const ZonesScreen({Key? key, required this.storage}) : super(key: key);

  @override
  State<ZonesScreen> createState() => _ZonesScreenState();
}

class _ZonesScreenState extends State<ZonesScreen> {
  late Box<Zone> _zoneBox;

  @override
  void initState() {
    super.initState();
    _zoneBox = Hive.box<Zone>('zones');
  }

  void _addOrEditZone({Zone? zone}) {
    final nameController = TextEditingController(text: zone?.name ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(zone == null ? 'Добавить зону' : 'Редактировать зону'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Название зоны'),
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

              if (zone == null) {
                final newZone = Zone(
                  id: UniqueKey().toString(),
                  name: name,
                  createdAt: DateTime.now(),
                  storageId: widget.storage.id,
                );
                _zoneBox.add(newZone);
              } else {
                zone.name = name;
                zone.save();
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

  void _deleteZone(Zone zone) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить зону?'),
        content: const Text('Все предметы в зоне тоже будут удалены.'),
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
      await zone.delete();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final zones = _zoneBox.values
        .where((z) => z.storageId == widget.storage.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Зоны: ${widget.storage.name}'),
        leading: IconButton(
          icon: const Text('<'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: zones.isEmpty
          ? const Center(child: Text('Нет зон'))
          : ListView.builder(
              itemCount: zones.length,
              itemBuilder: (_, index) {
                final zone = zones[index];
                return ListTile(
                  title: Text(zone.name),
                  subtitle:
                      Text('Создана: ${zone.createdAt.toIso8601String()}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemsScreen(zone: zone),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => _addOrEditZone(zone: zone),
                        child: const Text('✏'),
                      ),
                      TextButton(
                        onPressed: () => _deleteZone(zone),
                        child: const Text('❌'),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditZone(),
        child: const Text('+'),
      ),
    );
  }
}
