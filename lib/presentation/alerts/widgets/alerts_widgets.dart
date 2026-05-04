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
                style: TextStyle(color: c.muted, fontSize: 12),
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
                Text(time, style: TextStyle(color: c.muted, fontSize: 11)),
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
    final displayLabel = _labelFor(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  displayLabel,
                  style: TextStyle(
                    color: c.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '₹${_formatInr(limit)}',
                style: TextStyle(
                  color: c.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: c.accentPrimary,
              inactiveTrackColor: c.surfaceContainerHigh,
              thumbColor: c.accentPrimary,
              overlayColor: c.accentPrimary.withValues(alpha: 0.12),
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
              Text(
                '₹${_formatInr(max)}',
                style: TextStyle(color: c.muted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _labelFor(String category) {
    switch (category) {
      case PaymentCategories.food:
        return 'Food & Dining';
      case PaymentCategories.shopping:
        return 'Shopping';
      case PaymentCategories.entertainment:
        return 'Entertainment';
      case PaymentCategories.transport:
        return 'Transport';
      case PaymentCategories.bills:
        return 'Bills';
      case PaymentCategories.health:
        return 'Health';
      default:
        return category;
    }
  }

  static String _formatInr(double amount) {
    final rounded = amount.round().abs();
    final raw = rounded.toString();
    if (raw.length <= 3) return raw;

    final lastThree = raw.substring(raw.length - 3);
    var rest = raw.substring(0, raw.length - 3);
    final parts = <String>[];

    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);

    return '${parts.join(',')},$lastThree';
  }
}

// The "Add" button that sits in the header row
class AddThresholdHeaderButton extends StatelessWidget {
  const AddThresholdHeaderButton({required this.onAdd, super.key});
  final void Function(int) onAdd;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return OutlinedButton.icon(
      onPressed: () => showAddThresholdPicker(context, onAdd),
      icon: Icon(Icons.add, size: 18, color: c.gold),
      label: Text('Add', style: TextStyle(color: c.gold, fontSize: 14)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: c.gold.withValues(alpha: 0.3)),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}

// The clean status chip (No close button, matches the screenshot)
class ThresholdTile extends StatelessWidget {
  const ThresholdTile({required this.percent, required this.onDelete, super.key});
  final int percent;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131517), // Deep charcoal background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFFFFB800),
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            '$percent%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close_rounded, color: Colors.white54, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// The dashed placeholder at the end of the list
class AddPlaceholder extends StatelessWidget {
  final VoidCallback onTap;
  const AddPlaceholder({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: Colors.white.withValues(alpha: 0.1),
          radius: 16,
        ),
        child: const SizedBox(
          width: 60,
          height: 52,
          child: Icon(Icons.add, color: Colors.white38, size: 24),
        ),
      ),
    );
  }
}

Future<void> showAddThresholdPicker(
  BuildContext context,
  void Function(int) onAdd,
) async {
  final c = AppColors.of(context);
  final controller = TextEditingController();
  await showDialog<void>(
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


class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
          Radius.circular(radius),
        ),
      );

    const dashLength = 4.5;
    const dashGap = 3.5;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
