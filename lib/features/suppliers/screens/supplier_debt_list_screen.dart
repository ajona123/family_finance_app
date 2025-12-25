import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart'
import '../../../core/constants/app_spacing.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/models/category.dart';
import 'supplier_debt_detail_screen.dart';

class SupplierDebtListScreen extends StatefulWidget {
  const SupplierDebtListScreen({super.key});

  @override
  State<SupplierDebtListScreen> createState() => _SupplierDebtListScreenState();
}

class _SupplierDebtListScreenState extends State<SupplierDebtListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hutang ke Supplier',
          style: AppTypography.headingMedium,
        ),
        centerTitle: true,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, _) {
          // Get all supplier transactions
          final supplierTransactions = transactionProvider.transactions
              .where((t) =>
                  t.category == CategoryType.supplierDebt &&
                  t.supplierId != null &&
                  t.supplierId!.isNotEmpty)
              .toList();

          if (supplierTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 80,
                    color: AppColors.border,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Belum ada hutang ke supplier',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Group transactions by supplier ID
          final Map<String, List<dynamic>> groupedBySupplier = {};
          for (var txn in supplierTransactions) {
            final supplierId = txn.supplierId!;
            if (!groupedBySupplier.containsKey(supplierId)) {
              groupedBySupplier[supplierId] = [];
            }
            groupedBySupplier[supplierId]!.add(txn);
          }

          // Sort suppliers by most recent transaction
          final sortedSuppliers = groupedBySupplier.entries.toList()
            ..sort((a, b) {
              final aLatest = (a.value as List).reduce((cur, next) =>
                  cur.createdAt.isAfter(next.createdAt) ? cur : next);
              final bLatest = (b.value as List).reduce((cur, next) =>
                  cur.createdAt.isAfter(next.createdAt) ? cur : next);
              return bLatest.createdAt.compareTo(aLatest.createdAt);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: sortedSuppliers.length,
            itemBuilder: (context, index) {
              final supplierEntry = sortedSuppliers[index];
              final supplierId = supplierEntry.key;
              final supplierTxns = supplierEntry.value as List;

              // Calculate totals from all supplier transactions
              double totalAmount = 0;
              double totalRemaining = 0;

              for (var txn in supplierTxns) {
                totalAmount += txn.amount;
                if (txn.paymentStatus == 'unpaid' &&
                    txn.remainingAmount != null) {
                  totalRemaining += txn.remainingAmount!;
                }
              }

              final isFullyPaid = totalRemaining == 0;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SupplierDebtDetailScreen(
                        supplierId: supplierId,
                        supplierName: supplierId,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: isFullyPaid
                        ? AppColors.incomeGradient
                        : AppColors.expenseGradient,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: (isFullyPaid
                                ? AppColors.income
                                : AppColors.expense)
                            .withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  supplierId,
                                  style: AppTypography.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${supplierTxns.length} transaksi',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                            child: Text(
                              isFullyPaid ? '✓ Lunas' : '⊙ Sisa',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                'Rp ${totalAmount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (!isFullyPaid)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Sisa',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  'Rp ${totalRemaining.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


