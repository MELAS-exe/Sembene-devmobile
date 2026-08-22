import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/payment/domain/entities/payment.dart';
import 'package:tera/features/payment/domain/entities/payment_reference_type.dart';
import 'package:tera/features/payment/domain/repositories/i_payment_repository.dart';
import 'package:url_launcher/url_launcher.dart';

part 'payment_state.dart';

@injectable
class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(this._repo) : super(const PaymentInitial());

  final IPaymentRepository _repo;

  Timer? _pollTimer;

  // The checkout is created asynchronously after the order commits, so the
  // first few by-reference reads may have no URL yet.
  static const _checkoutAttempts = 6;
  static const _checkoutRetryDelay = Duration(seconds: 1);
  static const _statusPollInterval = Duration(seconds: 4);

  /// Primary entry point: resolve the auto-created checkout for a reference,
  /// retrying while the URL is being prepared. Falls back to an explicit
  /// initiate if the checkout never becomes available.
  Future<void> fetchCheckout({
    required String referenceId,
    required PaymentReferenceType referenceType,
    required double amount,
    required String description,
  }) async {
    emit(const PaymentLoading());

    for (var attempt = 0; attempt < _checkoutAttempts; attempt++) {
      final result = await _repo.getByReference(
        referenceId: referenceId,
        referenceType: referenceType,
      );
      final payment = result.fold((_) => null, (p) => p);
      if (payment != null) {
        if (payment.isTerminal) {
          _emitForStatus(payment);
          return;
        }
        if (payment.hasCheckoutUrl) {
          emit(PaymentCheckout(payment));
          return;
        }
      }
      if (attempt < _checkoutAttempts - 1) {
        await Future<void>.delayed(_checkoutRetryDelay);
      }
    }

    // Auto-initiation didn't surface a URL in time — force one.
    final fallback = await _repo.initiatePayment(
      referenceId: referenceId,
      referenceType: referenceType,
      amount: amount,
      description: description,
    );
    fallback.fold((f) => emit(PaymentError(_msg(f))), (payment) {
      if (payment.hasCheckoutUrl) {
        emit(PaymentCheckout(payment));
      } else {
        emit(
          const PaymentError(
            'Le paiement est en cours de préparation. '
            'Réessayez dans un instant.',
          ),
        );
      }
    });
  }

  /// Opens the NabooPay hosted page then begins confirming the final status.
  Future<void> openCheckoutUrl(Payment payment) async {
    final url = payment.checkoutUrl;
    if (url != null) {
      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
    emit(PaymentPolling(payment));
    _startPolling(payment.id);
  }

  /// Re-reads the payment; the webhook-confirmed status is the source of truth.
  Future<void> checkStatus(String paymentId) async {
    final result = await _repo.getPaymentById(paymentId);
    result.fold((f) => emit(PaymentError(_msg(f))), _emitForStatus);
  }

  void _emitForStatus(Payment payment) {
    if (payment.isPaid) {
      _pollTimer?.cancel();
      emit(PaymentSuccess(payment));
    } else if (payment.isTerminal) {
      _pollTimer?.cancel();
      emit(PaymentFailed(payment));
    } else {
      emit(PaymentPolling(payment));
    }
  }

  void _startPolling(String paymentId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      _statusPollInterval,
      (_) => checkStatus(paymentId),
    );
  }

  String _msg(Failure f) =>
      f is LocalFailure ? f.message : (f as ServerFailure).message;

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
