import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';

import 'notif_backend_helper.dart';
import 'savings_evaluator.dart';
import 'sms_parser.dart';

// ---------------------------------------------------------------------------
// Background SMS handler — called by the telephony plugin when a new SMS
// arrives while the app is in the background or killed.
//
// This is a top-level function (required by the telephony plugin).
// It does NOT write to Isar (to avoid duplicate-ID issues with the
// foreground sync). Instead it:
//   1. Parses the SMS via the shared SmsParser.
//   2. Tracks cumulative monthly spend + income in SharedPreferences.
//   3. Checks salary-based thresholds (user-configured %) against income
//      derived from credit transactions.
//   4. Checks per-category 50 / 80 / 100 % limits.
//   5. Fires local notifications when thresholds are crossed and POSTs
//      each notification to the backend for persistence.
//
// When the user next opens the app, FinanceController.fetchMessages() will
// pick up the same SMS from the inbox and persist it in Isar as usual.
// ---------------------------------------------------------------------------

/// SharedPreferences keys used for threshold tracking.
const _kMonthlySp = 'bg_monthly_spend';
const _kTrackedMonth = 'bg_tracked_month';
const _kMonthlyIncome = 'bg_monthly_income';
const _kThresholds = 'spend_alert_thresholds';

/// Prefix for per-category monthly spend.
const _kCatSpendPrefix = 'bg_cat_spend_';

/// Prefix for category limit values (same key as alert_config.dart writes).
const _kCatLimitPrefix = 'category_limit_';

/// Prefix for per-category per-threshold fired flags.
const _kCatAlertedPrefix = 'bg_cat_alerted_';

/// Fixed thresholds checked for every category that has a non-zero limit set.
const _kCatThresholds = [50, 80, 100];

/// All categories tracked for per-category spend limits.
/// Must match kLimitCategories in alerts_widgets.dart.
const _kTrackedCategories = [
  'Food & Dining',
  'Shopping & Grocery',
  'Transport & Travel',
  'Entertainment',
  'Bills & Utilities',
  'Health & Wellness',
];

/// Must be a top-level function for the telephony plugin.
@pragma('vm:entry-point')
void backgroundSmsHandler(SmsMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await _handleIncomingSms(message);
}

/// Shared logic usable from both the foreground [onNewMessage] callback
/// and the background handler above.
Future<void> handleIncomingSms(SmsMessage message) => _handleIncomingSms(message);

