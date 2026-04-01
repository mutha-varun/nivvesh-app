import 'package:file_picker/file_picker.dart';
import 'package:nivvesh/application/transactions/dummy_finance_data.dart';
import 'package:nivvesh/application/transactions/finance_controller.dart';
import 'package:nivvesh/data/cache/sms_cache.dart';

class PdfFinanceController extends FinanceController {
  PdfFinanceController(SmsDataSource dataSource) : super.noAutoInit(dataSource);

  @override
  Future<void> uploadPdf() async {
    setIsLoading(true);
    setError(null);
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

      // TODO: Replace with real PDF parsing later
      setMessages(generateDummyFinanceData());
    } catch (e) {
      setError(e.toString());
    }

    setIsLoading(false);
    notifyListeners();
  }
}
