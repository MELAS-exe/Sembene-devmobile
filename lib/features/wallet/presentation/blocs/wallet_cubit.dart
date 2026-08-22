import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/wallet/domain/entities/payout.dart';
import 'package:tera/features/wallet/domain/entities/payout_method.dart';
import 'package:tera/features/wallet/domain/entities/wallet_balance.dart';
import 'package:tera/features/wallet/domain/repositories/i_wallet_repository.dart';

part 'wallet_state.dart';

@injectable
class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._repo) : super(const WalletInitial());

  final IWalletRepository _repo;

  Future<void> loadWallet() async {
    emit(const WalletLoading());
    final balanceResult = await _repo.getBalance();
    await balanceResult.fold((f) async => emit(WalletError(_msg(f))), (
      balance,
    ) async {
      // The balance is the gate; payout history is best-effort.
      final payoutsResult = await _repo.getPayouts();
      final payouts = payoutsResult.fold((_) => <Payout>[], (p) => p);
      emit(WalletLoaded(balance: balance, payouts: payouts));
    });
  }

  /// Returns `null` on success, or a user-facing error message on failure.
  /// On success the wallet is reloaded so the balance and history refresh.
  Future<String?> withdraw({
    required double amount,
    required PayoutMethod method,
    required String recipientFirstName,
    required String recipientLastName,
    required String recipientPhone,
  }) async {
    final result = await _repo.requestWithdrawal(
      amount: amount,
      method: method,
      recipientFirstName: recipientFirstName,
      recipientLastName: recipientLastName,
      recipientPhone: recipientPhone,
    );
    return result.fold((f) async => _msg(f), (_) async {
      await loadWallet();
      return null;
    });
  }

  String _msg(Failure f) =>
      f is LocalFailure ? f.message : (f as ServerFailure).message;
}
