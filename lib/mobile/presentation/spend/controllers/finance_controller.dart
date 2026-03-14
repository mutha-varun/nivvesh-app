import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nivvesh/mobile/domain/models/finance_model.dart';

class FinanceController extends ChangeNotifier {
  List<FinanceModel> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<FinanceModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final status = await Permission.sms.request();
    if (!status.isGranted) {
      _error = 'SMS permission denied. Please grant it in app settings.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final query = SmsQuery();
    final smsList = await query.querySms(kinds: [SmsQueryKind.inbox]);

    final parsed = <FinanceModel>[];
    for (final sms in smsList) {
      final model = _parseFinancialSms(sms);
      if (model != null) parsed.add(model);
    }

    parsed.sort((a, b) => b.date.compareTo(a.date));

    _messages = parsed;
    _isLoading = false;
    notifyListeners();
  }

  // Matches: INR 1,234.56 | Rs. 1234 | Rs 50.00 | ₹450
  static final _amountRegex = RegExp(
    r'(?:INR|Rs\.?|₹)\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  static const _debitKeywords = [
    'debited', 'deducted', 'spent', 'paid', 'payment of', 'withdrawn',
  ];

  static const _creditKeywords = [
    'credited', 'received', 'refund', 'cashback',
  ];

  FinanceModel? _parseFinancialSms(SmsMessage sms) {
    final body = sms.body ?? '';
    final bodyLower = body.toLowerCase();

    final amountMatch = _amountRegex.firstMatch(body);
    if (amountMatch == null) return null;

    final amountStr = amountMatch.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) return null;

    final isDebit = _debitKeywords.any((k) => bodyLower.contains(k));
    final isCredit = _creditKeywords.any((k) => bodyLower.contains(k));
    if (!isDebit && !isCredit) return null;

    return FinanceModel(
      category: _inferCategory(bodyLower, isDebit),
      date: sms.date ?? DateTime.now(),
      amount: amount,
      application: sms.sender ?? 'Unknown',
    );
  }

  String _inferCategory(String bodyLower, bool isDebit) {
    if (!isDebit) return 'Credit';
    if (bodyLower.contains('swiggy') || bodyLower.contains('zomato') ||
        bodyLower.contains('food') || bodyLower.contains('restaurant')) {
      return 'Food & Dining';
    }
    if (bodyLower.contains('uber') || bodyLower.contains('ola') ||
        bodyLower.contains('metro') || bodyLower.contains('rapido')) {
      return 'Transport';
    }
    if (bodyLower.contains('amazon') || bodyLower.contains('flipkart') ||
        bodyLower.contains('myntra') || bodyLower.contains('shopping')) {
      return 'Shopping';
    }
    if (bodyLower.contains('netflix') || bodyLower.contains('hotstar') ||
        bodyLower.contains('spotify') || bodyLower.contains('youtube')) {
      return 'Entertainment';
    }
    if (bodyLower.contains('electricity') || bodyLower.contains('bill') ||
        bodyLower.contains('recharge') || bodyLower.contains('broadband')) {
      return 'Bills & Utilities';
    }
    if (bodyLower.contains('atm') || bodyLower.contains('cash withdrawal')) {
      return 'Cash Withdrawal';
    }
    return 'Other';
  }
}

final financeControllerProvider =
    ChangeNotifierProvider<FinanceController>((ref) => FinanceController());
