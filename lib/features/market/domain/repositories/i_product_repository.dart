import 'package:dartz/dartz.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/market/domain/entities/product.dart';
import 'package:tera/features/market/domain/entities/stock_level.dart';

abstract class IProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 0,
    int size = 50,
  });

  Future<Either<Failure, List<Product>>> searchProducts({
    required String keyword,
    int page = 0,
    int size = 20,
  });

  Future<Either<Failure, List<StockLevel>>> getStockByProduct(
    String productId,
  );
}
