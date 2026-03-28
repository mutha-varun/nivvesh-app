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

  static final _gold = AppColors.dark.gold;
  static final _surface = AppColors.dark.cardSurface;
  static final _muted = AppColors.dark.muted;
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.28)),
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
            child: _mode == ChartMode.total
                ? _buildTotalChart(data)
                : _buildCategoryChart(data),
          ),
          if (_mode == ChartMode.byCategory &&
              data.categorySeries.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildLegend(data),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalChart(SpendChartData data) {
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
            curveSmoothness: 0.3,
            color: _gold,
            barWidth: 1.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _gold.withValues(alpha: 0.3),
                  _gold.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        gridData: _gridData(),
        titlesData: _titlesData(data),
        borderData: FlBorderData(show: false),
        lineTouchData: _touchData(data),
        minY: 0,
      ),
    );
  }

  Widget _buildCategoryChart(SpendChartData data) {
    final bars = <LineChartBarData>[];
    final activeEntries = data.categorySeries.entries
        .where((e) => !e.value.every((v) => v == 0))
        .toList();

    for (final entry in activeEntries) {
      final color = categoryChartColors[entry.key] ?? Colors.grey;
      final spots = <FlSpot>[];
      for (int i = 0; i < entry.value.length; i++) {
        spots.add(FlSpot(i.toDouble(), entry.value[i]));
      }

      bars.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.3,
        color: color,
        barWidth: 1.2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ));
    }

    return LineChart(
      LineChartData(
        lineBarsData: bars,
        gridData: _gridData(),
        titlesData: _titlesData(data),
        borderData: FlBorderData(show: false),
        lineTouchData: _touchData(data),
        minY: 0,
      ),
    );
  }

  FlGridData _gridData() => FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(
          color: Colors.white.withValues(alpha: 0.06),
          strokeWidth: 1,
        ),
      );

  FlTitlesData _titlesData(SpendChartData data) {
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
                style: TextStyle(color: _muted, fontSize: 10),
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
                style: TextStyle(color: _muted, fontSize: 10),
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

  LineTouchData _touchData(SpendChartData data) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        tooltipRoundedRadius: 10,
        tooltipPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        getTooltipColor: (_) => const Color(0xFF1A1A1A),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final i = spot.x.toInt();
            final dateLabel = (i >= 0 && i < data.bucketDates.length)
                ? _fmtBucketLabelFull(data.bucketDates[i], data.resolution)
                : '';
            return LineTooltipItem(
              '$dateLabel\n₹${_fmtAmount(spot.y)}',
              TextStyle(
                color: spot.bar.color ?? _gold,
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
              color: _gold.withValues(alpha: 0.3),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
            FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: bar.color ?? _gold,
                strokeWidth: 2,
                strokeColor: Colors.black,
              ),
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildLegend(SpendChartData data) {
    final entries = data.categorySeries.entries
        .where((e) => !e.value.every((v) => v == 0))
        .toList();

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: entries.map((e) {
        final color = categoryChartColors[e.key] ?? Colors.grey;
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
            Text(e.key, style: TextStyle(color: _muted, fontSize: 11)),
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
        return '${_months[d.month - 1]} ${d.year}';
    }
  }
}

// ── Internal widgets ────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});
  final ChartMode mode;
  final ValueChanged<ChartMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final gold = AppColors.dark.gold;
    return Row(
      children: [
        _ToggleItem(
          label: 'Total',
          selected: mode == ChartMode.total,
          color: gold,
          onTap: () => onChanged(ChartMode.total),
        ),
        const SizedBox(width: 8),
        _ToggleItem(
          label: 'By Category',
          selected: mode == ChartMode.byCategory,
          color: gold,
          onTap: () => onChanged(ChartMode.byCategory),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
