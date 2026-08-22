import 'package:tera/features/wallet/domain/entities/payout_method.dart';

/// Body for `POST /api/wallet/withdraw`.
class WithdrawalRequestModel {
  const WithdrawalRequestModel({
    required this.amount,
    required this.method,
    required this.recipientFirstName,
    required this.recipientLastName,
    required this.recipientPhone,
  });

  final double amount;
  final PayoutMethod method;
  final String recipientFirstName;
  final String recipientLastName;
  final String recipientPhone;

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'method': method.toApiString(),
    'recipientFirstName': recipientFirstName,
    'recipientLastName': recipientLastName,
    'recipientPhone': recipientPhone,
  };
}
