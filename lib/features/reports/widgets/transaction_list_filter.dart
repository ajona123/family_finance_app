import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart'
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';

class TransactionListFilter extends StatefulWidget {
  final List<String> members;
  final Function(TransactionFilterParams) onFilterChanged;

  const TransactionListFilter({
    super.key,
    required this.members,
    required this.onFilterChanged,
  });

  @override
  State<TransactionListFilter> createState() => _TransactionListFilterState();
}

class TransactionFilterParams {
  final String? selectedMember;
  final TransactionType? selectedType;
  final CategoryType? selectedCategory;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchText;
  final String sortBy; // 'date_desc', 'date_asc', 'amount_desc', 'amount_asc', 'name'
  final double? minAmount;
  final double? maxAmount;

  TransactionFilterParams({
    this.selectedMember,
    this.selectedType,
    this.selectedCategory,
    this.startDate,
    this.endDate,
    this.searchText,
    this.sortBy = 'date_desc',
    this.minAmount,
    this.maxAmount,
  });
}

class _TransactionListFilterState extends State<TransactionListFilter> {
  String? _selectedMember;
  TransactionType? _selectedType;
  CategoryType? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  String _sortBy = 'date_desc';
  double? _minAmount;
  double? _maxAmount;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    _endDate = DateTime.now();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    widget.onFilterChanged(
      TransactionFilterParams(
        selectedMember: _selectedMember,
        selectedType: _selectedType,
        selectedCategory: _selectedCategory,
        startDate: _startDate,
        endDate: _endDate,
        searchText: _searchController.text.isEmpty ? null : _searchController.text,
        sortBy: _sortBy,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
      ),
    );
  }

  void _resetFilter() {
    setState(() {
      _selectedMember = null;
      _selectedType = null;
      _selectedCategory = null;
      _sortBy = 'date_desc';
      _minAmount = null;
      _maxAmount = null;
      _startDate = DateTime.now().subtract(const Duration(days: 30));
      _endDate = DateTime.now();
      _searchController.clear();
    });
    _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Transaksi',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: _resetFilter,
                child: Text(
                  'Reset',
                  style: AppTypography.labelSmall.copyWith(
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari catatan...',
              hintStyle: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
            onChanged: (_) => _applyFilter(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Member filter
          Text(
            'Anggota',
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              underline: const SizedBox(),
              value: _selectedMember,
              hint: Text(
                'Semua Anggota',
                style: AppTypography.labelSmall,
              ),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'Semua Anggota',
                    style: AppTypography.labelSmall,
                  ),
                ),
                ...widget.members.map((member) {
                  return DropdownMenuItem<String>(
                    value: member,
                    child: Text(member),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() => _selectedMember = value);
                _applyFilter();
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Transaction type filter
          Text(
            'Jenis Transaksi',
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: DropdownButton<TransactionType>(
              isExpanded: true,
              underline: const SizedBox(),
              value: _selectedType,
              hint: Text(
                'Semua Jenis',
                style: AppTypography.labelSmall,
              ),
              items: [
                DropdownMenuItem<TransactionType>(
                  value: null,
                  child: Text(
                    'Semua Jenis',
                    style: AppTypography.labelSmall,
                  ),
                ),
                DropdownMenuItem<TransactionType>(
                  value: TransactionType.income,
                  child: Text(
                    'Pemasukan',
                    style: AppTypography.labelSmall,
                  ),
                ),
                DropdownMenuItem<TransactionType>(
                  value: TransactionType.expense,
                  child: Text(
                    'Pengeluaran',
                    style: AppTypography.labelSmall,
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value);
                _applyFilter();
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Category filter
          Text(
            'Kategori',
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: DropdownButton<CategoryType>(
              isExpanded: true,
              underline: const SizedBox(),
              value: _selectedCategory,
              hint: Text(
                'Semua Kategori',
                style: AppTypography.labelSmall,
              ),
              items: [
                DropdownMenuItem<CategoryType>(
                  value: null,
                  child: Text(
                    'Semua Kategori',
                    style: AppTypography.labelSmall,
                  ),
                ),
                ...CategoryType.values.map((category) {
                  final categoryInfo = Category.getByType(category);
                  return DropdownMenuItem<CategoryType>(
                    value: category,
                    child: Row(
                      children: [
                        Text(
                          categoryInfo.emoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          categoryInfo.name,
                          style: AppTypography.labelSmall,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() => _selectedCategory = value);
                _applyFilter();
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Date range
          Text(
            'Periode',
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _startDate = picked);
                      _applyFilter();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dari',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Pilih tanggal',
                          style: AppTypography.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _endDate = picked);
                      _applyFilter();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sampai',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Pilih tanggal',
                          style: AppTypography.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Sorting
          Text(
            'Urutkan Berdasarkan',
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              underline: const SizedBox(),
              value: _sortBy,
              items: [
                DropdownMenuItem<String>(
                  value: 'date_desc',
                  child: Text(
                    'Tanggal (Terbaru)',
                    style: AppTypography.labelSmall,
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'date_asc',
                  child: Text(
                    'Tanggal (Tertua)',
                    style: AppTypography.labelSmall,
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'amount_desc',
                  child: Text(
                    'Jumlah (Terbesar)',
                    style: AppTypography.labelSmall,
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'amount_asc',
                  child: Text(
                    'Jumlah (Terkecil)',
                    style: AppTypography.labelSmall,
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'name',
                  child: Text(
                    'Nama Anggota',
                    style: AppTypography.labelSmall,
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sortBy = value);
                  _applyFilter();
                }
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Amount range
          Text(
            'Range Jumlah (Opsional)',
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Min',
                    hintStyle: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() => _minAmount = double.tryParse(value));
                    _applyFilter();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '-',
                style: AppTypography.labelSmall,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Max',
                    hintStyle: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() => _maxAmount = double.tryParse(value));
                    _applyFilter();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


