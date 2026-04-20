import 'package:nivvesh/data/repositories/journey_repository_base.dart';
import 'package:nivvesh/domain/models/requests/journey.dart';

class FakeJourneyRepository extends JourneyRepositoryBase {
  int _nextId = 4;

  final List<JourneyItem> _journeys = [
    JourneyItem(
      id: 1,
      goalName: 'Emergency Fund',
      time: '8',
      amount: 300000,
      userId: 1,
      progress: 120000,
      createdAt: DateTime.now(),
      isComplete: false,
    ),
    JourneyItem(
      id: 2,
      goalName: 'New Laptop',
      time: '3',
      amount: 150000,
      userId: 1,
      progress: 95000,
      createdAt: DateTime.now(),
      isComplete: false,
    ),
    JourneyItem(
      id: 3,
      goalName: 'House Downpayment',
      time: '36',
      amount: 2000000,
      userId: 1,
      progress: 450000,
      createdAt: DateTime.now(),
      isComplete: false,
    ),
  ];

  @override
  Future<JourneyListResponse> getJourneys({int page = 1, int perPage = 20}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return JourneyListResponse(
      journeys: List.unmodifiable(_journeys),
      totalJourneys: _journeys.length,
      currentPage: 1,
      totalPages: 1,
      perPage: perPage,
    );
  }

  @override
  Future<JourneyDetailResponse> getJourneyById(int journeyId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final journey = _journeys.firstWhere(
      (j) => j.id == journeyId,
      orElse: () => throw Exception('Journey not found'),
    );
    return JourneyDetailResponse(journey: journey);
  }

  @override
  Future<JourneyActionResponse> createJourney(JourneyCreateRequest request) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final item = JourneyItem(
      id: _nextId++,
      goalName: request.goalName,
      time: request.time,
      amount: request.amount,
      userId: 1,
      progress: 0,
      createdAt: DateTime.now(),
      isComplete: false,
    );
    _journeys.add(item);
    return JourneyActionResponse(message: 'Created', journey: item);
  }

  @override
  Future<JourneyActionResponse> updateJourneyById(
    int journeyId,
    JourneyUpdateRequest request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _journeys.indexWhere((j) => j.id == journeyId);
    if (idx == -1) throw Exception('Journey not found');
    final old = _journeys[idx];
    final updated = JourneyItem(
      id: old.id,
      goalName: request.goalName ?? old.goalName,
      time: request.time ?? old.time,
      amount: request.amount ?? old.amount,
      userId: old.userId,
      progress: request.progress ?? old.progress,
      createdAt: old.createdAt,
      isComplete: request.isComplete ?? old.isComplete,
    );
    _journeys[idx] = updated;
    return JourneyActionResponse(message: 'Updated', journey: updated);
  }

  @override
  Future<JourneyActionResponse> deleteJourneyById(int journeyId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _journeys.removeWhere((j) => j.id == journeyId);
    return JourneyActionResponse(message: 'Deleted', journey: null);
  }
}
