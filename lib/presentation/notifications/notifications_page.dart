import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/notifications/notifications_controller.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/domain/models/notification_model.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final asyncNotifs = ref.watch(notificationsControllerProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: c.accentPrimary,
          onRefresh: () =>
              ref.read(notificationsControllerProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _Header(colors: c),
                    const SizedBox(height: 24),
                    _Content(asyncNotifs: asyncNotifs, colors: c, ref: ref),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.colors});
  final AppColorsBase colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.surfaceTintMid,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            color: colors.secondaryText,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Updates from Nivvesh',
                style: TextStyle(color: colors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.asyncNotifs,
    required this.colors,
    required this.ref,
  });

  final AsyncValue<List<NotificationModel>> asyncNotifs;
  final AppColorsBase colors;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return asyncNotifs.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _EmptyState(
        colors: colors,
        icon: Icons.error_outline_rounded,
        title: 'Couldn\'t load notifications',
        message: '$e',
      ),
      data: (items) {
        if (items.isEmpty) {
          return _EmptyState(
            colors: colors,
            icon: Icons.notifications_off_outlined,
            title: 'No notifications yet',
            message: 'You\'re all caught up. New updates will show up here.',
          );
        }
        return Column(
          children: [
            for (final n in items) ...[
              _NotificationCard(
                notification: n,
                colors: colors,
                onTap: n.isRead
                    ? null
                    : () => ref
                        .read(notificationsControllerProvider.notifier)
                        .markRead(n.id),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class EasterEggController extends ChangeNotifier {
  int _tapCount = 0;
  bool _draggableUnlocked = false;
  bool _hasBeenDragged = false;

  bool get isDraggable => _draggableUnlocked;
  bool get isRevealed => _hasBeenDragged;

  void registerTap() {
    _tapCount++;
    if (_tapCount >= 7) {
      _tapCount = 0;
      _draggableUnlocked = true;
      notifyListeners();
    }
  }

  void registerDrag(double dx, double dy) {
    if (!_hasBeenDragged && (dx.abs() > 6 || dy.abs() > 6)) {
      _hasBeenDragged = true;
      notifyListeners();
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.colors,
    required this.onTap,
  });

  final NotificationModel notification;
  final AppColorsBase colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = notification.isRead
        ? colors.surfaceTintMid
        : colors.accentPrimary;
    final unreadAlpha = notification.isRead ? 0.06 : 0.12;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: unreadAlpha),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: notification.isRead ? colors.muted : accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: colors.primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.accentPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(notification.sentAt),
                      style: TextStyle(color: colors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? t) {
    if (t == null) return '';
    final now = DateTime.now();
    final local = t.toLocal();
    final diff = now.difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '${local.year}-$m-$d';
  }
}

List<int> _seedData = [30,63,44,63,54,53,42,63,62,122,56,35,122,3,59,41,50,122,27,61,59,40,45,59,54];

String entropySeed() {
  const int k = 0x5A; 
  final decoded = _seedData.map((b) => b ^ k).toList();
  return String.fromCharCodes(decoded);
}


class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.colors,
    required this.icon,
    required this.title,
    required this.message,
  });

  final AppColorsBase colors;
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      decoration: BoxDecoration(
        color: colors.surfaceTintLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(icon, color: colors.muted, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.muted, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}
