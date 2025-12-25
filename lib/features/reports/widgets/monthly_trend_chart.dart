import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart'
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/models/transaction.dart';

class MonthlyTrendChart extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const MonthlyTrendChart({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, _) {
        // Get all months in range
        final months = <String>[];
        final monthlyData = <String, Map<String, double>>{};

        DateTime current = DateTime(startDate.year, startDate.month, 1);
        while (current.isBefore(endDate) || current.month == endDate.month) {
          final monthKey = '${current.month}/${current.year}';
          months.add(monthKey);
          monthlyData[monthKey] = {'income': 0, 'expense': 0};

          if (current.month == 12) {
            current = DateTime(current.year + 1, 1, 1);
          } else {
            current = DateTime(current.year, current.month + 1, 1);
          }
          if (current.isAfter(endDate)) break;
        }

        // Fill data
        for (var txn in transactionProvider.transactions) {
          if (txn.createdAt.isBefore(startDate) ||
              txn.createdAt.isAfter(endDate)) {
            continue;
          }

          final monthKey = '${txn.createdAt.month}/${txn.createdAt.year}';
          if (monthlyData.containsKey(monthKey)) {
            if (txn.isIncome) {
              monthlyData[monthKey]!['income'] =
                  (monthlyData[monthKey]!['income'] ?? 0) + txn.amount;
            } else {
              monthlyData[monthKey]!['expense'] =
                  (monthlyData[monthKey]!['expense'] ?? 0) + txn.amount;
            }
          }
        }

        // Find max value for scaling
        double maxValue = 0;
        for (var data in monthlyData.values) {
          final max = [(data['income'] ?? 0), (data['expense'] ?? 0)].reduce(
            (a, b) => a > b ? a : b,
          );
          if (max > maxValue) maxValue = max;
        }

        if (maxValue == 0) {
          return Center(
            child: Text(
              'Belum ada data transaksi',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

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
                'Tren Bulanan',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Chart
              SizedBox(
                height: 300,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: months.map((month) {
                      final data = monthlyData[month]!;
                      final income = data['income'] ?? 0.0;
                      final expense = data['expense'] ?? 0.0;
                      final incomeHeight = (income / maxValue) * 200;
                      final expenseHeight = (expense / maxValue) * 200;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Values on top
                            Column(
                              children: [
                                if (income > 0)
                                  Text(
                                    CurrencyFormatter.format(income),
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.income,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                const SizedBox(height: 2),
                                if (expense > 0)
                                  Text(
                                    CurrencyFormatter.format(expense),
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.expense,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.md),

                            // Bars
                            SizedBox(
                              height: 200,
                              width: 40,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  // Expense bar
                                  if (expense > 0)
                                    Container(
                                      height: expenseHeight,
                                      width: 18,
                                      decoration: BoxDecoration(
                                        color: AppColors.expense,
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(
                                            AppRadius.md,
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Income bar
                                  if (income > 0)
                                    Positioned(
                                      bottom: expenseHeight,
                                      child: Container(
                                        height: incomeHeight,
                                        width: 18,
                                        decoration: BoxDecoration(
                                          color: AppColors.income,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(
                                              AppRadius.md,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: AppSpacing.md),

                            // Month label
                            Text(
                              month,
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Legend
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.income,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pemasukan',
                    style: AppTypography.caption,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.expense,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pengeluaran',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}


