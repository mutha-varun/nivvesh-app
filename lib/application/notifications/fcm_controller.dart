import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:nivvesh/application/auth/auth_provider.dart';
import 'package:nivvesh/application/notifications/notifications_controller.dart';
import 'package:nivvesh/application/user/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fcm_controller.g.dart';

/// Handles FCM token lifecycle: requests permission, fetches the token,
/// pushes it to the backend, and listens for refreshes.
///
/// Call [syncToken] after the user authenticates so the backend can target
/// this device for push notifications.
@Riverpod(keepAlive: true)
class FcmController extends _$FcmController {
  StreamSubscription<String>? _refreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;

  @override
  FutureOr<void> build() {
    ref.onDispose(() {
      _refreshSub?.cancel();
      _foregroundSub?.cancel();
    });
  }

  /// Requests notification permission, fetches the current FCM token,
  /// and syncs it to the backend. Safe to call multiple times.
  Future<void> syncToken() async {
    if (!_isSupported) return;

    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(alert: true, badge: true, sound: true);

      final token = await messaging.getToken();
      if (token == null || token.isEmpty) return;

      await _push(token);

      _refreshSub ??= messaging.onTokenRefresh.listen(
        _push,
        onError: (e) => debugPrint('FCM onTokenRefresh error: $e'),
      );

      _foregroundSub ??= FirebaseMessaging.onMessage.listen(
        (_) {
          // Backend already persisted the notification — refresh the list
          // so the bell-icon page reflects the new push.
          ref.read(notificationsControllerProvider.notifier).refresh();
        },
        onError: (e) => debugPrint('FCM onMessage error: $e'),
      );
    } catch (e) {
      debugPrint('FCM syncToken failed: $e');
    }
  }

  /// Clears the cached FCM token. Call on sign-out.
  Future<void> clear() async {
    await _refreshSub?.cancel();
    await _foregroundSub?.cancel();
    _refreshSub = null;
    _foregroundSub = null;
    try {
      await ref.read(userLocalDataSourceProvider).deleteFcmToken();
      if (_isSupported) {
        await FirebaseMessaging.instance.deleteToken();
      }
    } catch (e) {
      debugPrint('FCM clear failed: $e');
    }
  }

  Future<void> _push(String token) async {
    try {
      final phone = await ref.read(authLocalDataSourceProvider).getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        debugPrint('FCM sync skipped: no cached phone (user not signed in).');
        return;
      }
      await ref.read(userRepositoryProvider).updateFcmToken(
        phone: phone,
        token: token,
        platform: Platform.isAndroid ? 'android' : 'ios',
      );
    } catch (e) {
      debugPrint('FCM token sync to backend failed: $e');
    }
  }

  bool get _isSupported => Platform.isAndroid || Platform.isIOS;
}
