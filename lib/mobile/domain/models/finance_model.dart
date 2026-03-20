import 'package:isar/isar.dart';

part 'finance_model.g.dart';

@collection
class FinanceModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  final int smsId;

  final String category;
  
  @Index()
  final DateTime date;
  
  final double amount;
  final String application;
  final String? triggerKeyword;
  final String body; 
  FinanceModel({
    required this.smsId,
    required this.category,
    required this.date,
    required this.amount,
    required this.application,
    this.triggerKeyword,
    required this.body,
  });
}