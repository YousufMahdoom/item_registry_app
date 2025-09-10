import 'package:hive/hive.dart';

part 'item.g.dart'; // generated file

@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String sku;

  @HiveField(3)
  String category;

  @HiveField(4)
  String unit;

  @HiveField(5)
  double basePrice;

  @HiveField(6)
  double? retailPrice;

  @HiveField(7)
  String? supplier;

  @HiveField(8)
  DateTime? expiryDate;

  Item({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.unit,
    required this.basePrice,
    this.retailPrice,
    this.supplier,
    this.expiryDate,
  });
}
