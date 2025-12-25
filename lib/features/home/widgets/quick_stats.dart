import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/providers/transaction_provider.dart';

class QuickStats extends StatefulWidget {
  const QuickStats({super.key});

  @override
  State<QuickStats> createState() => _QuickStatsState();
}

class _QuickStatsState extends State<QuickStats> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final transactions = transactionProvider.currentMonthTransactions;
    final income = transactionProvider.getTotalIncome(transactions);
    final expense = transactionProvider.getTotalExpense(transactions);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _slideController,
        child: Row(
          children: [
            // INCOME CARD
            Expanded(
              child: _StatCard(
                label: 'Pemasukan',
                amount: income,
                icon: Icons.arrow_downward_rounded,
                gradient: AppColors.incomeGradient,
                delay: 0,
              ),
            ),

            SizedBox(width: AppSpacing.md),

            // EXPENSE CARD
            Expanded(
              child: _StatCard(
                label: 'Pengeluaran',
                amount: expense,
                icon: Icons.arrow_upward_rounded,
                gradient: AppColors.expenseGradient,
                delay: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Gradient gradient;
  final int delay;

  const _StatCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.gradient,
    required this.delay,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppRadius.lg,
            boxShadow: AppAnimations.cardShadowPressed(_isPressed),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICON
              Container(
                width: AppIconSize.lg,
                height: AppIconSize.lg,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  borderRadius: AppRadius.md,
                ),
                child: Icon(
                  widget.icon,
                  color: AppColors.textOnPrimary,
                  size: 24,
                ),
              ),

              SizedBox(height: AppSpacing.md),

              // LABEL
              Text(
                widget.label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: AppSpacing.xs),

              // AMOUNT (Animated)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: widget.amount),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    CurrencyFormatter.formatCompact(value),
                    style: AppTypography.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}