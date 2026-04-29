import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/transactions/chart_data_provider.dart';
import 'package:nivvesh/core/theme/app_colors.dart';

// ── Sliver wrapper used on the main spend page ─────────────────────────────

class SpendChart extends ConsumerWidget {
  const SpendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartData = ref.watch(spendChartDataProvider);

    if (chartData.bucketDates.isEmpty ||
        chartData.totalSeries.every((v) => v == 0)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SpendChartView(data: chartData),
      ),
    );
  }
}

// ── Reusable chart content widget (used both on main page + detail page) ───

class SpendChartView extends StatefulWidget {
  const SpendChartView({super.key, required this.data});
  final SpendChartData data;

  @override
  State<SpendChartView> createState() => _SpendChartViewState();
}

class _SpendChartViewState extends State<SpendChartView> {
  ChartMode _mode = ChartMode.total;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final data = widget.data;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
      decoration: BoxDecoration(
        color: c.surfaceTintLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.borderSubtle),
      ),
      child: Column(
        children: [
          _ModeToggle(
            mode: _mode,
            onChanged: (m) => setState(() => _mode = m),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: switch (_mode) {
              ChartMode.total => _buildTotalChart(data, c),
              ChartMode.byCategory => _buildCategoryChart(data, c),
              ChartMode.savings => _buildSavingsChart(data, c),
            },
          ),
          if (_mode == ChartMode.byCategory &&
              data.categorySeries.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildLegend(data, c),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalChart(SpendChartData data, AppColorsBase c) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.totalSeries.length; i++) {
      spots.add(FlSpot(i.toDouble(), data.totalSeries[i]));
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            preventCurveOverShooting: true,
            color: c.expenseNegative,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
        ],
        gridData: _gridData(c),
        titlesData: _titlesData(data, c),
        borderData: FlBorderData(show: false),
        lineTouchData: _touchData(data, c),
        minY: 0,
      ),
    );
  }

  Widget _buildCategoryChart(SpendChartData data, AppColorsBase c) {
    final bars = <LineChartBarData>[];
    final activeEntries = data.categorySeries.entries
        .where((e) => !e.value.every((v) => v == 0))
        .toList();

    for (final entry in activeEntries) {
      final color = c.categories.forCategory(entry.key).base;
      final spots = <FlSpot>[];
      for (int i = 0; i < entry.value.length; i++) {
        spots.add(FlSpot(i.toDouble(), entry.value[i]));
      }

      bars.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.2,
        preventCurveOverShooting: true,
        color: color,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
      ));
    }

    return LineChart(
      LineChartData(
        lineBarsData: bars,
        gridData: _gridData(c),
        titlesData: _titlesData(data, c),
        borderData: FlBorderData(show: false),
        lineTouchData: _touchData(data, c),
        minY: 0,
      ),
    );
  }

  FlGridData _gridData(AppColorsBase c) => FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(
          color: c.borderSubtle,
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      );

  FlTitlesData _titlesData(SpendChartData data, AppColorsBase c) {
    final count = data.bucketDates.length;
    final interval = count <= 7 ? 1 : (count ~/ 5).clamp(1, count);

    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 46,
          getTitlesWidget: (value, meta) {
            if (value == meta.min || value == meta.max) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                _fmtAmount(value),
                style: TextStyle(color: c.secondaryText, fontSize: 10),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: interval.toDouble(),
          getTitlesWidget: (value, meta) {
            final i = value.toInt();
            if (i < 0 || i >= count) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _fmtBucketLabel(data.bucketDates[i], data.resolution),
                style: TextStyle(color: c.secondaryText, fontSize: 10),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  LineTouchData _touchData(SpendChartData data, AppColorsBase c) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        tooltipRoundedRadius: 10,
        tooltipPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        getTooltipColor: (_) => c.surfaceTintHigh,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final i = spot.x.toInt();
            final dateLabel = (i >= 0 && i < data.bucketDates.length)
                ? _fmtBucketLabelFull(data.bucketDates[i], data.resolution)
                : '';
            return LineTooltipItem(
              '$dateLabel\n₹${_fmtAmount(spot.y)}',
              TextStyle(
                color: spot.bar.color ?? c.accentPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            );
          }).toList();
        },
      ),
      handleBuiltInTouches: true,
      getTouchedSpotIndicator: (barData, spotIndexes) {
        return spotIndexes.map((_) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: c.borderSubtle,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
            FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: bar.color ?? c.accentPrimary,
                strokeWidth: 2,
                strokeColor: Colors.black,
              ),
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildLegend(SpendChartData data, AppColorsBase c) {
    final entries = data.categorySeries.entries
        .where((e) => !e.value.every((v) => v == 0))
        .toList();

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: entries.map((e) {
        final color = c.categories.forCategory(e.key).base;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(e.key, style: TextStyle(color: c.secondaryText, fontSize: 11)),
          ],
        );
      }).toList(),
    );
  }

  static String _fmtAmount(double value) {
    if (value >= 100000) {
      final v = value / 100000;
      return '${v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1)}L';
    }
    if (value >= 1000) {
      final v = value / 1000;
      return '${v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  static String _fmtBucketLabel(DateTime d, ChartResolution res) {
    final thisYear = DateTime.now().year;
    final yearSuffix =
        d.year != thisYear ? ' \'${d.year.toString().substring(2)}' : '';
    switch (res) {
      case ChartResolution.daily:
        return '${d.day} ${_months[d.month - 1]}$yearSuffix';
      case ChartResolution.weekly:
        return '${d.day} ${_months[d.month - 1]}$yearSuffix';
      case ChartResolution.monthly:
      case ChartResolution.yearly:
        return '${_months[d.month - 1]} ${d.year.toString().substring(2)}';
    }
  }

  static String _fmtBucketLabelFull(DateTime d, ChartResolution res) {
    switch (res) {
      case ChartResolution.daily:
        return '${d.day} ${_months[d.month - 1]} ${d.year}';
      case ChartResolution.weekly:
        return 'Wk of ${d.day} ${_months[d.month - 1]}';
      case ChartResolution.monthly:
      case ChartResolution.yearly:
        return '${_months[d.month - 1]} ${d.year}';
    }
  }

  Widget _buildSavingsChart(SpendChartData data, AppColorsBase c) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.savingsSeries.length; i++) {
      spots.add(FlSpot(i.toDouble(), data.savingsSeries[i]));
    }

    // green when positive (saved), red-ish when negative (overspent)
    const savingsColor = Color(0xFF4CAF50);
    const deficitColor = Color(0xFFFF5252);

    // When all values are equal (e.g. single month), add padding so the
    // point is rendered at mid-height and the y-axis has something to show.
    final allEqual = spots.every((s) => s.y == spots.first.y);
    final singleVal = allEqual ? spots.first.y : 0.0;
    final minY = allEqual ? singleVal - singleVal.abs().clamp(500, double.infinity) : null;
    final maxY = allEqual ? singleVal + singleVal.abs().clamp(500, double.infinity) : null;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: spots.length > 1,
            curveSmoothness: 0.2,
            preventCurveOverShooting: true,
            color: savingsColor,
            barWidth: 1.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: spots.length == 1,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 5,
                color: spot.y >= 0 ? savingsColor : deficitColor,
                strokeWidth: 2,
                strokeColor: Colors.black,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  savingsColor.withValues(alpha: 0.25),
                  savingsColor.withValues(alpha: 0.0),
                ],
              ),
            ),
            aboveBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  deficitColor.withValues(alpha: 0.18),
                  deficitColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 0,
              color: Colors.white.withValues(alpha: 0.18),
              strokeWidth: 1,
              dashArray: [5, 4],
            ),
          ],
        ),
        gridData: _gridData(c),
        titlesData: _savingsTitlesData(data, c),
        borderData: FlBorderData(show: false),
        lineTouchData: _savingsTouchData(data, c),
      ),
    );
  }

  FlTitlesData _savingsTitlesData(SpendChartData data, AppColorsBase c) {
    final count = data.savingsMonthlyDates.length;
    final interval = count <= 6 ? 1 : (count ~/ 5).clamp(1, count);
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 46,
          getTitlesWidget: (value, meta) {
            if (value == meta.min || value == meta.max) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                _fmtAmount(value),
                style: TextStyle(color: c.secondaryText, fontSize: 10),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: interval.toDouble(),
          getTitlesWidget: (value, meta) {
            final i = value.toInt();
            if (i < 0 || i >= count) return const SizedBox.shrink();
            final d = data.savingsMonthlyDates[i];
            final label = data.savingsResolution == ChartResolution.yearly
                ? '${d.year}'
                : '${_months[d.month - 1]} ${d.year.toString().substring(2)}';
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(label, style: TextStyle(color: c.secondaryText, fontSize: 10)),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  LineTouchData _savingsTouchData(SpendChartData data, AppColorsBase c) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        tooltipRoundedRadius: 10,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        getTooltipColor: (_) => c.surfaceTintHigh,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final i = spot.x.toInt();
            String label = '';
            if (i >= 0 && i < data.savingsMonthlyDates.length) {
              final d = data.savingsMonthlyDates[i];
              label = data.savingsResolution == ChartResolution.yearly
                  ? '${d.year}\n'
                  : '${_months[d.month - 1]} ${d.year}\n';
            }
            final value = spot.y;
            final isPositive = value >= 0;
            return LineTooltipItem(
              '$label${isPositive ? '+' : ''}₹${_fmtAmount(value.abs())}',
              TextStyle(
                color: isPositive
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF5252),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            );
          }).toList();
        },
      ),
      handleBuiltInTouches: true,
      getTouchedSpotIndicator: (barData, spotIndexes) {
        return spotIndexes.map((_) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: Colors.white.withValues(alpha: 0.2),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
            FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: spot.y >= 0
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF5252),
                strokeWidth: 2,
                strokeColor: Colors.black,
              ),
            ),
          );
        }).toList();
      },
    );
  }
}

// ── Internal widgets ────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});
  final ChartMode mode;
  final ValueChanged<ChartMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      children: [
        _ToggleItem(
          label: 'Total',
          selected: mode == ChartMode.total,
          color: c.expenseNegative,
          onTap: () => onChanged(ChartMode.total),
        ),
        const SizedBox(width: 8),
        _ToggleItem(
          label: 'By Category',
          selected: mode == ChartMode.byCategory,
          color: c.accentPrimary,
          onTap: () => onChanged(ChartMode.byCategory),
        ),
        const SizedBox(width: 8),
        _ToggleItem(
          label: 'Savings',
          selected: mode == ChartMode.savings,
          color: c.incomePositive,
          onTap: () => onChanged(ChartMode.savings),
        ),
      ],
    );
  }
}

class _ToggleItem extends StatelessWidget {
  const _ToggleItem({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : c.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : c.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
