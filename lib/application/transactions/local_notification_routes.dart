import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const kAiNotificationRoute = '/ai';
const kAiNotificationPayload = 'open_ai_page';

Future<void> showAiRedirectTestNotification() async {
	final plugin = FlutterLocalNotificationsPlugin();

	const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
	const darwinInit = DarwinInitializationSettings();
	const initSettings =
			InitializationSettings(android: androidInit, iOS: darwinInit);

	await plugin.initialize(initSettings);

	const androidDetails = AndroidNotificationDetails(
		'budget_alerts',
		'Budget Alerts',
		channelDescription: 'Alerts when spending crosses budget thresholds',
		importance: Importance.high,
		priority: Priority.high,
	);

	const darwinDetails = DarwinNotificationDetails();

	await plugin.show(
		9999,
		'AI Redirect Test',
		'Tap this notification to verify the AI redirect.',
		const NotificationDetails(android: androidDetails, iOS: darwinDetails),
		payload: kAiNotificationPayload,
	);
}