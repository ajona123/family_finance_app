import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart'
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_helper.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/member_provider.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../widgets/search_filter_bar.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  String _searchQuery = '';
  TransactionType? _filterType;
  CategoryType? _filterCategory;
  String? _filterMemberId;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  double? _filterMinAmount;
  double? _filterMaxAmount;
  String? _filterPaymentStatus;
  String _sortBy = 'newest'; // newest, oldest, amount_high, amount_low

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Semua Transaksi'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // SEARCH & FILTER BAR
          SearchFilterBar(
            onSearchChanged: (value) => setState(() => _searchQuery = value),
            onFilterPressed: _showFilterDialog,
            filterCount: _getActiveFilterCount(),
          ),

          // SORT DROPDOWN
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Urutkan:',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(
                      value: 'newest',
                      child: Text('Terbaru'),
                    ),
                    DropdownMenuItem(
                      value: 'oldest',
                      child: Text('Terlama'),
                    ),
                    DropdownMenuItem(
                      value: 'amount_high',
                      child: Text('Jumlah Terbesar'),
                    ),
                    DropdownMenuItem(
                      value: 'amount_low',
                      child: Text('Jumlah Terkecil'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sortBy = value);
                    }
                  },
                ),
              ],
            ),
          ),

          // TRANSACTIONS LIST
          Expanded(
            child: Consumer2<TransactionProvider, MemberProvider>(
              builder: (context, transactionProvider, memberProvider, _) {
                // Filter transactions
                var filteredTransactions = transactionProvider.transactions.where((txn) {
                  // Search query
                  if (_searchQuery.isNotEmpty) {
                    final lowerQuery = _searchQuery.toLowerCase();
                    if (!(txn.note?.toLowerCase() ?? '').contains(lowerQuery) &&
                        !txn.categoryInfo.name.toLowerCase().contains(lowerQuery)) {
                      return false;
                    }
                  }

                  // Type filter
                  if (_filterType != null &&
                      (txn.isIncome ? TransactionType.income : TransactionType.expense) !=
                          _filterType) {
                    return false;
                  }

                  // Category filter
                  if (_filterCategory != null && txn.category != _filterCategory) {
                    return false;
                  }

                  // Member filter
                  if (_filterMemberId != null && txn.memberId != _filterMemberId) {
                    return false;
                  }

                  // Date range filter
                  if (_filterStartDate != null &&
                      txn.createdAt.isBefore(_filterStartDate!)) {
                    return false;
                  }
                  if (_filterEndDate != null &&
                      txn.createdAt.isAfter(_filterEndDate!)) {
                    return false;
                  }

                  // Amount range filter
                  if (_filterMinAmount != null && txn.amount < _filterMinAmount!) {
                    return false;
                  }
                  if (_filterMaxAmount != null && txn.amount > _filterMaxAmount!) {
                    return false;
                  }

                  // Payment status filter
                  if (_filterPaymentStatus != null &&
                      txn.paymentStatus != _filterPaymentStatus) {
                    return false;
                  }

                  return true;
                }).toList();

                // Sort transactions
                switch (_sortBy) {
                  case 'oldest':
                    filteredTransactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                    break;
                  case 'amount_high':
                    filteredTransactions.sort((a, b) => b.amount.compareTo(a.amount));
                    break;
                  case 'amount_low':
                    filteredTransactions.sort((a, b) => a.amount.compareTo(b.amount));
                    break;
                  default: // newest
                    filteredTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                }

                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Transaksi tidak ditemukan',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    final member = memberProvider.getMemberById(transaction.memberId);

                    return _TransactionCard(
                      transaction: transaction,
                      member: member,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_filterType != null) count++;
    if (_filterCategory != null) count++;
    if (_filterMemberId != null) count++;
    if (_filterStartDate != null) count++;
    if (_filterEndDate != null) count++;
    if (_filterMinAmount != null) count++;
    if (_filterMaxAmount != null) count++;
    if (_filterPaymentStatus != null) count++;
    return count;
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (context) => FilterSheet(
        filterType: _filterType,
        filterCategory: _filterCategory,
        filterMemberId: _filterMemberId,
        filterStartDate: _filterStartDate,
        filterEndDate: _filterEndDate,
        filterMinAmount: _filterMinAmount,
        filterMaxAmount: _filterMaxAmount,
        filterPaymentStatus: _filterPaymentStatus,
        onApplyFilter: (
          type,
          category,
          memberId,
          startDate,
          endDate,
          minAmount,
          maxAmount,
          paymentStatus,
        ) {
          setState(() {
            _filterType = type;
            _filterCategory = category;
            _filterMemberId = memberId;
            _filterStartDate = startDate;
            _filterEndDate = endDate;
            _filterMinAmount = minAmount;
            _filterMaxAmount = maxAmount;
            _filterPaymentStatus = paymentStatus;
          });
          Navigator.pop(context);
        },
        onResetFilter: () {
          setState(() {
            _filterType = null;
            _filterCategory = null;
            _filterMemberId = null;
            _filterStartDate = null;
            _filterEndDate = null;
            _filterMinAmount = null;
            _filterMaxAmount = null;
            _filterPaymentStatus = null;
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final dynamic member;

  const _TransactionCard({
    required this.transaction,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: transaction.categoryInfo.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                transaction.categoryInfo.emoji,
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
                  transaction.categoryInfo.name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (member != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          member.name,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      DateHelper.formatTime(transaction.createdAt),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatWithSign(
                  transaction.isIncome ? transaction.amount : -transaction.amount,
                ),
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: transaction.isIncome ? AppColors.income : AppColors.expense,
                ),
              ),
              if (transaction.customerId != null) ...[
                const SizedBox(height: 4),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: transaction.paymentStatus == 'lunas'
                        ? AppColors.income
                        : AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      transaction.paymentStatus == 'lunas' ? '✓' : '⊙',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class FilterSheet extends StatefulWidget {
  final TransactionType? filterType;
  final CategoryType? filterCategory;
  final String? filterMemberId;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final double? filterMinAmount;
  final double? filterMaxAmount;
  final String? filterPaymentStatus;
  final Function(
    TransactionType?,
    CategoryType?,
    String?,
    DateTime?,
    DateTime?,
    double?,
    double?,
    String?,
  ) onApplyFilter;
  final VoidCallback onResetFilter;

  const FilterSheet({
    required this.filterType,
    required this.filterCategory,
    required this.filterMemberId,
    required this.filterStartDate,
    required this.filterEndDate,
    required this.filterMinAmount,
    required this.filterMaxAmount,
    required this.filterPaymentStatus,
    required this.onApplyFilter,
    required this.onResetFilter,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late TransactionType? _tempFilterType;
  late CategoryType? _tempFilterCategory;
  late String? _tempFilterMemberId;
  late DateTime? _tempFilterStartDate;
  late DateTime? _tempFilterEndDate;
  late double? _tempFilterMinAmount;
  late double? _tempFilterMaxAmount;
  late String? _tempFilterPaymentStatus;

  @override
  void initState() {
    super.initState();
    _tempFilterType = widget.filterType;
    _tempFilterCategory = widget.filterCategory;
    _tempFilterMemberId = widget.filterMemberId;
    _tempFilterStartDate = widget.filterStartDate;
    _tempFilterEndDate = widget.filterEndDate;
    _tempFilterMinAmount = widget.filterMinAmount;
    _tempFilterMaxAmount = widget.filterMaxAmount;
    _tempFilterPaymentStatus = widget.filterPaymentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Transaksi',
                    style: AppTypography.headingSmall,
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onResetFilter();
                    },
                    child: Text(
                      'Reset',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Transaction type
              _buildFilterSection(
                'Jenis Transaksi',
                Column(
                  children: [
                    _buildFilterOption(
                      'Semua',
                      _tempFilterType == null,
                      () => setState(() => _tempFilterType = null),
                    ),
                    _buildFilterOption(
                      'Pemasukan',
                      _tempFilterType == TransactionType.income,
                      () => setState(
                        () => _tempFilterType = TransactionType.income,
                      ),
                    ),
                    _buildFilterOption(
                      'Pengeluaran',
                      _tempFilterType == TransactionType.expense,
                      () => setState(
                        () => _tempFilterType = TransactionType.expense,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Category filter
              _buildFilterSection(
                'Kategori',
                Consumer<MemberProvider>(
                  builder: (context, memberProvider, _) {
                    final selectedMember = memberProvider.selectedMember;
                    final allowedCategories = selectedMember?.allowedCategories ?? [];

                    return Column(
                      children: [
                        _buildFilterOption(
                          'Semua',
                          _tempFilterCategory == null,
                          () => setState(() => _tempFilterCategory = null),
                        ),
                        ...Category.all
                            .where((cat) => allowedCategories.contains(cat.type))
                            .map((cat) => _buildFilterOption(
                              cat.name,
                              _tempFilterCategory == cat.type,
                              () => setState(() => _tempFilterCategory = cat.type),
                            )),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Member filter
              _buildFilterSection(
                'Anggota',
                Consumer<MemberProvider>(
                  builder: (context, memberProvider, _) {
                    return Column(
                      children: [
                        _buildFilterOption(
                          'Semua',
                          _tempFilterMemberId == null,
                          () => setState(() => _tempFilterMemberId = null),
                        ),
                        ...memberProvider.members.map((member) =>
                            _buildFilterOption(
                              member.name,
                              _tempFilterMemberId == member.id,
                              () => setState(() => _tempFilterMemberId = member.id),
                            )),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Date range
              _buildFilterSection(
                'Tanggal',
                Column(
                  children: [
                    _buildDatePicker(
                      'Dari Tanggal',
                      _tempFilterStartDate,
                      (date) => setState(() => _tempFilterStartDate = date),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildDatePicker(
                      'Sampai Tanggal',
                      _tempFilterEndDate,
                      (date) => setState(() => _tempFilterEndDate = date),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilter(
                      _tempFilterType,
                      _tempFilterCategory,
                      _tempFilterMemberId,
                      _tempFilterStartDate,
                      _tempFilterEndDate,
                      _tempFilterMinAmount,
                      _tempFilterMaxAmount,
                      _tempFilterPaymentStatus,
                    );
                  },
                  child: const Text('Terapkan Filter'),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }

  Widget _buildFilterOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? value,
    Function(DateTime) onDateSelected,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value != null
                      ? '${value.day}/${value.month}/${value.year}'
                      : 'Pilih tanggal',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.calendar_today_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}


