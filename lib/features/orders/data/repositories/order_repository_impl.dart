import 'package:dartz/dartz.dart' hide Order;
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/core/network/dio_client.dart';
import 'package:tera/features/market/presentation/blocs/basket_cubit.dart';
import 'package:tera/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:tera/features/orders/domain/entities/order.dart';
import 'package:tera/features/orders/domain/repositories/i_order_repository.dart';

@LazySingleton(as: IOrderRepository)
class OrderRepositoryImpl implements IOrderRepository {
  OrderRepositoryImpl(this._remote);
  final OrderRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Order>>> getOrders(
      {int page = 0, int size = 20}) async {
    try {
      final models = await _remote.getOrders(page: page, size: size);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderById(String orderId) async {
    try {
      final model = await _remote.getOrderById(orderId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> createOrder(
    List<BasketItem> items,
    String destinationAddress,
  ) async {
    try {
      final payload = items
          .map((i) => {
                'productId': i.product.id,
                'quantity': i.quantity,
              })
          .toList();
      final model = await _remote.createOrder(payload, destinationAddress);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> cancelOrder(String orderId) async {
    try {
      final model = await _remote.cancelOrder(orderId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }
}
