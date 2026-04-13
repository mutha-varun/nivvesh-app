import 'dart:io';

import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/core/constants/payment_category.dart';
import 'package:nivvesh/application/transactions/filter_provider.dart';
import 'package:nivvesh/application/transactions/spend_provider.dart';
import 'package:nivvesh/application/transactions/filter_finance_provider.dart';
import 'package:nivvesh/application/transactions/alert_config.dart';
import 'package:nivvesh/application/transactions/search_provider.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/domain/models/finance_model.dart';
import 'package:nivvesh/presentation/transactions/widgets/spend_widgets.dart';
import 'package:nivvesh/presentation/transactions/widgets/spend_chart.dart';
import 'package:nivvesh/presentation/transactions/widgets/alert_config_sheet.dart';
import 'package:nivvesh/presentation/transactions/widgets/history_search_bar.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(financeControllerProvider);
    final filtered = ref.watch(filteredFinanceProvider);
    final filterState = ref.watch(filterProvider);
    final search = ref.watch(transactionSearchProvider);
    final searchResults = ref.watch(searchResultsProvider);
    ref.watch(alertConfigProvider);

    final typeFilteredTransactions =
      _applyTransactionType(filtered.filteredTransactions, filterState);
    final typeFilteredSearchResults =
      _applyTransactionType(searchResults, filterState);
    final typeFilteredCategoryGroups =
      _groupByCategory(typeFilteredTransactions);
    final typeFilteredPeriodAggregates =
      _aggregateByPeriod(typeFilteredTransactions, filterState.periodType);

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: CustomScrollView(
        slivers: [
          AppBar(
            onRefresh: Platform.isIOS ? ctrl.uploadPdf : ctrl.fetchMessages,
            isLoading: ctrl.isLoading,
            onAlertTap: () => _openAlertConfig(context),
            actionIcon: Platform.isIOS
                ? Icons.upload_file_rounded
                : Icons.refresh_rounded,
          ),
          if (ctrl.error != null && ctrl.needsPassword)
            SliverFillRemaining(
              child: _PasswordPrompt(
                onSubmit: (password) => ctrl.retryWithPassword(password),
              ),
            )
          else if (ctrl.error != null)
            SliverFillRemaining(
              child: ErrorState(
                ctrl.error!,
                Platform.isIOS ? ctrl.uploadPdf : ctrl.fetchMessages,
              ),
            )
          else if (ctrl.messages.isEmpty)
            const SliverFillRemaining(child: EmptyState())
          else ...[
            // Search bar sits above the chart — always visible
            const SliverToBoxAdapter(child: HistorySearchBar()),
            const TransactionTypeFilterBar(),
            const SpendChart(),
            const FilterToolbar(),
            // List area: search results take priority over filter views
            if (search.isActive) ...[
              if (typeFilteredSearchResults.isEmpty)
                const SliverFillRemaining(child: EmptyState())
              else
                AllTransactionsSliver(transactions: typeFilteredSearchResults),
            ] else if (typeFilteredTransactions.isEmpty)
              const SliverFillRemaining(child: EmptyState())
            else if (!filterState.hasNonDefaultGrouping && !filterState.hasNonDefaultDateRange && !filterState.hasCategories)
              AllTransactionsSliver(
                transactions: typeFilteredTransactions,
              )
            else if (filterState.grouping == GroupingType.category)
              CategoryGroupsSliver(groups: typeFilteredCategoryGroups)
            else
              PeriodSummarySliver(aggregates: typeFilteredPeriodAggregates),
          ],
        ],
      ),
    );
  }

  void _openAlertConfig(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AlertConfigSheet(),
    );
  }

}

List<FinanceModel> _applyTransactionType(
  List<FinanceModel> source,
  FinanceFilterState filter,
) {
  switch (filter.transactionType) {
    case TransactionType.all:
      return source;
    case TransactionType.income:
      return source
          .where((m) => m.category == PaymentCategories.creditCategory)
          .toList();
    case TransactionType.expenses:
      return source
          .where((m) => m.category != PaymentCategories.creditCategory)
          .toList();
  }
}

Map<String, List<FinanceModel>> _groupByCategory(List<FinanceModel> txns) {
  final categoryGroups = <String, List<FinanceModel>>{};
  for (final m in txns) {
    categoryGroups.putIfAbsent(m.category, () => []).add(m);
  }
  return categoryGroups;
}

