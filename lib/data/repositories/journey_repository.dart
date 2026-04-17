import 'dart:convert';

import 'package:nivvesh/data/api/http_client_interceptor.dart';
import 'package:nivvesh/data/api/journey.api.dart';
import 'package:nivvesh/data/cache/auth_cache.dart';
import 'package:nivvesh/data/repositories/api_response_handler.dart';
import 'package:nivvesh/domain/models/requests/journey.dart';

/// Repository for journey APIs.
///
/// Uses authenticated HTTP client; backend resolves user identity from JWT.
class JourneyRepository {
  JourneyRepository({
    required this.httpClient,
    required this.api,
    required this.localDataSource,
  });

  final HttpClientInterceptor httpClient;
  final JourneyApi api;
  final AuthLocalDataSource localDataSource;

  Future<Map<String, String>> _buildAuthHeaders({
    Map<String, String>? base,
  }) async {
    final headers = <String, String>{...?base};
    final token = await localDataSource.getAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = token.startsWith('Bearer ')
          ? token
          : 'Bearer $token';
    }
    return headers;
  }

  /// Fetches journeys for the authenticated user with pagination.
  Future<JourneyListResponse> getJourneys({
    int page = 1,
    int perPage = 20,
  }) => safeCall(() async {
    final safePage = page < 1 ? 1 : page;
    final safePerPage = perPage.clamp(1, 100).toInt();
    final uri = api.getJourneys(
      page: safePage,
      perPage: safePerPage,
    );
    final headers = await _buildAuthHeaders();

    final response = await httpClient.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return JourneyListResponse.fromJson(jsonResponse);
    }

    return ApiResponseHandler.handleErrorResponse(response);
  });

  /// Fetches a single journey by id.
  Future<JourneyDetailResponse> getJourneyById(int journeyId) => safeCall(
    () async {
      final uri = api.getJourneyById(journeyId);
      final headers = await _buildAuthHeaders();

      final response = await httpClient.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return JourneyDetailResponse.fromJson(jsonResponse);
      }

      return ApiResponseHandler.handleErrorResponse(response);
    },
  );

  /// Updates a journey by id.
  Future<JourneyActionResponse> updateJourneyById(
    int journeyId,
    JourneyUpdateRequest request,
  ) => safeCall(() async {
    final uri = api.updateJourneyById(journeyId);
    final headers = await _buildAuthHeaders(
      base: {'Content-Type': 'application/json'},
    );

    final response = await httpClient.put(
      uri,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return JourneyActionResponse.fromJson(jsonResponse);
    }

    return ApiResponseHandler.handleErrorResponse(response);
  });

  /// Creates a new journey.
  Future<JourneyActionResponse> createJourney(
    JourneyCreateRequest request,
  ) => safeCall(() async {
    final uri = api.createJourney();
    final headers = await _buildAuthHeaders(
      base: {'Content-Type': 'application/json'},
    );

    final response = await httpClient.post(
      uri,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return JourneyActionResponse.fromJson(jsonResponse);
    }

    return ApiResponseHandler.handleErrorResponse(response);
  });

  /// Deletes a journey by id.
  Future<JourneyActionResponse> deleteJourneyById(int journeyId) => safeCall(
    () async {
      final uri = api.deleteJourneyById(journeyId);
      final headers = await _buildAuthHeaders();

      final response = await httpClient.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return JourneyActionResponse.fromJson(jsonResponse);
      }

      return ApiResponseHandler.handleErrorResponse(response);
    },
  );
}
