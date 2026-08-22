import 'package:equatable/equatable.dart';

class Delivery extends Equatable {
  const Delivery({
    this.driverFirstName,
    this.driverLastName,
    this.driverPhoneNumber,
    this.destinationAddress,
    required this.status,
  });

  final String? driverFirstName;
  final String? driverLastName;
  final String? driverPhoneNumber;
  final String? destinationAddress;
  final String status;

  bool get hasDriver => driverFirstName != null;

  String get driverFullName {
    final parts = [driverFirstName, driverLastName].whereType<String>();
    return parts.isEmpty ? '' : parts.join(' ');
  }

  @override
  List<Object?> get props => [driverFirstName, driverLastName, status];
}

enum OrderStatus {
  pending,
  created,
  confirmed,
  shipping,
  shipped,
  delivered,
  cancelled;

  static OrderStatus fromString(String s) => switch (s.toUpperCase()) {
        'CREATED' => created,
        'CONFIRMED' => confirmed,
        'SHIPPING' => shipping,
        'SHIPPED' => shipped,
        'DELIVERED' => delivered,
        'CANCELLED' => cancelled,
        _ => pending,
      };

  String toApiString() => name.toUpperCase();
}

class OrderItem extends Equatable {
  const OrderItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final double quantity;
  final double unitPrice;

  double get lineTotal => quantity * unitPrice;

  @override
  List<Object?> get props => [productId, quantity, unitPrice];
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.customerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.delivery,
  });

  final String id;
  final String customerId;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final Delivery? delivery;

  bool get isActive => ![OrderStatus.delivered, OrderStatus.cancelled]
      .contains(status);

  @override
  List<Object?> get props => [id];
}
