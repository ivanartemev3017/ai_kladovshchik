import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/item.dart';
import '../models/zone.dart';

class ItemsScreen extends StatefulWidget {
  final Zone zone;

  const ItemsScreen({super.key, required this.zone});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final _itemsBox = Hive.box<Item>('items');
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String _sortOption = 'date_desc';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<String?> saveImagePermanently(XFile image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${image.name}';
      final savedImage = await File(image.path).copy(path);
      return savedImage.path;
    } catch (e) {
      return null;
    }
  }

  void _addItem(String name, int quantity, double? cost, String? imagePath) {
    final item = Item(
      id: UniqueKey().toString(),
      name: name,
      quantity: quantity,
      zoneId: widget.zone.id,
      addedAt: DateTime.now(),
      cost: cost,
      imagePath: imagePath,
    );
    _itemsBox.add(item);
    setState(() {});
  }

  void _editItem(Item item, String newName, int newQuantity, double? newCost, String? newImagePath) {
    item.name = newName;
    item.quantity = newQuantity;
    item.cost = newCost;
    item.imagePath = newImagePath;
    item.save();
    setState(() {});
  }

  void _deleteItem(Item item) {
    item.delete();
    setState(() {});
  }

  void _showItemDialog({Item? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final quantityController = TextEditingController(
      text: item != null ? item.quantity.toString() : '',
    );
    final costController = TextEditingController(
      text: item?.cost?.toString() ?? '',
    );
    String? imagePath = item?.imagePath;

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final result = await picker.pickImage(source: ImageSource.gallery);
      if (result != null) {
        final savedPath = await saveImagePermanently(result);
        if (savedPath != null) {
          setState(() {
            imagePath = savedPath;
          });
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Добавить вещь' : 'Редактировать вещь'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Количество'),
              ),
              TextField(
                controller: costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Стоимость (необязательно)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: pickImage,
                child: const Text('Выбрать фото'),
              ),
              if (imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    height: 100,
                    child: Image.file(File(imagePath!), fit: BoxFit.cover),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final quantity = int.tryParse(quantityController.text.trim()) ?? 1;
              final cost = double.tryParse(costController.text.trim());
              if (item != null) {
                _editItem(item, name, quantity, cost, imagePath);
              } else {
                _addItem(name, quantity, cost, imagePath);
              }
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  List<Item> _getFilteredAndSortedItems() {
    List<Item> items = _itemsBox.values
        .where((i) => i.zoneId == widget.zone.id)
        .where((i) => i.name.toLowerCase().contains(_searchText))
        .toList();

    switch (_sortOption) {
      case 'date_asc':
        items.sort((a, b) => a.addedAt.compareTo(b.addedAt));
        break;
      case 'quantity_asc':
        items.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'quantity_desc':
        items.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      default:
        items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    }

    return items;
  }

  void _showZoneStats() {
    final items = _itemsBox.values
        .where((i) => i.zoneId == widget.zone.id)
        .toList();

    final totalItems = items.length;
    final totalQuantity =
        items.fold<int>(0, (sum, item) => sum + item.quantity);
    final totalCost = items.fold<double>(0, (sum, item) {
      if (item.cost != null) {
        return sum + (item.cost! * item.quantity);
      }
      return sum;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Статистика зоны'),
        content: Text(
          'Всего разных вещей: $totalItems\n'
          'Суммарное количество: $totalQuantity\n'
          'Суммарная стоимость: ${totalCost.toStringAsFixed(2)}₸',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _getFilteredAndSortedItems();

    return Scaffold(
      appBar: AppBar(
        title: Text('Вещи в зоне: ${widget.zone.name}'),
        leading: IconButton(
          icon: const Text('<'),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'stats') {
                _showZoneStats();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'stats',
                child: Text('Статистика'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Поиск по названию...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Text('Сортировка: '),
                DropdownButton<String>(
                  value: _sortOption,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortOption = value;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'date_desc', child: Text('Новые сверху')),
                    DropdownMenuItem(value: 'date_asc', child: Text('Старые сверху')),
                    DropdownMenuItem(value: 'quantity_asc', child: Text('Количество ↑')),
                    DropdownMenuItem(value: 'quantity_desc', child: Text('Количество ↓')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Нет вещей'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final subtitleText = StringBuffer()
                        ..write('Кол-во: ${item.quantity}')
                        ..write(item.cost != null
                            ? ' — Цена: ${item.cost!.toStringAsFixed(2)}₸'
                            : '')
                        ..write(' — Добавлено: ${item.addedAt.toString().split(".")[0]}');
                      return ListTile(
                        leading: item.imagePath != null
                            ? Image.file(
                                File(item.imagePath!),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.inventory),
                        title: Text(item.name),
                        subtitle: Text(subtitleText.toString()),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => _showItemDialog(item: item),
                              child: const Text('✏'),
                            ),
                            TextButton(
                              onPressed: () => _deleteItem(item),
                              child: const Text('❌'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(),
        child: const Text('+'),
      ),
    );
  }
}