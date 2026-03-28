import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/transactions/chart_data_provider.dart';
import 'package:nivvesh/application/transactions/spend_provider.dart';
import 'package:nivvesh/core/constants/payment_category.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/domain/models/finance_model.dart';
import 'package:nivvesh/presentation/transactions/widgets/spend_chart.dart';
import 'package:nivvesh/presentation/transactions/widgets/spend_widgets.dart';

class PeriodDetailPage extends ConsumerStatefulWidget {
  const PeriodDetailPage({
    super.key,
    required this.label,
    required this.periodStart,
    required this.periodEnd,
  });

  final String label;
  final DateTime periodStart;
  final DateTime periodEnd;

  @override
  ConsumerState<PeriodDetailPage> createState() => _PeriodDetailPageState();
}

class _PeriodDetailPageState extends ConsumerState<PeriodDetailPage> {
  Set<String> _selectedCategories = {};

  static final _gold = AppColors.dark.gold;
  static final _muted = AppColors.dark.muted;
  static final _surface = AppColors.dark.cardSurface;

  @override
  Widget build(BuildContext context) {
    final allMessages = ref.watch(financeControllerProvider).messages;

    // All transactions that fall in this period
    final periodTransactions = allMessages
        .where((m) =>
            !m.date.isBefore(widget.periodStart) &&
            !m.date.isAfter(widget.periodEnd))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // All spendable categories present in this period
    final allCategories = <String>{};
    for (final t in periodTransactions) {
      if (t.category != PaymentCategories.creditCategory) {
        allCategories.add(t.category);
      }
    }

    // Apply category filter
    final displayed = _selectedCategories.isEmpty
        ? periodTransactions
        : periodTransactions
            .where((m) => _selectedCategories.contains(m.category))
            .toList();

    // Build category groups for the list
    final categoryGroups = <String, List<FinanceModel>>{};
    for (final t in displayed) {
      categoryGroups.putIfAbsent(t.category, () => []).add(t);
    }

    // Chart data — always uses all period transactions for context,
    // filtered by selected categories if any
    final chartData = buildChartData(displayed, widget.periodStart, widget.periodEnd);

    final totalDebit = displayed
        .where((m) => m.category != PaymentCategories.creditCategory)
        .fold(0.0, (s, m) => s + m.amount);
    final totalCredit = displayed
        .where((m) => m.category == PaymentCategories.creditCategory)
        .fold(0.0, (s, m) => s + m.amount);

    return Scaffold(
      backgroundColor: AppColors.dark.background,
      body: CustomScrollView(
        slivers: [
          _DetailAppBar(label: widget.label),
          // ── Summary ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _gold.withValues(alpha: 0.28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL SPEND',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 10,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${totalDebit.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -0.6,
                      ),
                    ),
                    if (totalCredit > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+ ₹${totalCredit.toStringAsFixed(2)} received',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // ── Chart ─────────────────────────────────────────────────────
          if (chartData.bucketDates.isNotEmpty &&
              !chartData.totalSeries.every((v) => v == 0))
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SpendChartView(data: chartData),
              ),
            ),
          // ── Category filter chips ─────────────────────────────────────
          if (allCategories.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CATEGORIES',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 10,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allCategories.map((cat) {
                        final selected = _selectedCategories.contains(cat);
                        final catColor =
                            categoryChartColors[cat] ?? Colors.grey;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _selectedCategories =
                                    {..._selectedCategories}..remove(cat);
                              } else {
                                _selectedCategories = {
                                  ..._selectedCategories,
                                  cat
                                };
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: selected
                                  ? catColor.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? catColor
                                    : Colors.white.withValues(alpha: 0.14),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: catColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cat,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          // ── Divider ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          // ── Category groups list ──────────────────────────────────────
          if (categoryGroups.isEmpty)
            const SliverFillRemaining(child: _EmptyState())
          else
            CategoryGroupsSliver(groups: categoryGroups),
        ],
      ),
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final gold = AppColors.dark.gold;
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 64,
      backgroundColor: AppColors.dark.background,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: gold, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 17,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 40,
              color: AppColors.dark.muted.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            'No transactions',
            style: TextStyle(
              color: AppColors.dark.muted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
