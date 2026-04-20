import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/data/repositories/fake_journey_repository.dart';
import 'package:nivvesh/data/repositories/journey_repository_base.dart';

final journeyRepositoryProvider = Provider<JourneyRepositoryBase>(
  (ref) => FakeJourneyRepository(),
);
