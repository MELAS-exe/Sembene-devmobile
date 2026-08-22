import 'package:dartz/dartz.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/auth/domain/entities/auth_tokens.dart';

abstract class IAuthRepository {
  Future<Either<Failure, AuthTokens>> login({
    required String phoneNumber,
    required String password,
  });

  Future<Either<Failure, AuthTokens>> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  });

  Future<Either<Failure, AuthTokens>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<Either<Failure, Unit>> logout();

  Future<bool> isAuthenticated();

  Future<bool> getMustChangePassword();
}
