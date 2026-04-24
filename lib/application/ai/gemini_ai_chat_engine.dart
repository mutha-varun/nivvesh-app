import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_chat_controller.dart';

/// Gemini REST-backed engine. Uses the `generativelanguage.googleapis.com`
/// endpoint with a plain API key — no extra SDK needed on top of `http`.
///
/// Pass the key at build/run time:
///   flutter run --dart-define=GEMINI_API_KEY=xxxx
class GeminiAiChatEngine implements AiChatEngine {
  GeminiAiChatEngine({
    required this.apiKey,
    this.model = 'gemini-2.0-flash',
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _client;

  @override
  Future<String> generate(
    String prompt, {
    required List<ChatMessage> history,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
    });

    final res = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Gemini API ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini API returned no candidates: ${res.body}');
    }
    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      throw Exception('Gemini API returned empty content: ${res.body}');
    }
    final text = parts
        .map((p) => (p as Map<String, dynamic>)['text'] as String? ?? '')
        .join();
    return text.trim();
  }
}
