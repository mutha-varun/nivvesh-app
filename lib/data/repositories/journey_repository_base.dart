import 'package:nivvesh/domain/models/requests/journey.dart';

abstract class JourneyRepositoryBase {
  Future<JourneyListResponse> getJourneys({int page = 1, int perPage = 20});
  Future<JourneyDetailResponse> getJourneyById(int journeyId);
  Future<JourneyActionResponse> createJourney(JourneyCreateRequest request);
  Future<JourneyActionResponse> updateJourneyById(int journeyId, JourneyUpdateRequest request);
  Future<JourneyActionResponse> deleteJourneyById(int journeyId);
}
