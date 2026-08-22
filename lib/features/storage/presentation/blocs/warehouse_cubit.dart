import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/storage/domain/entities/warehouse.dart';
import 'package:tera/features/storage/domain/repositories/i_warehouse_repository.dart';

part 'warehouse_state.dart';

@injectable
class WarehouseCubit extends Cubit<WarehouseState> {
  WarehouseCubit(this._repo) : super(const WarehouseInitial());

  final IWarehouseRepository _repo;

  Future<void> loadWarehouses() async {
    emit(const WarehouseLoading());
    final result = await _repo.getWarehouses();
    result.fold(
      (f) => emit(WarehouseError(
          f is LocalFailure ? f.message : (f as ServerFailure).message)),
      (warehouses) => emit(WarehousesLoaded(warehouses)),
    );
  }
}
