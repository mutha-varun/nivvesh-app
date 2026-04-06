import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';

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
//   2. Tracks cumulative monthly spend in SharedPreferences.
//   3. Checks 50% / 80% budget thresholds against the stored salary.
//   4. Fires a local notification when a threshold is crossed.
//
// When the user next opens the app, FinanceController.fetchMessages() will
// pick up the same SMS from the inbox and persist it in Isar as usual.
// ---------------------------------------------------------------------------

/// SharedPreferences keys used for threshold tracking.
const _kMonthlySp = 'bg_monthly_spend';
const _kTrackedMonth = 'bg_tracked_month';
const _kSalary = 'user_salary';
const _kThresholds = 'spend_alert_thresholds';

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

  final isDebit = model.category != 'Credit';
  if (!isDebit) return; // only debits matter for budget tracking

  final prefs = await SharedPreferences.getInstance();

  //Load user-configured thresholds (default 50, 80)
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

  //Reset on month change — snapshot previous month's spend for savings eval
  final now = DateTime.now();
  final currentMonth = '${now.year}-${now.month}';
  if (prefs.getString(_kTrackedMonth) != currentMonth) {
    // Snapshot last month's spend before resetting
    final lastMonthSpend = prefs.getDouble(_kMonthlySp) ?? 0;
    await prefs.setDouble(kPrevMonthSpend, lastMonthSpend);

    await prefs.setString(_kTrackedMonth, currentMonth);
    await prefs.setDouble(_kMonthlySp, 0);
    for (final t in thresholds) {
      await prefs.remove('bg_alerted_$t');
    }

    // Trigger savings evaluation for the month that just ended
    await evaluateMonthlySavings();
  }

  // --- Accumulate spend ---
  final spend = (prefs.getDouble(_kMonthlySp) ?? 0) + model.amount;
  await prefs.setDouble(_kMonthlySp, spend);

  // --- Threshold check ---
  final salary = prefs.getDouble(_kSalary) ?? 0;
  if (salary <= 0) return;

  final ratio = spend / salary;

  // Check highest first — fire only the most severe unalerted threshold.
  for (final percent in thresholds) {
    final key = 'bg_alerted_$percent';
    if (ratio >= (percent.toDouble() / 100) && !(prefs.getBool(key) ?? false)) {
      await prefs.setBool(key, true);
      await _showNotification(
        id: 5000 + percent,
        title: percent >= 80 ? 'Budget Warning' : 'Budget Alert',
        body: "You've used $percent% of your monthly budget.",
      );
      break; // one notification per SMS
    }
  }
}

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
