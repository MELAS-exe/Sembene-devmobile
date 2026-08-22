import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/market/domain/entities/product.dart';
import 'package:tera/features/market/domain/repositories/i_product_repository.dart';

part 'products_state.dart';

@injectable
class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._repo) : super(const ProductsInitial());

  final IProductRepository _repo;

  Future<void> loadProducts() async {
    emit(const ProductsLoading());
    final result = await _repo.getProducts();
    result.fold(
      (f) {
        final msg = f is LocalFailure ? f.message : (f as ServerFailure).message;
        emit(ProductsError(msg));
      },
      (products) => emit(ProductsLoaded(products)),
    );
  }
}
