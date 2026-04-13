import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/transactions/filter_finance_provider.dart';
import 'package:nivvesh/core/constants/payment_category.dart';
import 'package:nivvesh/domain/models/finance_model.dart';

class TransactionSearch {
  final String query;

  const TransactionSearch({this.query = ''});

  bool get isActive => query.isNotEmpty;

  TransactionSearch copyWith({String? query}) =>
      TransactionSearch(query: query ?? this.query);
}

class TransactionSearchNotifier extends StateNotifier<TransactionSearch> {
  TransactionSearchNotifier() : super(const TransactionSearch());

  void setQuery(String q) => state = state.copyWith(query: q);
  void reset() => state = const TransactionSearch();
}

final transactionSearchProvider =
    StateNotifierProvider<TransactionSearchNotifier, TransactionSearch>(
  (_) => TransactionSearchNotifier(),
);

/// Extracts a merchant display name from a transaction — mirrors
/// the _displayName() helper in spend_widgets.dart.
String _merchantName(FinanceModel m) {
  final bodyLower = m.body.toLowerCase();
  final catKws = PaymentCategories.keywords[m.category];
  if (catKws != null) {
    for (final kw in catKws) {
      if (bodyLower.contains(kw)) return kw;
    }
  }
  final vpaKws = PaymentCategories.vpaIdentifiers[m.category];
  if (vpaKws != null) {
    for (final kw in vpaKws) {
      final clean = kw.replaceAll('@', '').replaceAll('vpa:', '');
      if (bodyLower.contains(clean)) return clean;
    }
  }
  return m.application.toLowerCase();
}

/// Full month names (lowercased) indexed 1-12 for date-string search.
const _monthNames = [
  '', // index 0 unused
  'january', 'february', 'march', 'april', 'may', 'june',
  'july', 'august', 'september', 'october', 'november', 'december',
];
const _monthAbbr = [
  '',
  'jan', 'feb', 'mar', 'apr', 'may', 'jun',
  'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
];

/// Applies text search on top of the date-range/category-filtered list.
/// Matches: sender, category, full SMS body, extracted merchant keyword,
/// amount (digits), and date (e.g. "jan", "march", "2025").
final searchResultsProvider = Provider<List<FinanceModel>>((ref) {
  final allFiltered = ref.watch(filteredFinanceProvider).filteredTransactions;
  final search = ref.watch(transactionSearchProvider);

  if (!search.isActive) return allFiltered;

  final q = search.query.toLowerCase().trim();
  if (q.isEmpty) return allFiltered;

  return allFiltered.where((m) {
    // Sender app / bank code
    if (m.application.toLowerCase().contains(q)) return true;
    // Category label
    if (m.category.toLowerCase().contains(q)) return true;
    // Full raw SMS body — catches every merchant/keyword
    if (m.body.toLowerCase().contains(q)) return true;
    // Extracted merchant name (e.g. "swiggy", "netflix")
    if (_merchantName(m).contains(q)) return true;
    // Amount — "500" matches ₹500, "1500" matches ₹1,500
    if (m.amount.toStringAsFixed(0).contains(q)) return true;
    // Date — matches "jan", "january", "2025", "15"
    final month = m.date.month;
    if (_monthNames[month].contains(q)) return true;
    if (_monthAbbr[month].contains(q)) return true;
    if (m.date.year.toString().contains(q)) return true;
    if (m.date.day.toString() == q) return true;
    return false;
  }).toList();
});
