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
    this.model = 'gemini-2.5-flash',
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _client;

  @override
  Future<String> generate(
    String prompt, {
    required List<ChatMessage> history,
    String? systemInstruction,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final contents = <Map<String, dynamic>>[
      for (final m in history)
        {
          'role': m.role == ChatRole.user ? 'user' : 'model',
          'parts': [
            {'text': m.text},
          ],
        },
      {
        'role': 'user',
        'parts': [
          {'text': prompt},
        ],
      },
    ];

    final body = <String, dynamic>{
      'contents': contents,
      if (systemInstruction != null && systemInstruction.isNotEmpty)
        'system_instruction': {
          'parts': [
            {'text': systemInstruction},
          ],
        },
    };

    final encodedBody = jsonEncode(body);
    _logLong('--- Gemini request → $uri ---');
    _logLong(const JsonEncoder.withIndent('  ').convert(body));
    _logLong('--- end Gemini request ---');

    final res = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: encodedBody,
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

/// `debugPrint` truncates long lines on Android. Split into ~800-char chunks
/// and print sequentially so the whole payload reaches the terminal.
void _logLong(String s) {
  const chunk = 800;
  for (var i = 0; i < s.length; i += chunk) {
    final end = (i + chunk < s.length) ? i + chunk : s.length;
    // ignore: avoid_print
    print(s.substring(i, end));
  }
}
