import 'dart:async';

import 'package:nivvesh/application/journey/journey_provider.dart';
import 'package:nivvesh/domain/models/requests/journey.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'journey_controller.g.dart';

const _kDefaultEmergencyFundAmount = 50000;
const _kDefaultEmergencyFundMonths = '12';
const _kEmergencyFundName = 'Emergency Fund';

@riverpod
class JourneysController extends _$JourneysController {
  @override
  Future<JourneyListResponse> build() => _fetchWithDefaults();

  Future<JourneyListResponse> _fetchWithDefaults() async {
    final repo = ref.read(journeyRepositoryProvider);
    final response = await repo.getJourneys();
    if (response.journeys.isEmpty) {
      await repo.createJourney(
        JourneyCreateRequest(
          goalName: _kEmergencyFundName,
          time: _kDefaultEmergencyFundMonths,
          amount: _kDefaultEmergencyFundAmount,
        ),
      );
      return repo.getJourneys();
    }
    return response;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchWithDefaults);
  }

  Future<void> addMonthlyProgress(JourneyItem journey, int increment) async {
    if (increment <= 0 || journey.isComplete) return;
    final newProgress = (journey.progress + increment).clamp(0, journey.amount);
    final isNowComplete = newProgress >= journey.amount;
    await ref.read(journeyRepositoryProvider).updateJourneyById(
          journey.id,
          JourneyUpdateRequest(
            progress: newProgress,
            isComplete: isNowComplete,
          ),
        );
    await refresh();
  }

  Future<void> deleteJourney(int journeyId) async {
    await ref.read(journeyRepositoryProvider).deleteJourneyById(journeyId);
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

@riverpod
class DeleteJourneyController extends _$DeleteJourneyController {
  @override
  FutureOr<void> build() {}

  Future<void> deleteJourney(int journeyId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(journeyRepositoryProvider).deleteJourneyById(journeyId);
    });
    if (!state.hasError) {
      ref.invalidate(journeysControllerProvider);
    }
  }
}
