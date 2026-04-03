import 'dart:io';

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
            onRefresh: Platform.isIOS ? ctrl.uploadPdf : ctrl.fetchMessages,
            isLoading: ctrl.isLoading,
            onFilterTap: () => _openTopFilters(context),
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
            const Icon(Icons.lock_outline_rounded, size: 48, color: Color(0xFFFFD700)),
            const SizedBox(height: 16),
            const Text(
              'Password Protected',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'This PDF requires a password to open.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showDialog(context),
              icon: const Icon(Icons.key_rounded),
              label: const Text('Enter Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
              ),
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
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Enter PDF Password', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Password',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
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
            child: const Text('Open', style: TextStyle(color: Color(0xFFFFD700))),
          ),
        ],
      ),
    );
  }
}

