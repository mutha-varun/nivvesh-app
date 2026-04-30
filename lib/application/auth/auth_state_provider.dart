import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/auth/auth_provider.dart';
import 'package:nivvesh/application/notifications/fcm_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state_provider.g.dart';

final authRedirectUrlProvider = StateProvider<String?>((ref) => null);

@riverpod
class AuthState extends _$AuthState {
  @override
  FutureOr<bool> build() async {
    try {
      final local = ref.watch(authLocalDataSourceProvider);
      final token = await local.getAccessToken();
      final redirectUrl = await local.getRedirectUrl();
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        ref.read(authRedirectUrlProvider.notifier).state = redirectUrl;
      }
      final isAuthed = token != null && token.isNotEmpty;
      if (isAuthed) {
        unawaited(ref.read(fcmControllerProvider.notifier).syncToken());
      }
      return isAuthed;
    } catch (_) {
      // If secure storage fails to decrypt/migrate for any reason, treat as signed out.
      return false;
    }
  }

  Future<void> signOut() async {
    final local = ref.read(authLocalDataSourceProvider);
    await local.deleteAllTokens();
    await local.deletePhoneNumber();
    await ref.read(fcmControllerProvider.notifier).clear();
    ref.read(authRedirectUrlProvider.notifier).state = null;
    state = const AsyncData(false);
  }

  void markAuthenticated() {
    state = const AsyncData(true);
  }

  Future<void> setRedirectUrl(String url) async {
    await ref.read(authLocalDataSourceProvider).saveRedirectUrl(url);
    ref.read(authRedirectUrlProvider.notifier).state = url;
  }
}