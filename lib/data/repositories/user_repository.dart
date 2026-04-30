import 'dart:convert';

import 'package:nivvesh/data/api/http_client_interceptor.dart';
import 'package:nivvesh/data/api/user_api.dart';
import 'package:nivvesh/data/cache/user_cache.dart';
import 'package:nivvesh/data/repositories/api_response_handler.dart';
import 'package:nivvesh/domain/models/requests/fcm_token_model.dart';

/// Repository for user-related operations (FCM token sync, profile, etc.).
class UserRepository {
  UserRepository({
    required this.localDataSource,
    required this.httpClient,
    required this.api,
  });

  final UserLocalDataSource localDataSource;
  final HttpClientInterceptor httpClient;
  final UserApi api;

  /// Pushes the device's FCM token to the backend and caches it locally.
  ///
  /// Skips the network call if [token] matches the cached token, since the
  /// backend already has it. Returns true when a sync actually happened.
  Future<bool> updateFcmToken({
    required String phone,
    required String token,
    required String platform,
  }) => safeCall(() async {
    final cached = await localDataSource.getFcmToken();
    if (cached == token) return false;

    final uri = api.updateFcmToken();
    final headers = {'Content-Type': 'application/json'};
    final body = FcmTokenRequest(
      phone: phone,
      fcmToken: token,
      platform: platform,
    ).toJson();

    final response = await httpClient.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      return ApiResponseHandler.handleErrorResponse(response);
    }

    await localDataSource.saveFcmToken(token);
    return true;
  });
}
