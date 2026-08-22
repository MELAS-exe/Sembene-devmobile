import 'package:tera/features/storage/domain/entities/warehouse.dart';

class WarehouseModel {
  const WarehouseModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.usedCapacity,
    this.city = '',
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) => WarehouseModel(
        id: json['warehouseId'] as String,
        name: json['name'] as String,
        capacity: (json['capacity'] as num?)?.toDouble() ?? 0,
        usedCapacity: (json['usedCapacity'] as num?)?.toDouble() ?? 0,
        city: json['city'] as String? ?? '',
      );

  final String id;
  final String name;
  final double capacity;
  final double usedCapacity;
  final String city;

  Warehouse toEntity() => Warehouse(
        id: id,
        name: name,
        capacity: capacity,
        usedCapacity: usedCapacity,
        city: city,
      );
}
