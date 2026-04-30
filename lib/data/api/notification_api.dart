import 'package:nivvesh/data/api/api_client.dart';

class NotificationApi extends ApiClient {
  /// GET /notifications?phone=...&page=&per_page=
  Uri listNotifications({
    required String phone,
    int page = 1,
    int perPage = 20,
  }) => buildUri(
    endpoint: 'notifications',
    queryParameters: {
      'phone': phone,
      'page': page.toString(),
      'per_page': perPage.toString(),
    },
  );

  /// POST /notifications/{id}/read
  Uri markRead(int notificationId) =>
      buildUri(endpoint: 'notifications/$notificationId/read');
}
