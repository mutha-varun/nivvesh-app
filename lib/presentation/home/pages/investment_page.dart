import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nivvesh/application/auth/auth_state_provider.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/webview/screens/bank_inappWebView.dart';

class InvestmentPage extends ConsumerWidget {
  const InvestmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final redirectUrl = ref.watch(authRedirectUrlProvider);
    final c = AppColors.of(context);

    if (redirectUrl == null || redirectUrl.isEmpty) {
      return Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          backgroundColor: c.background,
          title: Text(
            'Investment',
            style: TextStyle(color: c.gold, fontWeight: FontWeight.w600),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Investment link is not available yet. Please complete login again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: c.cardSurface,
                    side: BorderSide(color: c.gold.withValues(alpha: 0.30)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => context.push('/login'),
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
