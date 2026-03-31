import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:nivvesh/data/cache/sms_cache.dart';
import 'package:nivvesh/domain/models/finance_model.dart';
import 'package:permission_handler/permission_handler.dart';

import 'sms_parser.dart';

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

        final model = SmsParser.parse(
          smsId: sms.id ?? DateTime.now().millisecondsSinceEpoch,
          sender: sms.sender ?? 'Unknown',
          body: sms.body ?? '',
          date: sms.date ?? DateTime.now(),
        );
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
}