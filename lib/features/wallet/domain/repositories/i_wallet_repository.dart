import 'package:dartz/dartz.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/wallet/domain/entities/payout.dart';
import 'package:tera/features/wallet/domain/entities/payout_method.dart';
import 'package:tera/features/wallet/domain/entities/wallet_balance.dart';

abstract class IWalletRepository {
  Future<Either<Failure, WalletBalance>> getBalance();

  Future<Either<Failure, Payout>> requestWithdrawal({
    required double amount,
    required PayoutMethod method,
    required String recipientFirstName,
    required String recipientLastName,
    required String recipientPhone,
  });

  Future<Either<Failure, List<Payout>>> getPayouts();
}
