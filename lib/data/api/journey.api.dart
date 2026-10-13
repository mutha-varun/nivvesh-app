import 'package:nivvesh/data/api/api_client.dart';

class JourneyApi extends ApiClient {
  /// Returns URI for fetching journeys for the authenticated user (GET /journeys).
  Uri getJourneys({
    required int page,
    required int perPage,
  }) => buildUri(
    endpoint: 'journeys',
    queryParameters: {
      'page': page.toString(),
      'per_page': perPage.toString(),
    },
  );

  /// Returns URI for fetching a single journey (GET /journeys/{journey_id}).
  Uri getJourneyById(int journeyId) =>
      buildUri(endpoint: 'journeys/$journeyId');

  /// Returns URI for updating a journey (PUT /journeys/{journey_id}).
  Uri updateJourneyById(int journeyId) =>
      buildUri(endpoint: 'journeys/$journeyId');

  /// Returns URI for deleting a journey (DELETE /journeys/{journey_id}).
  Uri deleteJourneyById(int journeyId) =>
      buildUri(endpoint: 'journeys/$journeyId');

  /// Returns URI for creating a new journey (POST /journeys).
  Uri createJourney() => buildUri(endpoint: 'journeys');
}
