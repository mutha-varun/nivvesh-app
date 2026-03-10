import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException(
    this.message, {
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'AppException: $message';
}

class ApiResponseHandler {
  static const Map<int, String> defaultMessages = {
    400: 'Bad request or invalid parameters.',
    401: 'Unauthorized: Invalid credentials or token.',
    403: 'Forbidden: You do not have permission.',
    404: 'Resource not found.',
    409: 'Conflict: The resource already exists.',
    500: 'Server error. Please try again later.',
  };

  static String _extractMessage(http.Response response, String fallback) {
    try {
      final body = json.decode(response.body);
      if (body is Map<String, dynamic> && body['message'] != null) {
        return body['message'] as String;
      }
    } catch (_) {}
    return fallback;
  }

// TODOYash: have to check how server sends error responses

  /// Handles HTTP error responses with optional custom messages per status code
  ///
  /// [response] - The HTTP response object
  /// [customMessages] - Optional map to override default error messages for specific status codes
  /// Example: {404: 'Phone number not found', 400: 'Invalid phone format'}
  static Never handleErrorResponse(
    http.Response response, {
    Map<int, String>? customMessages,
  }) {
    final statusCode = response.statusCode;

    final message = customMessages?[statusCode] ??
        defaultMessages[statusCode] ??
        _extractMessage(response, 'Unexpected error occurred (Code: $statusCode)');

    throw AppException(
      message,
      code: statusCode.toString(),
    );
  }
}

Future<T> safeCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on SocketException {
    throw AppException('No internet connection. Please check your network.');
  } on http.ClientException {
    throw AppException('Could not connect to the server. Please try again later.');
  } on AppException {
    rethrow;
  } catch (e) {
    throw AppException('An unexpected error occurred: $e');
  }
}