import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/journey/journey_controller.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/domain/models/requests/journey.dart';
import 'package:nivvesh/presentation/journey/widgets/create_journey_sheet.dart';
import 'package:nivvesh/presentation/journey/widgets/edit_journey_sheet.dart';

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
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _JourneyHeader(c: c),
                Expanded(
                  child: journeysAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => _JourneyErrorState(
                      message: e.toString(),
                      onRetry: () => ref
                          .read(journeysControllerProvider.notifier)
                          .refresh(),
                    ),
                    data: (response) => response.journeys.isEmpty
                        ? _JourneyEmptyState(c: c)
                        : _JourneyList(journeys: response.journeys, c: c),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 24,
              right: 20,
              child: FloatingActionButton(
                onPressed: () => _openCreateSheet(context, ref),
                backgroundColor: c.accentPrimary,
                foregroundColor: Colors.black,
                child: const Icon(Icons.add_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyHeader extends StatelessWidget {
  const _JourneyHeader({required this.c});

  final AppColorsBase c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x336366F1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x4D6366F1)),
            ),
            child: const Icon(
              Icons.map_outlined,
              color: Color(0xFF818CF8),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Journey',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: c.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                'Track your savings goals',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: c.secondaryText),
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: journeys.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _JourneyCard(
        journey: journeys[index],
        c: c,
      ),
    );
  }
}

enum _GoalType { short, mid, long }

extension _GoalTypeX on _GoalType {
  Color get iconColor {
    switch (this) {
      case _GoalType.short:
        return const Color(0xFF34D399);
      case _GoalType.mid:
        return const Color(0xFF60A5FA);
      case _GoalType.long:
        return const Color(0xFFC084FC);
    }
  }

  Color get iconBg {
    switch (this) {
      case _GoalType.short:
        return const Color(0x1A10B981);
      case _GoalType.mid:
        return const Color(0x1A3B82F6);
      case _GoalType.long:
        return const Color(0x1AA855F7);
    }
  }

  Color get progressColor {
    switch (this) {
      case _GoalType.short:
        return const Color(0xFF34D399);
      case _GoalType.mid:
        return const Color(0xFF60A5FA);
      case _GoalType.long:
        return const Color(0xFFC084FC);
    }
  }

  IconData get icon {
    switch (this) {
      case _GoalType.short:
        return Icons.rocket_launch_rounded;
      case _GoalType.mid:
        return Icons.track_changes_rounded;
      case _GoalType.long:
        return Icons.landscape_rounded;
    }
  }
}

_GoalType _goalTypeFromMonths(String time) {
  final months = int.tryParse(time) ?? 0;
  if (months < 6) return _GoalType.short;
  if (months <= 24) return _GoalType.mid;
  return _GoalType.long;
}

String _formatAmount(int amount) {
  if (amount >= 10000000) {
    return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
  } else if (amount >= 100000) {
    return '₹${(amount / 100000).toStringAsFixed(1)}L';
  } else if (amount >= 1000) {
    final formatted = amount.toString();
    if (formatted.length > 3) {
      return '₹${formatted.substring(0, formatted.length - 3)},${formatted.substring(formatted.length - 3)}';
    }
    return '₹$formatted';
  }
  return '₹$amount';
}

class _JourneyCard extends ConsumerWidget {
  const _JourneyCard({required this.journey, required this.c});

  final JourneyItem journey;
  final AppColorsBase c;

  void _openEditSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: EditJourneySheet(
          journey: journey,
          onUpdated: () => ref.invalidate(journeysControllerProvider),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = journey.amount > 0
        ? (journey.progress / journey.amount).clamp(0.0, 1.0)
        : 0.0;
    final progressPct = (progress * 100).round();
    final goalType = _goalTypeFromMonths(journey.time);
    final months = int.tryParse(journey.time) ?? 0;
    final monthlyNeeded = months > 0 ? (journey.amount / months).round() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceTintLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: goalType.iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(goalType.icon, color: goalType.iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journey.goalName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: c.primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${journey.time} months left',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: c.secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatAmount(journey.amount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: c.primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(width: 8),
                  _IconAction(
                    icon: Icons.edit_rounded,
                    color: c.secondaryText,
                    onTap: () => _openEditSheet(context, ref),
                  ),
                  const SizedBox(width: 4),
                  _IconAction(
                    icon: journey.isComplete
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                    color: journey.isComplete
                        ? Colors.green
                        : c.secondaryText,
                    onTap: () {
                      ref
                          .read(journeysControllerProvider.notifier)
                          .toggleComplete(journey);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: c.secondaryText),
              ),
              Text(
                '$progressPct%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: goalType.progressColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: c.borderSubtle,
              color: goalType.progressColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.borderSubtle)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Suggested monthly',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: c.secondaryText),
                ),
                Text(
                  _formatAmount(monthlyNeeded),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: c.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 20, color: color),
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
