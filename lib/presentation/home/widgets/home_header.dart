import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/presentation/home/widgets/home_cashflow_card.dart';
import 'package:nivvesh/presentation/notifications/notifications_page.dart';

class HomeHeader extends StatelessWidget {
  HomeHeader({super.key});

  final _easterEgg = EasterEggController();

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
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _easterEgg.registerTap,
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
          ),
          CashNoif(
            controller: _easterEgg,
            child: const NotificationBell(),
          ),
        ],
      ),
    );
  }
}

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return GestureDetector(
      onTap: () => context.push('/notifications'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: c.surfaceTintHigh,
          shape: BoxShape.circle,
          border: Border.all(color: c.borderSubtle),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.notifications_none_rounded,
                color: c.primaryText,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: c.expenseNegative,
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