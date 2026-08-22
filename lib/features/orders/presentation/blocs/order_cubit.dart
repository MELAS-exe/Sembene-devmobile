import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/market/presentation/blocs/basket_cubit.dart';
import 'package:tera/features/orders/domain/entities/order.dart';
import 'package:tera/features/orders/domain/repositories/i_order_repository.dart';

part 'order_state.dart';

@injectable
class OrderCubit extends Cubit<OrderState> {
  OrderCubit(this._repo) : super(const OrderInitial());

  final IOrderRepository _repo;

  Future<void> loadOrders() async {
    emit(const OrderLoading());
    final result = await _repo.getOrders();
    result.fold(
      (f) => emit(OrderError(
          f is LocalFailure ? f.message : (f as ServerFailure).message)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  Future<void> placeOrder(
    List<BasketItem> items, {
    required String destinationAddress,
  }) async {
    emit(const OrderLoading());
    final result = await _repo.createOrder(items, destinationAddress);
    result.fold(
      (f) => emit(OrderError(
          f is LocalFailure ? f.message : (f as ServerFailure).message)),
      (order) => emit(OrderSuccess(order)),
    );
  }

  Future<void> cancelOrder(String orderId) async {
    final result = await _repo.cancelOrder(orderId);
    result.fold(
      (f) => emit(OrderError(
          f is LocalFailure ? f.message : (f as ServerFailure).message)),
      (order) => loadOrders(),
    );
  }
}
