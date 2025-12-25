import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/providers/transaction_provider.dart';
import '../../../../data/models/transaction.dart';
import '../../../../data/models/category.dart';

class DebtListScreen extends StatefulWidget {
  const DebtListScreen({super.key});

  @override
  State<DebtListScreen> createState() => _DebtListScreenState();
}

class _DebtListScreenState extends State<DebtListScreen> {
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
          'Daftar Hutang',
          style: AppTypography.headingMedium,
        ),
        centerTitle: true,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, _) {
          // Get all unpaid transactions
          final unPaidTransactions = transactionProvider.transactions
              .where((t) =>
                  t.category == CategoryType.pelangganRdff &&
                  t.type == TransactionType.expense &&
                  t.paymentStatus == 'unpaid' &&
                  (t.remainingAmount ?? 0) > 0)
              .toList();

          // Group by customer
          final debtByCustomer = <String, double>{};
          final transactionsByCustomer = <String, List<Transaction>>{};

          for (var txn in unPaidTransactions) {
            final customerId = txn.customerId ?? 'Unknown';
            debtByCustomer[customerId] =
                (debtByCustomer[customerId] ?? 0) + (txn.remainingAmount ?? 0);
            transactionsByCustomer.putIfAbsent(customerId, () => []);
            transactionsByCustomer[customerId]!.add(txn);
          }

          if (debtByCustomer.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 80,
                    color: AppColors.income,
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                  Text(
                    'Tidak ada hutang!',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Semua pelanggan sudah lunas',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            itemCount: debtByCustomer.length,
            itemBuilder: (context, index) {
              final entries = debtByCustomer.entries.toList();
              final customerName = entries[index].key;
              final totalDebt = entries[index].value;
              final transactions = transactionsByCustomer[customerName] ?? [];

              return Container(
                margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
                padding: const EdgeInsets.all(AppConstants.spacingL),
                decoration: BoxDecoration(
                  gradient: AppColors.expenseGradient,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.expense.withOpacity(0.3),
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
                                customerName,
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${transactions.length} transaksi',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingM,
                            vertical: AppConstants.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusM),
                          ),
                          child: Text(
                            '⚠ Hutang',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    Text(
                      'Total Hutang',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      'Rp ${totalDebt.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingL),
                    // Show breakdown of transactions
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detail Transaksi:',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingS),
                          ...transactions.map((txn) {
                            final category = Category.getByType(txn.category);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppConstants.spacingS,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${category.emoji} ${category.name}',
                                          style: AppTypography.caption.copyWith(
                                            color: Colors.white
                                                .withOpacity(0.9),
                                          ),
                                        ),
                                        if (txn.note != null)
                                          Text(
                                            txn.note!,
                                            style:
                                                AppTypography.caption.copyWith(
                                              color: Colors.white
                                                  .withOpacity(0.6),
                                              fontSize: 10,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Rp ${(txn.remainingAmount ?? 0).toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
