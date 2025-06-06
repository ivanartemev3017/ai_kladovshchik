import 'package:flutter/material.dart';
import 'package:ai_kladovshchik/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/item.dart';
import '../models/zone.dart';
import 'package:path/path.dart' as path;
import 'full_image_screen.dart';
import '../services/export_service.dart';
import '../models/storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Widget buildLocalImage(String? path, {double width = 48, double height = 48}) {
  if (path == null) {
    return Icon(Icons.image_not_supported, size: width);
  }

  final file = File(path);
  return FutureBuilder<bool>(
    future: file.exists(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done && snapshot.data == true) {
        return Image.file(file, width: width, height: height, fit: BoxFit.cover);
      } else {
        return Icon(Icons.image_not_supported, size: width);
      }
    },
  );
}
Widget buildImageWithFirebaseFallback(String? localPath, String firebasePath, {double width = 48, double height = 48}) {
  if (localPath != null && File(localPath).existsSync()) {
    return Image.file(File(localPath), width: width, height: height, fit: BoxFit.cover);
  } else {
    return FutureBuilder<String>(
      future: FirebaseStorage.instance.ref(firebasePath).getDownloadURL(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(width: width, height: height, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Icon(Icons.image_not_supported, size: width);
        } else {
          return Image.network(snapshot.data!, width: width, height: height, fit: BoxFit.cover);
        }
      },
    );
  }
}

class ItemsScreen extends StatefulWidget {
  final Zone zone;
  final List<Zone> zones;
  final List<Storage> storages;

