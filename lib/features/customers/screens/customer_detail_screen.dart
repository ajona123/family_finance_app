import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/customer.dart';
import '../../../../data/providers/transaction_provider.dart';
import '../../../../data/models/transaction.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailScreen({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  void _showEditPaymentStatusDialog(
    BuildContext context,
    Transaction transaction,
  ) {
    final remainingController = TextEditingController(
      text: transaction.remainingAmount?.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Edit Status Pembayaran',
                      style: AppTypography.headingSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),
              Text(
                'Rp ${transaction.amount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                style: AppTypography.headingSmall,
              ),
              const SizedBox(height: AppConstants.spacingXL),
              Column(
                children: [
                  _PaymentStatusOption(
                    isSelected: transaction.paymentStatus == 'lunas',
                    title: 'Lunas',
                    subtitle: 'Pembayaran sudah selesai',
                    onTap: () {
                      final updatedTxn = transaction.copyWith(
                        paymentStatus: 'lunas',
                        remainingAmount: 0,
                      );
                      context
                          .read<TransactionProvider>()
                          .updateTransaction(updatedTxn);
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  _PaymentStatusOption(
                    isSelected: transaction.paymentStatus == 'unpaid',
                    title: 'Belum Lunas',
                    subtitle: 'Ada sisa pembayaran',
                    onTap: () {
                      // Will show input field below
                    },
                  ),
                  if (transaction.paymentStatus == 'unpaid') ...[
                    const SizedBox(height: AppConstants.spacingM),
                    TextField(
                      controller: remainingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Jumlah Sisa (Rp)',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusM),
                          borderSide:
                              const BorderSide(color: Color(0xFFE8E8E8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusM),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingM,
                          vertical: AppConstants.spacingM,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppConstants.spacingXL),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFE8E8E8),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusL),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.spacingM,
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (transaction.paymentStatus == 'unpaid') {
                          final remaining = double.tryParse(
                                remainingController.text,
                              ) ??
                              0;
                          final updatedTxn = transaction.copyWith(
                            paymentStatus: 'unpaid',
                            remainingAmount: remaining,
                          );
                          context
                              .read<TransactionProvider>()
                              .updateTransaction(updatedTxn);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusL),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.spacingM,
                        ),
                      ),
                      child: Text(
                        'Simpan',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
          widget.customer.name,
          style: AppTypography.headingMedium,
        ),
        centerTitle: true,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, _) {
          final transactions =
              transactionProvider.getTransactionsByCustomer(widget.customer.id);

          // Calculate totals
          double totalAmount = 0;
          double totalRemaining = 0;
          int unaidCount = 0;

          for (var txn in transactions) {
            totalAmount += txn.amount;
            if (txn.paymentStatus == 'unpaid' && txn.remainingAmount != null) {
              totalRemaining += txn.remainingAmount!;
              unaidCount++;
            }
          }

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 80,
                    color: AppColors.border,
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                  Text(
                    'Belum ada transaksi',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // SUMMARY CARDS
              Container(
                margin: const EdgeInsets.all(AppConstants.spacingL),
                child: Column(
                  children: [
                    // Total Card
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingL),
                      decoration: BoxDecoration(
                        gradient: AppColors.incomeGradient,
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.income.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Transaksi',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rp ${totalAmount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                            style: AppTypography.headingSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (totalRemaining > 0) ...[
                      const SizedBox(height: AppConstants.spacingM),
                      // Remaining Card
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spacingL),
                        decoration: BoxDecoration(
                          gradient: AppColors.expenseGradient,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusL),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.expense.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sisa Pembayaran',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Rp ${totalRemaining.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spacingM,
                                vertical: AppConstants.spacingS,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusM,
                                ),
                              ),
                              child: Text(
                                '$unaidCount belum lunas',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // TRANSACTIONS LIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingL,
                  ),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction =
                        transactions[transactions.length - 1 - index];
                    final isLunas = transaction.paymentStatus == 'lunas';

                    return GestureDetector(
                      onTap: () {
                        _showEditPaymentStatusDialog(context, transaction);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                          bottom: AppConstants.spacingM,
                        ),
                        padding: const EdgeInsets.all(AppConstants.spacingL),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusL),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rp ${transaction.amount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                                  style: AppTypography.labelLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.spacingM,
                                    vertical: AppConstants.spacingS,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isLunas
                                        ? AppColors.income.withOpacity(0.2)
                                        : AppColors.expense.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.radiusM,
                                    ),
                                  ),
                                  child: Text(
                                    isLunas ? '✓ Lunas' : '⊙ Sisa',
                                    style: AppTypography.caption.copyWith(
                                      color: isLunas
                                          ? AppColors.income
                                          : AppColors.expense,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spacingM),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (!isLunas && transaction.remainingAmount != null)
                                  Text(
                                    'Sisa: Rp ${transaction.remainingAmount!.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.expense,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PaymentStatusOption extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentStatusOption({
    required this.isSelected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
