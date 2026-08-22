import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  Future<String?> getApiKey();
  Future<void> setApiKey(String apiKey);

  // JWT tokens
  Future<String?> getToken();
  Future<void> setToken(String token);
  Future<String?> getRefreshToken();
  Future<void> setRefreshToken(String token);
  Future<bool> getMustChangePassword();
  Future<void> setMustChangePassword(bool value);
  Future<void> clearTokens();

  // Cached user info
  Future<String?> getPhoneNumber();
  Future<void> setPhoneNumber(String phone);
  Future<String?> getFirstName();
  Future<void> setFirstName(String name);
  Future<String?> getLastName();
  Future<void> setLastName(String name);

  // Addresses
  Future<List<Map<String, dynamic>>> getAddresses();
  Future<void> setAddresses(List<Map<String, dynamic>> addresses);

  // Locale
  String getLocale();
  Future<void> setLocale(String lang);

  // Clears all user-specific cached data (call on login/register before writing new session)
  Future<void> clearUserCache();

  // Onboarding
  Future<bool> isOnboardingDone();
  Future<void> setOnboardingDone();
}

@LazySingleton(as: LocalStorage)
class LocalStorageImpl implements LocalStorage {
  const LocalStorageImpl(this._storage);
  final SharedPreferences _storage;

  static const _apiKeyKey = 'apiKey';
  static const _tokenKey = 'jwt_token';
  static const _refreshTokenKey = 'jwt_refresh_token';
  static const _mustChangePasswordKey = 'must_change_password';
  static const _phoneKey = 'user_phone';
  static const _firstNameKey = 'user_first_name';
  static const _lastNameKey = 'user_last_name';
  static const _addressesKey = 'user_addresses';
  static const _localeKey = 'app_locale';
  static const _onboardingKey = 'onboarding_done';

  @override
  Future<String?> getApiKey() =>
      Future.value(_storage.getString(_apiKeyKey));

  @override
  Future<void> setApiKey(String apiKey) async =>
      _storage.setString(_apiKeyKey, apiKey);

  @override
  Future<String?> getToken() =>
      Future.value(_storage.getString(_tokenKey));

  @override
  Future<void> setToken(String token) async =>
      _storage.setString(_tokenKey, token);

  @override
  Future<String?> getRefreshToken() =>
      Future.value(_storage.getString(_refreshTokenKey));

  @override
  Future<void> setRefreshToken(String token) async =>
      _storage.setString(_refreshTokenKey, token);

  @override
  Future<bool> getMustChangePassword() =>
      Future.value(_storage.getBool(_mustChangePasswordKey) ?? false);

  @override
  Future<void> setMustChangePassword(bool value) async =>
      _storage.setBool(_mustChangePasswordKey, value);

  @override
  Future<void> clearTokens() async {
    await _storage.remove(_tokenKey);
    await _storage.remove(_refreshTokenKey);
    await _storage.remove(_mustChangePasswordKey);
  }

  @override
  Future<String?> getPhoneNumber() =>
      Future.value(_storage.getString(_phoneKey));

  @override
  Future<void> setPhoneNumber(String phone) async =>
      _storage.setString(_phoneKey, phone);

  @override
  Future<String?> getFirstName() =>
      Future.value(_storage.getString(_firstNameKey));

  @override
  Future<void> setFirstName(String name) async =>
      _storage.setString(_firstNameKey, name);

  @override
  Future<String?> getLastName() =>
      Future.value(_storage.getString(_lastNameKey));

  @override
  Future<void> setLastName(String name) async =>
      _storage.setString(_lastNameKey, name);

  @override
  Future<List<Map<String, dynamic>>> getAddresses() {
    final raw = _storage.getString(_addressesKey);
    if (raw == null) return Future.value([]);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return Future.value(
      decoded.cast<Map<String, dynamic>>(),
    );
  }

  @override
  Future<void> setAddresses(List<Map<String, dynamic>> addresses) async =>
      _storage.setString(_addressesKey, jsonEncode(addresses));

  @override
  Future<void> clearUserCache() async {
    await _storage.remove(_phoneKey);
    await _storage.remove(_firstNameKey);
    await _storage.remove(_lastNameKey);
    await _storage.remove(_addressesKey);
  }

  @override
  String getLocale() => _storage.getString(_localeKey) ?? 'fr';

  @override
  Future<void> setLocale(String lang) async =>
      _storage.setString(_localeKey, lang);

  @override
  Future<bool> isOnboardingDone() =>
      Future.value(_storage.getBool(_onboardingKey) ?? false);

  @override
  Future<void> setOnboardingDone() async =>
      _storage.setBool(_onboardingKey, true);
}
