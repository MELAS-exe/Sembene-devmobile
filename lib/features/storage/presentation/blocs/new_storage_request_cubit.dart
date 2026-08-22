import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/storage/domain/repositories/i_warehouse_repository.dart';

part 'new_storage_request_state.dart';

@injectable
class NewStorageRequestCubit extends Cubit<NewStorageRequestState> {
  NewStorageRequestCubit(this._repo) : super(const NewStorageInitial());

  final IWarehouseRepository _repo;

  Future<void> submit({
    required String productId,
    required String type,
    String? destinationWarehouseId,
    String? sourceWarehouseId,
    required double quantity,
    String? startDate,
    String? endDate,
    bool delegatedSale = false,
  }) async {
    emit(const NewStorageSubmitting());
    final result = await _repo.createStorageRequest(
      productId: productId,
      type: type,
      destinationWarehouseId: destinationWarehouseId,
      sourceWarehouseId: sourceWarehouseId,
      quantity: quantity,
      startDate: startDate,
      endDate: endDate,
      delegatedSale: delegatedSale,
    );
    result.fold(
      (f) => emit(NewStorageError(
          f is LocalFailure ? f.message : (f as ServerFailure).message)),
      (_) => emit(const NewStorageSuccess()),
    );
  }
}
