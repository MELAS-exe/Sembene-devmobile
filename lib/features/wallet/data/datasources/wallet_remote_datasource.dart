import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/features/wallet/data/models/balance_model.dart';
import 'package:tera/features/wallet/data/models/payout_model.dart';
import 'package:tera/features/wallet/data/models/withdrawal_request_model.dart';

abstract class WalletRemoteDataSource {
  Future<BalanceModel> getBalance();
  Future<PayoutModel> requestWithdrawal(WithdrawalRequestModel request);
  Future<List<PayoutModel>> getPayouts();
}

@LazySingleton(as: WalletRemoteDataSource)
class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  const WalletRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<BalanceModel> getBalance() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/wallet/balance');
    return BalanceModel.fromJson(res.data!);
  }

  @override
  Future<PayoutModel> requestWithdrawal(WithdrawalRequestModel request) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/wallet/withdraw',
      data: request.toJson(),
    );
    return PayoutModel.fromJson(res.data!);
  }

  @override
  Future<List<PayoutModel>> getPayouts() async {
    final res = await _dio.get<List<dynamic>>('/api/wallet/payouts');
    final list = res.data ?? <dynamic>[];
    return list
        .map((e) => PayoutModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
