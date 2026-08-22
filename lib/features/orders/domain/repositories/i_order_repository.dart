import 'package:dartz/dartz.dart' hide Order;
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/market/presentation/blocs/basket_cubit.dart';
import 'package:tera/features/orders/domain/entities/order.dart';

abstract interface class IOrderRepository {
  Future<Either<Failure, List<Order>>> getOrders({int page = 0, int size = 20});
  Future<Either<Failure, Order>> getOrderById(String orderId);
  Future<Either<Failure, Order>> createOrder(
    List<BasketItem> items,
    String destinationAddress,
  );
  Future<Either<Failure, Order>> cancelOrder(String orderId);
}
