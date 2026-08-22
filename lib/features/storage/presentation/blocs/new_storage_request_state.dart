part of 'new_storage_request_cubit.dart';

sealed class NewStorageRequestState {
  const NewStorageRequestState();
}

class NewStorageInitial extends NewStorageRequestState {
  const NewStorageInitial();
}

class NewStorageSubmitting extends NewStorageRequestState {
  const NewStorageSubmitting();
}

class NewStorageSuccess extends NewStorageRequestState {
  const NewStorageSuccess();
}

class NewStorageError extends NewStorageRequestState {
  const NewStorageError(this.message);
  final String message;
}
