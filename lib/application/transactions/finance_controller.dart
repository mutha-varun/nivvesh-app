import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:nivvesh/core/constants/payment_category.dart';
import 'package:nivvesh/data/cache/sms_cache.dart';
import 'package:nivvesh/domain/models/finance_model.dart';
import 'package:permission_handler/permission_handler.dart';

class FinanceController extends ChangeNotifier {
  FinanceController(this._dataSource) {
    _init();
  }

  final SmsDataSource _dataSource;
  List<FinanceModel> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<FinanceModel> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _init() async {
    _messages = await _dataSource.getAll();
    notifyListeners();
    await fetchMessages();
  }

  Future<void> fetchMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (!(await Permission.sms.request().isGranted)) {
      _isLoading = false;
      _error = 'SMS permission is required to read financial messages.';
      notifyListeners();
      return;
    }

    try {
      final lastMessage = await _dataSource.getLatest();
      final lastSyncDate = lastMessage?.date;

      final smsList = await SmsQuery().querySms(kinds: [SmsQueryKind.inbox]);

      final newParsedMessages = <FinanceModel>[];
      for (final sms in smsList) {
        if (lastSyncDate != null &&
            sms.date != null &&
            sms.date!.isBefore(lastSyncDate)) break;

        final model = _parseFinancialSms(sms);
        if (model != null) newParsedMessages.add(model);
      }

      if (newParsedMessages.isNotEmpty) {
        await _dataSource.putAll(newParsedMessages);
      }

      _messages = await _dataSource.getAll();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

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

  final Map<String, String> _sessionCache = {};

  double? _extractAmount(String body) {
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

  FinanceModel? _parseFinancialSms(SmsMessage sms) {
    final body = sms.body ?? '';
    final bodyLower = body.toLowerCase();
    final sender = sms.sender ?? 'Unknown';
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
    final categoryMatch = _inferCategory(bodyLower, effectiveIsDebit);

    String? transactionKeyword;
    final hints = effectiveIsDebit
        ? PaymentCategories.debitKeywordHints
        : PaymentCategories.creditKeywordHints;
    final found = hints.firstWhere((k) => bodyLower.contains(k), orElse: () => '');
    if (found.isNotEmpty) transactionKeyword = found;

    return FinanceModel(
      smsId: sms.id ?? DateTime.now().millisecondsSinceEpoch,
      category: categoryMatch.category,
      date: sms.date ?? DateTime.now(),
      amount: amount,
      application: sender,
      triggerKeyword: categoryMatch.triggerKeyword ?? transactionKeyword,
      body: body,
    );
  }

  _CategoryMatch _inferCategory(String bodyLower, bool isDebit) {
    if (!isDebit) return const _CategoryMatch(PaymentCategories.creditCategory, null);

    for (final entry in _sessionCache.entries) {
      if (bodyLower.contains(entry.key)) {
        return _CategoryMatch(entry.value, entry.key);
      }
    }

    for (final entry in PaymentCategories.vpaIdentifiers.entries) {
      for (final id in entry.value) {
        if (bodyLower.contains(id)) {
          _sessionCache[id] = entry.key;
          return _CategoryMatch(entry.key, id);
        }
      }
    }

    for (final entry in PaymentCategories.keywords.entries) {
      for (final keyword in entry.value) {
        if (bodyLower.contains(keyword)) {
          _sessionCache[keyword] = entry.key;
          return _CategoryMatch(entry.key, keyword);
        }
      }
    }

    return const _CategoryMatch(PaymentCategories.uncategorized, null);
  }
}

class _CategoryMatch {
  const _CategoryMatch(this.category, this.triggerKeyword);
  final String category;
  final String? triggerKeyword;
}