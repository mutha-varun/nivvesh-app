import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivvesh/core/constants/payment_category.dart';
import 'package:nivvesh/core/theme/app_colors.dart';

const kLimitCategories = [
  PaymentCategories.food,
  PaymentCategories.shopping,
  PaymentCategories.transport,
  PaymentCategories.entertainment,
  PaymentCategories.bills,
  PaymentCategories.health,
];

const kLimitMax = {
  PaymentCategories.food: 50000.0,
  PaymentCategories.shopping: 50000.0,
  PaymentCategories.transport: 30000.0,
  PaymentCategories.entertainment: 20000.0,
  PaymentCategories.bills: 30000.0,
  PaymentCategories.health: 30000.0,
};

class AlertsHeader extends StatelessWidget {
  const AlertsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: c.surfaceTintMid,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.borderSubtle),
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            color: c.secondaryText,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alerts & Limits',
                style: TextStyle(
                  color: c.primaryText,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Manage your notifications',
                style: TextStyle(
                  color: c.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {required this.colors, super.key});

  final String text;
  final AppColorsBase colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: colors.secondaryText,
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class SmartAlertCard extends StatelessWidget {
  const SmartAlertCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.accent,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    color: c.primaryText,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(color: c.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryLimitSlider extends StatelessWidget {
  const CategoryLimitSlider({
    required this.category,
    required this.limit,
    required this.onChanged,
    super.key,
  });

  final String category;
  final double limit;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final max = kLimitMax[category] ?? 50000.0;
    final isSet = limit > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category,
                  style: TextStyle(
                    color: c.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                isSet ? '₹${_fmt(limit)}' : 'No limit',
                style: TextStyle(
                  color: isSet ? c.gold : c.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: c.gold,
              inactiveTrackColor: c.muted.withValues(alpha: 0.2),
              thumbColor: c.gold,
              overlayColor: c.gold.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: limit.clamp(0, max),
              min: 0,
              max: max,
              divisions: (max / 500).round(),
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹0', style: TextStyle(color: c.muted, fontSize: 10)),
              Text('₹${_fmt(max)}', style: TextStyle(color: c.muted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    final n = v.round();
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return n.toString();
  }
}

class ThresholdTile extends StatelessWidget {
  const ThresholdTile({
    required this.percent,
    required this.salary,
    required this.onDelete,
    super.key,
  });

  final int percent;
  final double salary;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final amountStr = salary > 0 ? '₹${(salary * percent / 100).toStringAsFixed(0)}' : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: c.gold.withValues(alpha: 0.18),
          ),
          color: c.surfaceTintLow,
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_active_rounded, color: _iconColor(percent, c.gold), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$percent% of income',
                    style: TextStyle(
                      color: c.primaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (amountStr.isNotEmpty)
                    Text(
                      'Triggers at $amountStr',
                      style: TextStyle(color: c.muted, fontSize: 12),
                    ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.close_rounded, color: c.muted, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _iconColor(int percent, Color defaultColor) {
    if (percent >= 90) return const Color(0xFFFF5252);
    if (percent >= 70) return const Color(0xFFFFB74D);
    return defaultColor;
  }
}

class AddThresholdButton extends StatelessWidget {
  const AddThresholdButton({required this.onAdd, super.key});

  final void Function(int) onAdd;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.gold.withValues(alpha: 0.30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: c.gold, size: 16),
            const SizedBox(width: 4),
            Text(
              'Add',
              style: TextStyle(
                color: c.gold,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final c = AppColors.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.cardSurface,
        title: Text('Add Alert', style: TextStyle(color: c.primaryText, fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(color: c.primaryText),
          decoration: InputDecoration(
            suffixText: '%',
            suffixStyle: TextStyle(color: c.muted),
            hintText: 'e.g. 75',
            hintStyle: TextStyle(color: c.muted.withValues(alpha: 0.5)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.gold)),
          ),
          onSubmitted: (val) {
            final percent = int.tryParse(val);
            if (percent != null && percent > 0 && percent <= 100) {
              onAdd(percent);
            }
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final percent = int.tryParse(controller.text);
              if (percent != null && percent > 0 && percent <= 100) {
                onAdd(percent);
              }
              Navigator.pop(ctx);
            },
            child: Text('Add', style: TextStyle(color: c.gold)),
          ),
        ],
      ),
    );
  }
}
