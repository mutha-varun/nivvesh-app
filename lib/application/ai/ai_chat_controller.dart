import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'finance_context_builder.dart';

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
  Future<String> generate(
    String prompt, {
    required List<ChatMessage> history,
    String? systemInstruction,
  });
}

class StubAiChatEngine implements AiChatEngine {
  @override
  Future<String> generate(
    String prompt, {
    required List<ChatMessage> history,
    String? systemInstruction,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return "I'm a placeholder reply. Your on-device tflite model will answer here once wired in.";
  }
}

const _financeSystemPrompt = '''
You are Nivvesh's in-app finance assistant. You ONLY answer questions related
to the user's personal finances: spending, saving, budgeting, transactions,
categories, bills, income, savings goals, and basic personal-finance education.

Rules:
- If a question is unrelated to personal finance, politely refuse in one short
  sentence and suggest a finance question they could ask instead.
- Use the FINANCE SNAPSHOT below as the source of truth for the user's data.
  It includes lifetime totals, a 12-month timeline, this/last month category
  breakdowns, recent transactions, and active savings goals. Never invent
  numbers. If the snapshot does not contain what the user asks about, say so.
- Match response length to the request:
    • Quick questions ("how much did I spend on food?") → 1–3 sentences.
    • Open prompts ("help me save more", "make me a plan") → use a structured
      breakdown with headings or bullets and go as deep as needed; offer to
      drill into any section further.
  When unsure, give a short answer first and end with one line offering more
  detail (e.g. "Want a month-by-month breakdown?").
- Use Indian Rupees (₹) and keep numbers consistent with the snapshot.
- Do not give regulated investment advice or recommend specific securities.
''';

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
      final context = ref.read(financeContextProvider);
      final systemInstruction =
          '$_financeSystemPrompt\n\n${context.render()}';
      final historyForEngine = state
          .where((m) => m.id != pendingId && m.id != userMsg.id && !m.isPending)
          .toList();
      final reply = await engine.generate(
        trimmed,
        history: historyForEngine,
        systemInstruction: systemInstruction,
      );
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
