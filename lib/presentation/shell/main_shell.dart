import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nivvesh/core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _NivveshBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _NivveshBottomNav extends StatelessWidget {
  const _NivveshBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    const items = <({IconData icon, String label})>[
      (icon: Icons.home_outlined, label: 'Home'),
      (icon: Icons.history_rounded, label: 'History'),
      (icon: Icons.auto_awesome_rounded, label: 'AI'),
      (icon: Icons.map_outlined, label: 'Journey'),
      (icon: Icons.notifications_none_rounded, label: 'Alerts'),
    ];

    return SafeArea(
      top: false,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.surfaceTintHigh,
              border: Border(top: BorderSide(color: c.borderSubtle)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final active = currentIndex == index;
                  final color = active ? c.accentPrimary : c.muted;

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onTap(index),
                    child: Container(
                      width: 64,
                      height: 48,
                      decoration: BoxDecoration(
                        color: active ? c.accentTint10 : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item.icon, size: 20, color: color),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
