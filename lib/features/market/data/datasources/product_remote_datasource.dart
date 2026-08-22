import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/features/market/data/models/product_model.dart';
import 'package:tera/features/market/data/models/stock_level_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({int page = 0, int size = 50});
  Future<List<ProductModel>> searchProducts({
    required String keyword,
    int page = 0,
    int size = 20,
  });
  Future<List<StockLevelModel>> getStockByProduct(
    String productId, {
    int size = 100,
  });
}

@LazySingleton(as: ProductRemoteDataSource)
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  const ProductRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  static List<ProductModel> _parsePage(dynamic data) {
    if (data is Map && data['content'] is List) {
      return (data['content'] as List)
          .cast<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    }
    if (data is List) {
      return data
          .cast<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    }
    return [];
  }

  static List<dynamic> _parseList(dynamic data) {
    if (data is Map && data['content'] is List) {
      return data['content'] as List<dynamic>;
    }
    if (data is List) return data;
    return [];
  }

  @override
  Future<List<ProductModel>> getProducts({
    int page = 0,
    int size = 50,
  }) async {
    final res = await _dio.get<dynamic>(
      '/api/products',
      queryParameters: {'page': page, 'size': size},
    );
    return _parsePage(res.data);
  }

  @override
  Future<List<ProductModel>> searchProducts({
    required String keyword,
    int page = 0,
    int size = 20,
  }) async {
    final res = await _dio.get<dynamic>(
      '/api/products/$keyword',
      queryParameters: {'page': page, 'size': size},
    );
    return _parsePage(res.data);
  }

  @override
  Future<List<StockLevelModel>> getStockByProduct(
    String productId, {
    int size = 100,
  }) async {
    final res = await _dio.get<dynamic>(
      '/api/stock/product/$productId',
      queryParameters: {'page': 0, 'size': size},
    );
    return _parseList(res.data)
        .cast<Map<String, dynamic>>()
        .map(StockLevelModel.fromJson)
        .toList();
  }
}
