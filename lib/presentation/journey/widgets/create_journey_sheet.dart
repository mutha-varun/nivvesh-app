import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/journey/journey_controller.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/core/theme/app_theme.dart';
import 'package:nivvesh/domain/models/requests/journey.dart';

class CreateJourneySheet extends ConsumerStatefulWidget {
  const CreateJourneySheet({super.key, this.onCreated});

  /// Called after a journey is successfully created.
  final VoidCallback? onCreated;

  @override
  ConsumerState<CreateJourneySheet> createState() => _CreateJourneySheetState();
}

class _CreateJourneySheetState extends ConsumerState<CreateJourneySheet> {
  final _goalController = TextEditingController();
  final _timeController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _goalController.dispose();
    _timeController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final goal = _goalController.text.trim();
    final time = _timeController.text.trim();
    final amount = int.tryParse(_amountController.text.trim());

    if (goal.isEmpty || time.isEmpty || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields correctly.')),
      );
      return;
    }

    await ref.read(createJourneyControllerProvider.notifier).createJourney(
          JourneyCreateRequest(goalName: goal, time: time, amount: amount),
        );

    if (!mounted) return;

    final state = ref.read(createJourneyControllerProvider);
    state.when(
      data: (_) {
        Navigator.of(context).pop();
        widget.onCreated?.call();
      },
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      },
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isLoading =
        ref.watch(createJourneyControllerProvider).isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: AppDecorations.luxBottomSheet(radius: 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: AppDecorations.dragHandle,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Create a new journey',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),

            // Goal name field
            _InputField(
              controller: _goalController,
              hint: 'Enter goal name',
              icon: Icons.rocket_launch_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),

            // Time field
            _InputField(
              controller: _timeController,
              hint: 'Enter time (in months)',
              icon: Icons.calendar_month_rounded,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),

            // Amount field
            _InputField(
              controller: _amountController,
              hint: 'Enter amount',
              prefixText: '₹',
              icon: Icons.currency_rupee_rounded,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: c.background,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.prefixText,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? prefixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceTintLow,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: c.borderSubtle),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(icon, size: 18, color: c.secondaryText),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: c.primaryText),
              decoration: InputDecoration(
                hintText: hint,
                prefixText: prefixText,
                prefixStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: c.primaryText),
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: c.secondaryText),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
