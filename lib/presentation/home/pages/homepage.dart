import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/presentation/home/widgets/home_balance_card.dart';
import 'package:nivvesh/presentation/home/widgets/home_cashflow_card.dart';
import 'package:nivvesh/presentation/home/widgets/home_header.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/bank'),
        icon: Icon(Icons.account_balance, color: c.primaryText),
        label: Text(
          'FDs',
          style: TextStyle(
            color: c.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: c.surfaceTintLow,
        foregroundColor: c.primaryText,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
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
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
