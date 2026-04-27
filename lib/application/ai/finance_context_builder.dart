import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/journey/journey_controller.dart';
import 'package:nivvesh/application/transactions/alert_config.dart';
import 'package:nivvesh/application/transactions/spend_provider.dart';
import 'package:nivvesh/core/constants/payment_category.dart';
import 'package:nivvesh/domain/models/finance_model.dart';
import 'package:nivvesh/domain/models/requests/journey.dart';

/// Snapshot of the user's finances assembled for the AI model.
///
/// Strategy: avoid dumping every transaction. Instead, pre-aggregate at three
/// granularities the model can reason over:
///   1. Lifetime totals + per-category top spends (high-level baseline)
///   2. Monthly time series for the last 12 months (trend detection)
///   3. Current + previous month per-category breakdown (recent focus)
/// Plus a small tail of the most recent raw transactions for specific recall.
class FinanceContext {
  const FinanceContext({
    required this.monthLabel,
    required this.monthlyIncome,
    required this.thisMonth,
    required this.lastMonth,
    required this.lifetime,
    required this.monthlyTimeline,
    required this.thisMonthByCategory,
    required this.lastMonthByCategory,
    required this.lifetimeByCategory,
    required this.categoryLimits,
    required this.recentTransactions,
    required this.journeys,
    required this.totalTransactionCount,
    required this.firstTransactionDate,
  });

  final String monthLabel;
  final double monthlyIncome;
  final PeriodTotals thisMonth;
  final PeriodTotals lastMonth;
  final PeriodTotals lifetime;

  /// Last 12 months, oldest first.
  final List<MonthlyPoint> monthlyTimeline;

  final Map<String, double> thisMonthByCategory;
  final Map<String, double> lastMonthByCategory;
  final Map<String, double> lifetimeByCategory;
  final Map<String, double> categoryLimits;

  final List<FinanceModel> recentTransactions;
  final List<JourneyItem> journeys;
  final int totalTransactionCount;
  final DateTime? firstTransactionDate;

  String render() {
    final buf = StringBuffer()
      ..writeln('USER FINANCE SNAPSHOT (current month: $monthLabel)')
      ..writeln('Configured monthly income: ₹${_fmt(monthlyIncome)}');

    if (firstTransactionDate != null) {
      buf.writeln(
        'Tracked transactions: $totalTransactionCount '
        '(since ${_dateStr(firstTransactionDate!)})',
      );
    }

    buf
      ..writeln()
      ..writeln('TOTALS')
      ..writeln('  This month  → debit ₹${_fmt(thisMonth.debit)}, '
          'credit ₹${_fmt(thisMonth.credit)}, '
          'net ₹${_fmt(thisMonth.net)}')
      ..writeln('  Last month  → debit ₹${_fmt(lastMonth.debit)}, '
          'credit ₹${_fmt(lastMonth.credit)}, '
          'net ₹${_fmt(lastMonth.net)}')
      ..writeln('  Lifetime    → debit ₹${_fmt(lifetime.debit)}, '
          'credit ₹${_fmt(lifetime.credit)}, '
          'net ₹${_fmt(lifetime.net)}');

    if (monthlyTimeline.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('MONTHLY TIMELINE (last ${monthlyTimeline.length} months, oldest first)');
      for (final p in monthlyTimeline) {
        buf.writeln(
          '  ${p.label}: debit ₹${_fmt(p.debit)}, credit ₹${_fmt(p.credit)}, '
          'net ₹${_fmt(p.credit - p.debit)}',
        );
      }
    }

    void writeCategoryBlock(String title, Map<String, double> map, {int? topN}) {
      if (map.isEmpty) return;
      buf
        ..writeln()
        ..writeln(title);
      final sorted = map.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final list = topN != null ? sorted.take(topN) : sorted;
      for (final e in list) {
        final limit = categoryLimits[e.key] ?? 0;
        final limitStr = limit > 0 ? ' (limit ₹${_fmt(limit)})' : '';
        buf.writeln('  - ${e.key}: ₹${_fmt(e.value)}$limitStr');
      }
    }

    writeCategoryBlock('SPEND BY CATEGORY — THIS MONTH', thisMonthByCategory);
    writeCategoryBlock('SPEND BY CATEGORY — LAST MONTH', lastMonthByCategory);
    writeCategoryBlock(
      'SPEND BY CATEGORY — LIFETIME (top 10)',
      lifetimeByCategory,
      topN: 10,
    );

    if (journeys.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('SAVINGS GOALS');
      for (final j in journeys) {
        final pct = j.amount == 0 ? 0 : (j.progress * 100 / j.amount).round();
        buf.writeln(
          '  - ${j.goalName}: ₹${j.progress}/₹${j.amount} ($pct%) by ${j.time}'
          '${j.isComplete ? ' [done]' : ''}',
        );
      }
    }

    if (recentTransactions.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('RECENT TRANSACTIONS (latest ${recentTransactions.length})');
      for (final t in recentTransactions) {
        buf.writeln(
          '  - ${_dateStr(t.date)} | ${t.category} | ₹${_fmt(t.amount)} | ${t.application}',
        );
      }
    }

    return buf.toString();
  }
}

