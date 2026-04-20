import 'dart:async';

import 'package:nivvesh/application/journey/journey_provider.dart';
import 'package:nivvesh/domain/models/requests/journey.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'journey_controller.g.dart';

@riverpod
class JourneysController extends _$JourneysController {
  @override
  Future<JourneyListResponse> build() =>
      ref.read(journeyRepositoryProvider).getJourneys();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(journeyRepositoryProvider).getJourneys(),
    );
  }

  Future<void> toggleComplete(JourneyItem journey) async {
    await ref.read(journeyRepositoryProvider).updateJourneyById(
          journey.id,
          JourneyUpdateRequest(isComplete: !journey.isComplete),
        );
    await refresh();
  }
}

@riverpod
class CreateJourneyController extends _$CreateJourneyController {
  @override
  FutureOr<void> build() {}

  Future<void> createJourney(JourneyCreateRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(journeyRepositoryProvider).createJourney(request);
    });
    if (!state.hasError) {
      ref.invalidate(journeysControllerProvider);
    }
  }
}

@riverpod
class EditJourneyController extends _$EditJourneyController {
  @override
  FutureOr<void> build() {}

  Future<void> editJourney(int journeyId, JourneyUpdateRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(journeyRepositoryProvider)
          .updateJourneyById(journeyId, request);
    });
    if (!state.hasError) {
      ref.invalidate(journeysControllerProvider);
    }
  }
}
