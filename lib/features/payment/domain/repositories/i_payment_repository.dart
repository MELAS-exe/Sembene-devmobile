import 'package:dartz/dartz.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/payment/domain/entities/payment.dart';
import 'package:tera/features/payment/domain/entities/payment_reference_type.dart';

abstract class IPaymentRepository {
  /// Fetches the checkout for an order / storage reference. The checkout is
  /// auto-created by the backend when the order is placed, so this is the
  /// primary "start a payment" call — no explicit initiate is needed.
  Future<Either<Failure, Payment>> getByReference({
    required String referenceId,
    required PaymentReferenceType referenceType,
  });

  /// Polls a single payment by its id — the source of truth for final status.
  Future<Either<Failure, Payment>> getPaymentById(String id);

  /// Fallback used only when auto-initiation failed: forces a fresh checkout.
  Future<Either<Failure, Payment>> initiatePayment({
    required String referenceId,
    required PaymentReferenceType referenceType,
    required double amount,
    required String description,
  });
}
