import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';

class TopSpendingCategories extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const TopSpendingCategories({
    super.key,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, _) {
        // Get expense transactions in date range
        final transactions = transactionProvider.transactions.where((txn) {
          if (!txn.isIncome) {
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
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Center(
              child: Text(
                'Belum ada pengeluaran',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        // Calculate total for percentage
        final totalSpending = sortedCategories.fold<double>(
          0,
          (sum, entry) => sum + entry.value,
        );

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengeluaran Top Kategori',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...sortedCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final categoryName = entry.value.key;
                final amount = entry.value.value;
                final percentage = (amount / totalSpending * 100).toStringAsFixed(1);

                // Find category color
                final category = Category.all.firstWhere(
                  (cat) => cat.name == categoryName,
                  orElse: () => Category.all.first,
                );

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < sortedCategories.length - 1
                        ? AppSpacing.md
                        : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: category.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                categoryName,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$percentage%',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: amount / totalSpending,
                          minHeight: 6,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            category.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatWithSign(-amount),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}





