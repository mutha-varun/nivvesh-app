import 'dart:async';

import 'package:nivvesh/application/auth/auth_provider.dart';
import 'package:nivvesh/data/api/http_client_interceptor.dart';
import 'package:nivvesh/data/api/notification_api.dart';
import 'package:nivvesh/data/repositories/notification_repository.dart';
import 'package:nivvesh/domain/models/notification_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_controller.g.dart';

final notificationApiProvider = Provider<NotificationApi>(
  (ref) => NotificationApi(),
);

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(
    httpClient: ref.watch(httpClientProvider),
    api: ref.watch(notificationApiProvider),
  );
});

@riverpod
class NotificationsController extends _$NotificationsController {
  @override
  Future<List<NotificationModel>> build() async {
    return _fetch();
  }

  Future<List<NotificationModel>> _fetch() async {
    final phone = await ref.read(authLocalDataSourceProvider).getPhoneNumber();
    if (phone == null || phone.isEmpty) return const [];
    final response = await ref
        .read(notificationRepositoryProvider)
        .listNotifications(phone: phone, perPage: 50);
    return response.notifications;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> markRead(int notificationId) async {
    final phone = await ref.read(authLocalDataSourceProvider).getPhoneNumber();
    if (phone == null || phone.isEmpty) return;
    await ref.read(notificationRepositoryProvider).markRead(
      phone: phone,
      notificationId: notificationId,
    );
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData([
      for (final n in current)
        if (n.id == notificationId)
          NotificationModel(
            id: n.id,
            title: n.title,
            body: n.body,
            data: n.data,
            isRead: true,
            sentAt: n.sentAt,
          )
        else
          n,
    ]);
  }
}
