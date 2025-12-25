import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../utils/constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../transactions/screens/pay_supplier_debt_screen.dart';

class SupplierDebtDetailScreen extends StatefulWidget {
  final String supplierId;
  final String supplierName;

  const SupplierDebtDetailScreen({
    super.key,
    required this.supplierId,
    required this.supplierName,
  });

  @override
  State<SupplierDebtDetailScreen> createState() =>
      _SupplierDebtDetailScreenState();
}

class _SupplierDebtDetailScreenState extends State<SupplierDebtDetailScreen> {
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
          widget.supplierName,
          style: AppTypography.headingMedium,
        ),
        centerTitle: true,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, _) {
          // Get all transactions for this supplier (including meat transactions)
          final allTransactions = transactionProvider.transactions
              .where((t) =>
                  (t.category == CategoryType.supplierDebt ||
                   t.category == CategoryType.meatLocal ||
                   t.category == CategoryType.meatImport) &&
                  t.supplierId == widget.supplierId)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // Get payment records for this supplier
          final paymentRecords = transactionProvider.transactions
              .where((t) =>
                  t.category == CategoryType.supplierPayment &&
                  t.supplierId == widget.supplierId)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // Separate unpaid dan paid
          final unpaidTxns = allTransactions
              .where((t) =>
                  t.paymentStatus == 'unpaid' &&
                  (t.remainingAmount ?? 0) > 0)
              .toList();

          final paidTxns = allTransactions.where((t) =>
              t.paymentStatus == 'lunas' || t.paymentStatus == null).toList();

          // Calculate total debt
          double totalDebt =
              unpaidTxns.fold(0, (sum, t) => sum + (t.remainingAmount ?? 0));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DEBT SUMMARY
                if (totalDebt > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: AppColors.expenseGradient,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                    AppRadius.md),
                              ),
                              child: const Icon(
                                Icons.warning_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Hutang',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${totalDebt.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                                  style: AppTypography.headingSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PaySupplierDebtScreen(
                                    initialSupplierName:
                                        widget.supplierName,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.payment_rounded),
                            label: const Text('Catat Pembayaran'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: AppColors.incomeGradient,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          'Semua transaksi sudah lunas ✓',
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],

                // UNPAID TRANSACTIONS
                if (unpaidTxns.isNotEmpty) ...[
                  Text(
                    'Hutang yang Belum Dibayar (${unpaidTxns.length})',
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...unpaidTxns.map((txn) => _buildTransactionCard(txn, true)),
                  const SizedBox(height: AppSpacing.xxl),
                ],

                // PAYMENT RECORDS - Always show if not empty
                if (paymentRecords.isNotEmpty) ...[
                  Text(
                    'Riwayat Pembayaran',
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...paymentRecords.map((txn) => _buildPaymentRecordCard(txn)),
                  const SizedBox(height: AppSpacing.xxl),
                ],

                // PAID TRANSACTIONS
                if (paidTxns.isNotEmpty) ...[
                  Text(
                    'Transaksi Lunas (${paidTxns.length})',
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...paidTxns.map((txn) => _buildTransactionCard(txn, false)),
                ],

                if (allTransactions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xxl,
                      ),
                      child: Text(
                        'Belum ada transaksi',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(Transaction txn, bool isUnpaid) {
    final category = Category.getByType(txn.category);
    final statusColor = isUnpaid
        ? const Color(0xFFFFA500) // Orange/Kuning
        : const Color(0xFF10B981); // Hijau
    final statusIcon = isUnpaid ? Icons.warning_rounded : Icons.check_rounded;
    final statusLabel = isUnpaid ? '⚠ Belum Lunas' : '✓ Lunas';

    return GestureDetector(
      onTap: isUnpaid
          ? () {
              // Buka PaySupplierDebtScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaySupplierDebtScreen(
                    initialSupplierName: widget.supplierName,
                  ),
                ),
              );
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: AppTypography.labelMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (txn.note != null)
                              Text(
                                txn.note!,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${txn.amount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isUnpaid && (txn.remainingAmount ?? 0) > 0)
                      Text(
                        'Sisa: Rp ${(txn.remainingAmount ?? 0).toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFFFFA500),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(txn.createdAt),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: AppTypography.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isUnpaid)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  '👆 Tap untuk catat pembayaran',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFFFFA500),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRecordCard(Transaction record) {
    // Calculate payment number based on order in list (sorted by date, oldest first)
    final allPayments = context.read<TransactionProvider>().transactions
        .where((t) =>
            t.category == CategoryType.supplierPayment &&
            t.supplierId == record.supplierId)
        .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // Oldest first
    
    final paymentIndex = allPayments.indexWhere((t) => t.id == record.id);
    final paymentNumber = paymentIndex >= 0 ? paymentIndex + 1 : 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Pembayaran ke-$paymentNumber ke ${record.supplierId}',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Rp ${record.amount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                style: AppTypography.labelMedium.copyWith(
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _formatDate(record.createdAt),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (record.note != null && record.note!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Catatan: ${record.note}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}



