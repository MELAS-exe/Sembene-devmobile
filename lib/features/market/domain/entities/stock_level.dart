import 'package:equatable/equatable.dart';

class StockLevel extends Equatable {
  const StockLevel({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.quantity,
    this.ownerId,
    this.delegatedSale = false,
  });

  final String id;
  final String productId;
  final String warehouseId;
  final double quantity;
  final String? ownerId;
  final bool delegatedSale;

  @override
  List<Object?> get props => [id];
}
