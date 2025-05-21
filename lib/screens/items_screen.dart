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
    final quantityController = TextEditingController(text: item != null ? item.quantity.toString() : '');
    final costController = TextEditingController(text: item?.cost?.toString() ?? '');
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
        backgroundColor: Colors.grey[900],
        title: Text(item == null ? 'Добавить вещь' : 'Редактировать вещь',
            style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDarkInputField(nameController, 'Название'),
              const SizedBox(height: 8),
              _buildDarkInputField(quantityController, 'Количество', isNumber: true),
              const SizedBox(height: 8),
              _buildDarkInputField(costController, 'Стоимость (необязательно)', isNumber: true),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: pickImage,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
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
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
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
    final items = _itemsBox.values.where((i) => i.zoneId == widget.zone.id).toList();
    final totalItems = items.length;
    final totalQuantity = items.fold<int>(0, (sum, item) => sum + item.quantity);
    final totalCost = items.fold<double>(0, (sum, item) {
      if (item.cost != null) {
        return sum + (item.cost! * item.quantity);
      }
      return sum;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Статистика зоны', style: TextStyle(color: Colors.white)),
        content: Text(
          'Всего разных вещей: $totalItems\n'
          'Суммарное количество: $totalQuantity\n'
          'Суммарная стоимость: ${totalCost.toStringAsFixed(2)}₸',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть', style: TextStyle(color: Colors.tealAccent)),
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
        backgroundColor: Colors.black87,
		foregroundColor: Colors.white,
        title: Text('Вещи в зоне: ${widget.zone.name}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black54,
                  hintText: 'Поиск по названию...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
			Padding(
			  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
			  child: Container(
				padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
				decoration: BoxDecoration(
				  color: Colors.black45, // 👈 фон под текст и выпадашку
				  borderRadius: BorderRadius.circular(8),
				),
				child: Row(
				  children: [
					const Text(
					  'Сортировка: ',
					  style: TextStyle(
						color: Colors.white,
						fontWeight: FontWeight.w500,
					  ),
					),
					DropdownButton<String>(
					  value: _sortOption,
					  dropdownColor: Colors.grey[900],
					  iconEnabledColor: Colors.white,
					  style: const TextStyle(color: Colors.white),
					  underline: const SizedBox(), // убрать подчёркивание
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
			),

            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('Нет вещей', style: TextStyle(color: Colors.white70)))
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
                        return Card(
                          color: Colors.black45,
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: ListTile(
                            leading: item.imagePath != null
                                ? Image.file(
                                    File(item.imagePath!),
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.inventory, color: Colors.white),
                            title: Text(item.name, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(subtitleText.toString(),
                                style: const TextStyle(color: Colors.white70)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () => _showItemDialog(item: item),
                                  child: const Text('✏', style: TextStyle(color: Colors.orange)),
                                ),
                                TextButton(
                                  onPressed: () => _deleteItem(item),
                                  child: const Text('❌', style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDarkInputField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.black38,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
