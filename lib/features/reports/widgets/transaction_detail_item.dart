import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart'
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';

class TransactionDetailItem extends StatelessWidget {
  final Transaction transaction;
  final String memberName;

  const TransactionDetailItem({
    super.key,
    required this.transaction,
    required this.memberName,
  });

  Color _getCategoryColor() {
    final category = Category.getByType(transaction.category);
    return category.color;
  }

  String _getCategoryLabel() {
    final category = Category.getByType(transaction.category);
    return category.name;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memberName,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormatter.format(transaction.createdAt),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                style: AppTypography.headingSmall.copyWith(
                  color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF5350),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Category and type badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: _getCategoryColor().withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getCategoryLabel(),
                  style: AppTypography.labelSmall.copyWith(
                    color: _getCategoryColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: (isIncome ? const Color(0xFF10B981) : const Color(0xFFEF5350))
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: (isIncome ? const Color(0xFF10B981) : const Color(0xFFEF5350))
                        .withOpacity(0.3),
                  ),
                ),
                child: Text(
                  isIncome ? 'Pemasukan' : 'Pengeluaran',
                  style: AppTypography.labelSmall.copyWith(
                    color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF5350),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Notes if available
          if (transaction.note != null && transaction.note!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Catatan',
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              transaction.note!,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],

          // Meat items if available
          if (transaction.hasMeatItems) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Daging',
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...transaction.meatItems!.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.cutName,
                                  style: AppTypography.labelSmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.weight} kg × ${CurrencyFormatter.format(item.pricePerKg)}/kg',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(item.totalPrice),
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],

          // Payment status if applicable
          if (transaction.paymentStatus != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status Pembayaran',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: (transaction.paymentStatus == 'lunas'
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B))
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: (transaction.paymentStatus == 'lunas'
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B))
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    transaction.paymentStatus == 'lunas' ? 'Lunas' : 'Belum Lunas',
                    style: AppTypography.labelSmall.copyWith(
                      color: transaction.paymentStatus == 'lunas'
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (transaction.remainingAmount != null && transaction.remainingAmount! > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sisa Pembayaran',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(transaction.remainingAmount!),
                    style: AppTypography.labelSmall.copyWith(
                      color: const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}


