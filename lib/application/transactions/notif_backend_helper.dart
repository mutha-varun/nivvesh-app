import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:nivvesh/data/api/server_api.dart';

/// Best-effort POST to the backend to persist a notification record.
///
/// Reads the JWT from FlutterSecureStorage so it works both in the
/// foreground and in background isolates (telephony plugin callbacks).
/// Swallows all errors — notification delivery must not depend on this call.
Future<void> postNotificationToBackend({
  required String title,
  required String message,
}) async {
  try {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null || token.isEmpty) return;

    final uri = Uri(scheme: 'https', host: apiBaseUrl, path: 'notif');
    await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({'title': title, 'message': message}),
    );
  } catch (_) {
    // best-effort — don't let API failures break notification delivery
  }
}
