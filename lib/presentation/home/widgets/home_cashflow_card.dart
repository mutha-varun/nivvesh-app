import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/home/home_cashflow_provider.dart';
import 'package:nivvesh/application/home/home_summary_provider.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/presentation/notifications/notifications_page.dart';

class HomeCashflowCard extends ConsumerWidget {
  const HomeCashflowCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final period = ref.watch(homePeriodProvider);
    final mode = ref.watch(homeGraphModeProvider);
    final series = ref.watch(homeCashflowProvider);
    final salary = ref.watch(homeSummaryProvider).monthIncome;

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
              // _ModeToggleButton(
              //   selected: mode,
              //   onChanged: (next) =>
              //       ref.read(homeGraphModeProvider.notifier).state = next,
              // ),
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

class CashNoif extends StatefulWidget {
  final Widget child;
  final EasterEggController controller;

  const CashNoif({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<CashNoif> createState() => _CashNoifState();
}

class _CashNoifState extends State<CashNoif> {
  double _dx = 0;
  double _dy = 0;

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _dx = (_dx + d.delta.dx).clamp(-80.0, 80.0);
      _dy = (_dy + d.delta.dy).clamp(-80.0, 80.0);
    });
    widget.controller.registerDrag(_dx, _dy);
  }

  void _revealSignature(BuildContext context) {
    final sig = entropySeed();
    final c = AppColors.of(context);

    showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 26),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0F1A), Color(0xFF131C2D)],
            ),
            border: Border.all(
              color: c.accentPrimary.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: c.accentPrimary.withValues(alpha: 0.35),
                blurRadius: 26,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, color: Color(0xFFFFD54F), size: 36),
              const SizedBox(height: 10),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFFFF176),
                    Color(0xFFFFB300),
                    Color(0xFFFF6F00),
                  ],
                ).createShader(bounds),
                child: Text(
                  sig,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final isDraggable = widget.controller.isDraggable;
        final isRevealed = widget.controller.isRevealed;

        return SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Lightning — fixed, underneath
              if (isRevealed)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _revealSignature(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFEE58), Color(0xFFFFA000)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFC107).withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        size: 22,
                        color: Color(0xFF231500),
                      ),
                    ),
                  ),
                ),

              // Child (the bell) — draggable on top
              Positioned(
                top: 8.0 + _dy,
                right: 8.0 - _dx,
                child: GestureDetector(
                  onTap: isRevealed ? null : null, // bell handles its own tap
                  onPanUpdate: isDraggable ? _onPanUpdate : null,
                  behavior: HitTestBehavior.opaque,
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
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
        // color: color.withValues(alpha: 0.14),
        // borderRadius: BorderRadius.circular(999),
        // border: Border.all(color: c.borderSubtle),
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

// class _ModeToggleButton extends StatelessWidget {
//   const _ModeToggleButton({
//     required this.selected,
//     required this.onChanged,
//   });

//   final HomeGraphMode selected;
//   final ValueChanged<HomeGraphMode> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     final c = AppColors.of(context);
//     final isOverview = selected == HomeGraphMode.overview;

//     return GestureDetector(
//       onTap: () => onChanged(
//         isOverview ? HomeGraphMode.category : HomeGraphMode.overview,
//       ),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
//         decoration: BoxDecoration(
//           color: c.surface,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: c.borderSubtle),
//         ),
//         child: Text(
//           isOverview ? 'Overview' : 'Category',
//           style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                 color: c.primaryText,
//                 fontWeight: FontWeight.w600,
//               ),
//         ),
//       ),
//     );
//   }
// }

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
      curveSmoothness: 0.2,
      preventCurveOverShooting: true,
      color: const Color(0xFF34D399),
      barWidth: 2,
      dotData: const FlDotData(show: false),
    ),
    LineChartBarData(
      spots: expenseSpots,
      isCurved: true,
      curveSmoothness: 0.2,
      preventCurveOverShooting: true,
      color: const Color(0xFFFB7185),
      barWidth: 2,
      dotData: const FlDotData(show: false),
    ),
    LineChartBarData(
      spots: savingsSpots,
      isCurved: true,
      curveSmoothness: 0.2,
      preventCurveOverShooting: true,
      color: const Color(0xFF3B82F6),
      barWidth: 2,
      dotData: const FlDotData(show: false),
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
