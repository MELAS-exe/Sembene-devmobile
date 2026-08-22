import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/features/auth/data/models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String phoneNumber,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  });

  Future<AuthResponseModel> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<AuthResponseModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'phoneNumber': phoneNumber, 'password': password},
    );
    return AuthResponseModel.fromJson(res.data!);
  }

  @override
  Future<AuthResponseModel> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/auth/register_consumer',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'password': password,
      },
    );
    return AuthResponseModel.fromJson(res.data!);
  }

  @override
  Future<AuthResponseModel> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    return AuthResponseModel.fromJson(res.data!);
  }
}
