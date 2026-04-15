class SaveLocalNotifRequest {
	final String title;
	final String message;

	SaveLocalNotifRequest({
		required this.title,
		required this.message,
	});

	Map<String, dynamic> toJson() {
		return {
			'title': title,
			'message': message,
		};
	}
}

class LocalNotificationItem {
	final int id;
	final int userId;
	final String title;
	final String message;
	final DateTime? createdAt;

	LocalNotificationItem({
		required this.id,
		required this.userId,
		required this.title,
		required this.message,
		required this.createdAt,
	});

	factory LocalNotificationItem.fromJson(Map<String, dynamic> json) {
		return LocalNotificationItem(
			id: json['id'] as int? ?? 0,
			userId: json['user_id'] as int? ?? 0,
			title: json['title'] as String? ?? '',
			message: json['message'] as String? ?? '',
			createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
		);
	}
}

class SaveLocalNotifResponse {
	final String message;
	final LocalNotificationItem? notification;

	SaveLocalNotifResponse({
		required this.message,
		required this.notification,
	});

	factory SaveLocalNotifResponse.fromJson(Map<String, dynamic> json) {
		final notifJson = json['notification'];
		return SaveLocalNotifResponse(
			message: json['message'] as String? ?? '',
			notification: notifJson is Map<String, dynamic>
					? LocalNotificationItem.fromJson(notifJson)
					: null,
		);
	}
}

class LocalNotifListResponse {
	final List<LocalNotificationItem> notifications;
	final int totalNotifications;
	final int currentPage;
	final int totalPages;
	final int perPage;

	LocalNotifListResponse({
		required this.notifications,
		required this.totalNotifications,
		required this.currentPage,
		required this.totalPages,
		required this.perPage,
	});

	factory LocalNotifListResponse.fromJson(Map<String, dynamic> json) {
		final rawItems = json['notifications'];
		final items = rawItems is List
				? rawItems
						.whereType<Map<String, dynamic>>()
						.map(LocalNotificationItem.fromJson)
						.toList()
				: <LocalNotificationItem>[];

		return LocalNotifListResponse(
			notifications: items,
			totalNotifications: json['total_notifications'] as int? ?? 0,
			currentPage: json['current_page'] as int? ?? 1,
			totalPages: json['total_pages'] as int? ?? 1,
			perPage: json['per_page'] as int? ?? 20,
		);
	}
}
