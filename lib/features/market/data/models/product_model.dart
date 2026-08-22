import 'package:tera/features/market/domain/entities/product.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    required this.price,
    required this.dailyRate,
    required this.perKgRate,
    this.tags = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        unit: json['unit'] as String? ?? 'kg',
        price: (json['price'] as num).toDouble(),
        dailyRate: (json['dailyRate'] as num?)?.toDouble() ?? 0,
        perKgRate: (json['perKgRate'] as num?)?.toDouble() ?? 0,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  final String id;
  final String name;
  final String description;
  final String unit;
  final double price;
  final double dailyRate;
  final double perKgRate;
  final List<String> tags;

  Product toEntity() => Product(
        id: id,
        name: name,
        description: description,
        unit: unit,
        price: price,
        dailyRate: dailyRate,
        perKgRate: perKgRate,
        tags: tags,
      );
}
