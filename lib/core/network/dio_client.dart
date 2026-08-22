  import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/core/network/session_manager.dart';
import 'package:tera/core/storages/local_storages.dart';

const _baseUrl = 'http://10.0.2.2:8081';

Dio createDio(LocalStorage storage, SessionManager sessionManager) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[HTTP] $obj'),
      ),
    );
  }
  dio.interceptors.add(_AuthInterceptor(storage, dio, sessionManager));
  return dio;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage, this._dio, this._sessionManager);
  final LocalStorage _storage;
  final Dio _dio;
  final SessionManager _sessionManager;

  static const _refreshPath = '/api/auth/refresh';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Never attach an auth header to the refresh endpoint itself.
    if (options.path != _refreshPath) {
      final token = await _storage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Don't attempt a refresh if the failing request was itself a refresh.
    final isRefreshRequest = err.requestOptions.path == _refreshPath;
    if (err.response?.statusCode == 401 && !isRefreshRequest) {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final response = await _dio.post<Map<String, dynamic>>(
            _refreshPath,
            data: {'refreshToken': refreshToken},
          );
          final newToken = response.data?['token'] as String?;
          final newRefresh = response.data?['refreshToken'] as String?;
          if (newToken != null) {
            await _storage.setToken(newToken);
            if (newRefresh != null) await _storage.setRefreshToken(newRefresh);
            final retryOptions = err.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newToken';
            final retryResponse = await _dio.fetch<dynamic>(retryOptions);
            handler.resolve(retryResponse);
            return;
          }
        } catch (_) {
          await _storage.clearTokens();
          _sessionManager.invalidate();
        }
      } else {
        // No refresh token at all — session is gone.
        _sessionManager.invalidate();
      }
    }
    handler.next(err);
  }
}

Failure dioToFailure(DioException e) {
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return const Failure.serverFailure(
      message: 'Problème de connexion réseau.',
    );
  }
  final status = e.response?.statusCode;
  final msg = _extractMessage(e.response?.data) ??
      e.message ??
      "Une erreur s'est produite.";
  if (status == 401) {
    return const Failure.localFailure(
      message: 'Session expirée. Veuillez vous reconnecter.',
    );
  }
  return Failure.serverFailure(message: msg);
}

String? _extractMessage(dynamic data) {
  if (data is Map) return data['message'] as String?;
  if (data is String) return data;
  return null;
}
