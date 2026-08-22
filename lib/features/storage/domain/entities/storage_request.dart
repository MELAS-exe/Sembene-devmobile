import 'package:equatable/equatable.dart';

enum StorageRequestStatus {
  pending,
  approved,
  rejected,
  completed;

  static StorageRequestStatus fromString(String s) =>
      switch (s.toUpperCase()) {
        'APPROVED' => approved,
        'REJECTED' => rejected,
        'COMPLETED' => completed,
        _ => pending,
      };
}

class StorageRequest extends Equatable {
  const StorageRequest({
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
  final StorageRequestStatus status;
  final String type;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? billingAmount;
  final DateTime createdAt;
  final bool delegatedSale;

  bool get isActive =>
      status == StorageRequestStatus.pending ||
      status == StorageRequestStatus.approved;

  @override
  List<Object?> get props => [id];
}
