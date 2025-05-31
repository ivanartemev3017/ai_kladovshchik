import 'package:hive/hive.dart';

part 'zone.g.dart';

@HiveType(typeId: 1)
class Zone extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String storageId;

  @HiveField(2)
  String name;

  @HiveField(3)
  DateTime createdAt;

  Zone({
    required this.id,
    required this.storageId,
    required this.name,
    required this.createdAt,
  });

  factory Zone.fromJson(Map<String, dynamic> json) => Zone(
        id: json['id'],
        storageId: json['storageId'],
        name: json['name'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'storageId': storageId,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
      };
}
