import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/auth/auth_provider.dart';
import 'package:nivvesh/data/api/http_client_interceptor.dart';
import 'package:nivvesh/data/api/journey.api.dart';
import 'package:nivvesh/data/repositories/journey_repository.dart';

final journeyApiProvider = Provider<JourneyApi>((ref) => JourneyApi());

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  return JourneyRepository(
    httpClient: ref.watch(httpClientProvider),
    api: ref.watch(journeyApiProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});
