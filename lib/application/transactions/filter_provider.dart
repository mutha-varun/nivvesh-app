import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GroupingType { category, period }
enum PeriodType { weekly, monthly, yearly }

FinanceFilterState defaultFilter() {
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  return FinanceFilterState(
    dateFrom: DateTime(thirtyDaysAgo.year, thirtyDaysAgo.month, thirtyDaysAgo.day),
    dateTo: DateTime(now.year, now.month, now.day, 23, 59, 59),
  );
}

class FinanceFilterState {
  final DateTime dateFrom;
  final DateTime dateTo;
  final Set<String> selectedCategories;
  final GroupingType grouping;
  final PeriodType periodType;

  FinanceFilterState({
    required this.dateFrom,
    required this.dateTo,
    this.selectedCategories = const {},
    this.grouping = GroupingType.category,
    this.periodType = PeriodType.weekly,
  });

  bool get hasNonDefaultDateRange {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final defFrom = DateTime(thirtyDaysAgo.year, thirtyDaysAgo.month, thirtyDaysAgo.day);
    return dateFrom != defFrom ||
        dateTo.year != now.year ||
        dateTo.month != now.month ||
        dateTo.day != now.day;
  }

  bool get hasCategories => selectedCategories.isNotEmpty;

  bool get hasNonDefaultGrouping => grouping != GroupingType.category;

  bool get hasAnyNonDefault =>
      hasNonDefaultDateRange ||
      hasCategories ||
      hasNonDefaultGrouping ||
      (grouping == GroupingType.period && periodType != PeriodType.weekly);

  FinanceFilterState copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    Set<String>? selectedCategories,
    GroupingType? grouping,
    PeriodType? periodType,
  }) {
    return FinanceFilterState(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      grouping: grouping ?? this.grouping,
      periodType: periodType ?? this.periodType,
    );
  }
}

final filterProvider = StateProvider<FinanceFilterState>((ref) {
  return defaultFilter();
});
