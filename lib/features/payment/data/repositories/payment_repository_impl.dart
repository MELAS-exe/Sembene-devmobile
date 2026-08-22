import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/core/network/dio_client.dart';
import 'package:tera/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:tera/features/payment/data/models/initiate_payment_request_model.dart';
import 'package:tera/features/payment/domain/entities/payment.dart';
import 'package:tera/features/payment/domain/entities/payment_reference_type.dart';
import 'package:tera/features/payment/domain/repositories/i_payment_repository.dart';

@LazySingleton(as: IPaymentRepository)
class PaymentRepositoryImpl implements IPaymentRepository {
  const PaymentRepositoryImpl(this._remote);
  final PaymentRemoteDataSource _remote;

  @override
  Future<Either<Failure, Payment>> getByReference({
    required String referenceId,
    required PaymentReferenceType referenceType,
  }) async {
    try {
      final model = await _remote.getByReference(referenceId, referenceType);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Payment>> getPaymentById(String id) async {
    try {
      final model = await _remote.getPaymentById(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Payment>> initiatePayment({
    required String referenceId,
    required PaymentReferenceType referenceType,
    required double amount,
    required String description,
  }) async {
    try {
      final model = await _remote.initiatePayment(
        InitiatePaymentRequestModel(
          referenceId: referenceId,
          referenceType: referenceType,
          amount: amount,
          description: description,
        ),
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }
}
