import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/core/notifications/notification_service.dart';
import 'package:tera/features/auth/domain/repositories/i_auth_repository.dart';

part 'change_password_state.dart';

@injectable
class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._repo) : super(const ChangePasswordInitial());

  final IAuthRepository _repo;

  Future<void> submit({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(const ChangePasswordLoading());
    final result = await _repo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    result.fold(
      (f) => emit(ChangePasswordError(
          f is LocalFailure ? f.message : (f as ServerFailure).message)),
      (_) {
        NotificationService.instance.registerTokenAfterLogin();
        emit(const ChangePasswordSuccess());
      },
    );
  }
}
