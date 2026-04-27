import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/journey/journey_controller.dart';
import 'package:nivvesh/application/transactions/alert_config.dart';
import 'package:nivvesh/application/transactions/spend_provider.dart';
import 'package:nivvesh/core/constants/payment_category.dart';
import 'package:nivvesh/domain/models/finance_model.dart';
import 'package:nivvesh/domain/models/requests/journey.dart';

/// Snapshot of the user's finances assembled for the AI model.
/// Kept compact — current month aggregates plus a small recent-transaction tail.
class FinanceContext {
  const FinanceContext({
    required this.monthLabel,
    required this.monthlyIncome,
    required this.monthDebit,
    required this.monthCredit,
    required this.monthSavings,
    required this.spendByCategory,
    required this.categoryLimits,
    required this.recentTransactions,
    required this.journeys,
  });

  final String monthLabel;
  final double monthlyIncome;
  final double monthDebit;
  final double monthCredit;
  final double monthSavings;
  final Map<String, double> spendByCategory;
  final Map<String, double> categoryLimits;
  final List<FinanceModel> recentTransactions;
  final List<JourneyItem> journeys;

  /// Render as a short markdown-ish block the model can read.
  String render() {
    final buf = StringBuffer()
      ..writeln('User finance snapshot ($monthLabel):')
      ..writeln('- Monthly income (configured): ₹${monthlyIncome.toStringAsFixed(0)}')
      ..writeln('- Total credits this month: ₹${monthCredit.toStringAsFixed(0)}')
      ..writeln('- Total debits this month: ₹${monthDebit.toStringAsFixed(0)}')
      ..writeln('- Net savings this month: ₹${monthSavings.toStringAsFixed(0)}');

    if (spendByCategory.isNotEmpty) {
      buf.writeln('Spend by category this month:');
      final sorted = spendByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final e in sorted) {
        final limit = categoryLimits[e.key] ?? 0;
        final limitStr = limit > 0
            ? ' (limit ₹${limit.toStringAsFixed(0)})'
            : '';
        buf.writeln('  - ${e.key}: ₹${e.value.toStringAsFixed(0)}$limitStr');
      }
    }

    if (journeys.isNotEmpty) {
      buf.writeln('Active savings goals:');
      for (final j in journeys) {
        final pct = j.amount == 0 ? 0 : (j.progress * 100 / j.amount).round();
        buf.writeln(
          '  - ${j.goalName}: ₹${j.progress}/₹${j.amount} ($pct%) by ${j.time}'
          '${j.isComplete ? ' [done]' : ''}',
        );
      }
    }

    if (recentTransactions.isNotEmpty) {
      buf.writeln('Recent transactions (latest first):');
      for (final t in recentTransactions) {
        final d = t.date;
        final dateStr =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        buf.writeln(
          '  - $dateStr | ${t.category} | ₹${t.amount.toStringAsFixed(0)} | ${t.application}',
        );
      }
    }

    return buf.toString();
  }
}

final financeContextProvider = Provider<FinanceContext>((ref) {
  final finance = ref.watch(financeControllerProvider);
  final alerts = ref.watch(alertConfigProvider);
  final journeysAsync = ref.watch(journeysControllerProvider);

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final monthLabel =
      '${_monthName(now.month)} ${now.year}';

  final thisMonth = finance.messages
      .where((m) => !m.date.isBefore(monthStart))
      .toList();

  double monthDebit = 0;
  double monthCredit = 0;
  final spendByCategory = <String, double>{};
  for (final t in thisMonth) {
    if (t.category == PaymentCategories.creditCategory) {
      monthCredit += t.amount;
    } else {
      monthDebit += t.amount;
      spendByCategory.update(
        t.category,
        (v) => v + t.amount,
        ifAbsent: () => t.amount,
      );
    }
  }

  final income =
      alerts.monthlyIncome > 0 ? alerts.monthlyIncome : monthCredit;
  final savings = income - monthDebit;

  final recent = finance.messages.take(10).toList();

  final journeys = journeysAsync.maybeWhen(
    data: (r) => r.journeys,
    orElse: () => const <JourneyItem>[],
  );

  return FinanceContext(
    monthLabel: monthLabel,
    monthlyIncome: income,
    monthDebit: monthDebit,
    monthCredit: monthCredit,
    monthSavings: savings,
    spendByCategory: spendByCategory,
    categoryLimits: alerts.categoryLimits,
    recentTransactions: recent,
    journeys: journeys,
  );
});

String _monthName(int m) => const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][m - 1];
