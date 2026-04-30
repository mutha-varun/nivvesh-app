import 'dart:async';
import 'package:nivvesh/application/auth/auth_state_provider.dart';
import 'package:nivvesh/application/notifications/fcm_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nivvesh/application/auth/auth_provider.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class SignInScreenController extends _$SignInScreenController {
  @override
  FutureOr<void> build() {}

  Future<void> sendOtp(String phone) async {
    state = const AsyncLoading();
    
    // Use the internal 'ref' property of the Notifier
    final authRepository = ref.read(authRepositoryProvider);

    state = await AsyncValue.guard(() async {
      await authRepository.sendOtp(phone);
    });
  }

  Future<void> verifyOtp(String phone, String otp) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);

    state = await AsyncValue.guard(() async {
      final result = await authRepository.verifyOtp(phone, otp);

      await ref.read(authStateProvider.notifier).setRedirectUrl(result.redirectUrl);
      ref.read(authStateProvider.notifier).markAuthenticated();
      unawaited(ref.read(fcmControllerProvider.notifier).syncToken());
    });
  }
}