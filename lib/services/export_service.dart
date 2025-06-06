import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/item.dart'; // или откуда ты берешь список предметов
import '../models/zone.dart';
import '../models/storage.dart';

class ExportService {
  static Future<String?> exportItemsToExcel(
      List<Item> items, List<Zone> zones, List<Storage> storages) async {
    final status = await Permission.manageExternalStorage.request();

    if (!status.isGranted) {
      print('Нет доступа к хранилищу');
      return null;
    }

    final excel = Excel.createExcel();
    final sheet = excel['Items'];

    // Заголовок
    sheet.appendRow([
      'Название',
      'Стоимость',
      'Количество',
      'Дата добавления',
      'Зона',
      'Склад'
    ]);

    for (final item in items) {
      final zone = zones.firstWhere(
        (z) => z.id == item.zoneId,
        orElse: () => Zone(
          id: '',
          name: '',
          storageId: '',
          createdAt: DateTime.now(),
        ),
      );

      final storage = storages.firstWhere(
        (s) => s.id == zone.storageId,
        orElse: () => Storage(
          id: '',
          name: '',
          createdAt: DateTime.now(),
        ),
      );

      sheet.appendRow([
        item.name,
        item.cost?.toStringAsFixed(2) ?? '',
        item.quantity.toString(),
        DateFormat('yyyy-MM-dd HH:mm').format(item.addedAt),
        zone.name,
        storage.name,
      ]);
    }

    // Создание директории /storage/emulated/0/Download/
    final downloadsDir = Directory('/storage/emulated/0/Download');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    final fileName =
        'items_export_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.xlsx';
    final filePath = '${downloadsDir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    print('✅ Excel-файл успешно сохранён: $filePath');
    return filePath;
  }
}

