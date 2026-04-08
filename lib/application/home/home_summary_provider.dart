import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/transactions/alert_config.dart';
import 'package:nivvesh/application/transactions/spend_provider.dart';

class HomeSummary {
  final double salary;
  final double monthSpend;
  final double monthRemaining;
  final bool salaryConfigured;

  const HomeSummary({
    required this.salary,
    required this.monthSpend,
    required this.monthRemaining,
    required this.salaryConfigured,
  });
}

final homeSummaryProvider = Provider<HomeSummary>((ref) {
  final salary = ref.watch(alertConfigProvider).salary;
  final allMessages = ref.watch(financeControllerProvider).messages;

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 1);

  final monthSpend = allMessages
      .where((m) => !m.date.isBefore(monthStart) && m.date.isBefore(monthEnd))
      .fold<double>(0, (sum, m) => sum + m.amount);

  return HomeSummary(
    salary: salary,
    monthSpend: monthSpend,
    monthRemaining: salary - monthSpend,
    salaryConfigured: salary > 0,
  );
});
