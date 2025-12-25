import 'package:flutter/material.dart';
import '../../../data/models/category.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/member_provider.dart';
import '../../../data/models/transaction.dart';
import '../../customers/screens/customer_debt_detail_screen.dart';
import '../../suppliers/screens/supplier_debt_detail_screen.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final groupedTransactions = transactionProvider.transactionsGroupedByDate;

    if (groupedTransactions.isEmpty) {
      return _EmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaksi Terbaru',
                style: AppTypography.headingMedium,
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all transactions
                },
                child: Text(
                  'Lihat Semua',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: AppSpacing.md),

        // TRANSACTIONS LIST
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: groupedTransactions.length,
          itemBuilder: (context, index) {
            final dateKey = groupedTransactions.keys.elementAt(index);
            final transactions = groupedTransactions[dateKey]!;

            return _TransactionGroup(
              dateLabel: dateKey,
              transactions: transactions,
            );
          },
        ),
      ],
    );
  }
}

class _TransactionGroup extends StatelessWidget {
  final String dateLabel;
  final List<Transaction> transactions;

  const _TransactionGroup({
    required this.dateLabel,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    // Group transactions by customerId/supplierId for deduplication
    final deduplicatedTransactions = <Transaction>[];
    final seenCustomerIds = <String>{};
    final seenSupplierIds = <String>{};

    for (final transaction in transactions) {
      // If it's a pelanggan RDFF with hutang, only show once per customer
      if (transaction.customerId != null && 
          transaction.category == CategoryType.pelangganRdff &&
          transaction.paymentStatus == 'unpaid' &&
          (transaction.remainingAmount ?? 0) > 0) {
        if (!seenCustomerIds.contains(transaction.customerId)) {
          deduplicatedTransactions.add(transaction);
          seenCustomerIds.add(transaction.customerId!);
        }
      } 
      // If it's a supplier debt with hutang, only show once per supplier
      else if (transaction.supplierId != null && 
               transaction.category == CategoryType.supplierDebt &&
               transaction.paymentStatus == 'unpaid' &&
               (transaction.remainingAmount ?? 0) > 0) {
        if (!seenSupplierIds.contains(transaction.supplierId)) {
          deduplicatedTransactions.add(transaction);
          seenSupplierIds.add(transaction.supplierId!);
        }
      }
      // If it's a debt payment, only show the latest one per customer
      else if (transaction.customerId != null && 
               transaction.category == CategoryType.debtPayment) {
        if (!seenCustomerIds.contains(transaction.customerId)) {
          deduplicatedTransactions.add(transaction);
          seenCustomerIds.add(transaction.customerId!);
        }
      }
      // If it's a supplier payment, only show the latest one per supplier
      else if (transaction.supplierId != null && 
               transaction.category == CategoryType.supplierPayment) {
        if (!seenSupplierIds.contains(transaction.supplierId)) {
          deduplicatedTransactions.add(transaction);
          seenSupplierIds.add(transaction.supplierId!);
        }
      }
      // Non-pelanggan/supplier or paid transactions show all
      else {
        deduplicatedTransactions.add(transaction);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DATE LABEL
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            dateLabel,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // TRANSACTION ITEMS
        ...deduplicatedTransactions.map((transaction) {
          return _TransactionItem(
            key: ValueKey(transaction.id),
            transaction: transaction,
            isLast: transaction == deduplicatedTransactions.last,
          );
        }),

        const SizedBox(height: AppConstants.spacingM),
      ],
    );
  }
}

class _TransactionItem extends StatefulWidget {
  final Transaction transaction;
  final bool isLast;

  const _TransactionItem({
    super.key,
    required this.transaction,
    this.isLast = false,
  });

