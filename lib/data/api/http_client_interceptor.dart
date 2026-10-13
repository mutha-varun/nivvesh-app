import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/auth/auth_provider.dart';

/// Provides an HTTP client with automatic authentication handling.
///
/// Automatically adds auth tokens to requests and handles token refresh
/// when receiving 401 responses.
final httpClientProvider = Provider<HttpClientInterceptor>((ref) {
  return HttpClientInterceptor(ref);
});

/// HTTP client interceptor that handles authentication automatically.
///
/// Adds access tokens to all requests and automatically refreshes
/// expired tokens when receiving 401 responses, then retries the request.
class HttpClientInterceptor extends http.BaseClient {
  final Ref _ref;
  final http.Client _inner = http.Client();

  HttpClientInterceptor(this._ref);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final localDataSource = _ref.read(authLocalDataSourceProvider);
    final accessToken = await localDataSource.getAccessToken();
    final refreshToken = await localDataSource.getRefreshToken();

    if (accessToken != null) {
      request.headers['Authorization'] = accessToken;
    }
    if (refreshToken != null) {
      request.headers['refresh-token'] = refreshToken;
    }
    request.headers['ngrok-skip-browser-warning'] = 'true';

    final response = await _inner.send(request);

    if (response.statusCode == 401) {
      try {
        final newAccessToken = await _refreshToken();

        if (newAccessToken != null) {
          final newHeaders = Map<String, String>.from(request.headers);
          newHeaders['Authorization'] = newAccessToken;
          
          final newRequest = http.Request(request.method, request.url)
            ..headers.addAll(newHeaders)
            ..bodyBytes = (request is http.Request) ? request.bodyBytes : await request.finalize().toBytes();
          
          return _inner.send(newRequest);
        }
      } catch (e) {
        // If refresh fails, log the user out
        // _ref.read(authServiceProvider).signOut();
      }
    }

    return response;
  }

  /// Calls the backend to get a new access token.
  Future<String?> _refreshToken() async {
    final localDataSource = _ref.read(authLocalDataSourceProvider);
    final refreshToken = await localDataSource.getRefreshToken();

    if (refreshToken == null) return null;

    final uri = _ref.read(authApiProvider).refreshToken(); 
    final response = await _inner.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'refresh-token': refreshToken,
      },
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final nestedData = data['data'];
      final newAccessToken = nestedData is Map<String, dynamic>
          ? nestedData['accessToken'] as String?
          : data['accessToken'] as String?;
      final newRefreshToken = response.headers['refresh-token'] ??
          (nestedData is Map<String, dynamic> ? nestedData['refreshToken'] as String? : null) ??
          data['refreshToken'] as String?;

      if (newAccessToken == null || newRefreshToken == null) {
        throw Exception('Token refresh response did not include required tokens.');
      }

      await localDataSource.saveAuthToken(newAccessToken, newRefreshToken);
      return newAccessToken;
    } else {

      throw Exception('Failed to refresh token');
    }
  }
}