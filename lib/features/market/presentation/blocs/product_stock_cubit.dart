import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/features/market/domain/repositories/i_product_repository.dart';

part 'product_stock_state.dart';

@injectable
class ProductStockCubit extends Cubit<ProductStockState> {
  ProductStockCubit(this._repo) : super(const ProductStockInitial());

  final IProductRepository _repo;

  Future<void> loadStock(String productId) async {
    emit(const ProductStockLoading());
    final result = await _repo.getStockByProduct(productId);
    result.fold(
      (_) => emit(const ProductStockError()),
      (levels) {
        final total = levels.fold<double>(0, (sum, l) => sum + l.quantity);
        emit(ProductStockLoaded(totalQuantity: total));
      },
    );
  }
}
