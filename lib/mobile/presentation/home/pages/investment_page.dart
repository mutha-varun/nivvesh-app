import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nivvesh/mobile/data/providers/auth_state_provider.dart';
import 'package:nivvesh/webview/screens/bank_inappWebView.dart';

class InvestmentPage extends ConsumerWidget {
  const InvestmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final redirectUrl = ref.watch(authRedirectUrlProvider);

    if (redirectUrl == null || redirectUrl.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Investment')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Investment link is not available yet. Please complete login again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return InAppWebViewScreen(
      url: redirectUrl,
      title: 'Investment',
    );
  }
}
