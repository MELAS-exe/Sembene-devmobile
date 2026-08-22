import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/features/storage/data/models/storage_request_model.dart';
import 'package:tera/features/storage/data/models/warehouse_model.dart';

abstract interface class IWarehouseRemoteDataSource {
  Future<List<WarehouseModel>> getWarehouses({int page = 0, int size = 20});
  Future<void> createStorageRequest({
    required String productId,
    required String type,
    String? destinationWarehouseId,
    String? sourceWarehouseId,
    required double quantity,
    String? startDate,
    String? endDate,
    bool delegatedSale = false,
  });
  Future<List<StorageRequestModel>> getStorageRequests({
    String? status,
    String? type,
    int page = 0,
    int size = 20,
  });
}

@LazySingleton(as: IWarehouseRemoteDataSource)
class WarehouseRemoteDataSourceImpl implements IWarehouseRemoteDataSource {
  const WarehouseRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<WarehouseModel>> getWarehouses(
      {int page = 0, int size = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/warehouse',
      queryParameters: {'page': page, 'size': size},
    );
    final list =
        (response.data?['content'] as List<dynamic>?) ?? <dynamic>[];
    return list
        .map((e) => WarehouseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createStorageRequest({
    required String productId,
    required String type,
    String? destinationWarehouseId,
    String? sourceWarehouseId,
    required double quantity,
    String? startDate,
    String? endDate,
    bool delegatedSale = false,
  }) async {
    final body = <String, dynamic>{
      'productId': productId,
      'type': type,
      'quantity': quantity,
      'delegatedSale': delegatedSale,
      if (destinationWarehouseId != null)
        'destinationWarehouseId': destinationWarehouseId,
      if (sourceWarehouseId != null) 'sourceWarehouseId': sourceWarehouseId,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };
    await _dio.post<dynamic>('/api/storage', data: body);
  }

  @override
  Future<List<StorageRequestModel>> getStorageRequests({
    String? status,
    String? type,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/storage',
      queryParameters: {
        'page': page,
        'size': size,
        if (status != null) 'status': status,
        if (type != null) 'type': type,
      },
    );
    final list =
        (response.data?['content'] as List<dynamic>?) ?? <dynamic>[];
    return list
        .map((e) => StorageRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
