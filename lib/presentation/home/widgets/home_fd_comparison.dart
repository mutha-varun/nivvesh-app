import 'package:flutter/material.dart';
import 'package:nivvesh/core/theme/app_colors.dart';

// TODO(fd): wire to real provider when backend is available.
const _fdStubs = [
  _FdStub('HDFC Bank', 7.25, '1 Yr 1 Day', '₹10,000', _FdColor.blue),
  _FdStub('SBI', 7.10, '400 Days', '₹5,000', _FdColor.indigo),
  _FdStub('ICICI Bank', 7.20, '15 Months', '₹10,000', _FdColor.orange),
  _FdStub('Axis Bank', 7.30, '16 Months', '₹5,000', _FdColor.rose),
];

class HomeFdComparison extends StatelessWidget {
  const HomeFdComparison({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Compare FDs',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: c.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(color: c.accentPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _fdStubs.length,
            separatorBuilder: (_, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _FdCard(stub: _fdStubs[index]),
          ),
        ),
      ],
    );
  }
}

class _FdCard extends StatelessWidget {
  const _FdCard({required this.stub});

  final _FdStub stub;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final stripColor = switch (stub.color) {
      _FdColor.blue => c.categories.blue.base,
      _FdColor.indigo => c.categories.indigo.base,
      _FdColor.orange => c.categories.orange.base,
      _FdColor.rose => c.categories.rose.base,
    };

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: c.surfaceTintMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: stripColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.surfaceTintHigh,
                        ),
                        child: Icon(
                          Icons.account_balance_rounded,
                          color: c.secondaryText,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          stub.bankName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: c.primaryText,
                                fontWeight: FontWeight.w600,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: c.accentTint10,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${stub.interestRate.toStringAsFixed(2)}% p.a.',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: c.accentPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tenure: ${stub.tenure}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: c.secondaryText,
                              ),
                        ),
                      ),
                      Text(
                        'Min: ${stub.minAmount}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: c.secondaryText,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: c.muted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FdStub {
  final String bankName;
  final double interestRate;
  final String tenure;
  final String minAmount;
  final _FdColor color;

  const _FdStub(
    this.bankName,
    this.interestRate,
    this.tenure,
    this.minAmount,
    this.color,
  );
}

enum _FdColor { blue, indigo, orange, rose }
