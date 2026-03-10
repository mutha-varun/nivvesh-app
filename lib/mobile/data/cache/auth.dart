import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSource({required this.sharedPreferences});

  static const String _phoneNumberKey = 'phoneNumber';
  static const String _loginTimestampKey = 'loginTimestamp';

  Future<void> cachePhoneNumber(String phone) async {
    await sharedPreferences.setString(_phoneNumberKey, phone);
  }

  Future<void> cacheLoginTimestamp() async {
    await sharedPreferences.setString(
      _loginTimestampKey,
      DateTime.now().toIso8601String(),
    );
  }

  Future<String?> getPhoneNumber() async {
    return sharedPreferences.getString(_phoneNumberKey);
  }

  Future<void> clearCache() async {
    await Future.wait([
      sharedPreferences.remove(_phoneNumberKey),
      sharedPreferences.remove(_loginTimestampKey),
    ]);
  }
}