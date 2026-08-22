import 'package:tera/features/market/domain/entities/stock_level.dart';

class StockLevelModel {
  const StockLevelModel({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.quantity,
    this.ownerId,
    this.delegatedSale = false,
  });

  factory StockLevelModel.fromJson(Map<String, dynamic> json) =>
      StockLevelModel(
        id: json['stockLevelId'] as String,
        productId: json['productId'] as String,
        warehouseId: json['warehouseId'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        ownerId: json['ownerId'] as String?,
        delegatedSale: json['delegatedSale'] as bool? ?? false,
      );

  final String id;
  final String productId;
  final String warehouseId;
  final double quantity;
  final String? ownerId;
  final bool delegatedSale;

  StockLevel toEntity() => StockLevel(
        id: id,
        productId: productId,
        warehouseId: warehouseId,
        quantity: quantity,
        ownerId: ownerId,
        delegatedSale: delegatedSale,
      );
}
