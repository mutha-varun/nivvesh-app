import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GroupingType { category, period }
enum PeriodType { weekly, monthly, yearly }

class FinanceFilterState {
  final int selectedYear;
  final int? selectedMonth;
  final Set<String> selectedCategories;
  final GroupingType grouping;
  final PeriodType periodType;

  FinanceFilterState({
    required this.selectedYear,
    this.selectedMonth,
    this.selectedCategories = const {},
    this.grouping = GroupingType.category,
    this.periodType = PeriodType.weekly,
  });

  FinanceFilterState copyWith({
    int? year,
    int? month,
    Set<String>? selectedCategories,
    GroupingType? grouping,
    PeriodType? periodType,
  }) {
    return FinanceFilterState(
      selectedYear: year ?? selectedYear,
      selectedMonth: month == -1 ? null : (month ?? selectedMonth),
      selectedCategories: selectedCategories ?? this.selectedCategories,
      grouping: grouping ?? this.grouping,
      periodType: periodType ?? this.periodType,
    );
  }
}

final filterProvider = StateProvider<FinanceFilterState>((ref) {
  final now = DateTime.now();
  return FinanceFilterState(selectedYear: now.year, selectedMonth: now.month);
});