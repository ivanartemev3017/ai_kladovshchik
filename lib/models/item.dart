import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 2)
class Item extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String zoneId;

  @HiveField(2)
  String name;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  double? cost;

  @HiveField(5)
  DateTime addedAt;

  @HiveField(6)
  String? imagePath;
  
  String? imageUrl;

  Item({
    required this.id,
    required this.zoneId,
    required this.name,
    required this.quantity,
    required this.cost,
    required this.addedAt,
    this.imagePath,
	this.imageUrl,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'],
    zoneId: json['zoneId'],
    name: json['name'],
    quantity: (json['quantity'] ?? 0) as int,
    cost: (json['cost'] != null) ? (json['cost'] as num).toDouble() : null,
    addedAt: DateTime.parse(json['addedAt']),
    imagePath: json['imagePath'],
    imageUrl: json['imageUrl'],
  );


  Map<String, dynamic> toJson() => {
        'id': id,
        'zoneId': zoneId,
        'name': name,
        'quantity': quantity,
        'cost': cost,
        'addedAt': addedAt.toIso8601String(),
        'imagePath': imagePath,
		'imageUrl': imageUrl,
      };
}
