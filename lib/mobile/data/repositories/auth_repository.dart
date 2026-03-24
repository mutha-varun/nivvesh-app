import 'dart:convert';
import 'package:nivvesh/mobile/data/api/auth_api.dart';
import 'package:nivvesh/mobile/data/api/http_client_interceptor.dart';
import 'package:nivvesh/mobile/data/cache/auth.dart';
import 'package:nivvesh/mobile/data/repositories/api_response_handler.dart';
import 'package:nivvesh/mobile/domain/models/requests/login_model.dart';
import 'package:nivvesh/mobile/domain/models/requests/otp_model.dart';

/// Repository for handling authentication operations
/// Manages API calls and local data caching
class AuthRepository {
  AuthRepository({
    required this.localDataSource,
    required this.httpClient,
    required this.api,
  });

  final AuthLocalDataSource localDataSource;
  final HttpClientInterceptor httpClient;
  final AuthApi api;

  /// Sends OTP to the provided phone number
  /// 
  /// [phone] - Phone number without country code (e.g., '9876543210')
  /// Returns the formatted phone with country code (e.g., '+919876543210')
  Future<String> sendOtp(String phone) => safeCall(() async {
    final formattedPhone = '+91$phone';
    final uri = api.sendOtp();
    final headers = {'Content-Type': 'application/json'};

    final response = await httpClient.post(
      uri,
      headers: headers,
      body: jsonEncode({'phone': formattedPhone}),
    );

    if (response.statusCode != 200) {
      return ApiResponseHandler.handleErrorResponse(response);
    }

    return formattedPhone;
  });

  /// Verifies the OTP sent to the phone number
  /// 
  /// [phone] - Phone number in format +91XXXXXXXXXX
  /// [otp] - The OTP code
  /// Returns [OtpResponseData] with server response message and redirect URL
  Future<OtpResponseData> verifyOtp(String phone, String otp) => safeCall(() async {
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

      final nestedData = jsonResponse['data'];
      final accessToken = nestedData is Map<String, dynamic>
          ? nestedData['accessToken'] as String?
          : (jsonResponse['accessToken'] as String? ?? response.headers['authorization']);
        final refreshToken = response.headers['refresh-token'] ?? response.headers['Refresh-Token'];

      if (accessToken != null && refreshToken != null) {
        await localDataSource.saveAuthToken(accessToken, refreshToken);
        await localDataSource.savePhoneNumber(phone);
      } else {
        throw AppException('Authentication tokens were not provided in the response.');
      }

      return OtpResponseData.fromJson(jsonResponse);
    } else {
      return ApiResponseHandler.handleErrorResponse(response);
    }
  });

  /// Re-authenticates user using cached phone number
  /// Typically used when session expires
  /// 
  /// Returns [OtpResponseData] with server response message and redirect URL
  Future<OtpResponseData> relogin() => safeCall(() async {
    final cachedPhone = await localDataSource.getPhoneNumber();

    if (cachedPhone == null || cachedPhone.isEmpty) {
      throw AppException('No cached phone number found. Please log in again.');
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
      return ApiResponseHandler.handleErrorResponse(response);
    }
  });
}