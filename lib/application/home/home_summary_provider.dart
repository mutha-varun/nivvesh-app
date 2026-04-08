import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/transactions/alert_config.dart';
import 'package:nivvesh/application/transactions/spend_provider.dart';
import 'package:nivvesh/core/constants/payment_category.dart';

class HomeSummary {
  final double monthIncome;
  final double monthSpend;
  final double monthRemaining;

  const HomeSummary({
    required this.monthIncome,
    required this.monthSpend,
    required this.monthRemaining,
  });
}

final homeSummaryProvider = Provider<HomeSummary>((ref) {
  final manualSalary = ref.watch(alertConfigProvider).salary;
  final allMessages = ref.watch(financeControllerProvider).messages;

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 1);

  final monthMessages = allMessages.where(
    (m) => !m.date.isBefore(monthStart) && m.date.isBefore(monthEnd),
  );

  // Spend = debits this month (matches SummaryBar / history page).
  final monthSpend = monthMessages
      .where((m) => m.category != PaymentCategories.creditCategory)
      .fold<double>(0, (sum, m) => sum + m.amount);

  // Credits parsed from SMS this month.
  final creditSum = monthMessages
      .where((m) => m.category == PaymentCategories.creditCategory)
      .fold<double>(0, (sum, m) => sum + m.amount);

  // Manual salary (from tap-to-edit on balance card or bell icon sheet)
  // wins over the credits sum; fall back to credits when nothing is set.
  final monthIncome = manualSalary > 0 ? manualSalary : creditSum;

  return HomeSummary(
    monthIncome: monthIncome,
    monthSpend: monthSpend,
    monthRemaining: monthIncome - monthSpend,
  );
});
