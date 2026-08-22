import 'package:tera/features/storage/domain/entities/storage_request.dart';

class StorageRequestModel {
  const StorageRequestModel({
    required this.id,
    required this.productId,
    this.destinationWarehouseId,
    this.sourceWarehouseId,
    required this.quantity,
    required this.status,
    required this.type,
    this.startDate,
    this.endDate,
    this.billingAmount,
    required this.createdAt,
    this.delegatedSale = false,
  });

  final String id;
  final String productId;
  final String? destinationWarehouseId;
  final String? sourceWarehouseId;
  final double quantity;
  final String status;
  final String type;
  final String? startDate;
  final String? endDate;
  final double? billingAmount;
  final String createdAt;
  final bool delegatedSale;

  factory StorageRequestModel.fromJson(Map<String, dynamic> json) =>
      StorageRequestModel(
        id: json['id'] as String,
        productId: json['productId'] as String,
        destinationWarehouseId: json['destinationWarehouseId'] as String?,
        sourceWarehouseId: json['sourceWarehouseId'] as String?,
        quantity: (json['quantity'] as num).toDouble(),
        status: json['status'] as String? ?? 'PENDING',
        type: json['type'] as String? ?? 'INBOUND',
        startDate: json['startDate'] as String?,
        endDate: json['endDate'] as String?,
        billingAmount: (json['billingAmount'] as num?)?.toDouble(),
        createdAt: json['createdAt'] as String,
        delegatedSale: json['delegatedSale'] as bool? ?? false,
      );

  StorageRequest toEntity() => StorageRequest(
        id: id,
        productId: productId,
        destinationWarehouseId: destinationWarehouseId,
        sourceWarehouseId: sourceWarehouseId,
        quantity: quantity,
        status: StorageRequestStatus.fromString(status),
        type: type,
        startDate: startDate != null ? DateTime.tryParse(startDate!) : null,
        endDate: endDate != null ? DateTime.tryParse(endDate!) : null,
        billingAmount: billingAmount,
        createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
        delegatedSale: delegatedSale,
      );
}
