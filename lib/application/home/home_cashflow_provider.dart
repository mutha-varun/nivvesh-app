import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/transactions/spend_provider.dart';

enum HomePeriod { m1, m3, m6, y1 }

enum HomeGraphMode { overview, category }

class CashflowPoint {
  final DateTime time;
  final double value;

  const CashflowPoint({required this.time, required this.value});
}

class CategoryBucket {
  final String category;
  final List<CashflowPoint> points;

  const CategoryBucket({required this.category, required this.points});
}

class HomeCashflowSeries {
  final List<CategoryBucket> buckets;
  final List<DateTime> timeAxis;
  final DateTime rangeStart;
  final DateTime rangeEnd;

  const HomeCashflowSeries({
    required this.buckets,
    required this.timeAxis,
    required this.rangeStart,
    required this.rangeEnd,
  });
}

final homePeriodProvider = StateProvider<HomePeriod>((ref) => HomePeriod.m3);
final homeGraphModeProvider =
  StateProvider<HomeGraphMode>((ref) => HomeGraphMode.overview);

const _categoryOrder = <String>[
  'Food',
  'Shopping',
  'Transport',
  'Entertainment',
  'Bills',
  'Health',
  'Investment',
  'Others',
];

final homeCashflowProvider = Provider<HomeCashflowSeries>((ref) {
  final period = ref.watch(homePeriodProvider);
  final messages = ref.watch(financeControllerProvider).messages;
  final now = DateTime.now();

  final config = _periodConfig(period, now);
  final axis = _buildAxis(config.start, config.end, config.bucket, config.monthly);

  final buckets = {
    for (final category in _categoryOrder)
      category: List<double>.filled(axis.length, 0),
  };

  for (final message in messages) {
    final date = message.date;
    if (date.isBefore(config.start) || !date.isBefore(config.end)) {
      continue;
    }

    final category = _canonicalCategory(message.category);
    final index = _bucketIndexFor(date, axis, config.end);
    if (index < 0 || index >= axis.length) {
      continue;
    }

    buckets[category]![index] += message.amount;
  }

  final categoryBuckets = _categoryOrder
      .map(
        (category) => CategoryBucket(
          category: category,
          points: List.generate(
            axis.length,
            (index) => CashflowPoint(
              time: axis[index],
              value: buckets[category]![index],
            ),
          ),
        ),
      )
      .toList(growable: false);

  return HomeCashflowSeries(
    buckets: categoryBuckets,
    timeAxis: axis,
    rangeStart: config.start,
    rangeEnd: config.end,
  );
});

String _canonicalCategory(String raw) {
  final value = raw.toLowerCase();

  if (value.contains('food')) return 'Food';
  if (value.contains('shopping')) return 'Shopping';
  if (value.contains('transport')) return 'Transport';
  if (value.contains('entertainment')) return 'Entertainment';
  if (value.contains('bill')) return 'Bills';
  if (value.contains('health')) return 'Health';
  if (value.contains('investment')) return 'Investment';

  return 'Others';
}

int _bucketIndexFor(DateTime date, List<DateTime> axis, DateTime end) {
  for (var i = axis.length - 1; i >= 0; i--) {
    final bucketStart = axis[i];
    final bucketEnd = i == axis.length - 1 ? end : axis[i + 1];
    if (!date.isBefore(bucketStart) && date.isBefore(bucketEnd)) {
      return i;
    }
  }
  return -1;
}

List<DateTime> _buildAxis(DateTime start, DateTime end, Duration bucket, bool monthly) {
  if (monthly) {
    final points = <DateTime>[];
    var cursor = DateTime(start.year, start.month, 1);
    while (cursor.isBefore(end)) {
      points.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }
    return points;
  }

  final points = <DateTime>[];
  var cursor = start;
  while (cursor.isBefore(end)) {
    points.add(cursor);
    cursor = cursor.add(bucket);
  }
  return points;
}

({DateTime start, DateTime end, Duration bucket, bool monthly}) _periodConfig(
  HomePeriod period,
  DateTime now,
) {
  final end = DateTime(now.year, now.month, now.day + 1);

  switch (period) {
    case HomePeriod.m1:
      return (
        start: end.subtract(const Duration(days: 30)),
        end: end,
        bucket: const Duration(days: 1),
        monthly: false,
      );
    case HomePeriod.m3:
      return (
        start: end.subtract(const Duration(days: 90)),
        end: end,
        bucket: const Duration(days: 7),
        monthly: false,
      );
    case HomePeriod.m6:
      return (
        start: end.subtract(const Duration(days: 180)),
        end: end,
        bucket: const Duration(days: 14),
        monthly: false,
      );
    case HomePeriod.y1:
      return (
        start: end.subtract(const Duration(days: 365)),
        end: end,
        bucket: const Duration(days: 30),
        monthly: true,
      );
  }
}
