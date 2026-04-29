import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nivvesh/application/transactions/local_notification_routes.dart';
import 'package:nivvesh/core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.surfaceTintHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, color: c.primaryText, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning,',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: c.secondaryText,
                      ),
                ),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: c.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          _TestNotifButton(colors: c),
          const SizedBox(width: 8),
          _BellButton(colors: c),
        ],
      ),
    );
  }
}

class _TestNotifButton extends StatelessWidget {
  const _TestNotifButton({required this.colors});

  final AppColorsBase colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async => showAiRedirectTestNotification(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colors.surfaceTintHigh,
          shape: BoxShape.circle,
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Icon(
          Icons.bolt_rounded,
          color: colors.muted,
          size: 16,
        ),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.colors});

  final AppColorsBase colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/alerts'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.surfaceTintHigh,
          shape: BoxShape.circle,
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(
                Icons.notifications_none_rounded,
                color: colors.primaryText,
              ),
            ),
            // TODO(home-alerts): replace always-on dot with provider-backed pending alert state.
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.expenseNegative,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
