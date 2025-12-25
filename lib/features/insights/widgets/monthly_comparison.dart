import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/providers/transaction_provider.dart';

class MonthlyComparison extends StatelessWidget {
  const MonthlyComparison({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final currentMonthBalance = transactionProvider.currentMonthBalance;
    final changePercentage = transactionProvider.getMonthlyChangePercentage();
    final isPositive = changePercentage >= 0;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        gradient: isPositive
            ? AppColors.incomeGradient
            : AppColors.expenseGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: isPositive
                ? AppColors.income.withOpacity(0.3)
                : AppColors.expense.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Perbandingan Bulan Ini',
                  style: AppTypography.headingSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingL),

          // CURRENT MONTH BALANCE
          Text(
            'Saldo Bulan Ini',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),

          const SizedBox(height: 8),

          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: currentMonthBalance),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                CurrencyFormatter.format(value),
                style: AppTypography.displayMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),

          const SizedBox(height: AppConstants.spacingL),

          // COMPARISON
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Row(
              children: [
                Icon(
                  isPositive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPositive ? 'Naik' : 'Turun',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Dari bulan lalu',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isPositive ? '+' : ''}${changePercentage.toStringAsFixed(1)}%',
                  style: AppTypography.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingM),

          // INFO TEXT
          Text(
            isPositive
                ? '🎉 Bagus! Saldo bulan ini lebih baik dari bulan lalu'
                : '⚠️ Perhatian! Saldo bulan ini menurun dari bulan lalu',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}