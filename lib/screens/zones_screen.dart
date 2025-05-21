import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/storage.dart';
import '../models/zone.dart';
import 'items_screen.dart';
import '../widgets/background_wrapper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        title: Text(zone == null
            ? AppLocalizations.of(context)!.addZone
            : AppLocalizations.of(context)!.editZone),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.zoneName,
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
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _deleteZone(Zone zone) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteZone),
        content: Text(AppLocalizations.of(context)!.zoneDeleteWarning),
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
      await zone.delete();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final zones = _zoneBox.values
        .where((z) => z.storageId == widget.storage.id)
        .toList();

    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
		  backgroundColor: Colors.black87,
		  foregroundColor: Colors.white,
          title: Text('${AppLocalizations.of(context)!.zones}: ${widget.storage.name}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: zones.isEmpty
            ? Center(
                child: Text(
                  AppLocalizations.of(context)!.noZones,
                  style: const TextStyle(color: Colors.white70),
                ),
              )
            : ListView.builder(
                itemCount: zones.length,
                itemBuilder: (_, index) {
                  final zone = zones[index];
                  return Card(
                    color: Colors.black54,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: ListTile(
                      title: Text(
                        zone.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${AppLocalizations.of(context)!.created}: ${zone.createdAt.toString().split(".")[0]}',
                        style: const TextStyle(color: Colors.white70),
                      ),
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
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _addOrEditZone(zone: zone),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteZone(zone),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addOrEditZone(),
          child: const Text('+'),
        ),
      ),
    );
  }
}