Future<void> _handleIncomingSms(SmsMessage message) async {
  final sender = message.address ?? 'Unknown';
  final body = message.body ?? '';
  final date = message.date != null
      ? DateTime.fromMillisecondsSinceEpoch(message.date!)
      : DateTime.now();
  final smsId = message.id ?? DateTime.now().millisecondsSinceEpoch;

  final model = SmsParser.parse(
    smsId: smsId,
    sender: sender,
    body: body,
    date: date,
  );
  if (model == null) return; // not a financial SMS

  final prefs = await SharedPreferences.getInstance();

  // Load user-configured salary thresholds (default 50, 80)
  final rawThresholds = prefs.getString(_kThresholds);
  List<int> thresholds;
  if (rawThresholds != null && rawThresholds.isNotEmpty) {
    thresholds = rawThresholds
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // highest first
  } else {
    thresholds = [80, 50];
  }

  // Reset on month change — snapshot previous month's spend for savings eval
  final now = DateTime.now();
  final currentMonth = '${now.year}-${now.month}';
  if (prefs.getString(_kTrackedMonth) != currentMonth) {
    // Snapshot last month's spend before resetting
    final lastMonthSpend = prefs.getDouble(_kMonthlySp) ?? 0;
    await prefs.setDouble(kPrevMonthSpend, lastMonthSpend);

    await prefs.setString(_kTrackedMonth, currentMonth);
    await prefs.setDouble(_kMonthlySp, 0);
    await prefs.setDouble(_kMonthlyIncome, 0);

    for (final t in thresholds) {
      await prefs.remove('bg_alerted_$t');
    }
    for (final category in _kTrackedCategories) {
      await prefs.setDouble('$_kCatSpendPrefix$category', 0);
      for (final t in _kCatThresholds) {
        await prefs.remove('$_kCatAlertedPrefix${category}_$t');
      }
    }

    // Trigger savings evaluation for the month that just ended
    await evaluateMonthlySavings();
  }

  final isCredit = model.category == 'Credit';

  if (isCredit) {
    // Accumulate monthly income from credit transactions
    final income = (prefs.getDouble(_kMonthlyIncome) ?? 0) + model.amount;
    await prefs.setDouble(_kMonthlyIncome, income);
    return;
  }

  // --- Debit: accumulate overall monthly spend ---
  final spend = (prefs.getDouble(_kMonthlySp) ?? 0) + model.amount;
  await prefs.setDouble(_kMonthlySp, spend);

  // --- Debit: accumulate per-category monthly spend ---
  final catKey = '$_kCatSpendPrefix${model.category}';
  final catSpend = (prefs.getDouble(catKey) ?? 0) + model.amount;
  await prefs.setDouble(catKey, catSpend);

  // --- Income-based threshold check ---
  final income = prefs.getDouble(_kMonthlyIncome) ?? 0;
  if (income > 0) {
    final ratio = spend / income;
    // Check highest first — fire only the most severe unalerted threshold.
    for (final percent in thresholds) {
      final key = 'bg_alerted_$percent';
      if (ratio >= (percent.toDouble() / 100) &&
          !(prefs.getBool(key) ?? false)) {
        await prefs.setBool(key, true);
        final title = percent >= 80 ? 'Budget Warning' : 'Budget Alert';
        final body =
            "You've used $percent% of your monthly income.";
        await _showNotification(
          id: 5000 + percent,
          title: title,
          body: body,
        );
        await postNotificationToBackend(title: title, message: body);
        break; // one notification per SMS for income-based checks
      }
    }
  }

  // --- Per-category limit check (50 / 80 / 100 %) ---
  final catLimit =
      prefs.getDouble('$_kCatLimitPrefix${model.category}') ?? 0;
  if (catLimit > 0) {
    final catRatio = catSpend / catLimit;
    for (final percent in _kCatThresholds) {
      final alertKey =
          '$_kCatAlertedPrefix${model.category}_$percent';
      if (catRatio >= (percent.toDouble() / 100) &&
          !(prefs.getBool(alertKey) ?? false)) {
        await prefs.setBool(alertKey, true);
        final categoryLabel = _shortLabel(model.category);
        final String title;
        final String body;
        if (percent == 100) {
          title = '$categoryLabel Limit Reached';
          body =
              "You've hit your ₹${catLimit.toStringAsFixed(0)} limit for $categoryLabel this month.";
        } else {
          title = '$categoryLabel Spending Alert';
          body =
              "You've used $percent% of your ₹${catLimit.toStringAsFixed(0)} $categoryLabel budget.";
        }
        await _showNotification(
          id: 6000 + _categoryIndex(model.category) * 3 +
              _catThresholdIndex(percent),
          title: title,
          body: body,
        );
        await postNotificationToBackend(title: title, message: body);
        break; // one category notification per SMS
      }
    }
  }
}

String _shortLabel(String category) {
  switch (category) {
    case 'Food & Dining':
      return 'Food';
    case 'Shopping & Grocery':
      return 'Shopping';
    case 'Transport & Travel':
      return 'Transport';
    case 'Bills & Utilities':
      return 'Bills';
    case 'Health & Wellness':
      return 'Health';
    default:
      return category;
  }
}

int _categoryIndex(String category) =>
    _kTrackedCategories.indexOf(category).clamp(0, _kTrackedCategories.length - 1);

int _catThresholdIndex(int percent) => _kCatThresholds.indexOf(percent).clamp(0, 2);

// Notification helper
const _channelId = 'budget_alerts';
const _channelName = 'Budget Alerts';

Future<void> _showNotification({
  required int id,
  required String title,
  required String body,
}) async {
  final plugin = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await plugin.initialize(initSettings);

  const androidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: 'Alerts when spending crosses budget thresholds',
    importance: Importance.high,
    priority: Priority.high,
  );

  await plugin.show(
    id,
    title,
    body,
    const NotificationDetails(android: androidDetails),
  );
}
