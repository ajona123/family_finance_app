import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/member_provider.dart';
import '../../../data/models/transaction.dart';

class MemberSpendingBreakdown extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const MemberSpendingBreakdown({
    super.key,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, MemberProvider>(
      builder: (context, transactionProvider, memberProvider, _) {
        // Get expense transactions in date range
        final transactions = transactionProvider.transactions.where((txn) {
          if (!txn.isIncome) {
            if (startDate != null && txn.createdAt.isBefore(startDate!)) return false;
            if (endDate != null && txn.createdAt.isAfter(endDate!)) return false;
            return true;
          }
          return false;
        }).toList();

        // Group by member and calculate total
        final memberTotals = <String, double>{};
        for (var txn in transactions) {
          final member = memberProvider.getMemberById(txn.memberId);
          final memberName = member?.name ?? 'Unknown';
          memberTotals[memberName] = (memberTotals[memberName] ?? 0) + txn.amount;
        }

        // Sort by total (descending)
        final sortedMembers = memberTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (sortedMembers.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
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
        final totalSpending = sortedMembers.fold<double>(
          0,
          (sum, entry) => sum + entry.value,
        );

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
                'Pengeluaran Per Anggota',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),
              ...sortedMembers.asMap().entries.map((entry) {
                final index = entry.key;
                final memberName = entry.value.key;
                final amount = entry.value.value;
                final percentage = (amount / totalSpending * 100).toStringAsFixed(1);

                // Get member color (use primary color)
                final colors = [
                  AppColors.primary,
                  AppColors.income,
                  AppColors.expense,
                  AppColors.warning,
                  const Color(0xFF7E57C2),
                  const Color(0xFF26A69A),
                  const Color(0xFFFFA726),
                ];
                final color = colors[index % colors.length];

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < sortedMembers.length - 1
                        ? AppConstants.spacingM
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
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                memberName,
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
                          valueColor: AlwaysStoppedAnimation<Color>(color),
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
