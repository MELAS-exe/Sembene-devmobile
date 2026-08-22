import 'package:equatable/equatable.dart';
import 'package:tera/features/wallet/domain/entities/balance_source.dart';

class WalletBalance extends Equatable {
  const WalletBalance({
    required this.available,
    required this.currency,
    required this.source,
  });

  final double available;
  final String currency;
  final BalanceSource source;

  /// Minimum withdrawal accepted by the gateway.
  static const double minWithdrawal = 11;

  bool get canWithdraw =>
      source != BalanceSource.unavailable && available >= minWithdrawal;

  @override
  List<Object?> get props => [available, currency, source];
}
