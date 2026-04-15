import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/transactions/alert_config.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/presentation/alerts/widgets/alerts_widgets.dart';

class AlertsPage extends ConsumerStatefulWidget {
  const AlertsPage({super.key});

  @override
  ConsumerState<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends ConsumerState<AlertsPage> {
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

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(alertConfigProvider);
    final c = AppColors.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    ref.listen<AlertConfigController>(alertConfigProvider, (_, next) {
      if (_salaryCtrl.text.isEmpty && next.salary > 0) {
        _salaryCtrl.text = next.salary.toStringAsFixed(0);
        _salaryCtrl.selection = TextSelection.collapsed(offset: _salaryCtrl.text.length);
      }
    });

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const AlertsHeader(),
                  const SizedBox(height: 24),
                  SectionLabel('SMART ALERTS', colors: c),
                  const SizedBox(height: 12),
                  const SmartAlertCard(
                    icon: Icons.warning_amber_rounded,
                    title: '80% Salary Used',
                    message:
                        'You\'ve used 80% of your salary. You have ₹16,000 left for the next 12 days until payday.',
                    time: '2 hours ago',
                    accent: Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 12),
                  SmartAlertCard(
                    icon: Icons.trending_up_rounded,
                    title: 'Great Savings!',
                    message:
                        'You saved 20% more this month compared to last month. Keep up the good work!',
                    time: '1 day ago',
                    accent: c.incomePositive,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: SectionLabel('EXPENSE LIMITS', colors: c)),
                      Icon(Icons.tune_rounded, color: c.muted, size: 16),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: c.surfaceTintLow,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: c.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionLabel('MONTHLY INCOME', colors: c),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _salaryCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: TextStyle(color: c.primaryText, fontSize: 16),
                          decoration: InputDecoration(
                            prefixText: '₹ ',
                            prefixStyle: TextStyle(color: c.gold, fontSize: 16),
                            hintText: 'e.g. 50000',
                            hintStyle: TextStyle(color: c.muted.withValues(alpha: 0.5)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: c.gold.withValues(alpha: 0.26)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: c.gold),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                          onChanged: (val) {
                            final parsed = double.tryParse(val);
                            if (parsed != null) {
                              ref.read(alertConfigProvider).setSalary(parsed);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: SectionLabel('ALERT THRESHOLDS', colors: c)),
                            AddThresholdButton(onAdd: (percent) {
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
                                style: TextStyle(color: c.muted, fontSize: 13),
                              ),
                            ),
                          )
                        else
                          ...config.thresholds.map(
                            (percent) => ThresholdTile(
                              percent: percent,
                              salary: config.salary,
                              onDelete: () {
                                ref.read(alertConfigProvider).removeThreshold(percent);
                              },
                            ),
                          ),
                        const SizedBox(height: 16),
                        SectionLabel('CATEGORY LIMITS', colors: c),
                        const SizedBox(height: 4),
                        Text(
                          'Set a monthly spending limit per category.',
                          style: TextStyle(color: c.muted, fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        ...kLimitCategories.map(
                          (cat) => CategoryLimitSlider(
                            category: cat,
                            limit: config.getCategoryLimit(cat),
                            onChanged: (val) {
                              ref.read(alertConfigProvider).setCategoryLimit(cat, val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
