import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:nivvesh/data/cache/sms_cache.dart';
import 'package:nivvesh/application/transactions/finance_controller.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar must be overridden at app startup.');
});

final smsDataSourceProvider = Provider<SmsDataSource>((ref) {
  return SmsDataSource(ref.watch(isarProvider));
});

final financeControllerProvider =
    ChangeNotifierProvider<FinanceController>((ref) {
  return FinanceController(ref.watch(smsDataSourceProvider));
});