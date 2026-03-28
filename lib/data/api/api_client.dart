import 'package:nivvesh/data/api/server_api.dart';

/// Base class for all API clients.
///
/// Provides common URI building functionality for making HTTP requests
/// to the backend API. All specific API clients extend this class.
abstract class ApiClient {
  /// Builds a URI for the given endpoint with optional query parameters.
  ///
  /// Uses HTTPS scheme and the configured [apiBaseUrl] host.
  Uri buildUri({
    required String endpoint,
    Map<String, String>? queryParameters,
  }) {
    return Uri(
      scheme: "https",
      host: apiBaseUrl,
      path: endpoint,
      queryParameters: queryParameters,
    );
  }
}