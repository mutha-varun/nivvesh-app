import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nivvesh/mobile/data/api/auth_api.dart';
import 'package:nivvesh/mobile/data/cache/auth.dart';
import 'package:nivvesh/mobile/data/providers/auth_provider.dart';
import 'package:nivvesh/mobile/domain/models/requests/login_model.dart';
import 'package:nivvesh/mobile/domain/models/requests/otp_model.dart';

/// Response model for OTP operations


/// Repository for handling authentication operations
/// Manages API calls and local data caching
class AuthRepository {
  AuthRepository({
    required this.localDataSource,
    required this.httpClient,
    required this.api,
  });

  final AuthLocalDataSource localDataSource;
  final http.Client httpClient;
  final AuthApi api;

  /// Sends OTP to the provided phone number
  /// 
  /// [phone] - Phone number without country code (e.g., '9876543210')
  /// Returns the formatted phone with country code (e.g., '+919876543210')
  Future<String> sendOtp(String phone) async {
    try {
      final formattedPhone = '+91$phone';
      final uri = api.sendOtp();
      final headers = {'Content-Type': 'application/json'};

      final response = await httpClient.post(
        uri,
        headers: headers,
        body: jsonEncode({'phone': formattedPhone}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send OTP: ${response.statusCode}');
      }

      // Cache the phone number and login timestamp
      await localDataSource.cachePhoneNumber(formattedPhone);
      await localDataSource.cacheLoginTimestamp();

      return formattedPhone;
    } catch (e) {
      rethrow;
    }
  }

  /// Verifies the OTP sent to the phone number
  /// 
  /// [phone] - Phone number in format +91XXXXXXXXXX
  /// [otp] - The OTP code
  /// Returns [OtpResponseData] with server response message and redirect URL
  Future<OtpResponseData> verifyOtp(String phone, String otp) async {
    try {
      final uri = api.verifyOtp();
      final headers = {'Content-Type': 'application/json'};
      
      final authUser = AuthUser(phone: phone, otp: otp);

      final response = await httpClient.post(
        uri,
        headers: headers,
        body: jsonEncode(authUser.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return OtpResponseData.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to verify OTP: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Re-authenticates user using cached phone number
  /// Typically used when session expires
  /// 
  /// Returns [OtpResponseData] with server response message and redirect URL
  /// Throws exception if no cached phone number found
  Future<OtpResponseData> relogin() async {
    try {
      final cachedPhone = await localDataSource.getPhoneNumber();
      
      if (cachedPhone == null || cachedPhone.isEmpty) {
        throw Exception('No cached phone number found. Please log in again.');
      }

      final uri = api.refreshToken();
      final headers = {'Content-Type': 'application/json'};

      final response = await httpClient.post(
        uri,
        headers: headers,
        body: jsonEncode({'phone': cachedPhone}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return OtpResponseData.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to re-login: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}