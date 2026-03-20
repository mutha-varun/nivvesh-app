import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/mobile/core/constants/payment_category.dart';
import 'package:nivvesh/mobile/domain/models/finance_model.dart';
import 'package:nivvesh/mobile/presentation/shared/themes/colors.dart';
import 'package:nivvesh/mobile/presentation/spend/spend_provider.dart';
import 'package:nivvesh/mobile/presentation/spend/widget/spend_widgets.dart';

class FinanceSheet extends ConsumerWidget {
  const FinanceSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(financeControllerProvider);
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          AppBar(onRefresh: ctrl.fetchMessages, isLoading: ctrl.isLoading),
          if (ctrl.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (ctrl.error != null)
            SliverFillRemaining(
              child: ErrorState(ctrl.error!, ctrl.fetchMessages),
            )
          else if (ctrl.messages.isEmpty)
            const SliverFillRemaining(child: EmptyState())
          else ...[
            SummaryBar(messages: ctrl.messages),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList.separated(
                itemCount: ctrl.messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) => TransactionCard(ctrl.messages[i]),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: ctrl.isLoading
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.of(context).onAccentContainer,
              foregroundColor: AppColors.of(context).accentText,
              onPressed: ctrl.fetchMessages,
              icon: const Icon(Icons.sync_rounded),
              label: const Text('Sync'),
            ),
    );
  }
}

