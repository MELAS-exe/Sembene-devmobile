import 'package:tera/features/auth/domain/entities/auth_tokens.dart';

class AuthResponseModel {
  const AuthResponseModel({
    required this.token,
    required this.refreshToken,
    this.mustChangePassword = false,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
    );
  }

  final String token;
  final String refreshToken;
  final bool mustChangePassword;

  AuthTokens toEntity() => AuthTokens(
        token: token,
        refreshToken: refreshToken,
        mustChangePassword: mustChangePassword,
      );
}
