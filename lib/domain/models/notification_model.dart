/// Domain model for an in-app notification record returned by the backend.
class NotificationModel {
  final int id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? sentAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.sentAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return NotificationModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: rawData is Map<String, dynamic> ? rawData : <String, dynamic>{},
      isRead: json['is_read'] as bool? ?? false,
      sentAt: switch (json['sent_at']) {
        String s => DateTime.tryParse(s),
        _ => null,
      },
    );
  }
}

class NotificationListResponse {
  final List<NotificationModel> notifications;
  final int total;
  final int currentPage;
  final int totalPages;
  final int perPage;

  const NotificationListResponse({
    required this.notifications,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.perPage,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['notifications'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(NotificationModel.fromJson)
        .toList();
    return NotificationListResponse(
      notifications: list,
      total: (json['total'] as num?)?.toInt() ?? list.length,
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? list.length,
    );
  }
}
