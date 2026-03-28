
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nivvesh/core/theme/app_colors.dart';

class FinanceEntrySplash extends StatefulWidget {
  const FinanceEntrySplash({super.key});

  @override
  State<FinanceEntrySplash> createState() => _FinanceEntrySplashState();
}

class _FinanceEntrySplashState extends State<FinanceEntrySplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _startTransition();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _startTransition() async {
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    context.pushReplacement('/finance/sheet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.luxBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopSkeleton(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  children: [
                    _buildSummarySkeleton(),
                    const SizedBox(height: 18),
                    Expanded(
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        separatorBuilder: (_, index) => const SizedBox(height: 12),
                        itemBuilder: (_, index) => _buildTransactionSkeleton(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSkeleton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          const Text(
            'Nivvesh',
            style: TextStyle(
              color: AppColors.luxGold,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
          const Spacer(),
          _ShimmerCircle(controller: _shimmerController, size: 38),
          const SizedBox(width: 10),
          _ShimmerCircle(controller: _shimmerController, size: 38),
        ],
      ),
    );
  }

  Widget _buildSummarySkeleton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.luxSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.luxGold.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBox(controller: _shimmerController, width: 130, height: 10),
          const SizedBox(height: 10),
          _ShimmerBox(controller: _shimmerController, width: 210, height: 36),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ShimmerBox(
                  controller: _shimmerController,
                  width: double.infinity,
                  height: 52,
                  borderRadius: 12,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ShimmerBox(
                  controller: _shimmerController,
                  width: double.infinity,
                  height: 52,
                  borderRadius: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          _ShimmerCircle(controller: _shimmerController, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(controller: _shimmerController, width: 140, height: 14),
                const SizedBox(height: 8),
                _ShimmerBox(controller: _shimmerController, width: 90, height: 10),
                const SizedBox(height: 6),
                _ShimmerBox(controller: _shimmerController, width: 190, height: 10),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ShimmerBox(controller: _shimmerController, width: 70, height: 14),
              const SizedBox(height: 8),
              _ShimmerBox(controller: _shimmerController, width: 56, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.controller,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final AnimationController controller;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * controller.value, 0),
              end: Alignment(1.0 + 2.0 * controller.value, 0),
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.11),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  const _ShimmerCircle({
    required this.controller,
    required this.size,
  });

  final AnimationController controller;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * controller.value, 0),
              end: Alignment(1.0 + 2.0 * controller.value, 0),
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.11),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
          ),
        );
      },
    );
  }
}
