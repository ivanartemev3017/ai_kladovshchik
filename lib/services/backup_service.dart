import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/storage.dart';
import '../models/zone.dart';
import '../models/item.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> uploadFileToFirebaseStorage(File file, String userId, String itemId) async {
  try {
    final ref = FirebaseStorage.instance
        .ref()
        .child('backups')
        .child(userId)
        .child('images')
        .child('$itemId.jpg');
    final uploadTask = await ref.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print('Ошибка загрузки файла $file: $e');
    return null;
  }
}


class BackupService {
  Future<bool> _isUserPremium() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final plan = doc.data()?['plan'] ?? 'free';
    return plan == 'premium';
  }
  
  Future<bool> restoreBackupFromFirebase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final listRef = FirebaseStorage.instance.ref().child('backups/$uid');
    final result = await listRef.listAll();

    if (result.items.isEmpty) return false;

    // Используем самый последний файл по алфавитному порядку (он соответствует времени)
    final latestFile = result.items.last;
    return await restoreBackupFromFile(latestFile.name);
  }

  Future<bool> exportAndUploadBackup() async {
    if (!await _isUserPremium()) return false;

    final storagesBox = Hive.box<Storage>('storages');
    final zonesBox = Hive.box<Zone>('zones');
    final itemsBox = Hive.box<Item>('items');

    final List<Item> itemsWithUrls = [];

    for (final item in itemsBox.values) {
      final newItem = Item(
        id: item.id,
        zoneId: item.zoneId,
        name: item.name,
        quantity: item.quantity,
        cost: item.cost,
        addedAt: item.addedAt,
        imagePath: item.imagePath,
      );

    // 🧹 Очищаем ID от символов [], # и пробелов
      final cleanedId = newItem.id.replaceAll(RegExp(r'[\[\]#\s]'), '');

      if (newItem.imagePath != null) {
        final file = File(newItem.imagePath!);
        if (await file.exists()) {
          final ref = FirebaseStorage.instance.ref().child('images/$cleanedId.jpg');
          await ref.putFile(file);
          final url = await ref.getDownloadURL();
          newItem.imageUrl = url;
        }
      }

      itemsWithUrls.add(newItem);
    }

    final data = {
      'storages': storagesBox.values.map((s) => s.toJson()).toList(),
      'zones': zonesBox.values.map((z) => z.toJson()).toList(),
      'items': itemsWithUrls.map((i) => i.toJson()).toList(),
    };

    final jsonString = jsonEncode(data);
    final bytes = Uint8List.fromList(utf8.encode(jsonString));

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final now = DateTime.now();
    final formatted = DateFormat('yyyy-MM-dd_HH-mm').format(now);
    final ref = FirebaseStorage.instance.ref().child('backups/$uid/$formatted.json');

    await ref.putData(bytes, SettableMetadata(contentType: 'application/json'));
    return true;
  }

/// ♻️ Восстановление по имени файла
  Future<bool> restoreBackupFromFile(String filename) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final ref = FirebaseStorage.instance.ref().child('backups/$uid/$filename');

    try {
      final data = await ref.getData();
      if (data == null) return false;

      final jsonMap = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;

      final storagesBox = Hive.box<Storage>('storages');
      final zonesBox = Hive.box<Zone>('zones');
      final itemsBox = Hive.box<Item>('items');

      await storagesBox.clear();
      await zonesBox.clear();
      await itemsBox.clear();

      final storages = (jsonMap['storages'] as List)
          .map((e) => Storage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final zones = (jsonMap['zones'] as List)
          .map((e) => Zone.fromJson(Map<String, dynamic>.from(e)))
          .toList();
	  final items = <Item>[];

	  final appDir = await getApplicationDocumentsDirectory();

	  for (final e in jsonMap['items'] as List) {
	    final map = Map<String, dynamic>.from(e);
	    final item = Item.fromJson(map);

		final imageUrl = map['imageUrl'];
		if (imageUrl != null && imageUrl is String && imageUrl.isNotEmpty) {
		  try {
		    final fileName = '${item.id}.jpg';
		    final imageRef = FirebaseStorage.instance.ref().child('images/$fileName');
		    final bytes = await imageRef.getData();

		    if (bytes != null) {
			  final cleanedId = item.id.replaceAll(RegExp(r'[\[\]#\s]'), '');
			  final fileName = 'restored_$cleanedId.jpg';
			  final file = File('${appDir.path}/$fileName');
			  await file.writeAsBytes(bytes);
			  item.imagePath = file.path;
		    } else {
			  print('⚠️ Файл изображения не найден для item ${item.id}');
		    }
		  } on FirebaseException catch (e) {
		    if (e.code == 'object-not-found') {
			  print('⚠️ [Not found] FirebaseStorage: файл отсутствует для item ${item.id}');
		    } else {
			  print('⚠️ Firebase ошибка для item ${item.id}: ${e.message}');
		    }
		  } catch (e) {
		    print('⚠️ Ошибка при загрузке изображения для item ${item.id}: $e');
		}
		}

	    items.add(item);
	  }

      for (final s in storages) {
        await storagesBox.put(s.id, s);
      }
      for (final z in zones) {
        await zonesBox.put(z.id, z);
      }
      for (final i in items) {
        await itemsBox.put(i.id, i);
      }

      return true;
    } catch (e) {
      print('❌ Restore failed: $e');
      return false;
    }
  }
}

