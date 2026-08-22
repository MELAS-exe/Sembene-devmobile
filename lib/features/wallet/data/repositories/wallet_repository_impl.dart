import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/core/network/dio_client.dart';
import 'package:tera/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:tera/features/wallet/data/models/withdrawal_request_model.dart';
import 'package:tera/features/wallet/domain/entities/balance_source.dart';
import 'package:tera/features/wallet/domain/entities/payout.dart';
import 'package:tera/features/wallet/domain/entities/payout_method.dart';
import 'package:tera/features/wallet/domain/entities/wallet_balance.dart';
import 'package:tera/features/wallet/domain/repositories/i_wallet_repository.dart';

@LazySingleton(as: IWalletRepository)
class WalletRepositoryImpl implements IWalletRepository {
  const WalletRepositoryImpl(this._remote);
  final WalletRemoteDataSource _remote;

  @override
  Future<Either<Failure, WalletBalance>> getBalance() async {
    try {
      final model = await _remote.getBalance();
      return Right(model.toEntity());
    } on DioException catch (e) {
      // Payments feature disabled on the server — treat as "no wallet".
      if (e.response?.statusCode == 404) {
        return const Right(
          WalletBalance(
            available: 0,
            currency: 'XOF',
            source: BalanceSource.unavailable,
          ),
        );
      }
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Payout>> requestWithdrawal({
    required double amount,
    required PayoutMethod method,
    required String recipientFirstName,
    required String recipientLastName,
    required String recipientPhone,
  }) async {
    try {
      final model = await _remote.requestWithdrawal(
        WithdrawalRequestModel(
          amount: amount,
          method: method,
          recipientFirstName: recipientFirstName,
          recipientLastName: recipientLastName,
          recipientPhone: recipientPhone,
        ),
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Payout>>> getPayouts() async {
    try {
      final models = await _remote.getPayouts();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }
}
