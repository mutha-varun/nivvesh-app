class JourneyCreateRequest {
  final String goalName;
  final String time;
  final int amount;

  JourneyCreateRequest({
    required this.goalName,
    required this.time,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'goal_name': goalName,
        'time': time,
        'amount': amount,
      };
}

class JourneyUpdateRequest {
  final String? goalName;
  final String? time;
  final int? amount;
  final int? progress;
  final bool? isComplete;

  JourneyUpdateRequest({
    this.goalName,
    this.time,
    this.amount,
    this.progress,
    this.isComplete,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (goalName != null) {
      json['goal_name'] = goalName;
    }
    if (time != null) {
      json['time'] = time;
    }
    if (amount != null) {
      json['amount'] = amount;
    }
    if (progress != null) {
      json['progress'] = progress;
    }
    if (isComplete != null) {
      json['is_complete'] = isComplete;
    }

    return json;
  }
}

class JourneyItem {
  final int id;
  final String goalName;
  final String time;
  final int amount;
  final int userId;
  final int progress;
  final DateTime? createdAt;
  final bool isComplete;

  JourneyItem({
    required this.id,
    required this.goalName,
    required this.time,
    required this.amount,
    required this.userId,
    required this.progress,
    required this.createdAt,
    required this.isComplete,
  });

  factory JourneyItem.fromJson(Map<String, dynamic> json) {
    return JourneyItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      goalName: json['goal_name'] as String? ?? '',
      time: json['time'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      isComplete: json['is_complete'] as bool? ?? false,
    );
  }
}

class JourneyDetailResponse {
  final JourneyItem journey;

  JourneyDetailResponse({required this.journey});

  factory JourneyDetailResponse.fromJson(Map<String, dynamic> json) {
    final journeyJson = json['journey'];
    return JourneyDetailResponse(
      journey: journeyJson is Map<String, dynamic>
          ? JourneyItem.fromJson(journeyJson)
          : JourneyItem(
              id: 0,
              goalName: '',
              time: '',
              amount: 0,
              userId: 0,
              progress: 0,
              createdAt: null,
              isComplete: false,
            ),
    );
  }
}

class JourneyActionResponse {
  final String message;
  final JourneyItem? journey;

  JourneyActionResponse({required this.message, required this.journey});

  factory JourneyActionResponse.fromJson(Map<String, dynamic> json) {
    final journeyJson = json['journey'];
    return JourneyActionResponse(
      message: json['message'] as String? ?? '',
      journey: journeyJson is Map<String, dynamic>
          ? JourneyItem.fromJson(journeyJson)
          : null,
    );
  }
}

class JourneyListResponse {
  final List<JourneyItem> journeys;
  final int totalJourneys;
  final int currentPage;
  final int totalPages;
  final int perPage;

  JourneyListResponse({
    required this.journeys,
    required this.totalJourneys,
    required this.currentPage,
    required this.totalPages,
    required this.perPage,
  });

  factory JourneyListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['journeys'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(JourneyItem.fromJson)
              .toList()
        : <JourneyItem>[];

    return JourneyListResponse(
      journeys: items,
      totalJourneys: (json['total_journeys'] as num?)?.toInt() ?? 0,
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 20,
    );
  }
}
