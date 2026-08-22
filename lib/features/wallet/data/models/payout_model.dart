import 'package:tera/features/wallet/domain/entities/payout.dart';
import 'package:tera/features/wallet/domain/entities/payout_method.dart';
import 'package:tera/features/wallet/domain/entities/payout_status.dart';

/// Maps the backend `PayoutResponse` DTO.
class PayoutModel {
  const PayoutModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.method,
    required this.recipientName,
    required this.recipientPhone,
    required this.status,
    required this.createdAt,
    this.gatewayReference,
    this.reason,
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) => PayoutModel(
    id: json['id'] as String,
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'XOF',
    method: PayoutMethod.fromString(json['method'] as String?),
    recipientName: json['recipientName'] as String? ?? '',
    recipientPhone: json['recipientPhone'] as String? ?? '',
    status: PayoutStatus.fromString(json['status'] as String?),
    gatewayReference: json['gatewayReference'] as String?,
    reason: json['reason'] as String?,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  final String id;
  final double amount;
  final String currency;
  final PayoutMethod method;
  final String recipientName;
  final String recipientPhone;
  final PayoutStatus status;
  final String? gatewayReference;
  final String? reason;
  final DateTime createdAt;

  Payout toEntity() => Payout(
    id: id,
    amount: amount,
    currency: currency,
    method: method,
    recipientName: recipientName,
    recipientPhone: recipientPhone,
    status: status,
    gatewayReference: gatewayReference,
    reason: reason,
    createdAt: createdAt,
  );
}
