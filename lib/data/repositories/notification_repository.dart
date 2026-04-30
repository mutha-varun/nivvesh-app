import 'dart:convert';

import 'package:nivvesh/data/api/http_client_interceptor.dart';
import 'package:nivvesh/data/api/notification_api.dart';
import 'package:nivvesh/data/repositories/api_response_handler.dart';
import 'package:nivvesh/domain/models/notification_model.dart';

/// Repository for notification APIs.
class NotificationRepository {
  NotificationRepository({required this.httpClient, required this.api});

  final HttpClientInterceptor httpClient;
  final NotificationApi api;

  Future<NotificationListResponse> listNotifications({
    required String phone,
    int page = 1,
    int perPage = 20,
  }) => safeCall(() async {
    final uri = api.listNotifications(
      phone: phone,
      page: page,
      perPage: perPage,
    );
    final response = await httpClient.get(uri);
    if (response.statusCode == 200) {
      return NotificationListResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    return ApiResponseHandler.handleErrorResponse(response);
  });

  Future<void> markRead({required String phone, required int notificationId}) =>
      safeCall(() async {
        final uri = api.markRead(notificationId);
        final response = await httpClient.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': phone}),
        );
        if (response.statusCode != 200) {
          ApiResponseHandler.handleErrorResponse(response);
        }
      });
}
