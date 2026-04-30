import 'package:nivvesh/data/api/api_client.dart';

class UserApi extends ApiClient {
  /// Returns URI for updating the user's FCM token (POST /update-fcm-token).
  Uri updateFcmToken() => buildUri(endpoint: "update-fcm-token");
}
