import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/home/home_summary_provider.dart';
import 'package:nivvesh/application/transactions/alert_config.dart';
import 'package:nivvesh/core/theme/app_colors.dart';

class HomeBalanceCard extends ConsumerWidget {
  const HomeBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final summary = ref.watch(homeSummaryProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.borderSubtle),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [c.surfaceTintHigh, c.surface],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: _BlurDot(color: c.accentTint20),
          ),
          Positioned(
            left: -20,
            top: -16,
            child: _BlurDot(color: c.categories.purple.tint20),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remaining this month',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: c.secondaryText,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatAmount(summary.monthRemaining),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: c.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 34,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _IncomeEditorTile(income: summary.monthIncome),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MoneyTile(
                        label: 'Spent',
                        value: _formatAmount(summary.monthSpend),
                        icon: Icons.arrow_upward_rounded,
                        iconColor: c.expenseNegative,
                        iconBg: c.categories.rose.tint20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurDot extends StatelessWidget {
  const _BlurDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _MoneyTile extends StatelessWidget {
  const _MoneyTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: c.surfaceTintLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: c.secondaryText,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: c.primaryText,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _IncomeEditorTile extends ConsumerStatefulWidget {
  const _IncomeEditorTile({required this.income});

  final double income;

  @override
  ConsumerState<_IncomeEditorTile> createState() => _IncomeEditorTileState();
}

class _IncomeEditorTileState extends ConsumerState<_IncomeEditorTile> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _editing) {
      _commit();
    }
  }

  void _startEditing() {
    setState(() {
      _editing = true;
      _controller.text =
          widget.income > 0 ? widget.income.round().toString() : '';
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _commit() async {
    final parsed = double.tryParse(_controller.text.trim());
    if (parsed != null && parsed >= 0) {
      await ref.read(alertConfigProvider).setSalary(parsed);
    }
    if (!mounted) return;
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final textStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          color: c.primaryText,
          fontWeight: FontWeight.w700,
        );

    return GestureDetector(
      onTap: _editing ? null : _startEditing,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: c.surfaceTintLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: c.categories.emerald.tint20,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_downward_rounded,
                    size: 14,
                    color: c.incomePositive,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Income',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: c.secondaryText,
                      ),
                ),
                const Spacer(),
                Icon(Icons.edit_rounded, size: 12, color: c.muted),
              ],
            ),
            const SizedBox(height: 8),
            if (_editing)
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: textStyle,
                cursorColor: c.accentPrimary,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  prefixText: '₹',
                  prefixStyle: textStyle,
                  hintText: '0',
                  hintStyle: textStyle?.copyWith(color: c.muted),
                ),
                onSubmitted: (_) => _focusNode.unfocus(),
              )
            else
              Text(_formatAmount(widget.income), style: textStyle),
          ],
        ),
      ),
    );
  }
}

String _formatAmount(double amount) {
  final rounded = amount.round();
  final negative = rounded < 0;
  final raw = rounded.abs().toString();

  String grouped;
  if (raw.length <= 3) {
    grouped = raw;
  } else {
    final lastThree = raw.substring(raw.length - 3);
    var rest = raw.substring(0, raw.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) {
      parts.insert(0, rest);
    }
    grouped = '${parts.join(',')},$lastThree';
  }

  return '${negative ? '-' : ''}₹$grouped';
}
