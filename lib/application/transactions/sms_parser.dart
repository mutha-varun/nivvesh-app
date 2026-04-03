import 'package:nivvesh/core/constants/payment_category.dart';
import 'package:nivvesh/domain/models/finance_model.dart';

/// Pure static SMS parsing logic extracted from FinanceController.
/// Shared by both the foreground UI flow and the background SMS handler.
class SmsParser {
  SmsParser._();

  static final List<RegExp> _amountRegexes = [
    RegExp(r'(?:INR|Rs\.?|₹)\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false),
    RegExp(
      r'(?:debited by|credited by|paid|payment(?:\s+of)?|withdrawn(?:\s+by)?|received|refund(?:\s+of)?|for)\s*(?:INR|Rs\.?|₹)?\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ),
  ];

  static const _debitKeywords = [
    'debited', 'deducted', 'spent', 'paid', 'payment of', 'withdrawn',
  ];
  static const _creditKeywords = [
    'credited', 'received', 'refund', 'cashback',
  ];
  static final _upiSenderRegex = RegExp(
    r'(?:^|[-_])sbiupi$|\b(?:vm|vk|vd|bz)-sbiupi\b|\bsbiupi\b',
    caseSensitive: false,
  );

  /// Parse an SMS into a [FinanceModel]. Returns null if not a financial SMS.
  static FinanceModel? parse({
    required int smsId,
    required String sender,
    required String body,
    required DateTime date,
  }) {
    final bodyLower = body.toLowerCase();
    final senderLower = sender.toLowerCase();

    final amount = _extractAmount(body);
    if (amount == null || amount <= 0) return null;

    final isDebit = _debitKeywords.any((k) => bodyLower.contains(k));
    final isCredit = _creditKeywords.any((k) => bodyLower.contains(k));
    final isUpiSender = _upiSenderRegex.hasMatch(senderLower);
    final hasTxnContext = PaymentCategories.transactionContextKeywords
        .any((k) => bodyLower.contains(k));

    if (!isDebit && !isCredit && !(isUpiSender && hasTxnContext)) return null;

    final effectiveIsDebit = isDebit || (!isCredit && isUpiSender);
    final category = inferCategory(bodyLower, effectiveIsDebit);

    String? transactionKeyword;
    final hints = effectiveIsDebit
        ? PaymentCategories.debitKeywordHints
        : PaymentCategories.creditKeywordHints;
    final found =
        hints.firstWhere((k) => bodyLower.contains(k), orElse: () => '');
    if (found.isNotEmpty) transactionKeyword = found;

    return FinanceModel(
      smsId: smsId,
      category: category,
      date: date,
      amount: amount,
      application: sender,
      triggerKeyword: transactionKeyword,
      body: body,
    );
  }

  /// Returns true if the parsed transaction is a debit.
  static bool isDebitSms(String body, String sender) {
    final bodyLower = body.toLowerCase();
    final senderLower = sender.toLowerCase();
    final isDebit = _debitKeywords.any((k) => bodyLower.contains(k));
    final isCredit = _creditKeywords.any((k) => bodyLower.contains(k));
    final isUpiSender = _upiSenderRegex.hasMatch(senderLower);
    return isDebit || (!isCredit && isUpiSender);
  }

  static double? _extractAmount(String body) {
    for (final regex in _amountRegexes) {
      final match = regex.firstMatch(body);
      if (match == null) continue;
      final value = match.group(1)?.replaceAll(',', '');
      if (value == null) continue;
      final parsed = double.tryParse(value);
      if (parsed != null && parsed > 0) return parsed;
    }
    return null;
  }

  /// Infer a spending category from text content.
  /// Shared by both SMS and PDF parsers.
  static String inferCategory(String bodyLower, bool isDebit) {
    if (!isDebit) return PaymentCategories.creditCategory;

    for (final entry in PaymentCategories.vpaIdentifiers.entries) {
      for (final id in entry.value) {
        if (bodyLower.contains(id)) return entry.key;
      }
    }

    for (final entry in PaymentCategories.keywords.entries) {
      for (final keyword in entry.value) {
        if (bodyLower.contains(keyword)) return entry.key;
      }
    }

    return PaymentCategories.uncategorized;
  }
}
