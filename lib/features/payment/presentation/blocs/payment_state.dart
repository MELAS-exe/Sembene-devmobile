part of 'payment_cubit.dart';

sealed class PaymentState {
  const PaymentState();
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentCheckout extends PaymentState {
  const PaymentCheckout(this.payment);
  final Payment payment;
}

class PaymentPolling extends PaymentState {
  const PaymentPolling(this.payment);
  final Payment payment;
}

class PaymentSuccess extends PaymentState {
  const PaymentSuccess(this.payment);
  final Payment payment;
}

class PaymentFailed extends PaymentState {
  const PaymentFailed(this.payment);
  final Payment payment;
}

class PaymentError extends PaymentState {
  const PaymentError(this.message);
  final String message;
}
