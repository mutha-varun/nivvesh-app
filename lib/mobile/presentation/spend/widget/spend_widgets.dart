import 'package:flutter/material.dart';
import 'package:nivvesh/mobile/core/constants/payment_category.dart';
import 'package:nivvesh/mobile/domain/models/finance_model.dart';
import 'package:nivvesh/mobile/presentation/shared/themes/colors.dart';

class AppBar extends StatelessWidget {
  const AppBar({required this.onRefresh, required this.isLoading});
  final VoidCallback onRefresh;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SliverAppBar.large(
      backgroundColor: AppColors.of(context).background,
      title: Text(
        'Transactions',
        style: TextStyle(
          color: c.primaryText,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        if (!isLoading)
          IconButton(
            icon: Icon(Icons.tune_rounded, color: c.secondaryText),
            tooltip: 'Filter',
            onPressed: () {},
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}


class SummaryBar extends StatelessWidget {
  const SummaryBar({super.key,required this.messages});
  final List<FinanceModel> messages;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    final totalDebit = messages
        .where((m) => m.category != PaymentCategories.creditCategory)
        .fold(0.0, (sum, m) => sum + m.amount);
    final totalCredit = messages
        .where((m) => m.category == PaymentCategories.creditCategory)
        .fold(0.0, (sum, m) => sum + m.amount);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: _SummaryChip(
                label: 'Spent',
                amount: totalDebit,
                color: c.debitContainer,
                textColor: c.onDebitContainer,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryChip(
                label: 'Received',
                amount: totalCredit,
                color: c.accentContainer,
                textColor: c.onAccentContainer,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(16),
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
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '₹${_fmt(amount)}',
                  style: TextStyle(
                    fontSize: 15,
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

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class TransactionCard extends StatelessWidget {
  const TransactionCard(this.msg);
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
    final c = AppColors.of(context);
    final isCredit = msg.category == PaymentCategories.creditCategory;
    final icon = _categoryIcons[msg.category] ?? Icons.receipt_long_rounded;
    final amountColor = isCredit ? c.onAccentContainer : c.debit;

    return Material(
      color: c.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: c.border,
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon bubble
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCredit ? c.accentContainer : c.debitContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isCredit ? c.onAccentContainer : c.debit,
                  size: 22,
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
                            color: c.primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${isCredit ? '+' : '-'}₹${msg.amount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
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
                              color: c.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _fmtDate(msg.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: c.secondaryText,
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
                          color: c.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          msg.triggerKeyword!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: c.secondaryText,
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
      '${d.day} ${_months[d.month - 1]} ${d.year}';
}

class _DetailSheet extends StatelessWidget {
  const _DetailSheet(this.msg);
  final FinanceModel msg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = AppColors.of(context);
    final isCredit = msg.category == PaymentCategories.creditCategory;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, sc) => Container(
        decoration: BoxDecoration(
          color: c.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: ListView(
          controller: sc,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: c.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '₹${msg.amount.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isCredit ? c.onAccentContainer : c.debit,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              msg.category,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: c.secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow(label: 'Sender',  value: msg.application,    c: c),
            _DetailRow(label: 'Date',    value: _fmtFull(msg.date), c: c),
            if (msg.triggerKeyword != null)
              _DetailRow(label: 'Keyword', value: msg.triggerKeyword!, c: c),
            _DetailRow(label: 'SMS ID',  value: '${msg.smsId}',     c: c),
            const SizedBox(height: 16),
            Text(
              'Raw SMS',
              style: theme.textTheme.labelLarge?.copyWith(
                color: c.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                msg.body,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: c.primaryText,
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
    required this.c,
  });

  final String label;
  final String value;
  final AppColorsBase c;

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
              style: TextStyle(color: c.secondaryText, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: c.primaryText,
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
  const ErrorState(this.message, this.onRetry);
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
              style: FilledButton.styleFrom(
                backgroundColor: c.onAccentContainer,
                foregroundColor: c.accentText,
              ),
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