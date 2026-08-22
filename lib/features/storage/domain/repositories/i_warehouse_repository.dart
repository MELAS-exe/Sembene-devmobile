import 'package:dartz/dartz.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/storage/domain/entities/storage_request.dart';
import 'package:tera/features/storage/domain/entities/warehouse.dart';

abstract interface class IWarehouseRepository {
  Future<Either<Failure, List<Warehouse>>> getWarehouses();
  Future<Either<Failure, void>> createStorageRequest({
    required String productId,
    required String type,
    String? destinationWarehouseId,
    String? sourceWarehouseId,
    required double quantity,
    String? startDate,
    String? endDate,
    bool delegatedSale = false,
  });
  Future<Either<Failure, List<StorageRequest>>> getStorageRequests({
    String? status,
    String? type,
  });
}