class PeriodTotals {
  const PeriodTotals({required this.debit, required this.credit});
  final double debit;
  final double credit;
  double get net => credit - debit;
}

class MonthlyPoint {
  const MonthlyPoint({
    required this.label,
    required this.debit,
    required this.credit,
  });
  final String label;
  final double debit;
  final double credit;
}

final financeContextProvider = Provider<FinanceContext>((ref) {
  final finance = ref.watch(financeControllerProvider);
  final alerts = ref.watch(alertConfigProvider);
  final journeysAsync = ref.watch(journeysControllerProvider);

  final all = finance.messages;
  final now = DateTime.now();
  final thisMonthStart = DateTime(now.year, now.month, 1);
  final lastMonthStart = DateTime(now.year, now.month - 1, 1);

  bool isCredit(FinanceModel t) => t.category == PaymentCategories.creditCategory;

  PeriodTotals totalsFor(Iterable<FinanceModel> txns) {
    var d = 0.0, c = 0.0;
    for (final t in txns) {
      if (isCredit(t)) {
        c += t.amount;
      } else {
        d += t.amount;
      }
    }
    return PeriodTotals(debit: d, credit: c);
  }

  Map<String, double> categorySpend(Iterable<FinanceModel> txns) {
    final m = <String, double>{};
    for (final t in txns) {
      if (isCredit(t)) continue;
      m.update(t.category, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    return m;
  }

  final thisMonthTxns =
      all.where((t) => !t.date.isBefore(thisMonthStart)).toList();
  final lastMonthTxns = all
      .where((t) =>
          !t.date.isBefore(lastMonthStart) && t.date.isBefore(thisMonthStart))
      .toList();

  // 12-month timeline, oldest first.
  final timeline = <MonthlyPoint>[];
  for (var i = 11; i >= 0; i--) {
    final start = DateTime(now.year, now.month - i, 1);
    final end = DateTime(now.year, now.month - i + 1, 1);
    final bucket =
        all.where((t) => !t.date.isBefore(start) && t.date.isBefore(end));
    final tot = totalsFor(bucket);
    timeline.add(
      MonthlyPoint(
        label: '${_monthName(start.month)} ${start.year}',
        debit: tot.debit,
        credit: tot.credit,
      ),
    );
  }

  final lifetimeTotals = totalsFor(all);
  final income =
      alerts.monthlyIncome > 0 ? alerts.monthlyIncome : totalsFor(thisMonthTxns).credit;

  final journeys = journeysAsync.maybeWhen(
    data: (r) => r.journeys,
    orElse: () => const <JourneyItem>[],
  );

  return FinanceContext(
    monthLabel: '${_monthName(now.month)} ${now.year}',
    monthlyIncome: income,
    thisMonth: totalsFor(thisMonthTxns),
    lastMonth: totalsFor(lastMonthTxns),
    lifetime: lifetimeTotals,
    monthlyTimeline: timeline,
    thisMonthByCategory: categorySpend(thisMonthTxns),
    lastMonthByCategory: categorySpend(lastMonthTxns),
    lifetimeByCategory: categorySpend(all),
    categoryLimits: alerts.categoryLimits,
    recentTransactions: all.take(20).toList(),
    journeys: journeys,
    totalTransactionCount: all.length,
    firstTransactionDate: all.isEmpty ? null : all.last.date,
  );
});

String _monthName(int m) {
  // Handle wrap-around for negative months from `month - i` arithmetic.
  final idx = ((m - 1) % 12 + 12) % 12;
  return const [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ][idx];
}

String _dateStr(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _fmt(double v) {
  if (v == 0) return '0';
  return v.toStringAsFixed(v.abs() < 100 ? 2 : 0);
}
