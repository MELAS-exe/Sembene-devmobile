import 'package:tera/features/wallet/domain/entities/balance_source.dart';
import 'package:tera/features/wallet/domain/entities/wallet_balance.dart';

/// Maps the backend `BalanceResponse` DTO.
class BalanceModel {
  const BalanceModel({
    required this.available,
    required this.currency,
    required this.source,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) => BalanceModel(
    available: (json['available'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'XOF',
    source: BalanceSource.fromString(json['source'] as String?),
  );

  final double available;
  final String currency;
  final BalanceSource source;

  WalletBalance toEntity() =>
      WalletBalance(available: available, currency: currency, source: source);
}
