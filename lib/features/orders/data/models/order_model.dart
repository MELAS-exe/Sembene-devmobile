import 'package:tera/features/orders/domain/entities/order.dart';

class DeliveryModel {
  const DeliveryModel({
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

  factory DeliveryModel.fromJson(Map<String, dynamic> json) => DeliveryModel(
        driverFirstName: json['driverFirstName'] as String?,
        driverLastName: json['driverLastName'] as String?,
        driverPhoneNumber: json['driverPhoneNumber'] as String?,
        destinationAddress: json['destinationAddress'] as String?,
        status: json['status'] as String? ?? '',
      );

  Delivery toEntity() => Delivery(
        driverFirstName: driverFirstName,
        driverLastName: driverLastName,
        driverPhoneNumber: driverPhoneNumber,
        destinationAddress: destinationAddress,
        status: status,
      );
}

class OrderItemModel {
  const OrderItemModel({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final double quantity;
  final double unitPrice;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        productId: json['productId'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );

  OrderItem toEntity() =>
      OrderItem(productId: productId, quantity: quantity, unitPrice: unitPrice);
}

class OrderModel {
  const OrderModel({
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
  final List<OrderItemModel> items;
  final double totalAmount;
  final String status;
  final String createdAt;
  final DeliveryModel? delivery;

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['orderId'] as String,
        customerId: json['customerId'] as String,
        items: (json['items'] as List<dynamic>)
            .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        status: json['status'] as String,
        createdAt: json['createdAt'] as String,
        delivery: json['delivery'] != null
            ? DeliveryModel.fromJson(json['delivery'] as Map<String, dynamic>)
            : null,
      );

  Order toEntity() => Order(
        id: id,
        customerId: customerId,
        items: items.map((e) => e.toEntity()).toList(),
        totalAmount: totalAmount,
        status: OrderStatus.fromString(status),
        createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
        delivery: delivery?.toEntity(),
      );
}
