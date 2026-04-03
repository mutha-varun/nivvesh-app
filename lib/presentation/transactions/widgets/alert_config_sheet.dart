import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/transactions/alert_config.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/core/theme/app_theme.dart';

class AlertConfigSheet extends ConsumerStatefulWidget {
  const AlertConfigSheet({super.key});

  @override
  ConsumerState<AlertConfigSheet> createState() => _AlertConfigSheetState();
}

class _AlertConfigSheetState extends ConsumerState<AlertConfigSheet> {
  late TextEditingController _salaryCtrl;

  @override
  void initState() {
    super.initState();
    final salary = ref.read(alertConfigProvider).salary;
    _salaryCtrl = TextEditingController(
      text: salary > 0 ? salary.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _salaryCtrl.dispose();
    super.dispose();
  }

  static final _gold = AppColors.dark.gold;
  static final _muted = AppColors.dark.muted;

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(alertConfigProvider);

    // Sync text controller if load() completed after initState() ran
    ref.listen<AlertConfigController>(alertConfigProvider, (_, next) {
      if (_salaryCtrl.text.isEmpty && next.salary > 0) {
        _salaryCtrl.text = next.salary.toStringAsFixed(0);
        _salaryCtrl.selection =
            TextSelection.collapsed(offset: _salaryCtrl.text.length);
      }
    });

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      decoration: AppDecorations.luxBottomSheet(radius: 24),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: AppDecorations.dragHandle,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Spend Alerts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Get notified when your spending crosses a threshold of your monthly income.',
                style: TextStyle(color: _muted, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 18),

              // --- Monthly income ---
              Text(
                'MONTHLY INCOME',
                style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _salaryCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(color: _gold, fontSize: 16),
                  hintText: 'e.g. 50000',
                  hintStyle: TextStyle(color: _muted.withValues(alpha: 0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _gold.withValues(alpha: 0.26)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _gold),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null) {
                    ref.read(alertConfigProvider).setSalary(parsed);
                  }
                },
              ),
              const SizedBox(height: 20),

              // --- Alert thresholds ---
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'ALERT THRESHOLDS',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _AddThresholdButton(onAdd: (percent) {
                    ref.read(alertConfigProvider).addThreshold(percent);
                  }),
                ],
              ),
              const SizedBox(height: 10),
              if (config.thresholds.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No alerts set. Tap + to add one.',
                      style: TextStyle(color: _muted, fontSize: 13),
                    ),
                  ),
                )
              else
                ...config.thresholds.map((percent) => _ThresholdTile(
                      percent: percent,
                      salary: config.salary,
                      onDelete: () {
                        ref.read(alertConfigProvider).removeThreshold(percent);
                      },
                    )),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Threshold row
class _ThresholdTile extends StatelessWidget {
  const _ThresholdTile({
    required this.percent,
    required this.salary,
    required this.onDelete,
  });

  final int percent;
  final double salary;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final amountStr = salary > 0
        ? '₹${(salary * percent / 100).toStringAsFixed(0)}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.dark.gold.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_active_rounded,
                color: _iconColor(percent), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$percent% of income',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (amountStr.isNotEmpty)
                    Text(
                      'Triggers at $amountStr',
                      style: TextStyle(
                        color: AppColors.dark.muted,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.close_rounded,
                    color: AppColors.dark.muted, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _iconColor(int percent) {
    if (percent >= 90) return const Color(0xFFFF5252);
    if (percent >= 70) return const Color(0xFFFFB74D);
    return AppColors.dark.gold;
  }
}

// Add-threshold button (shows a popup to pick %)
class _AddThresholdButton extends StatelessWidget {
  const _AddThresholdButton({required this.onAdd});
  final void Function(int) onAdd;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.dark.gold.withValues(alpha: 0.30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: AppColors.dark.gold, size: 16),
            const SizedBox(width: 4),
            Text(
              'Add',
              style: TextStyle(
                color: AppColors.dark.gold,
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
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dark.cardSurface,
        title: const Text('Add Alert',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            suffixText: '%',
            suffixStyle: TextStyle(color: AppColors.dark.muted),
            hintText: 'e.g. 75',
            hintStyle: TextStyle(color: AppColors.dark.muted.withValues(alpha: 0.5)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.dark.gold)),
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
            child: Text('Add',
                style: TextStyle(color: AppColors.dark.gold)),
          ),
        ],
      ),
    );
  }
}