List<PeriodAggregate> _aggregateByPeriod(
  List<FinanceModel> txns,
  PeriodType periodType,
) {
  final buckets = <String, _PeriodBucket>{};
  for (final m in txns) {
    final key = _periodKey(m.date, periodType);
    final bucket = buckets.putIfAbsent(
      key,
      () => _PeriodBucket(
        label: _periodLabel(m.date, periodType),
        periodStart: _computePeriodStart(m.date, periodType),
      ),
    );
    bucket.total += m.amount;
    bucket.count += 1;
  }

  final periodAggregates = buckets.entries
      .map((e) => PeriodAggregate(
            label: e.value.label,
            sortKey: e.key,
            total: e.value.total,
            count: e.value.count,
            periodStart: e.value.periodStart,
            periodEnd: _computePeriodEnd(e.value.periodStart, periodType),
          ))
      .toList()
    ..sort((a, b) => b.sortKey.compareTo(a.sortKey));

  return periodAggregates;
}

String _periodKey(DateTime date, PeriodType type) {
  switch (type) {
    case PeriodType.weekly:
      final week = ((date.day - 1) ~/ 7) + 1;
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-W$week';
    case PeriodType.monthly:
      return '${date.year}-${date.month.toString().padLeft(2, '0')}';
    case PeriodType.yearly:
      return '${date.year}';
  }
}

String _periodLabel(DateTime date, PeriodType type) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  switch (type) {
    case PeriodType.weekly:
      final week = ((date.day - 1) ~/ 7) + 1;
      return 'Week $week - ${months[date.month - 1]} ${date.year}';
    case PeriodType.monthly:
      return '${months[date.month - 1]} ${date.year}';
    case PeriodType.yearly:
      return '${date.year}';
  }
}

DateTime _computePeriodStart(DateTime date, PeriodType type) {
  switch (type) {
    case PeriodType.weekly:
      final startDay = ((date.day - 1) ~/ 7) * 7 + 1;
      return DateTime(date.year, date.month, startDay);
    case PeriodType.monthly:
      return DateTime(date.year, date.month, 1);
    case PeriodType.yearly:
      return DateTime(date.year, 1, 1);
  }
}

DateTime _computePeriodEnd(DateTime start, PeriodType type) {
  switch (type) {
    case PeriodType.weekly:
      final tentative =
          DateTime(start.year, start.month, start.day + 6, 23, 59, 59);
      final monthEnd = _lastDayOfMonthEnd(start.year, start.month);
      return tentative.isAfter(monthEnd) ? monthEnd : tentative;
    case PeriodType.monthly:
      return _lastDayOfMonthEnd(start.year, start.month);
    case PeriodType.yearly:
      return DateTime(start.year, 12, 31, 23, 59, 59);
  }
}

DateTime _lastDayOfMonthEnd(int year, int month) {
  final firstOfNext = DateTime(year, month + 1, 1);
  return firstOfNext.subtract(const Duration(seconds: 1));
}

class _PeriodBucket {
  final String label;
  final DateTime periodStart;
  double total = 0;
  int count = 0;

  _PeriodBucket({required this.label, required this.periodStart});
}

class _PasswordPrompt extends StatelessWidget {
  const _PasswordPrompt({required this.onSubmit});
  final void Function(String) onSubmit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 48, color: AppColors.of(context).accentPrimary),
            const SizedBox(height: 16),
            const Text(
              'Password Protected',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'This PDF requires a password to open.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showDialog(context),
              icon: const Icon(Icons.key_rounded),
              label: const Text('Enter Password'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.of(context).surfaceTintHigh,
        title: Text('Enter PDF Password',
            style: TextStyle(color: AppColors.of(context).primaryText)),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          style: TextStyle(color: AppColors.of(context).primaryText),
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: TextStyle(color: AppColors.of(context).muted),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.of(context).borderSubtle)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.of(context).accentPrimary)),
          ),
          onSubmitted: (value) {
            Navigator.pop(ctx);
            onSubmit(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onSubmit(controller.text);
            },
            child: Text('Open',
                style: TextStyle(color: AppColors.of(context).accentPrimary)),
          ),
        ],
      ),
    );
  }
}
