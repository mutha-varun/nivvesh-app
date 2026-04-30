// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fcmControllerHash() => r'b1a16a1249ace7e8d6d82d9ddedb8384d8128b54';

/// Handles FCM token lifecycle: requests permission, fetches the token,
/// pushes it to the backend, and listens for refreshes.
///
/// Call [syncToken] after the user authenticates so the backend can target
/// this device for push notifications.
///
/// Copied from [FcmController].
@ProviderFor(FcmController)
final fcmControllerProvider =
    AsyncNotifierProvider<FcmController, void>.internal(
  FcmController.new,
  name: r'fcmControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fcmControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FcmController = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
