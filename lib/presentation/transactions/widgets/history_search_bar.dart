import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/transactions/search_provider.dart';
import 'package:nivvesh/core/theme/app_colors.dart';
import 'package:nivvesh/presentation/transactions/widgets/spend_widgets.dart';

class HistorySearchBar extends ConsumerStatefulWidget {
  const HistorySearchBar({super.key});

  @override
  ConsumerState<HistorySearchBar> createState() => _HistorySearchBarState();
}

class _HistorySearchBarState extends ConsumerState<HistorySearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TopFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final search = ref.watch(transactionSearchProvider);
    final notifier = ref.read(transactionSearchProvider.notifier);

    final isActive = search.isActive || _focusNode.hasFocus;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search field ──────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: c.surfaceTintLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? c.accentPrimary.withValues(alpha: 0.6)
                    : c.borderSubtle,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(Icons.search_rounded, color: c.secondaryText, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: notifier.setQuery,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: c.primaryText,
                        ),
                    decoration: InputDecoration(
                      hintText: 'Search by merchant, category, amount...',
                      hintStyle: TextStyle(color: c.muted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                // ✕ when typing, filter icon otherwise
                if (search.query.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: c.secondaryText, size: 18),
                    onPressed: () {
                      _controller.clear();
                      notifier.setQuery('');
                    },
                  )
                else
                  IconButton(
                    icon: Icon(
                      Icons.tune_rounded,
                      color: c.secondaryText,
                      size: 20,
                    ),
                    onPressed: _openFilterSheet,
                  ),
              ],
            ),
          ),

          // ── Reset / Done (visible while searching or focused) ─────────────
          if (isActive) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _controller.clear();
                      _focusNode.unfocus();
                      notifier.reset();
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _focusNode.unfocus(),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
