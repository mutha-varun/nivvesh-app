import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/presentation/home/widgets/home_balance_card.dart';
import 'package:nivvesh/presentation/home/widgets/home_cashflow_card.dart';
import 'package:nivvesh/presentation/home/widgets/home_fd_comparison.dart';
import 'package:nivvesh/presentation/home/widgets/home_header.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                const [
                  HomeHeader(),
                  SizedBox(height: 20),
                  HomeBalanceCard(),
                  SizedBox(height: 20),
                  HomeCashflowCard(),
                  SizedBox(height: 20),
                  HomeFdComparison(),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
