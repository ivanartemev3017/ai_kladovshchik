import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 2)
class Item extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  String zoneId;

  @HiveField(4)
  DateTime addedAt;

  @HiveField(5)
  double? cost; // 💰 новое поле (необязательное)

  @HiveField(6)
  String? imagePath;

  Item({
    required this.id,
    required this.name,
    required this.quantity,
    required this.zoneId,
    required this.addedAt,
    this.cost,
    this.imagePath,
  });
}
