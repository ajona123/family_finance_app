import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '';import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';

class CategoryDetailReport extends StatefulWidget {
  final List<Transaction> transactions;
  final DateTime startDate;
  final DateTime endDate;

  const CategoryDetailReport({
    super.key,
    required this.transactions,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<CategoryDetailReport> createState() => _CategoryDetailReportState();
}

class _CategoryDetailReportState extends State<CategoryDetailReport> {
  String _expandedCategory = '';

  @override
  Widget build(BuildContext context) {
    // Group by category
    final categoryTotals = <String, Map<String, dynamic>>{};
    final categoryTransactions = <String, List<Transaction>>{};

    for (var txn in widget.transactions) {
      final categoryName = txn.categoryInfo.name;
      if (!categoryTotals.containsKey(categoryName)) {
        categoryTotals[categoryName] = {
          'income': 0.0,
          'expense': 0.0,
          'count': 0,
          'category': txn.categoryInfo,
        };
        categoryTransactions[categoryName] = [];
      }
      if (txn.isIncome) {
        categoryTotals[categoryName]!['income'] += txn.amount;
      } else {
        categoryTotals[categoryName]!['expense'] += txn.amount;
      }
      categoryTotals[categoryName]!['count'] += 1;
      categoryTransactions[categoryName]!.add(txn);
    }

    // Sort by expense
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) {
        final aTotal = (a.value['expense'] as double?) ?? 0;
        final bTotal = (b.value['expense'] as double?) ?? 0;
        return bTotal.compareTo(aTotal);
      });

    if (sortedCategories.isEmpty) {
      return Center(
        child: Text(
          'Belum ada transaksi',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      children: sortedCategories.map((entry) {
        final categoryName = entry.key;
        final stats = entry.value;
        final transactions = categoryTransactions[categoryName] ?? [];
        final isExpanded = _expandedCategory == categoryName;

        return _CategoryDetailCard(
          categoryName: categoryName,
          category: stats['category'] as Category,
          income: stats['income'] as double,
          expense: stats['expense'] as double,
          count: stats['count'] as int,
          transactions: transactions,
          isExpanded: isExpanded,
          onToggle: () {
            setState(() {
              _expandedCategory = isExpanded ? '' : categoryName;
            });
          },
        );
      }).toList(),
    );
  }
}

class _CategoryDetailCard extends StatelessWidget {
  final String categoryName;
  final Category category;
  final double income;
  final double expense;
  final int count;
  final List<Transaction> transactions;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _CategoryDetailCard({
    required this.categoryName,
    required this.category,
    required this.income,
    required this.expense,
    required this.count,
    required this.transactions,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final total = income + expense;
    final avgAmount = count > 0 ? total / count : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // Header (always visible)
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (income > 0) ...[
                              Text(
                                '+${CurrencyFormatter.format(income)}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.income,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (expense > 0) ...[
                              Text(
                                '-${CurrencyFormatter.format(expense)}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.expense,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Expand icon
                  Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded) ...[
            Divider(
              color: AppColors.border,
              height: 0,
              thickness: 1,
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.5,
                    children: [
                      _StatBox(
                        label: 'Jumlah',
                        value: count.toString(),
                        color: AppColors.primary,
                      ),
                      _StatBox(
                        label: 'Rata-rata',
                        value: CurrencyFormatter.format(avgAmount.toDouble()),
                        color: AppColors.warning,
                      ),
                      _StatBox(
                        label: 'Total Pemasukan',
                        value: '+${CurrencyFormatter.format(income)}',
                        color: AppColors.income,
                      ),
                      _StatBox(
                        label: 'Total Pengeluaran',
                        value: '-${CurrencyFormatter.format(expense)}',
                        color: AppColors.expense,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Transactions list
                  if (transactions.isNotEmpty) ...[
                    Text(
                      'Transaksi (${transactions.length})',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...transactions.take(5).map((txn) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (txn.note ?? '').isEmpty ? 'Tanpa catatan' : (txn.note ?? ''),
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${txn.createdAt.day}/${txn.createdAt.month}/${txn.createdAt.year}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              CurrencyFormatter.formatWithSign(
                                txn.isIncome ? txn.amount : -txn.amount,
                              ),
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: txn.isIncome
                                    ? AppColors.income
                                    : AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    if (transactions.length > 5) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '+${transactions.length - 5} transaksi lainnya',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}



