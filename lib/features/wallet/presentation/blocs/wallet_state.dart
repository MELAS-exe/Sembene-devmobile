part of 'wallet_cubit.dart';

sealed class WalletState {
  const WalletState();
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  const WalletLoaded({required this.balance, required this.payouts});
  final WalletBalance balance;
  final List<Payout> payouts;
}

class WalletError extends WalletState {
  const WalletError(this.message);
  final String message;
}
