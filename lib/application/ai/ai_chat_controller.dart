import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_chat_controller.g.dart';

enum ChatRole { user, assistant }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    this.isPending = false,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime timestamp;
  final bool isPending;

  ChatMessage copyWith({String? text, bool? isPending}) => ChatMessage(
        id: id,
        role: role,
        text: text ?? this.text,
        timestamp: timestamp,
        isPending: isPending ?? this.isPending,
      );
}

/// Pluggable inference backend. Swap [StubAiChatEngine] with a tflite-backed
/// implementation by overriding [aiChatEngineProvider] in `main.dart`.
abstract class AiChatEngine {
  Future<String> generate(String prompt, {required List<ChatMessage> history});
}

class StubAiChatEngine implements AiChatEngine {
  @override
  Future<String> generate(
    String prompt, {
    required List<ChatMessage> history,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return "I'm a placeholder reply. Your on-device tflite model will answer here once wired in.";
  }
}

final aiChatEngineProvider = Provider<AiChatEngine>((_) => StubAiChatEngine());

@riverpod
class AiChatController extends _$AiChatController {
  @override
  List<ChatMessage> build() => const [];

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    final userMsg = ChatMessage(
      id: 'u-${now.microsecondsSinceEpoch}',
      role: ChatRole.user,
      text: trimmed,
      timestamp: now,
    );
    final pendingId = 'a-${now.microsecondsSinceEpoch}';
    final pendingMsg = ChatMessage(
      id: pendingId,
      role: ChatRole.assistant,
      text: '',
      timestamp: now,
      isPending: true,
    );

    state = [...state, userMsg, pendingMsg];

    try {
      final engine = ref.read(aiChatEngineProvider);
      final reply = await engine.generate(trimmed, history: state);
      state = [
        for (final m in state)
          if (m.id == pendingId)
            m.copyWith(text: reply, isPending: false)
          else
            m,
      ];
    } catch (e, st) {
      debugPrint('AI chat engine failed: $e\n$st');
      state = [
        for (final m in state)
          if (m.id == pendingId)
            m.copyWith(
              text: 'Something went wrong: $e',
              isPending: false,
            )
          else
            m,
      ];
    }
  }

  void clear() => state = const [];
}
