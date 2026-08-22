import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/core/notifications/notification_service.dart';
import 'package:tera/features/auth/domain/repositories/i_auth_repository.dart';

part 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthInitial());

  final IAuthRepository _repo;

  Future<void> checkAuth() async {
    final ok = await _repo.isAuthenticated();
    if (!ok) {
      emit(const AuthUnauthenticated());
      return;
    }
    final mustChange = await _repo.getMustChangePassword();
    emit(AuthAuthenticated(mustChangePassword: mustChange));
  }

  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    emit(const AuthLoading());
    final result = await _repo.login(
      phoneNumber: phoneNumber,
      password: password,
    );
    result.fold(
      (f) => emit(AuthError(f is LocalFailure ? f.message : (f as ServerFailure).message)),
      (tokens) {
        emit(AuthAuthenticated(mustChangePassword: tokens.mustChangePassword));
        if (!tokens.mustChangePassword) {
          NotificationService.instance.registerTokenAfterLogin();
        }
      },
    );
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  }) async {
    emit(const AuthLoading());
    final result = await _repo.register(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      password: password,
    );
    result.fold(
      (f) => emit(AuthError(f is LocalFailure ? f.message : (f as ServerFailure).message)),
      (tokens) {
        emit(AuthAuthenticated(mustChangePassword: tokens.mustChangePassword));
        if (!tokens.mustChangePassword) {
          NotificationService.instance.registerTokenAfterLogin();
        }
      },
    );
  }

  void onPasswordChanged() {
    emit(const AuthAuthenticated());
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(const AuthUnauthenticated());
  }
}
