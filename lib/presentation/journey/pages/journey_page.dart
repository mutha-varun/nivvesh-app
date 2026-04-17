import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/journey/journey_controller.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/domain/models/requests/journey.dart';
import 'package:nivvesh/presentation/journey/widgets/create_journey_sheet.dart';

class JourneyPage extends ConsumerWidget {
  const JourneyPage({super.key});

  void _openCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: CreateJourneySheet(
          onCreated: () => ref.invalidate(journeysControllerProvider),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final journeysAsync = ref.watch(journeysControllerProvider);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(
          'Journey',
          style: TextStyle(
            color: c.primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateSheet(context, ref),
        backgroundColor: c.accentPrimary,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add_rounded),
      ),
      body: journeysAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _JourneyErrorState(
          message: e.toString(),
          onRetry: () => ref.read(journeysControllerProvider.notifier).refresh(),
        ),
        data: (response) => response.journeys.isEmpty
            ? _JourneyEmptyState(c: c)
            : _JourneyList(journeys: response.journeys, c: c),
      ),
    );
  }
}

class _JourneyList extends StatelessWidget {
  const _JourneyList({required this.journeys, required this.c});

  final List<JourneyItem> journeys;
  final AppColorsBase c;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: journeys.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _JourneyCard(
        journey: journeys[index],
        c: c,
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.journey, required this.c});

  final JourneyItem journey;
  final AppColorsBase c;

  @override
  Widget build(BuildContext context) {
    final progress = journey.amount > 0
        ? (journey.progress / journey.amount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surfaceTintLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  journey.goalName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: c.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (journey.isComplete)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Complete',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 14, color: c.secondaryText),
              const SizedBox(width: 4),
              Text(
                '${journey.time} months',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: c.secondaryText),
              ),
              const SizedBox(width: 16),
              Icon(Icons.currency_rupee_rounded, size: 14, color: c.secondaryText),
              Text(
                '${journey.amount}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: c.secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: c.borderSubtle,
              color: c.accentPrimary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹${journey.progress} / ₹${journey.amount}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: c.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _JourneyEmptyState extends StatelessWidget {
  const _JourneyEmptyState({required this.c});

  final AppColorsBase c;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.map_outlined,
            size: 56,
            color: c.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No journeys yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: c.primaryText,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first savings goal.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _JourneyErrorState extends StatelessWidget {
  const _JourneyErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
