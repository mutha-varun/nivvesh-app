import 'package:isar/isar.dart';
import 'package:nivvesh/domain/models/finance_model.dart';

class SmsDataSource {
  const SmsDataSource(this.isar);
  final Isar isar;

  Future<List<FinanceModel>> getAll() =>
      isar.financeModels.where().sortByDateDesc().findAll();

  Future<FinanceModel?> getLatest() =>
      isar.financeModels.where().sortByDateDesc().findFirst();

  Future<void> putAll(List<FinanceModel> models) =>
      isar.writeTxn(() => isar.financeModels.putAll(models));
}