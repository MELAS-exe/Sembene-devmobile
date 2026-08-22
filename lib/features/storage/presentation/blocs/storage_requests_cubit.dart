import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/storage/domain/entities/storage_request.dart';
import 'package:tera/features/storage/domain/repositories/i_warehouse_repository.dart';

part 'storage_requests_state.dart';

@injectable
class StorageRequestsCubit extends Cubit<StorageRequestsState> {
  StorageRequestsCubit(this._repo) : super(const StorageRequestsInitial());

  final IWarehouseRepository _repo;

  Future<void> loadRequests() async {
    emit(const StorageRequestsLoading());
    final result = await _repo.getStorageRequests();
    result.fold(
      (failure) => emit(StorageRequestsError(
            failure is LocalFailure ? failure.message : (failure as ServerFailure).message,
          )),
      (requests) => emit(StorageRequestsLoaded(requests)),
    );
  }
}
