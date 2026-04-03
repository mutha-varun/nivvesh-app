import 'dart:typed_data';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:nivvesh/application/transactions/sms_parser.dart';
import 'package:nivvesh/domain/models/finance_model.dart';

/// Parses bank statement PDFs (SBI format) into [FinanceModel] transactions.
/// Supports password-protected PDFs.
class BankStatementParser {
  BankStatementParser._();


  /// Matches date pairs: "DD/MM/YYYY DD/MM/YYYY"
  static final _datePairRegex =
      RegExp(r'(\d{2}/\d{2}/\d{4})\s+(\d{2}/\d{2}/\d{4})');

  /// Matches decimal amounts (Indian lakh/crore comma format OK):
  /// 500.00, 1,614.30, 1,05,861.84
  static final _amountRegex = RegExp(r'([\d,]+\.\d{2})');

  /// UPI payee: UPI/(CR|DR)/refnum/NAME/BANK/upiid
  static final _upiPayeeRegex =
      RegExp(r'UPI/(?:CR|DR)/\d+/([^/]+)/', caseSensitive: false);

  /// NEFT payee: NEFT*BANKCODE*REF*DESCRIPTION
  static final _neftPayeeRegex =
      RegExp(r'NEFT\*[^*]+\*[^*]+\*(.+?)(?:\s+\d{10,}|\s+AT\s)', caseSensitive: false);

  /// POS merchant: OTHPOSrefnumMERCHANT_NAME
  static final _posPayeeRegex =
      RegExp(r'OTHPOS\d+([A-Za-z][A-Za-z\s&.]+)', caseSensitive: false);

  /// IMPS payee: IMPS/refnum/NAME/...
  static final _impsPayeeRegex =
      RegExp(r'IMPS/\d+/([^/]+)/', caseSensitive: false);

  // Transaction type keywords

  static const _debitTypes = ['wdl tfr', 'wdl-trf', 'pos atm', 'atm wdl'];
  static const _creditTypes = ['dep tfr', 'dep-trf'];

  // -----------------------------------------------------------------------

  /// Parse a bank statement PDF into a list of [FinanceModel].
  ///
  /// Throws if the PDF is encrypted and [password] is null/wrong.
  static List<FinanceModel> parse(Uint8List bytes, {String? password}) {
    final PdfDocument document;
    try {
      document = (password != null && password.isNotEmpty)
          ? PdfDocument(inputBytes: bytes, password: password)
          : PdfDocument(inputBytes: bytes);
    } catch (_) {
      rethrow; // Let caller distinguish password errors
    }

    try {
      final extractor = PdfTextExtractor(document);
      final rawText = extractor.extractText();
      return _parseTransactions(rawText);
    } finally {
      document.dispose();
    }
  }


  static List<FinanceModel> _parseTransactions(String rawText) {
    final text = _preprocess(rawText);
    final dateMatches = _datePairRegex.allMatches(text).toList();
    final transactions = <FinanceModel>[];

    for (int i = 0; i < dateMatches.length; i++) {
      final dateStr = dateMatches[i].group(1)!;
      final blockStart = dateMatches[i].end;
      final blockEnd =
          i + 1 < dateMatches.length ? dateMatches[i + 1].start : text.length;
      final block = text.substring(blockStart, blockEnd);

      final date = _parseDate(dateStr);
      if (date == null) continue;

      final txn = _parseBlock(block, date);
      if (txn != null) transactions.add(txn);
    }

    return transactions;
  }

  /// Strip page markers, repeated table headers, and statement summary.
  static String _preprocess(String raw) {
    var text = raw;
    // Remove "Page no. N"
    text = text.replaceAll(RegExp(r'Page\s+no\.?\s*\d+'), '');
    // Truncate at statement summary
    final summaryIdx = text.indexOf(RegExp(r'Statement\s+Summary'));
    if (summaryIdx != -1) text = text.substring(0, summaryIdx);
    return text;
  }

  static DateTime? _parseDate(String s) {
    final p = s.split('/');
    if (p.length != 3) return null;
    final d = int.tryParse(p[0]), m = int.tryParse(p[1]), y = int.tryParse(p[2]);
    if (d == null || m == null || y == null) return null;
    return DateTime(y, m, d);
  }

  static FinanceModel? _parseBlock(String block, DateTime date) {
    // Collapse whitespace for uniform matching
    final normalized = block.replaceAll(RegExp(r'\s+'), ' ').trim();
    final lower = normalized.toLowerCase();

    // Determine debit / credit
    final bool isDebit;
    if (_debitTypes.any((t) => lower.contains(t))) {
      isDebit = true;
    } else if (_creditTypes.any((t) => lower.contains(t))) {
      isDebit = false;
    } else if (lower.contains('upi/dr')) {
      isDebit = true;
    } else if (lower.contains('upi/cr')) {
      isDebit = false;
    } else {
      return null; // Unknown type — skip
    }

    //Extract amounts
    final amounts = _amountRegex
        .allMatches(normalized)
        .map((m) => double.tryParse(m.group(1)!.replaceAll(',', '')))
        .whereType<double>()
        .where((a) => a > 0)
        .toList();
    if (amounts.isEmpty) return null;

    // Last amount = running balance; second-to-last = transaction amount
    final amount =
        amounts.length >= 2 ? amounts[amounts.length - 2] : amounts.first;

    // Extract payee
    final payee = _extractPayee(normalized);

    // Category inference (reuses SmsParser logic)
    final searchText = '$lower ${payee.toLowerCase()}';
    final category = SmsParser.inferCategory(searchText, isDebit);

    return FinanceModel(
      smsId: _deterministicId(date, amount, payee),
      category: category,
      date: date,
      amount: amount,
      application: payee,
      triggerKeyword: isDebit ? 'debited' : 'credited',
      body: normalized,
    );
  }

  static String _extractPayee(String text) {
    // Try UPI first (most common)
    final upi = _upiPayeeRegex.firstMatch(text);
    if (upi != null) return _cleanPayee(upi.group(1)!);

    // NEFT
    final neft = _neftPayeeRegex.firstMatch(text);
    if (neft != null) return _cleanPayee(neft.group(1)!);

    // IMPS
    final imps = _impsPayeeRegex.firstMatch(text);
    if (imps != null) return _cleanPayee(imps.group(1)!);

    // POS
    final pos = _posPayeeRegex.firstMatch(text);
    if (pos != null) return _cleanPayee(pos.group(1)!);

    return 'Bank Transaction';
  }

  static String _cleanPayee(String raw) =>
      raw.replaceAll(RegExp(r'\s+'), ' ').trim();

  /// FNV-1a–style hash → negative int (avoids collision with SMS IDs).
  static int _deterministicId(DateTime date, double amount, String payee) {
    final key = '${date.year}${date.month}${date.day}_${amount}_$payee';
    var hash = 0x811c9dc5;
    for (var i = 0; i < key.length; i++) {
      hash ^= key.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return -(hash + 100000);
  }
}
