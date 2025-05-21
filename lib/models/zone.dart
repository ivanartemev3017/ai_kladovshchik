import 'package:hive/hive.dart';

part 'zone.g.dart';

@HiveType(typeId: 1)
class Zone extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String storageId;

  @HiveField(3)
  DateTime createdAt;

  Zone({
    required this.id,
    required this.name,
    required this.storageId,
    required this.createdAt,
  });
}
