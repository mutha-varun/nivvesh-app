import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/ai/ai_chat_controller.dart';
import 'package:nivvesh/core/theme/app_colors.dart';

const Color _accent = Color(0xFF7C5CFF);
const Color _accentSoft = Color(0x337C5CFF);

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _handleSend() async {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    _inputController.clear();
    await ref.read(aiChatControllerProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  Future<void> _handlePromptTap(String text) async {
    _inputController.text = text;
    await _handleSend();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final messages = ref.watch(aiChatControllerProvider);

    ref.listen<List<ChatMessage>>(aiChatControllerProvider, (prev, next) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            _ChatHeader(c: c),
            Expanded(
              child: messages.isEmpty
                  ? _HomeView(c: c, onPromptTap: _handlePromptTap)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      itemCount: messages.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _MessageBubble(message: messages[i], c: c),
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 12 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: _ChatInputBar(
                controller: _inputController,
                focusNode: _focusNode,
                onSend: _handleSend,
                c: c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends ConsumerWidget {
  const _ChatHeader({required this.c});

  final AppColorsBase c;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accent.withValues(alpha: 0.4)),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: _accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: c.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  'Ask about your money',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: c.secondaryText),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                ref.read(aiChatControllerProvider.notifier).clear(),
            icon: Icon(
              Icons.refresh_rounded,
              color: c.secondaryText,
              size: 22,
            ),
            tooltip: 'Clear chat',
          ),
        ],
      ),
    );
  }
}

class _Prompt {
  const _Prompt(this.text, this.color);
  final String text;
  final Color color;
}

class _Feature {
  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.iconBg,
    required this.border,
    required this.prompts,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final Color iconBg;
  final Color border;
  final List<_Prompt> prompts;
}

const _features = <_Feature>[
  _Feature(
    icon: Icons.track_changes_rounded,
    title: 'Savings Goals',
    description: 'Plan and achieve your savings goals',
    iconColor: Color(0xFF22C55E),
    iconBg: Color(0x1A22C55E),
    border: Color(0x3322C55E),
    prompts: [
      _Prompt('How can I save for a car?', Color(0xFF4ADE80)),
      _Prompt('Best way to save for a phone?', Color(0xFF4ADE80)),
    ],
  ),
  _Feature(
    icon: Icons.credit_card_rounded,
    title: 'Spending Optimization',
    description: 'Understand and reduce unnecessary expenses',
    iconColor: Color(0xFF3B82F6),
    iconBg: Color(0x1A3B82F6),
    border: Color(0x333B82F6),
    prompts: [
      _Prompt('Where am I overspending?', Color(0xFF60A5FA)),
      _Prompt('How can I save more from my salary?', Color(0xFF60A5FA)),
    ],
  ),
  _Feature(
    icon: Icons.show_chart_rounded,
    title: 'Investment Tips',
    description: 'Smart investment strategies for growth',
    iconColor: Color(0xFFA855F7),
    iconBg: Color(0x1AA855F7),
    border: Color(0x33A855F7),
    prompts: [
      _Prompt('Should I invest in stocks?', Color(0xFFC084FC)),
      _Prompt('Best mutual funds for beginners?', Color(0xFFC084FC)),
    ],
  ),
  _Feature(
    icon: Icons.account_balance_wallet_rounded,
    title: 'Budget Planning',
    description: 'Create and maintain effective budgets',
    iconColor: Color(0xFFF59E0B),
    iconBg: Color(0x1AF59E0B),
    border: Color(0x33F59E0B),
    prompts: [
      _Prompt('Help me create a monthly budget', Color(0xFFFBBF24)),
      _Prompt('How to track daily expenses?', Color(0xFFFBBF24)),
    ],
  ),
];

class _HomeView extends StatelessWidget {
  const _HomeView({required this.c, required this.onPromptTap});

  final AppColorsBase c;
  final ValueChanged<String> onPromptTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        _Hero(c: c),
        const SizedBox(height: 20),
        _QuickInsightCard(c: c),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _FeatureCard(
                feature: _features[0],
                c: c,
                onPromptTap: onPromptTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                feature: _features[1],
                c: c,
                onPromptTap: onPromptTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _FeatureCard(
                feature: _features[2],
                c: c,
                onPromptTap: onPromptTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                feature: _features[3],
                c: c,
                onPromptTap: onPromptTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.c});

