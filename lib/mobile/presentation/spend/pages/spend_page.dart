import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/mobile/presentation/spend/filter_provider.dart';
import 'package:nivvesh/mobile/presentation/spend/spend_provider.dart';
import 'package:nivvesh/mobile/presentation/spend/widget/filtered_provider.dart';
import 'package:nivvesh/mobile/presentation/spend/widget/spend_widgets.dart';

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
            SummaryBar(messages: filtered.filteredTransactions),
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

