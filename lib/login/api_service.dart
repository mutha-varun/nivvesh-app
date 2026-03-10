import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'https://api.nivvesh.com';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  static Future<bool> sendOtp(String phone) async {
    final url = Uri.parse('$_baseUrl/send-otp');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'phone': phone}),
    );
    print("phoneNumber: $phone");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('phoneNumber', phone);
    sharedPreferences.setString(
        'loginTimestamp', DateTime.now().toIso8601String());
    return response.statusCode == 200;
  }

  static Future<VerifyOtpResponse?> verifyOtp(String phone, String otp) async {
    final url = Uri.parse('$_baseUrl/verify-otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return VerifyOtpResponse(
        message: data['message'] ?? '',
        redirectUrl: data['redirect_url'] ?? '',
      );
    } else {
      return null;
    }
  }

  static Future<VerifyOtpResponse?> relogin() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final phoneNumber = sharedPreferences.getString('phoneNumber');
    print("object");
    final url = Uri.parse('$_baseUrl/re-login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phoneNumber}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return VerifyOtpResponse(
        message: data['message'] ?? '',
        redirectUrl: data['redirect_url'] ?? '',
      );
    } else {
      return null;
    }
  }
}

class VerifyOtpResponse {
  final String message;
  final String redirectUrl;

  VerifyOtpResponse({required this.message, required this.redirectUrl});
}
