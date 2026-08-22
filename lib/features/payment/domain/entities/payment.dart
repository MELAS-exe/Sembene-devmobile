import 'package:equatable/equatable.dart';
import 'package:tera/features/payment/domain/entities/payment_reference_type.dart';
import 'package:tera/features/payment/domain/entities/payment_status.dart';

class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.referenceId,
    required this.referenceType,
    required this.createdAt,
    this.checkoutUrl,
  });

  final String id;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String referenceId;
  final PaymentReferenceType referenceType;

  /// NabooPay hosted-checkout URL. Created asynchronously after the order
  /// commits, so it may be `null` for a short window after the reference
  /// exists — poll until it becomes available.
  final String? checkoutUrl;
  final DateTime createdAt;

  bool get hasCheckoutUrl =>
      checkoutUrl != null && checkoutUrl!.trim().isNotEmpty;
  bool get isPending => status == PaymentStatus.pending;
  bool get isPaid => status.isPaid;
  bool get isTerminal => status.isTerminal;

  @override
  List<Object?> get props => [id, status, checkoutUrl];
}