  final AppColorsBase c;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
            children: [
              TextSpan(
                text: 'Track smarter.\n',
                style: TextStyle(color: c.primaryText),
              ),
              const TextSpan(
                text: 'Save better. 🍃',
                style: TextStyle(color: Color(0xFF22C55E)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Your AI finance assistant is here to help you make better money decisions.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: c.secondaryText,
                ),
          ),
        ),
      ],
    );
  }
}

class _QuickInsightCard extends StatelessWidget {
  const _QuickInsightCard({required this.c});

  final AppColorsBase c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.surfaceTintMid,
            c.surfaceTintLow,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x3322C55E)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0x1A22C55E),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Color(0xFF22C55E),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✨ Quick Insight',
                  style: TextStyle(
                    color: Color(0xFF4ADE80),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You can save ₹2,000 this month',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: c.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'by reducing food delivery and subscriptions.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: c.secondaryText,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: c.secondaryText,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.feature,
    required this.c,
    required this.onPromptTap,
  });

  final _Feature feature;
  final AppColorsBase c;
  final ValueChanged<String> onPromptTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.surfaceTintMid, c.surfaceTintLow],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: feature.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: feature.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(feature.icon, color: feature.iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: TextStyle(
                        color: c.primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feature.description,
                      style: TextStyle(
                        color: c.secondaryText,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final p in feature.prompts)
            _PromptButton(prompt: p, onTap: () => onPromptTap(p.text)),
        ],
      ),
    );
  }
}

class _PromptButton extends StatelessWidget {
  const _PromptButton({required this.prompt, required this.onTap});

  final _Prompt prompt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                prompt.text,
                style: TextStyle(
                  color: prompt.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 14,
              color: prompt.color.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.c});

  final ChatMessage message;
  final AppColorsBase c;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final bubbleColor = isUser ? _accent : c.surfaceTintLow;
    final textColor = isUser ? Colors.white : c.primaryText;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final rowAlign =
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start;

    return Row(
      mainAxisAlignment: rowAlign,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isUser) ...[
          _AssistantAvatar(),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: align,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 18),
                  ),
                  border: isUser
                      ? null
                      : Border.all(color: c.borderSubtle),
                ),
                child: message.isPending
                    ? const _TypingDots()
                    : isUser
                        ? Text(
                            message.text,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: textColor, height: 1.35),
                          )
                        : MarkdownBody(
                            data: message.text,
                            styleSheet: _assistantMarkdownStyle(
                              context,
                              textColor,
                            ),
                          ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

MarkdownStyleSheet _assistantMarkdownStyle(BuildContext context, Color color) {
  final base = Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: color,
        height: 1.4,
      );
  return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
    p: base,
    listBullet: base,
    strong: base?.copyWith(fontWeight: FontWeight.w700),
    em: base?.copyWith(fontStyle: FontStyle.italic),
    h1: base?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
    h2: base?.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
    h3: base?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
    h4: base?.copyWith(fontWeight: FontWeight.w700),
    code: base?.copyWith(
      fontFamily: 'monospace',
      backgroundColor: color.withValues(alpha: 0.08),
    ),
    blockquote: base?.copyWith(fontStyle: FontStyle.italic),
    blockSpacing: 6,
    listIndent: 18,
  );
}

class _AssistantAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: _accentSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.auto_awesome, color: _accent, size: 16),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_ctrl.value + i * 0.2) % 1.0;
            final opacity = (0.3 + 0.7 * (1 - (t - 0.5).abs() * 2)).clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.c,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final AppColorsBase c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: c.surfaceTintLow,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: c.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.auto_awesome, color: _accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: TextStyle(color: c.primaryText, fontSize: 15),
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: 'Ask about your money...',
                hintStyle: TextStyle(
                  color: c.secondaryText,
                  fontSize: 15,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.mic_none_rounded, color: c.secondaryText),
            tooltip: 'Voice input',
          ),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: _accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
