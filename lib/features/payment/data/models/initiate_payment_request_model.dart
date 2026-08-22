import 'package:tera/features/payment/domain/entities/payment_reference_type.dart';

/// Body for `POST /api/payment/initiate` — the fallback used only when the
/// auto-created checkout never becomes available. NabooPay collects the
/// customer's wallet details on its own hosted page, so the app sends only the
/// reference, amount and a description.
class InitiatePaymentRequestModel {
  const InitiatePaymentRequestModel({
    required this.referenceId,
    required this.referenceType,
    required this.amount,
    required this.description,
  });

  final String referenceId;
  final PaymentReferenceType referenceType;
  final double amount;
  final String description;

  Map<String, dynamic> toJson() => {
    'referenceId': referenceId,
    'referenceType': referenceType.toApiString(),
    'amount': amount,
    'description': description,
  };
}
