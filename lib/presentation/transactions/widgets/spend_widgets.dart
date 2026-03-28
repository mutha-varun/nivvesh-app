import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/core/constants/payment_category.dart';
import 'package:nivvesh/domain/models/finance_model.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/core/theme/app_theme.dart';
import 'package:nivvesh/application/transactions/filter_provider.dart';
import 'package:nivvesh/application/transactions/filter_finance_provider.dart';

final _luxGold     = AppColors.dark.gold;
final _luxSoftGold = AppColors.dark.goldSoft;
final _luxBg       = AppColors.dark.background;
final _luxSurface  = AppColors.dark.cardSurface;
final _luxMuted    = AppColors.dark.muted;

class AppBar extends StatelessWidget {
  const AppBar({
    super.key,
    required this.onRefresh,
    required this.isLoading,
    required this.onFilterTap,
  });
  final VoidCallback onRefresh;
  final bool isLoading;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 72,
      backgroundColor: _luxBg,
      title: Text(
        'Nivvesh',
        style: TextStyle(
          color: _luxGold,
          fontWeight: FontWeight.w500,
          fontSize: 24,
          letterSpacing: 0.4,
        ),
      ),
      actions: [
        if (!isLoading)
          _HeaderIconButton(
            icon: Icons.refresh_rounded,
            onTap: onRefresh,
          ),
        const SizedBox(width: 10),
        if (!isLoading)
          _HeaderIconButton(
            icon: Icons.tune_rounded,
            onTap: onFilterTap,
          ),
        const SizedBox(width: 12),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _luxGold.withValues(alpha: 0.30)),
        ),
        child: Icon(icon, color: _luxGold, size: 20),
      ),
    );
  }
}


class SummaryBar extends StatelessWidget {
  const SummaryBar({super.key,required this.messages});
  final List<FinanceModel> messages;

