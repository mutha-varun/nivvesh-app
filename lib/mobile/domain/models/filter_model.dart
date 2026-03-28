enum GroupingType { category, date }
enum TimeFrame { weekly, monthly, yearly }

class FinanceFilter {
  final DateTime? selectedDate; // To pick March, or 2026, etc.
  final List<String> selectedCategories;
  final GroupingType grouping;
  final TimeFrame timeFrame;

  FinanceFilter({
    this.selectedDate,
    this.selectedCategories = const [],
    this.grouping = GroupingType.category,
    this.timeFrame = TimeFrame.monthly,
  });

  // Add a copyWith method for Riverpod updates
}