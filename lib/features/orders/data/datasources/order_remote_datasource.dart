import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/features/orders/data/models/order_model.dart';

abstract interface class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders({int page = 0, int size = 20});
  Future<OrderModel> getOrderById(String orderId);
  Future<OrderModel> createOrder(
    List<Map<String, dynamic>> items,
    String destinationAddress,
  );
  Future<OrderModel> cancelOrder(String orderId);
}

@LazySingleton(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<OrderModel>> getOrders({int page = 0, int size = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/order',
      queryParameters: {'page': page, 'size': size},
    );
    final content =
        (response.data?['content'] as List<dynamic>?) ?? <dynamic>[];
    return content
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/order/admin/$orderId',
    );
    return OrderModel.fromJson(response.data!);
  }

  @override
  Future<OrderModel> createOrder(
    List<Map<String, dynamic>> items,
    String destinationAddress,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/order',
      data: {'items': items, 'destinationAddress': destinationAddress},
    );
    return OrderModel.fromJson(response.data!);
  }

  @override
  Future<OrderModel> cancelOrder(String orderId) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/order/$orderId/cancel',
    );
    return OrderModel.fromJson(response.data!);
  }
}
