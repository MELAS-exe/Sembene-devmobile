part of 'product_stock_cubit.dart';

sealed class ProductStockState {
  const ProductStockState();
}

class ProductStockInitial extends ProductStockState {
  const ProductStockInitial();
}

class ProductStockLoading extends ProductStockState {
  const ProductStockLoading();
}

class ProductStockLoaded extends ProductStockState {
  const ProductStockLoaded({required this.totalQuantity});
  final double totalQuantity;
}

class ProductStockError extends ProductStockState {
  const ProductStockError();
}
