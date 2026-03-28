import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._storage);
  
  final FlutterSecureStorage _storage;
  static const _refreshTokenKey = 'refreshToken';
  static const _accessTokenKey = 'accessToken';
  static const _phoneNumberKey = 'phoneNumber';
  static const _redirectUrlKey = 'redirectUrl';

  Future<void> saveAuthToken(String accessToken, String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  Future<void> updateAccessToken(String accessToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  Future<void> deleteRefreshtoken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> deleteAllTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _redirectUrlKey);
  }

  Future<void> savePhoneNumber(String phoneNumber) async {
    await _storage.write(key: _phoneNumberKey, value: phoneNumber);
  }

  Future<String?> getPhoneNumber() async {
    return await _storage.read(key: _phoneNumberKey);
  }

  Future<void> deletePhoneNumber() async {
    await _storage.delete(key: _phoneNumberKey);
  }

  Future<void> saveRedirectUrl(String redirectUrl) async {
    await _storage.write(key: _redirectUrlKey, value: redirectUrl);
  }

  Future<String?> getRedirectUrl() async {
    return await _storage.read(key: _redirectUrlKey);
  }

  Future<void> deleteRedirectUrl() async {
    await _storage.delete(key: _redirectUrlKey);
  }
}