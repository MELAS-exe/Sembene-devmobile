part of 'products_cubit.dart';

sealed class ProductsState {
  const ProductsState();
}

class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

class ProductsLoaded extends ProductsState {
  const ProductsLoaded(this.products);
  final List<Product> products;
}

class ProductsError extends ProductsState {
  const ProductsError(this.message);
  final String message;
}
