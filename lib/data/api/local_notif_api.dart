import 'package:nivvesh/data/api/api_client.dart';

class LocalNotifApi extends ApiClient {
  /// Returns URI for saving a local notification (POST /notif).
  Uri saveNotification() => buildUri(endpoint: 'notif');

  /// Returns URI for fetching local notifications (GET /notif).
  Uri getNotifications({
    required int page,
    required int perPage,
  }) =>
      buildUri(
        endpoint: 'notif',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
}