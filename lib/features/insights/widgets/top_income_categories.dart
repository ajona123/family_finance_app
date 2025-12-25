import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';

class TopIncomeCategories extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const TopIncomeCategories({
    super.key,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, _) {
        // Get income transactions in date range
        final transactions = transactionProvider.transactions.where((txn) {
          if (txn.isIncome) {
            if (startDate != null && txn.createdAt.isBefore(startDate!)) return false;
            if (endDate != null && txn.createdAt.isAfter(endDate!)) return false;
            return true;
          }
          return false;
        }).toList();

        // Group by category and calculate total
        final categoryTotals = <String, double>{};
        for (var txn in transactions) {
          final categoryName = txn.categoryInfo.name;
          categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + txn.amount;
        }

        // Sort by total (descending)
        final sortedCategories = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (sortedCategories.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
            ),
            child: Center(
              child: Text(
                'Belum ada pemasukan',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        // Calculate total income
        final totalIncome =
            sortedCategories.fold(0.0, (sum, entry) => sum + entry.value);

        return Container(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pemasukan Top Kategori',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),
              ...sortedCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final categoryName = entry.value.key;
                final amount = entry.value.value;
                final percentage = (amount / totalIncome * 100).toStringAsFixed(1);

                // Find category color
                final category = Category.all.firstWhere(
                  (cat) => cat.name == categoryName,
                  orElse: () => Category.all.first,
                );

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index != sortedCategories.length - 1
                        ? AppConstants.spacingM
                        : 0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            category.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryName,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$percentage%',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(amount),
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.income,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: AppConstants.spacingL),
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.income.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pemasukan',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(totalIncome),
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.income,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
