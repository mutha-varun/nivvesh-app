import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/domain/models/finance_model.dart';
import 'package:nivvesh/application/transactions/filter_provider.dart';
import 'package:nivvesh/application/transactions/spend_provider.dart';

class PeriodAggregate {
  final String label;
  final String sortKey;
  final double total;
  final int count;

  const PeriodAggregate({
    required this.label,
    required this.sortKey,
    required this.total,
    required this.count,
  });
}

class FilteredFinanceResult {
  final List<FinanceModel> filteredTransactions;
  final Map<String, List<FinanceModel>> categoryGroups;
  final List<PeriodAggregate> periodAggregates;

  const FilteredFinanceResult({
    required this.filteredTransactions,
    required this.categoryGroups,
    required this.periodAggregates,
  });
}

final filteredFinanceProvider = Provider<FilteredFinanceResult>((ref) {
  final allMessages = ref.watch(financeControllerProvider).messages;
  final filter = ref.watch(filterProvider);

  final filtered = allMessages.where((m) {
    final dateMatch =
        !m.date.isBefore(filter.dateFrom) && !m.date.isAfter(filter.dateTo);
    final categoryMatch = filter.selectedCategories.isEmpty ||
        filter.selectedCategories.contains(m.category);
    return dateMatch && categoryMatch;
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  final categoryGroups = <String, List<FinanceModel>>{};
  for (final m in filtered) {
    categoryGroups.putIfAbsent(m.category, () => []).add(m);
  }

  final periodAggregatesMap = <String, _AggregateBucket>{};
  for (final m in filtered) {
    final key = _periodKey(m.date, filter.periodType);
    final label = _periodLabel(m.date, filter.periodType);
    final bucket = periodAggregatesMap.putIfAbsent(
      key,
      () => _AggregateBucket(label: label),
    );
    bucket.total += m.amount;
    bucket.count += 1;
  }

  final periodAggregates = periodAggregatesMap.entries
      .map((e) => PeriodAggregate(
            label: e.value.label,
            sortKey: e.key,
            total: e.value.total,
            count: e.value.count,
          ))
      .toList()
    ..sort((a, b) => b.sortKey.compareTo(a.sortKey));

  return FilteredFinanceResult(
    filteredTransactions: filtered,
    categoryGroups: categoryGroups,
    periodAggregates: periodAggregates,
  );
});

String _periodKey(DateTime date, PeriodType type) {
  switch (type) {
    case PeriodType.weekly:
      final week = ((date.day - 1) ~/ 7) + 1;
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-W$week';
    case PeriodType.monthly:
      return '${date.year}-${date.month.toString().padLeft(2, '0')}';
    case PeriodType.yearly:
      return '${date.year}';
  }
}

String _periodLabel(DateTime date, PeriodType type) {
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
  switch (type) {
    case PeriodType.weekly:
      final week = ((date.day - 1) ~/ 7) + 1;
      return 'Week $week - ${months[date.month - 1]} ${date.year}';
    case PeriodType.monthly:
      return '${months[date.month - 1]} ${date.year}';
    case PeriodType.yearly:
      return '${date.year}';
  }
}

class _AggregateBucket {
  final String label;
  double total = 0;
  int count = 0;

  _AggregateBucket({required this.label});
}