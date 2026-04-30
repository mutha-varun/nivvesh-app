import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:nivvesh/application/ai/ai_chat_controller.dart';
import 'package:nivvesh/application/ai/gemini_ai_chat_engine.dart';
import 'package:nivvesh/application/transactions/background_sms_handler.dart';
import 'package:nivvesh/application/transactions/local_notification_routes.dart';
import 'package:nivvesh/application/transactions/savings_evaluator.dart';
import 'package:nivvesh/domain/models/finance_model.dart';
import 'package:nivvesh/core/router/app_router.dart';
import 'package:nivvesh/application/transactions/spend_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';
import 'package:workmanager/workmanager.dart' as wm;
import 'package:nivvesh/core/theme/app_theme.dart';
import 'package:nivvesh/core/theme/theme_provider.dart';

// WorkManager task name
const _kSavingsTask = 'monthly_savings_eval';

const _kGeminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
const _kGeminiModel = String.fromEnvironment(
  'GEMINI_MODEL',
  defaultValue: 'gemini-2.5-flash',
);

final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

String? _pendingNotificationRoute;

void _openAiRouteFromNotification() {
  final context = rootNavigatorKey.currentContext;
  if (context != null) {
    context.go(kAiNotificationRoute);
  } else {
    _pendingNotificationRoute = kAiNotificationRoute;
  }
}

void _handleLocalNotificationTap(NotificationResponse response) {
  if (response.payload == kAiNotificationPayload) {
    _openAiRouteFromNotification();
  }
}

/// Top-level FCM background handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Top-level callback for WorkManager — must not be anonymous.
@pragma('vm:entry-point')
void workManagerCallbackDispatcher() {
  wm.Workmanager().executeTask((taskName, inputData) async {
    if (taskName == _kSavingsTask || taskName == wm.Workmanager.iOSBackgroundTask) {
      await evaluateMonthlySavings();
    }
    return true;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  final directory = await getApplicationDocumentsDirectory();
  final isar = Isar.instanceNames.isEmpty
      ? await Isar.open([FinanceModelSchema], directory: directory.path)
      : Isar.getInstance()!;

  // SMS background listener + notifications are Android-only
  if (Platform.isAndroid) {
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      await _localNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleLocalNotificationTap,
      );

      final launchDetails =
          await _localNotificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        _pendingNotificationRoute = kAiNotificationRoute;
      }

      await Permission.notification.request();

      final telephony = Telephony.instance;
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) async {
          await handleIncomingSms(message);
        },
        onBackgroundMessage: backgroundSmsHandler,
      );
    } catch (e) {
      debugPrint('Background SMS setup failed: $e');
    }
  }

  // Register WorkManager for periodic savings evaluation (daily check).
  // Runs even when app is closed. Safe to call repeatedly — WorkManager
  // deduplicates by unique name.
  await wm.Workmanager().initialize(workManagerCallbackDispatcher, isInDebugMode: false);
  await wm.Workmanager().registerPeriodicTask(
    _kSavingsTask,
    _kSavingsTask,
    frequency: const Duration(hours: 24),
    constraints: wm.Constraints(networkType: wm.NetworkType.notRequired),
    existingWorkPolicy: wm.ExistingPeriodicWorkPolicy.keep,
  );

  // On-app-open fallback: evaluate savings in case WorkManager was killed.
  // This is cheap — it no-ops if already evaluated for the current month.
  evaluateMonthlySavings().catchError(
    (e) => debugPrint('Savings evaluation failed: $e'),
  );

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        if (_kGeminiApiKey.isNotEmpty)
          aiChatEngineProvider.overrideWithValue(
            GeminiAiChatEngine(apiKey: _kGeminiApiKey, model: _kGeminiModel),
          ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pendingRoute = _pendingNotificationRoute;
      if (pendingRoute == null) return;
      _pendingNotificationRoute = null;
      ref.read(goRouterProvider).go(pendingRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Nivvesh',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
