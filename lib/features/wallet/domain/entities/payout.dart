import 'package:equatable/equatable.dart';
import 'package:tera/features/wallet/domain/entities/payout_method.dart';
import 'package:tera/features/wallet/domain/entities/payout_status.dart';

class Payout extends Equatable {
  const Payout({
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

  final String id;
  final double amount;
  final String currency;
  final PayoutMethod method;
  final String recipientName;
  final String recipientPhone;
  final PayoutStatus status;
  final DateTime createdAt;
  final String? gatewayReference;
  final String? reason;

  @override
  List<Object?> get props => [id, status];
}
