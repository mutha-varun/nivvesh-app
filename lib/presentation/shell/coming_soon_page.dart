import 'package:flutter/material.dart';
import 'package:nivvesh/core/theme/app_colors.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({required this.tabName, super.key});

  final String tabName;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 48,
              color: c.borderSubtle,
            ),
            const SizedBox(height: 14),
            Text(
              tabName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: c.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Coming soon',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: c.secondaryText,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
