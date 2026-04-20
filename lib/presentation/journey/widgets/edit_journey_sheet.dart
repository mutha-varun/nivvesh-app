import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/journey/journey_controller.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/core/theme/app_theme.dart';
import 'package:nivvesh/domain/models/requests/journey.dart';

class EditJourneySheet extends ConsumerStatefulWidget {
  const EditJourneySheet({super.key, required this.journey, this.onUpdated});

  final JourneyItem journey;
  final VoidCallback? onUpdated;

  @override
  ConsumerState<EditJourneySheet> createState() => _EditJourneySheetState();
}

class _EditJourneySheetState extends ConsumerState<EditJourneySheet> {
  late final TextEditingController _goalController;
  late final TextEditingController _timeController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController(text: widget.journey.goalName);
    _timeController = TextEditingController(text: widget.journey.time);
    _amountController =
        TextEditingController(text: widget.journey.amount.toString());
  }

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

    await ref.read(editJourneyControllerProvider.notifier).editJourney(
          widget.journey.id,
          JourneyUpdateRequest(goalName: goal, time: time, amount: amount),
        );

    if (!mounted) return;

    final state = ref.read(editJourneyControllerProvider);
    state.when(
      data: (_) {
        Navigator.of(context).pop();
        widget.onUpdated?.call();
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
    final isLoading = ref.watch(editJourneyControllerProvider).isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: AppDecorations.luxBottomSheet(radius: 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: AppDecorations.dragHandle,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Edit journey',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            _InputField(
              controller: _goalController,
              hint: 'Enter goal name',
              icon: Icons.rocket_launch_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            _InputField(
              controller: _timeController,
              hint: 'Enter time (in months)',
              icon: Icons.calendar_month_rounded,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
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
                    : const Text('Save changes'),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
