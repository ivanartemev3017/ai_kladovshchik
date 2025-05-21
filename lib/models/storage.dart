import 'package:hive/hive.dart';

part 'storage.g.dart';

@HiveType(typeId: 0)
class Storage extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  Storage({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}
