import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/core/network/dio_client.dart';
import 'package:tera/features/storage/data/datasources/warehouse_remote_datasource.dart';
import 'package:tera/features/storage/domain/entities/storage_request.dart';
import 'package:tera/features/storage/domain/entities/warehouse.dart';
import 'package:tera/features/storage/domain/repositories/i_warehouse_repository.dart';

@LazySingleton(as: IWarehouseRepository)
class WarehouseRepositoryImpl implements IWarehouseRepository {
  WarehouseRepositoryImpl(this._remote);
  final IWarehouseRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Warehouse>>> getWarehouses() async {
    try {
      final models = await _remote.getWarehouses();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createStorageRequest({
    required String productId,
    required String type,
    String? destinationWarehouseId,
    String? sourceWarehouseId,
    required double quantity,
    String? startDate,
    String? endDate,
    bool delegatedSale = false,
  }) async {
    try {
      await _remote.createStorageRequest(
        productId: productId,
        type: type,
        destinationWarehouseId: destinationWarehouseId,
        sourceWarehouseId: sourceWarehouseId,
        quantity: quantity,
        startDate: startDate,
        endDate: endDate,
        delegatedSale: delegatedSale,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StorageRequest>>> getStorageRequests({
    String? status,
    String? type,
  }) async {
    try {
      final models = await _remote.getStorageRequests(
        status: status,
        type: type,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }
}
