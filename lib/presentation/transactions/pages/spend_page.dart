import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/transactions/filter_provider.dart';
import 'package:nivvesh/application/transactions/spend_provider.dart';
import 'package:nivvesh/application/transactions/filter_finance_provider.dart';
import 'package:nivvesh/presentation/transactions/widgets/spend_widgets.dart';
import 'package:nivvesh/presentation/transactions/widgets/spend_chart.dart';

class FinanceSheet extends ConsumerWidget {
  const FinanceSheet({super.key});
  static const _luxBg = Color(0xFF000000);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(financeControllerProvider);
    final filtered = ref.watch(filteredFinanceProvider);
    final filterState = ref.watch(filterProvider);
    return Scaffold(
      backgroundColor: _luxBg,
      body: CustomScrollView(
        slivers: [
          AppBar(
            onRefresh: ctrl.fetchMessages,
            isLoading: ctrl.isLoading,
            onFilterTap: () => _openTopFilters(context),
          ),
          if (ctrl.error != null)
            SliverFillRemaining(
              child: ErrorState(ctrl.error!, ctrl.fetchMessages),
            )
          else if (ctrl.messages.isEmpty)
            const SliverFillRemaining(child: EmptyState())
          else ...[
            SummaryBar(messages: filtered.filteredTransactions),
            const SpendChart(),
            const FilterToolbar(),
            if (filtered.filteredTransactions.isEmpty)
              const SliverFillRemaining(child: EmptyState())
            else if (filterState.grouping == GroupingType.category)
              CategoryGroupsSliver(groups: filtered.categoryGroups)
            else
              PeriodSummarySliver(aggregates: filtered.periodAggregates),
          ],
        ],
      ),
    );
  }

  void _openTopFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TopFilterSheet(),
    );
  }
}

