import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notif_backend_helper.dart';

// Monthly savings evaluator
//
// Computes savings = salary − total debits for the previous month, classifies
// them (good / low) and compares with the month before that, then fires one
// of four motivational notifications.
//
// Called from two places:
//   1. WorkManager periodic task (runs even when app is closed).
//   2. On-app-open check in main.dart (fallback if Android killed the worker).
//
// Data comes entirely from SharedPreferences — no Isar dependency — because
// background_sms_handler.dart already maintains a running monthly spend total.


/// SharedPreferences keys
const kSavingsEvaluatedMonth = 'savings_evaluated_month';
const kPrevMonthSavings = 'prev_month_savings';
const kPrevPrevMonthSavings = 'prev_prev_month_savings';
const kPrevMonthSpend = 'prev_month_spend';

/// Income key — monthly income accumulated from credit transactions.
const _kSalary = 'bg_monthly_income';
const _kMonthlySpend = 'bg_monthly_spend';
const _kTrackedMonth = 'bg_tracked_month';

/// Evaluate savings for the previous month and fire a notification if needed.
///
/// Safe to call multiple times — it no-ops if the current month was already
/// evaluated or if salary is not set.
Future<void> evaluateMonthlySavings() async {
  final prefs = await SharedPreferences.getInstance();

  final now = DateTime.now();
  final currentMonth = '${now.year}-${now.month}';

  // Already evaluated this month?
  if (prefs.getString(kSavingsEvaluatedMonth) == currentMonth) return;

  final salary = prefs.getDouble(_kSalary) ?? 0;
  if (salary <= 0) return; // no salary set, can't classify

  final trackedMonth = prefs.getString(_kTrackedMonth) ?? '';

  // We only evaluate when the tracked month has rolled over to the current
  // month (meaning background_sms_handler already reset and we have last
  // month's snapshot), OR when the tracked month is still last month and
  // we can snapshot it ourselves.
  double lastMonthSpend;

  if (trackedMonth == currentMonth) {
    // Month already rolled over — use the snapshot saved during rollover
    lastMonthSpend = prefs.getDouble(kPrevMonthSpend) ?? 0;
  } else {
    // Tracked month is still the previous month (or empty) — the current
    // bg_monthly_spend IS last month's total. Snapshot it now.
    lastMonthSpend = prefs.getDouble(_kMonthlySpend) ?? 0;

    // Perform the rollover ourselves
    await prefs.setDouble(kPrevMonthSpend, lastMonthSpend);
    await prefs.setDouble(_kMonthlySpend, 0);
    await prefs.setString(_kTrackedMonth, currentMonth);
  }

  final lastMonthSavings = salary - lastMonthSpend;
  final prevPrevSavings = prefs.getDouble(kPrevPrevMonthSavings);

  // Shift savings history: prev becomes prev-prev
  final currentPrevSavings = prefs.getDouble(kPrevMonthSavings);
  if (currentPrevSavings != null) {
    await prefs.setDouble(kPrevPrevMonthSavings, currentPrevSavings);
  }
  await prefs.setDouble(kPrevMonthSavings, lastMonthSavings);

  // Mark as evaluated so we don't fire again
  await prefs.setString(kSavingsEvaluatedMonth, currentMonth);

  // Classify
  final isGoodSavings = lastMonthSavings > (salary * 0.20);

  // If no previous month to compare, just show savings quality message
  if (prevPrevSavings == null) {
    final message = isGoodSavings
        ? 'Great start! You saved well this month. Keep it up!'
        : 'Your savings are below 20% of your income. Let\'s work on that!';
    final notifTitle = isGoodSavings ? 'Good Savings!' : 'Savings Check';
    await _showSavingsNotification(title: notifTitle, body: message);
    await postNotificationToBackend(title: notifTitle, message: message);
    return;
  }

  final improved = lastMonthSavings > prevPrevSavings;

  // 2×2 notification matrix
  String title;
  String body;

  if (isGoodSavings && improved) {
    title = 'Great Savings! ✅';
    body =
        'Great job! You\'re saving well and improved from last month 🎉 Want to save for a car?';
  } else if (isGoodSavings && !improved) {
    title = 'Savings Update ⚠️';
    body =
        'You\'re saving well, but slightly less than last month. Need ideas to save?';
  } else if (!isGoodSavings && improved) {
    title = 'Keep Pushing! 👍';
    body =
        'You\'re doing better than last month, keep pushing! Want to save more?';
  } else {
    title = 'Savings Alert ❗';
    body = 'Your savings dropped this month, let\'s get back on track!';
  }

  await _showSavingsNotification(title: title, body: body);
  await postNotificationToBackend(title: title, message: body);
}

// Notification helper
const _channelId = 'savings_insights';
const _channelName = 'Savings Insights';
const _notificationId = 9001;

Future<void> _showSavingsNotification({
  required String title,
  required String body,
}) async {
  final plugin = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const darwinInit = DarwinInitializationSettings();
  const initSettings =
      InitializationSettings(android: androidInit, iOS: darwinInit);
  await plugin.initialize(initSettings);

  const androidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: 'Monthly savings insights and motivation',
    importance: Importance.high,
    priority: Priority.high,
  );

  const darwinDetails = DarwinNotificationDetails();

  await plugin.show(
    _notificationId,
    title,
    body,
    const NotificationDetails(android: androidDetails, iOS: darwinDetails),
  );
}
