import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:nivvesh/application/transactions/finance_controller.dart';
import 'package:nivvesh/application/transactions/pdf_parser.dart';
import 'package:nivvesh/data/cache/sms_cache.dart';

class PdfFinanceController extends FinanceController {
  PdfFinanceController(SmsDataSource ds) : super.noAutoInit(ds) {
    _loadCached();
  }

  Uint8List? _pendingPdfBytes;
  bool _needsPassword = false;

  @override
  bool get needsPassword => _needsPassword;

  /// Load previously persisted PDF transactions from Isar on startup.
  Future<void> _loadCached() async {
    final cached = await dataSource.getAll();
    if (cached.isNotEmpty) {
      setMessages(cached);
      notifyListeners();
    }
  }

  @override
  Future<void> uploadPdf() async {
    setIsLoading(true);
    setError(null);
    _needsPassword = false;
    notifyListeners();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.isEmpty) {
        setIsLoading(false);
        notifyListeners();
        return;
      }

      // Read bytes from picked file
      final fileResult = result.files.single;
      final Uint8List bytes;
      if (fileResult.bytes != null) {
        bytes = fileResult.bytes!;
      } else if (fileResult.path != null) {
        bytes = await File(fileResult.path!).readAsBytes();
      } else {
        setError('Could not read the selected file.');
        setIsLoading(false);
        notifyListeners();
        return;
      }

      _pendingPdfBytes = bytes;
      await _parseAndStore(bytes);
    } catch (e) {
      _handleError(e);
    }

    setIsLoading(false);
    notifyListeners();
  }

  @override
  Future<void> retryWithPassword(String password) async {
    if (_pendingPdfBytes == null) return;

    setIsLoading(true);
    setError(null);
    _needsPassword = false;
    notifyListeners();

    try {
      await _parseAndStore(_pendingPdfBytes!, password: password);
    } catch (e) {
      _handleError(e);
    }

    setIsLoading(false);
    notifyListeners();
  }

  Future<void> _parseAndStore(Uint8List bytes, {String? password}) async {
    final transactions = BankStatementParser.parse(bytes, password: password);

    if (transactions.isNotEmpty) {
      await dataSource.putAll(transactions);
    }

    setMessages(await dataSource.getAll());
    _pendingPdfBytes = null; // Clear once successful
  }

  void _handleError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('password') || msg.contains('encrypted')) {
      _needsPassword = true;
      setError('This PDF is password protected.');
    } else {
      setError(e.toString());
    }
  }
}
