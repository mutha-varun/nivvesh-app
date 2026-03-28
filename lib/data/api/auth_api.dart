import 'package:nivvesh/data/api/api_client.dart';

class AuthApi extends ApiClient {
  /// Returns URI for getting otp (POST /send-otp).
  Uri sendOtp() => buildUri(endpoint: "send-otp");

  /// Returns URI for verifying otp (POST /verify-otp).
  Uri verifyOtp() => buildUri(endpoint: "verify-otp");

  /// Returns URI for (POST /re-login).
  Uri refreshToken() => buildUri(endpoint: "re-login");
}