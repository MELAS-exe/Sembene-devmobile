import 'package:equatable/equatable.dart';

class AuthTokens extends Equatable {
  const AuthTokens({
    required this.token,
    required this.refreshToken,
    this.mustChangePassword = false,
  });

  final String token;
  final String refreshToken;
  final bool mustChangePassword;

  @override
  List<Object?> get props => [token, refreshToken, mustChangePassword];
}