  @override
  State<_TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<_TransactionItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _deleteTransaction(BuildContext context) async {
    HapticHelper.heavy();

    // Animate out
    await _controller.reverse();

    if (context.mounted) {
      await context.read<TransactionProvider>().deleteTransaction(
        widget.transaction.id,
      );

      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaksi berhasil dihapus'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();
    final member = memberProvider.getMemberById(widget.transaction.memberId);
    final category = widget.transaction.categoryInfo;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dismissible(
          key: Key(widget.transaction.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Hapus Transaksi?'),
                content: const Text(
                  'Transaksi yang dihapus tidak dapat dikembalikan.',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.lg,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) => _deleteTransaction(context),
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: AppSpacing.lg),
            margin: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.expenseGradient,
              borderRadius: AppRadius.lg,
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.textOnPrimary,
              size: 28,
            ),
          ),
          child: InkWell(
            onTap: widget.transaction.customerId != null
                ? () {
                    HapticHelper.light();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerDebtDetailScreen(
                          customerId: widget.transaction.customerId!,
                          customerName: widget.transaction.customerId!,
                        ),
                      ),
                    );
                  }
                : widget.transaction.supplierId != null
                    ? () {
                        HapticHelper.light();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SupplierDebtDetailScreen(
                              supplierId: widget.transaction.supplierId!,
                              supplierName: widget.transaction.supplierId!,
                            ),
                          ),
                        );
                      }
                    : null,
            borderRadius: AppRadius.lg,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 4,
              ),
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: AppRadius.lg,
                boxShadow: [AppShadows.sm],
              ),
              child: Row(
              children: [
                // CATEGORY ICON
                Container(
                  width: AppIconSize.lg,
                  height: AppIconSize.lg,
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: AppRadius.md,
                  ),
                  child: Center(
                    child: Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                SizedBox(width: AppSpacing.md),

                // INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          if (member != null) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: AppRadius.sm,
                              ),
                              child: Text(
                                member.name,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                          ],
                          // SUPPLIER NAME (if meat transaction)
                          if (widget.transaction.hasMeatItems &&
                              widget.transaction.meatItems!.isNotEmpty &&
                              widget.transaction.meatItems!.first.supplier != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.income.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.transaction.meatItems!.first.supplier!,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.income,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // CUSTOMER NAME (if pelanggan RDFF)
                          if (widget.transaction.customerId != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getCustomerBadgeColor(
                                  context,
                                  widget.transaction,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getCustomerBadgeIcon(
                                      context,
                                      widget.transaction,
                                    ),
                                    style: AppTypography.caption.copyWith(
                                      color: _getCustomerBadgeColor(
                                        context,
                                        widget.transaction,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.transaction.customerId!,
                                    style: AppTypography.caption.copyWith(
                                      color: _getCustomerBadgeColor(
                                        context,
                                        widget.transaction,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                          ],
                          // SUPPLIER STATUS (if supplier debt only, not meat)
                          if (widget.transaction.supplierId != null && 
                              !widget.transaction.hasMeatItems) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getSupplierBadgeColor(
                                  context,
                                  widget.transaction,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getSupplierBadgeIcon(
                                      context,
                                      widget.transaction,
                                    ),
                                    style: AppTypography.caption.copyWith(
                                      color: _getSupplierBadgeColor(
                                        context,
                                        widget.transaction,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.transaction.supplierId!,
                                    style: AppTypography.caption.copyWith(
                                      color: _getSupplierBadgeColor(
                                        context,
                                        widget.transaction,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // MEAT STATUS BADGE (if meat transaction)
                          if (widget.transaction.hasMeatItems) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getMeatBadgeColor(
                                  context,
                                  widget.transaction,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getMeatBadgeIcon(
                                      context,
                                      widget.transaction,
                                    ),
                                    style: AppTypography.caption.copyWith(
                                      color: _getMeatBadgeColor(
                                        context,
                                        widget.transaction,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getMeatBadgeStatus(
                                      context,
                                      widget.transaction,
                                    ),
                                    style: AppTypography.caption.copyWith(
                                      color: _getMeatBadgeColor(
                                        context,
                                        widget.transaction,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            DateHelper.formatTime(widget.transaction.createdAt),
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // AMOUNT
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.formatWithSign(
                            widget.transaction.isIncome
                                ? widget.transaction.amount
                                : -widget.transaction.amount,
                          ),
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.transaction.isIncome
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                        ),
                        // PAYMENT STATUS (for pelanggan RDFF and supplier)
                        if (widget.transaction.customerId != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _getCustomerBadgeColor(context, widget.transaction) == const Color(0xFF10B981)
                                  ? AppColors.income
                                  : AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _getCustomerBadgeIcon(context, widget.transaction) == '✓'
                                    ? '✓'
                                    : '⊙',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (widget.transaction.supplierId != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _getSupplierBadgeColor(context, widget.transaction) == const Color(0xFF10B981)
                                  ? AppColors.income
                                  : AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _getSupplierBadgeIcon(context, widget.transaction) == '✓'
                                    ? '✓'
                                    : '⊙',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (widget.transaction.hasMeatItems) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${widget.transaction.meatItems!.length} item',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
            ),
        ),
      ),
    );
  }

  Color _getCustomerBadgeColor(
    BuildContext context,
    Transaction txn,
  ) {
    final provider = context.read<TransactionProvider>();
    
    // For debtPayment, check if customer is fully paid
    if (txn.category == CategoryType.debtPayment) {
      final customerTxns = provider.transactions.where((t) =>
          t.category == CategoryType.pelangganRdff &&
          t.customerId == txn.customerId).toList();
      
      final hasUnpaid = customerTxns.any((t) =>
          t.paymentStatus == 'unpaid' && (t.remainingAmount ?? 0) > 0);
      
      return hasUnpaid ? const Color(0xFFFFA500) : const Color(0xFF10B981);
    }
    
    // For pelangganRdff, use paymentStatus
    return txn.paymentStatus == 'lunas'
        ? const Color(0xFF10B981)
        : const Color(0xFFFFA500);
  }

  String _getCustomerBadgeIcon(
    BuildContext context,
    Transaction txn,
  ) {
    final provider = context.read<TransactionProvider>();
    
    // For debtPayment, check if customer is fully paid
    if (txn.category == CategoryType.debtPayment) {
      final customerTxns = provider.transactions.where((t) =>
          t.category == CategoryType.pelangganRdff &&
          t.customerId == txn.customerId).toList();
      
      final hasUnpaid = customerTxns.any((t) =>
          t.paymentStatus == 'unpaid' && (t.remainingAmount ?? 0) > 0);
      
      return hasUnpaid ? '⚠' : '✓';
    }
    
    // For pelangganRdff, use paymentStatus
    return txn.paymentStatus == 'lunas' ? '✓' : '⚠';
  }

  Color _getSupplierBadgeColor(
    BuildContext context,
    Transaction txn,
  ) {
    final provider = context.read<TransactionProvider>();
    
    // For supplierPayment, check if supplier is fully paid
    if (txn.category == CategoryType.supplierPayment) {
      final supplierTxns = provider.transactions.where((t) =>
          t.category == CategoryType.supplierDebt &&
          t.supplierId == txn.supplierId).toList();
      
      final hasUnpaid = supplierTxns.any((t) =>
          t.paymentStatus == 'unpaid' && (t.remainingAmount ?? 0) > 0);
      
      return hasUnpaid ? const Color(0xFFFFA500) : const Color(0xFF10B981);
    }
    
    // For supplierDebt, use paymentStatus
    return txn.paymentStatus == 'lunas'
        ? const Color(0xFF10B981)
        : const Color(0xFFFFA500);
  }

  String _getSupplierBadgeIcon(
    BuildContext context,
    Transaction txn,
  ) {
    final provider = context.read<TransactionProvider>();
    
    // For supplierPayment, check if supplier is fully paid
    if (txn.category == CategoryType.supplierPayment) {
      final supplierTxns = provider.transactions.where((t) =>
          t.category == CategoryType.supplierDebt &&
          t.supplierId == txn.supplierId).toList();
      
      final hasUnpaid = supplierTxns.any((t) =>
          t.paymentStatus == 'unpaid' && (t.remainingAmount ?? 0) > 0);
      
      return hasUnpaid ? '⚠' : '✓';
    }
    
    // For supplierDebt, use paymentStatus
    return txn.paymentStatus == 'lunas' ? '✓' : '⚠';
  }

  Color _getMeatBadgeColor(
    BuildContext context,
    Transaction txn,
  ) {
    return txn.paymentStatus == 'lunas'
        ? const Color(0xFF10B981)
        : const Color(0xFFFFA500);
  }

  String _getMeatBadgeIcon(
    BuildContext context,
    Transaction txn,
  ) {
    return txn.paymentStatus == 'lunas' ? '✓' : '⚠';
  }

  String _getMeatBadgeStatus(
    BuildContext context,
    Transaction txn,
  ) {
    return txn.paymentStatus == 'lunas' ? 'Lunas' : 'Belum Lunas';
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingL),
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: AppColors.border,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 40,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            'Belum Ada Transaksi',
            style: AppTypography.headingSmall,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'Mulai catat transaksi keuangan keluarga Anda',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}