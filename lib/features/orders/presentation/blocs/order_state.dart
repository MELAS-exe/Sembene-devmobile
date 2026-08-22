part of 'order_cubit.dart';

sealed class OrderState {
  const OrderState();
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrdersLoaded extends OrderState {
  const OrdersLoaded(this.orders);
  final List<Order> orders;
}

class OrderSuccess extends OrderState {
  const OrderSuccess(this.order);
  final Order order;
}

class OrderError extends OrderState {
  const OrderError(this.message);
  final String message;
}
