part of 'storage_requests_cubit.dart';

sealed class StorageRequestsState extends Equatable {
  const StorageRequestsState();
  @override
  List<Object?> get props => [];
}

final class StorageRequestsInitial extends StorageRequestsState {
  const StorageRequestsInitial();
}

final class StorageRequestsLoading extends StorageRequestsState {
  const StorageRequestsLoading();
}

final class StorageRequestsLoaded extends StorageRequestsState {
  const StorageRequestsLoaded(this.requests);
  final List<StorageRequest> requests;
  @override
  List<Object?> get props => [requests];
}

final class StorageRequestsError extends StorageRequestsState {
  const StorageRequestsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
