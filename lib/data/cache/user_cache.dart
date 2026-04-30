import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserLocalDataSource {
  UserLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;
  static const _fcmTokenKey = 'fcmToken';

  Future<void> saveFcmToken(String token) async {
    await _storage.write(key: _fcmTokenKey, value: token);
  }

  Future<String?> getFcmToken() async {
    return await _storage.read(key: _fcmTokenKey);
  }

  Future<void> deleteFcmToken() async {
    await _storage.delete(key: _fcmTokenKey);
  }
}
