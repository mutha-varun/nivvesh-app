import 'dart:io';

import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/transactions/filter_provider.dart';
import 'package:nivvesh/application/transactions/spend_provider.dart';
import 'package:nivvesh/application/transactions/filter_finance_provider.dart';
import 'package:nivvesh/application/transactions/alert_config.dart';
import 'package:nivvesh/application/transactions/search_provider.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
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
            const SpendChart(),
            const FilterToolbar(),
            // List area: search results take priority over filter views
            if (search.isActive) ...[
              if (searchResults.isEmpty)
                const SliverFillRemaining(child: EmptyState())
              else
                AllTransactionsSliver(transactions: searchResults),
            ] else if (filtered.filteredTransactions.isEmpty)
              const SliverFillRemaining(child: EmptyState())
            else if (!filterState.hasAnyNonDefault)
              AllTransactionsSliver(
                transactions: filtered.filteredTransactions,
              )
            else if (filterState.grouping == GroupingType.category)
              CategoryGroupsSliver(groups: filtered.categoryGroups)
            else
              PeriodSummarySliver(aggregates: filtered.periodAggregates),
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
