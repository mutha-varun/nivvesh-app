import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // Income = credits parsed from SMS this month.
  final monthIncome = monthMessages
      .where((m) => m.category == PaymentCategories.creditCategory)
      .fold<double>(0, (sum, m) => sum + m.amount);

  return HomeSummary(
    monthIncome: monthIncome,
    monthSpend: monthSpend,
    monthRemaining: monthIncome - monthSpend,
  );
});