  const ItemsScreen({
    super.key,
    required this.zone,
    required this.zones,
    required this.storages,
  });


  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final _itemsBox = Hive.box<Item>('items');
  String? userPlan;
  bool planLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String _sortOption = 'date_desc';
  String? _imagePath;
  List<Zone> get zones => widget.zones;
  List<Storage> get storages => widget.storages;


  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });

    _loadUserPlan(); // ✅ Загружаем план пользователя при инициализации
  }
  
  Future<void> _loadUserPlan() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null && data.containsKey('plan')) {
        setState(() {
          userPlan = data['plan'];
          planLoading = false;
        });
      } else {
        setState(() {
          userPlan = 'free';
          planLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userPlan = 'free';
        planLoading = false;
      });
    }
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
    _imagePath = item?.imagePath;
	
	void showImageSourceDialog() {
      showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          AppLocalizations.of(context)!.choosePhoto,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              pickImage(false); // 📁 Галерея
            },
            child: Text('📁 ${AppLocalizations.of(context)!.gallery}',
                style: const TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              pickImage(true); // 📷 Камера
            },
            child: Text('📷 ${AppLocalizations.of(context)!.camera}',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          item == null
              ? AppLocalizations.of(context)!.addItem
              : AppLocalizations.of(context)!.editItem,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDarkInputField(
                  nameController, AppLocalizations.of(context)!.itemName),
              const SizedBox(height: 8),
              _buildDarkInputField(quantityController,
                  AppLocalizations.of(context)!.itemQuantity,
                  isNumber: true),
              const SizedBox(height: 8),
              _buildDarkInputField(
                  costController, AppLocalizations.of(context)!.itemCost,
                  isNumber: true),
              const SizedBox(height: 12),
			  Row(
			    children: [
				  Expanded(
				    child: ElevatedButton(
					  onPressed: () => pickImage(false),
					  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
					  child: Text(AppLocalizations.of(context)!.choosePhoto),
				    ),
				  ),
				  const SizedBox(width: 8),
				  Expanded(
				    child: ElevatedButton(
					  onPressed: () => pickImage(true),
					  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
					  child: Text(AppLocalizations.of(context)!.takePhoto),
				    ),
				  ),
			    ],
			  ),

			  if (_imagePath != null)
			    GestureDetector(
				  onTap: () {
				    Navigator.push(
					  context,
					  MaterialPageRoute(
					    builder: (_) => FullImageScreen(imagePath: _imagePath!),
					  ),
				    );
				  },
				  child: Padding(
				    padding: const EdgeInsets.only(top: 8.0),
				    child: SizedBox(
					  height: 100,
					  child: buildLocalImage(_imagePath, height: 100),
				    ),
				  ),
			    ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel,
                style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final quantity =
                  int.tryParse(quantityController.text.trim()) ?? 1;
              final cost = double.tryParse(costController.text.trim());
              if (item != null) {
                _editItem(item, name, quantity, cost, _imagePath);
              } else {
                _addItem(name, quantity, cost, _imagePath);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  Future<void> pickImage(bool fromCamera) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedFile != null) {
      final savedPath = await saveImagePermanently(pickedFile);
      if (savedPath != null) {
        setState(() {
          // Это будет работать, если imagePath объявлен в showItemDialog
          // мы его пробросим через замыкание
          _imagePath = savedPath;
        });
      }
    }
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

    final totalCostString = totalCost.toStringAsFixed(2);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(AppLocalizations.of(context)!.zoneStatsTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(
          AppLocalizations.of(context)!.zoneStatsBody(
            totalItems,
            totalQuantity,
            totalCostString,
          ),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close,
                style: const TextStyle(color: Colors.tealAccent)),
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
	    title: Text('${AppLocalizations.of(context)!.itemsInZone}: ${widget.zone.name}'),
	    leading: IconButton(
		  icon: const Icon(Icons.arrow_back, color: Colors.white),
		  onPressed: () => Navigator.pop(context),
	    ),
	    actions: [
		  if (!planLoading && userPlan == 'premium')
		    IconButton(
			  icon: const Icon(Icons.download, color: Colors.white),
			  tooltip: AppLocalizations.of(context)!.exportToExcel,
			  onPressed: () async {
			    final path = await ExportService.exportItemsToExcel(
				  items,
				  zones,
				  storages,
			    );
			    if (!mounted) return;
			    ScaffoldMessenger.of(context).showSnackBar(
				  SnackBar(
				    content: Text(path != null
					    ? 'Файл сохранён: $path'
					    : 'Нет доступа к хранилищу'),
				  ),
			    );
			  },
		    ),

		  PopupMenuButton<String>(
		    icon: const Icon(Icons.more_vert, color: Colors.white),
		    onSelected: (value) {
			  if (value == 'stats') {
			    _showZoneStats();
			  }
		    },
		    itemBuilder: (context) => [
			  PopupMenuItem(
			    value: 'stats',
			    child: Text(AppLocalizations.of(context)!.stats),
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
                  hintText: AppLocalizations.of(context)!.searchByName,
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
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.sortBy} ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _sortOption,
                      dropdownColor: Colors.grey[900],
                      iconEnabledColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      underline: const SizedBox(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _sortOption = value;
                          });
                        }
                      },
                      items: [
                        DropdownMenuItem(
                            value: 'date_desc',
                            child: Text(AppLocalizations.of(context)!.newestFirst)),
                        DropdownMenuItem(
                            value: 'date_asc',
                            child: Text(AppLocalizations.of(context)!.oldestFirst)),
                        DropdownMenuItem(
                            value: 'quantity_asc',
                            child: Text(AppLocalizations.of(context)!.quantityAsc)),
                        DropdownMenuItem(
                            value: 'quantity_desc',
                            child: Text(AppLocalizations.of(context)!.quantityDesc)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(AppLocalizations.of(context)!.noItems,
                          style: const TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final subtitleText = StringBuffer()
                          ..write('${AppLocalizations.of(context)!.quantity}: ${item.quantity}')
                          ..write(item.cost != null
                              ? ' — ${AppLocalizations.of(context)!.itemCost}: ${item.cost!.toStringAsFixed(2)}₸'
                              : '')
                          ..write(' — ${AppLocalizations.of(context)!.added}: ${item.addedAt.toString().split(".")[0]}');
                        return Card(
                          color: Colors.black45,
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: ListTile(
							leading: item.imagePath != null
							  ? GestureDetector(
								  onTap: () {
									Navigator.push(
									  context,
									  MaterialPageRoute(
										builder: (_) => FullImageScreen(imagePath: item.imagePath!),
									  ),
									);
								  },
								  child: buildImageWithFirebaseFallback(item.imagePath, 'items/${item.id}.jpg'),
								)
							  : const Icon(Icons.inventory, color: Colors.white),
                            title: Text(item.name,
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text(subtitleText.toString(),
                                style: const TextStyle(color: Colors.white70)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
								  icon: const Icon(Icons.edit, color: Colors.orange),
								  onPressed: () => _showItemDialog(item: item),
								),
								IconButton(
								  icon: const Icon(Icons.delete, color: Colors.redAccent),
								  onPressed: () => _deleteItem(item),
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
