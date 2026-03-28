import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/transactions/filter_provider.dart';
import 'package:nivvesh/application/transactions/filter_finance_provider.dart';
import 'package:nivvesh/core/constants/payment_category.dart';

enum ChartMode { total, byCategory }

enum ChartResolution { daily, weekly, monthly }

ChartResolution autoResolution(DateTime from, DateTime to) {
  final days = to.difference(from).inDays;
  if (days > 365 * 10) return ChartResolution.monthly;
  if (days > 365) return ChartResolution.weekly;
  return ChartResolution.daily;
}

class SpendChartData {
  final ChartResolution resolution;
  final List<DateTime> bucketDates;
  final List<double> totalSeries;
  final Map<String, List<double>> categorySeries;

  const SpendChartData({
    required this.resolution,
    required this.bucketDates,
    required this.totalSeries,
    required this.categorySeries,
  });
}

const categoryChartColors = <String, Color>{
  PaymentCategories.food: Color(0xFFFF9800),
  PaymentCategories.shopping: Color(0xFFE91E63),
  PaymentCategories.transport: Color(0xFF2196F3),
  PaymentCategories.entertainment: Color(0xFF9C27B0),
  PaymentCategories.bills: Color(0xFFFFEB3B),
  PaymentCategories.health: Color(0xFF4CAF50),
  PaymentCategories.investment: Color(0xFF00BCD4),
  PaymentCategories.creditCategory: Color(0xFF8BC34A),
  PaymentCategories.uncategorized: Color(0xFF9E9E9E),
};

final chartModeProvider = StateProvider<ChartMode>((ref) => ChartMode.total);

final spendChartDataProvider = Provider<SpendChartData>((ref) {
  final result = ref.watch(filteredFinanceProvider);
  final filter = ref.watch(filterProvider);
  final transactions = result.filteredTransactions;

  final resolution = autoResolution(filter.dateFrom, filter.dateTo);
  final bucketDates =
      _generateBuckets(filter.dateFrom, filter.dateTo, resolution);

  // Build key -> index map for O(1) lookup
  final keyToIndex = <String, int>{};
  for (int i = 0; i < bucketDates.length; i++) {
    keyToIndex[_bucketKey(bucketDates[i])] = i;
  }

  final totalSeries = List<double>.filled(bucketDates.length, 0);

  // Collect debit categories
  final categories = <String>{};
  for (final t in transactions) {
    if (t.category != PaymentCategories.creditCategory) {
      categories.add(t.category);
    }
  }

  final categorySeries = <String, List<double>>{};
  for (final cat in categories) {
    categorySeries[cat] = List<double>.filled(bucketDates.length, 0);
  }

  for (final t in transactions) {
    if (t.category == PaymentCategories.creditCategory) continue;
    final key = _bucketKey(_bucketStart(t.date, resolution));
    final idx = keyToIndex[key];
    if (idx != null) {
      totalSeries[idx] += t.amount;
      categorySeries[t.category]?[idx] += t.amount;
    }
  }

  return SpendChartData(
    resolution: resolution,
    bucketDates: bucketDates,
    totalSeries: totalSeries,
    categorySeries: categorySeries,
  );
});


List<DateTime> _generateBuckets(
    DateTime from, DateTime to, ChartResolution res) {
  final buckets = <DateTime>[];
  var current = _bucketStart(from, res);
  while (!current.isAfter(to)) {
    buckets.add(current);
    current = _nextBucket(current, res);
  }
  return buckets;
}

DateTime _bucketStart(DateTime date, ChartResolution res) {
  switch (res) {
    case ChartResolution.daily:
      return DateTime(date.year, date.month, date.day);
    case ChartResolution.weekly:
      final weekday = date.weekday; // Monday = 1
      return DateTime(date.year, date.month, date.day - (weekday - 1));
    case ChartResolution.monthly:
      return DateTime(date.year, date.month);
  }
}

DateTime _nextBucket(DateTime current, ChartResolution res) {
  switch (res) {
    case ChartResolution.daily:
      return current.add(const Duration(days: 1));
    case ChartResolution.weekly:
      return current.add(const Duration(days: 7));
    case ChartResolution.monthly:
      return DateTime(current.year, current.month + 1);
  }
}

String _bucketKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
