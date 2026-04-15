import 'dart:convert';

import 'package:nivvesh/data/api/http_client_interceptor.dart';
import 'package:nivvesh/data/api/local_notif_api.dart';
import 'package:nivvesh/data/cache/auth_cache.dart';
import 'package:nivvesh/data/repositories/api_response_handler.dart';
import 'package:nivvesh/domain/models/requests/local_noitfi.dart';

/// Repository for local notification APIs.
///
/// Uses authenticated HTTP client; backend resolves user identity from JWT.
class LocalNotifRepository {
	LocalNotifRepository({
		required this.httpClient,
		required this.api,
		required this.localDataSource,
	});

	final HttpClientInterceptor httpClient;
	final LocalNotifApi api;
	final AuthLocalDataSource localDataSource;

	Future<Map<String, String>> _buildAuthHeaders({
		Map<String, String>? base,
	}) async {
		final headers = <String, String>{...?base};
		final token = await localDataSource.getAccessToken();
		if (token != null && token.isNotEmpty) {
			headers['Authorization'] =
				token.startsWith('Bearer ') ? token : 'Bearer $token';
		}
		return headers;
	}

	/// Saves a local notification for the authenticated user.
	///
	/// Sends only title/message in body. user_id is resolved by backend token.
	Future<SaveLocalNotifResponse> saveLocalNotification(
		SaveLocalNotifRequest request,
	) =>
			safeCall(() async {
				final uri = api.saveNotification();
				final headers = await _buildAuthHeaders(
					base: {'Content-Type': 'application/json'},
				);

				final response = await httpClient.post(
					uri,
					headers: headers,
					body: jsonEncode(request.toJson()),
				);

				if (response.statusCode == 201) {
					final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
					return SaveLocalNotifResponse.fromJson(jsonResponse);
				}

				return ApiResponseHandler.handleErrorResponse(response);
			});

	/// Fetches authenticated user's local notifications with pagination.
	Future<LocalNotifListResponse> getLocalNotifications({
		int page = 1,
		int perPage = 20,
	}) =>
			safeCall(() async {
				final safePage = page < 1 ? 1 : page;
				final safePerPage = perPage.clamp(1, 100);
				final uri = api.getNotifications(page: safePage, perPage: safePerPage);
				final headers = await _buildAuthHeaders();

				final response = await httpClient.get(uri, headers: headers);

				if (response.statusCode == 200) {
					final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
					return LocalNotifListResponse.fromJson(jsonResponse);
				}

				return ApiResponseHandler.handleErrorResponse(response);
			});
}
