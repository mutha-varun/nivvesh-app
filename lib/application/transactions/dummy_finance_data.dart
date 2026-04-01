import 'package:nivvesh/core/constants/payment_category.dart';
import 'package:nivvesh/domain/models/finance_model.dart';

List<FinanceModel> generateDummyFinanceData() {
  final now = DateTime.now();
  int id = -1;

  FinanceModel txn({
    required String category,
    required double amount,
    required String sender,
    required int daysAgo,
    String keyword = 'debited',
  }) {
    return FinanceModel(
      smsId: id--,
      category: category,
      date: now.subtract(Duration(days: daysAgo)),
      amount: amount,
      application: sender,
      triggerKeyword: keyword,
      body: 'Dummy PDF transaction — $sender ₹$amount',
    );
  }

  return [
    txn(category: PaymentCategories.food, amount: 450, sender: 'Zomato', daysAgo: 1),
    txn(category: PaymentCategories.food, amount: 320, sender: 'Swiggy', daysAgo: 5),
    txn(category: PaymentCategories.shopping, amount: 2999, sender: 'Amazon', daysAgo: 2),
    txn(category: PaymentCategories.shopping, amount: 1499, sender: 'Flipkart', daysAgo: 8),
    txn(category: PaymentCategories.transport, amount: 180, sender: 'Uber', daysAgo: 3),
    txn(category: PaymentCategories.transport, amount: 750, sender: 'IRCTC', daysAgo: 12),
    txn(category: PaymentCategories.entertainment, amount: 649, sender: 'Netflix', daysAgo: 4),
    txn(category: PaymentCategories.bills, amount: 599, sender: 'Jio', daysAgo: 6),
    txn(category: PaymentCategories.bills, amount: 1200, sender: 'Electricity Board', daysAgo: 10),
    txn(category: PaymentCategories.health, amount: 350, sender: 'PharmEasy', daysAgo: 7),
    txn(category: PaymentCategories.investment, amount: 5000, sender: 'Groww', daysAgo: 9),
    txn(category: PaymentCategories.uncategorized, amount: 800, sender: 'UPI-Merchant', daysAgo: 11),
    txn(category: PaymentCategories.creditCategory, amount: 25000, sender: 'Salary', daysAgo: 0, keyword: 'credited'),
    txn(category: PaymentCategories.creditCategory, amount: 150, sender: 'Cashback', daysAgo: 6, keyword: 'cashback'),
    txn(category: PaymentCategories.food, amount: 210, sender: 'Starbucks', daysAgo: 14),
  ];
}
