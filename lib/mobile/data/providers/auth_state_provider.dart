import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/mobile/data/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state_provider.g.dart';

final authRedirectUrlProvider = StateProvider<String?>((ref) => null);

@riverpod
class AuthState extends _$AuthState {
  @override
  FutureOr<bool> build() async {
    final token = await ref.watch(authLocalDataSourceProvider).getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> signOut() async {
    await ref.read(authLocalDataSourceProvider).deleteAllTokens();
    ref.read(authRedirectUrlProvider.notifier).state = null;
    state = const AsyncData(false);
  }

  void markAuthenticated() {
    state = const AsyncData(true);
  }

  void setRedirectUrl(String url) {
    ref.read(authRedirectUrlProvider.notifier).state = url;
  }
}