import 'package:tera/features/payment/domain/entities/payment.dart';
import 'package:tera/features/payment/domain/entities/payment_reference_type.dart';
import 'package:tera/features/payment/domain/entities/payment_status.dart';

/// Maps the backend `PaymentResponse` DTO.
///
/// Note the id field is `paymentId` (not `id`); a fallback to `id` is kept for
/// resilience against older payloads.
class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.referenceId,
    required this.referenceType,
    required this.createdAt,
    this.checkoutUrl,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final url = json['checkoutUrl'] as String?;
    return PaymentModel(
      id: (json['paymentId'] ?? json['id']) as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'XOF',
      status: PaymentStatus.fromString(json['status'] as String? ?? 'PENDING'),
      referenceId: json['referenceId'] as String,
      referenceType: _parseRefType(json['referenceType'] as String? ?? 'ORDER'),
      checkoutUrl: (url != null && url.trim().isNotEmpty) ? url : null,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final String id;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String referenceId;
  final PaymentReferenceType referenceType;
  final String? checkoutUrl;
  final DateTime createdAt;

  static PaymentReferenceType _parseRefType(String s) =>
      switch (s.toUpperCase()) {
        'STORAGE_REQUEST' => PaymentReferenceType.storageRequest,
        _ => PaymentReferenceType.order,
      };

  Payment toEntity() => Payment(
    id: id,
    amount: amount,
    currency: currency,
    status: status,
    referenceId: referenceId,
    referenceType: referenceType,
    checkoutUrl: checkoutUrl,
    createdAt: createdAt,
  );
}