  @override
  Widget build(BuildContext context) {
    final totalDebit = messages
        .where((m) => m.category != PaymentCategories.creditCategory)
        .fold(0.0, (sum, m) => sum + m.amount);
    final totalCredit = messages
        .where((m) => m.category == PaymentCategories.creditCategory)
        .fold(0.0, (sum, m) => sum + m.amount);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: _luxSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _luxGold.withValues(alpha: 0.28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL SPEND',
                style: TextStyle(
                  color: _luxMuted,
                  fontSize: 10,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${totalDebit.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.07)),
              const SizedBox(height: 12),
              Row(
          children: [
            Expanded(
              child: _SummaryChip(
                label: 'Spent',
                amount: totalDebit,
                color: _luxGold.withValues(alpha: 0.11),
                textColor: _luxGold,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryChip(
                label: 'Received',
                amount: totalCredit,
                color: Colors.white.withValues(alpha: 0.07),
                textColor: Colors.white.withValues(alpha: 0.84),
                icon: Icons.arrow_downward_rounded,
              ),
            ),
          ],
        ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.amount,
    required this.color,
    required this.textColor,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final Color textColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class TransactionCard extends StatelessWidget {
  const TransactionCard(this.msg, {super.key});
  final FinanceModel msg;

  static const _categoryIcons = <String, IconData>{
    PaymentCategories.food:           Icons.restaurant_rounded,
    PaymentCategories.transport:      Icons.directions_car_rounded,
    PaymentCategories.shopping:       Icons.shopping_bag_rounded,
    PaymentCategories.entertainment:  Icons.movie_rounded,
    PaymentCategories.health:         Icons.local_hospital_rounded,
    PaymentCategories.creditCategory: Icons.savings_rounded,
    PaymentCategories.bills:          Icons.bolt_rounded,
    PaymentCategories.investment:     Icons.trending_up_rounded,
    PaymentCategories.uncategorized:  Icons.receipt_long_rounded,
  };

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = msg.category == PaymentCategories.creditCategory;
    final icon = _categoryIcons[msg.category] ?? Icons.receipt_long_rounded;
    final amountColor = _luxGold;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withValues(alpha: 0.06),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _luxSoftGold.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _luxSoftGold.withValues(alpha: 0.20)),
                ),
                child: Icon(
                  icon,
                  color: _luxSoftGold,
                  size: 21,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          msg.category,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${isCredit ? '+' : ''}₹${msg.amount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: amountColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            msg.application,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _luxMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _fmtDate(msg.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _luxMuted,
                          ),
                        ),
                      ],
                    ),
                    if (msg.triggerKeyword != null) ...[
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          msg.triggerKeyword!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _luxMuted.withValues(alpha: 0.85),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(msg),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _DetailSheet extends StatelessWidget {
  const _DetailSheet(this.msg);
  final FinanceModel msg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = msg.category == PaymentCategories.creditCategory;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, sc) => Container(
        decoration: AppDecorations.luxBottomSheet(radius: 24),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: ListView(
          controller: sc,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: AppDecorations.dragHandle,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '₹${msg.amount.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isCredit ? Colors.white : _luxGold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              msg.category,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: _luxMuted,
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow(label: 'Sender',  value: msg.application),
            _DetailRow(label: 'Date',    value: _fmtFull(msg.date)),
            if (msg.triggerKeyword != null)
              _DetailRow(label: 'Keyword', value: msg.triggerKeyword!),
            _DetailRow(label: 'SMS ID',  value: '${msg.smsId}'),
            const SizedBox(height: 16),
            Text(
              'Raw SMS',
              style: theme.textTheme.labelLarge?.copyWith(
                color: _luxMuted,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                msg.body,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtFull(DateTime d) {
    const months = [
      'January', 'February', 'March',    'April',   'May',      'June',
      'July',    'August',   'September', 'October', 'November', 'December',
    ];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} ${d.year}, $h:$m';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(color: _luxMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState(this.message, this.onRetry, {super.key});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.debitContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_off_rounded, size: 40, color: c.debit),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: c.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: c.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_rounded, size: 48, color: c.secondaryText),
          ),
          const SizedBox(height: 20),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: c.primaryText,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull to sync or tap the button below',
            style: TextStyle(color: c.secondaryText, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class FilterToolbar extends ConsumerWidget {
  const FilterToolbar({super.key});

  static const _monthAbbr = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _fmtShort(DateTime d) {
    final thisYear = DateTime.now().year;
    final yearPart = d.year != thisYear ? ' ${d.year}' : '';
    return '${d.day} ${_monthAbbr[d.month - 1]}$yearPart';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);

    if (!filter.hasAnyNonDefault) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final chips = <Widget>[];

    if (filter.hasNonDefaultDateRange) {
      final from = _fmtShort(filter.dateFrom);
      final to = _fmtShort(filter.dateTo);
      chips.add(_ReadOnlyChip(
        icon: Icons.date_range_rounded,
        label: '$from - $to',
      ));
    }

    if (filter.hasNonDefaultGrouping) {
      chips.add(_ReadOnlyChip(
        icon: Icons.view_list_rounded,
        label: filter.grouping == GroupingType.category
            ? 'Category View'
            : 'Summary View',
      ));
    }

    if (filter.grouping == GroupingType.period) {
      chips.add(_ReadOnlyChip(
        icon: Icons.timeline_rounded,
        label: _periodLabel(filter.periodType),
      ));
    }

    if (filter.hasCategories) {
      chips.add(_ReadOnlyChip(
        icon: Icons.category_rounded,
        label: '${filter.selectedCategories.length} categories',
      ));
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        ),
      ),
    );
  }

  String _periodLabel(PeriodType type) {
    switch (type) {
      case PeriodType.weekly:
        return 'Weekly';
      case PeriodType.monthly:
        return 'Monthly';
      case PeriodType.yearly:
        return 'Yearly';
    }
  }
}

class TopFilterSheet extends ConsumerWidget {
  const TopFilterSheet({super.key});

  static const _categories = [
    PaymentCategories.food,
    PaymentCategories.shopping,
    PaymentCategories.transport,
    PaymentCategories.entertainment,
    PaymentCategories.bills,
    PaymentCategories.health,
    PaymentCategories.investment,
    PaymentCategories.creditCategory,
    PaymentCategories.uncategorized,
  ];

  static const _monthAbbr = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_monthAbbr[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      decoration: AppDecorations.luxBottomSheet(radius: 24),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: AppDecorations.dragHandle,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Advanced Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Date Range',
                style: TextStyle(
                  color: _luxMuted,
                  fontSize: 12,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _pickRange(context, ref, filter),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: _luxGold.withValues(alpha: 0.26)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.date_range_rounded,
                          color: _luxGold, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_fmtDate(filter.dateFrom)}  —  ${_fmtDate(filter.dateTo)}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                      Icon(Icons.edit_calendar_rounded,
                          color: _luxMuted, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _SheetDropdown<GroupingType>(
                label: 'View Mode',
                value: filter.grouping,
                items: GroupingType.values,
                itemLabel: (v) =>
                    v == GroupingType.category ? 'Category View' : 'Summary View',
                onChanged: (value) {
                  if (value == null) return;
                  ref.read(filterProvider.notifier).state =
                      filter.copyWith(grouping: value);
                },
              ),
              if (filter.grouping == GroupingType.period) ...[
                const SizedBox(height: 10),
                _SheetDropdown<PeriodType>(
                  label: 'Summary Type',
                  value: filter.periodType,
                  items: PeriodType.values,
                  itemLabel: (v) => switch (v) {
                    PeriodType.weekly => 'Weekly',
                    PeriodType.monthly => 'Monthly',
                    PeriodType.yearly => 'Yearly',
                  },
                  onChanged: (value) {
                    if (value == null) return;
                    ref.read(filterProvider.notifier).state =
                        filter.copyWith(periodType: value);
                  },
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Categories',
                style: TextStyle(
                  color: _luxMuted,
                  fontSize: 12,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = filter.selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      final next = {...filter.selectedCategories};
                      if (isSelected) {
                        next.remove(category);
                      } else {
                        next.add(category);
                      }
                      ref.read(filterProvider.notifier).state =
                          filter.copyWith(selectedCategories: next);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(filterProvider.notifier).state =
                            defaultFilter();
                      },
                      child: const Text('Reset All'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickRange(
      BuildContext context, WidgetRef ref, FinanceFilterState filter) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          DateTimeRange(start: filter.dateFrom, end: filter.dateTo),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _luxGold,
              onPrimary: Colors.black,
              surface: AppColors.dark.cardSurface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref.read(filterProvider.notifier).state = filter.copyWith(
        dateFrom: picked.start,
        dateTo: DateTime(
            picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
      );
    }
  }
}

class _SheetDropdown<T> extends StatelessWidget {
  const _SheetDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        canvasColor: AppColors.dark.dropdownSurface,
      ),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        dropdownColor: AppColors.dark.dropdownSurface,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _luxMuted),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _luxGold.withValues(alpha: 0.26)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _luxGold),
          ),
        ),
        style: const TextStyle(color: Colors.white),
        iconEnabledColor: _luxGold,
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item), style: const TextStyle(color: Colors.white)),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _ReadOnlyChip extends StatelessWidget {
  const _ReadOnlyChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _luxGold.withValues(alpha: 0.26)),
        color: _luxSurface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _luxGold),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryGroupsSliver extends StatelessWidget {
  const CategoryGroupsSliver({super.key, required this.groups});

  final Map<String, List<FinanceModel>> groups;

  @override
  Widget build(BuildContext context) {
    final categories = groups.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      sliver: SliverList.separated(
        itemCount: categories.length,
        separatorBuilder: (_, index) => Divider(
          height: 1,
          color: Colors.white.withValues(alpha: 0.06),
        ),
        itemBuilder: (_, i) {
          final category = categories[i];
          final txns = groups[category] ?? const [];
          return _CategorySectionCard(category: category, transactions: txns);
        },
      ),
    );
  }
}

class _CategorySectionCard extends StatelessWidget {
  const _CategorySectionCard({
    required this.category,
    required this.transactions,
  });

  final String category;
  final List<FinanceModel> transactions;

  @override
  Widget build(BuildContext context) {
    final total = transactions.fold<double>(0, (sum, t) => sum + t.amount);
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
          title: Text(
            category,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${transactions.length} transactions',
            style: TextStyle(color: _luxMuted),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: _luxGold,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.expand_more_rounded, color: _luxMuted, size: 20),
            ],
          ),
          children: [
            for (final txn in transactions)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: TransactionCard(txn),
              ),
          ],
        ),
      ),
    );
  }
}

class PeriodSummarySliver extends StatelessWidget {
  const PeriodSummarySliver({super.key, required this.aggregates});

  final List<PeriodAggregate> aggregates;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      sliver: SliverList.separated(
        itemCount: aggregates.length,
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final item = aggregates[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: AppDecorations.luxCard,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${item.count} txn',
                  style: TextStyle(color: _luxMuted, fontSize: 12),
                ),
                const SizedBox(width: 10),
                Text(
                  '₹${item.total.toStringAsFixed(2)}',
                  style: TextStyle(color: _luxGold, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}