import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/core/network/dio_client.dart';
import 'package:tera/core/storages/local_storages.dart';
import 'package:tera/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:tera/features/auth/domain/entities/auth_tokens.dart';
import 'package:tera/features/auth/domain/repositories/i_auth_repository.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl(this._remote, this._storage);
  final AuthRemoteDataSource _remote;
  final LocalStorage _storage;

  @override
  Future<Either<Failure, AuthTokens>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      await _storage.clearUserCache();
      final model = await _remote.login(
        phoneNumber: phoneNumber,
        password: password,
      );
      await _storage.setToken(model.token);
      await _storage.setRefreshToken(model.refreshToken);
      await _storage.setMustChangePassword(model.mustChangePassword);
      await _storage.setPhoneNumber(phoneNumber);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      await _storage.clearUserCache();
      final model = await _remote.register(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        password: password,
      );
      await _storage.setToken(model.token);
      await _storage.setRefreshToken(model.refreshToken);
      await _storage.setMustChangePassword(model.mustChangePassword);
      await _storage.setPhoneNumber(phoneNumber);
      await _storage.setFirstName(firstName);
      await _storage.setLastName(lastName);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final model = await _remote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      await _storage.setToken(model.token);
      await _storage.setRefreshToken(model.refreshToken);
      await _storage.setMustChangePassword(model.mustChangePassword);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    await _storage.clearTokens();
    return const Right(unit);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<bool> getMustChangePassword() => _storage.getMustChangePassword();
}
