import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/home/home_cashflow_provider.dart';
import 'package:nivvesh/application/transactions/alert_config.dart';
import 'package:nivvesh/core/theme/app_colors.dart';

class HomeCashflowCard extends ConsumerWidget {
  const HomeCashflowCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final period = ref.watch(homePeriodProvider);
    final mode = ref.watch(homeGraphModeProvider);
    final series = ref.watch(homeCashflowProvider);
    final salary = ref.watch(alertConfigProvider).salary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceTintLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Cashflow',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: c.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              _ModeToggleButton(
                selected: mode,
                onChanged: (next) =>
                    ref.read(homeGraphModeProvider.notifier).state = next,
              ),
              const SizedBox(width: 8),
              _PeriodSegmentedControl(
                selected: period,
                onChanged: (next) => ref.read(homePeriodProvider.notifier).state = next,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 200,
            child: _CashflowChart(
              period: period,
              series: series,
              mode: mode,
              salary: salary,
            ),
          ),
          const SizedBox(height: 12),
          if (mode == HomeGraphMode.overview)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _LegendChip(label: 'Salary', color: Color(0xFF34D399)),
                _LegendChip(label: 'Expenses', color: Color(0xFFFB7185)),
                _LegendChip(label: 'Savings', color: Color(0xFF3B82F6)),
              ],
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: series.buckets.map((bucket) {
                final swatch = c.categories.forCategory(bucket.category);
                return _LegendChip(label: bucket.category, color: swatch.base);
              }).toList(growable: false),
            ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: c.secondaryText,
                ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  const _ModeToggleButton({
    required this.selected,
    required this.onChanged,
  });

  final HomeGraphMode selected;
  final ValueChanged<HomeGraphMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isOverview = selected == HomeGraphMode.overview;

    return GestureDetector(
      onTap: () => onChanged(
        isOverview ? HomeGraphMode.category : HomeGraphMode.overview,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.borderSubtle),
        ),
        child: Text(
          isOverview ? 'Overview' : 'Category',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: c.primaryText,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _PeriodSegmentedControl extends StatelessWidget {
  const _PeriodSegmentedControl({
    required this.selected,
    required this.onChanged,
  });

  final HomePeriod selected;
  final ValueChanged<HomePeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const items = [
      (period: HomePeriod.m1, label: '1M'),
      (period: HomePeriod.m3, label: '3M'),
      (period: HomePeriod.m6, label: '6M'),
      (period: HomePeriod.y1, label: '1Y'),
    ];

    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final active = selected == item.period;
          return GestureDetector(
            onTap: () => onChanged(item.period),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: active ? c.surfaceTintMid : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                item.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: active ? c.primaryText : c.muted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _CashflowChart extends StatelessWidget {
  const _CashflowChart({
    required this.period,
    required this.series,
    required this.mode,
    required this.salary,
  });

  final HomePeriod period;
  final HomeCashflowSeries series;
  final HomeGraphMode mode;
  final double salary;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final axisLength = series.timeAxis.length;

    if (axisLength == 0) {
      return const SizedBox.shrink();
    }

    final lineBarsData = mode == HomeGraphMode.overview
        ? _buildOverviewBars(series, salary)
        : _buildCategoryBars(series, c);

    final maxY = lineBarsData
        .expand((bar) => bar.spots)
        .fold<double>(0, (max, spot) => spot.y > max ? spot.y : max);
    final double effectiveMaxY = maxY <= 0 ? 1000.0 : maxY * 1.1;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (axisLength - 1).toDouble(),
        minY: 0,
        maxY: effectiveMaxY,
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: effectiveMaxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: c.borderSubtle,
            strokeWidth: 1.0,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: effectiveMaxY / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatK(value),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: c.secondaryText,
                        fontSize: 10,
                      ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _xInterval(period, axisLength),
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= series.timeAxis.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _formatDate(series.timeAxis[index], period),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: c.secondaryText,
                          fontSize: 10,
                        ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: lineBarsData,
      ),
    );
  }
}

List<LineChartBarData> _buildOverviewBars(
  HomeCashflowSeries series,
  double salary,
) {
  final expenses = List<double>.filled(series.timeAxis.length, 0);
  for (final bucket in series.buckets) {
    for (var i = 0; i < bucket.points.length; i++) {
      expenses[i] += bucket.points[i].value;
    }
  }

  final salarySpots = <FlSpot>[];
  final expenseSpots = <FlSpot>[];
  final savingsSpots = <FlSpot>[];

  for (var i = 0; i < series.timeAxis.length; i++) {
    final expense = expenses[i];
    final savings = salary - expense;

    salarySpots.add(FlSpot(i.toDouble(), salary));
    expenseSpots.add(FlSpot(i.toDouble(), expense));
    savingsSpots.add(FlSpot(i.toDouble(), savings < 0 ? 0 : savings));
  }

  return [
    LineChartBarData(
      spots: salarySpots,
      isCurved: true,
      color: const Color(0xFF34D399),
      barWidth: 2,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: const Color(0x1A34D399),
      ),
    ),
    LineChartBarData(
      spots: expenseSpots,
      isCurved: true,
      color: const Color(0xFFFB7185),
      barWidth: 2,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: const Color(0x1AFB7185),
      ),
    ),
    LineChartBarData(
      spots: savingsSpots,
      isCurved: true,
      color: const Color(0xFF3B82F6),
      barWidth: 2,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: const Color(0x1A3B82F6),
      ),
    ),
  ];
}

List<LineChartBarData> _buildCategoryBars(
  HomeCashflowSeries series,
  AppColorsBase colors,
) {
  final lineBars = <LineChartBarData>[];

  for (final bucket in series.buckets) {
    final swatch = colors.categories.forCategory(bucket.category);
    final spots = <FlSpot>[];

    for (var i = 0; i < bucket.points.length; i++) {
      spots.add(FlSpot(i.toDouble(), bucket.points[i].value));
    }

    lineBars.add(
      LineChartBarData(
        spots: spots,
        isCurved: true,
        color: swatch.base,
        barWidth: 2,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: swatch.tint20,
        ),
      ),
    );
  }

  return lineBars;
}

double _xInterval(HomePeriod period, int length) {
  if (length <= 1) return 1;
  switch (period) {
    case HomePeriod.m1:
      return 6;
    case HomePeriod.m3:
      return 2;
    case HomePeriod.m6:
      return 2;
    case HomePeriod.y1:
      return 1;
  }
}

String _formatK(double value) {
  final k = value / 1000;
  if (k >= 10) return '₹${k.round()}k';
  return '₹${k.toStringAsFixed(1)}k';
}

String _formatDate(DateTime date, HomePeriod period) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  if (period == HomePeriod.y1) {
    return months[date.month - 1];
  }

  final day = date.day.toString().padLeft(2, '0');
  final month = months[date.month - 1];
  return '$day $month';
}
