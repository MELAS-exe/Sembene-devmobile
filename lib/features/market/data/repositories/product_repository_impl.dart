import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/core/network/dio_client.dart';
import 'package:tera/features/market/data/datasources/product_remote_datasource.dart';
import 'package:tera/features/market/domain/entities/product.dart';
import 'package:tera/features/market/domain/entities/stock_level.dart';
import 'package:tera/features/market/domain/repositories/i_product_repository.dart';

@LazySingleton(as: IProductRepository)
class ProductRepositoryImpl implements IProductRepository {
  const ProductRepositoryImpl(this._remote);
  final ProductRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 0,
    int size = 50,
  }) async {
    try {
      final models = await _remote.getProducts(page: page, size: size);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts({
    required String keyword,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final models = await _remote.searchProducts(
          keyword: keyword, page: page, size: size);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StockLevel>>> getStockByProduct(
    String productId,
  ) async {
    try {
      final models = await _remote.getStockByProduct(productId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }
}
