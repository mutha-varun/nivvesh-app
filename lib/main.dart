import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:nivvesh/application/transactions/background_sms_handler.dart';
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

  final directory = await getApplicationDocumentsDirectory();
  final isar = Isar.instanceNames.isEmpty
      ? await Isar.open([FinanceModelSchema], directory: directory.path)
      : Isar.getInstance()!;

  // SMS background listener + notifications are Android-only
  if (Platform.isAndroid) {
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      await FlutterLocalNotificationsPlugin().initialize(initSettings);

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
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
