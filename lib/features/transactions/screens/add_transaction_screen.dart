import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/default_customers.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../core/utils/date_helper.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/member_provider.dart';
import '../../../data/providers/arisan_provider.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../data/models/meat_item.dart';
import '../../../data/models/arisan.dart';
import '../../../features/profile/widgets/create_arisan_dialog.dart';
import '../widgets/member_selector.dart';
import '../widgets/transaction_type_toggle.dart';
import '../widgets/category_grid.dart';
import '../widgets/meat_detail_form.dart';
import '../widgets/amount_input.dart';
import '../widgets/sticky_total_footer.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  TransactionType _selectedType = TransactionType.expense;
  CategoryType? _selectedCategory;
  double _amount = 0;
  String _note = '';
  List<MeatItem> _meatItems = [];
  String _customerName = ''; // For Pelanggan RDFF
  String? _selectedArisanId; // For Arisan
  DateTime? _arisanPaymentDate; // For Arisan payment date
  int _arisanDurationMonths = 1; // For Arisan duration (1-12 months)

  String _paymentStatus = 'lunas'; // lunas or unpaid
  double _remainingAmount = 0;

  final _noteController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeInOut,
    );

    _scrollController.addListener(_onScroll);

    // Animate in
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _headerController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _scrollController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = true);
    } else if (_scrollController.offset <= 50 && _isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = false);
    }
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _selectedType = type;
      // Reset category if switching type
      _selectedCategory = null;
      _meatItems.clear();
      _amount = 0;
      _customerName = '';
      _selectedArisanId = null;
      _paymentStatus = 'lunas';
      _remainingAmount = 0;
    });
    HapticHelper.medium();
  }

  void _onCategorySelected(CategoryType category) {
    setState(() {
      _selectedCategory = category;
      _meatItems.clear();
      _amount = 0;
      _customerName = '';
      _selectedArisanId = null;
      _paymentStatus = 'lunas';
      _remainingAmount = 0;
      
      // Auto-set type: Pelanggan RDFF adalah income, Supplier adalah expense
      if (category == CategoryType.pelangganRdff) {
        _selectedType = TransactionType.income;
      } else if (category == CategoryType.supplierDebt) {
        _selectedType = TransactionType.expense;
      }
    });
    HapticHelper.selection();
  }

  void _onAmountChanged(double amount) {
    setState(() => _amount = amount);
  }

  void _onMeatItemsChanged(List<MeatItem> items) {
    setState(() {
      _meatItems = items;
      _amount = items.fold(0, (sum, item) => sum + item.totalPrice);
    });
  }

  double get _totalAmount {
    if (_selectedCategory != null &&
        Category.getByType(_selectedCategory!).requiresMeatDetails) {
      return _meatItems.fold(0, (sum, item) => sum + item.totalPrice);
    }
    return _amount;
  }

  bool get _canSave {
    if (_selectedCategory == null) return false;
    if (_totalAmount <= 0) return false;

    final category = Category.getByType(_selectedCategory!);
    
    // For meat categories, need meat items with supplier
    if (category.requiresMeatDetails) {
      if (_meatItems.isEmpty) return false;
      // Meat items must have supplier set
      if (_meatItems.first.supplier == null) return false;
      
      // For meat with "Belum Lunas", must fill remaining amount
      if (_paymentStatus == 'unpaid' && _remainingAmount <= 0) {
        return false;
      }
    }
    
    // For Pelanggan RDFF, need customer name
    if (_selectedCategory == CategoryType.pelangganRdff && _customerName.isEmpty) {
      return false;
    }

    // For Supplier Daging, need supplier name from meat items
    if (_selectedCategory == CategoryType.supplierDebt && (_meatItems.isEmpty || _meatItems.first.supplier == null)) {
      return false;
    }

    // For Pelanggan RDFF with "Belum Lunas", must fill remaining amount
    if (_selectedCategory == CategoryType.pelangganRdff && 
        _paymentStatus == 'unpaid' && 
        _remainingAmount <= 0) {
      return false;
    }

    // For Supplier Daging with "Belum Lunas", must fill remaining amount
    if (_selectedCategory == CategoryType.supplierDebt && 
        _paymentStatus == 'unpaid' && 
        _remainingAmount <= 0) {
      return false;
    }

    return true;
  }

  Future<void> _saveTransaction() async {
    if (!_canSave) return;

    HapticHelper.success();

    final memberProvider = context.read<MemberProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final arisanProvider = context.read<ArisanProvider>();

    final transaction = Transaction(
      memberId: memberProvider.selectedMember!.id,
      type: _selectedType,
      category: _selectedCategory!,
      amount: _totalAmount,
      note: _note.isEmpty ? null : _note,
      meatItems: _meatItems.isEmpty ? null : _meatItems,
      customerId: _selectedCategory == CategoryType.pelangganRdff ? _customerName : null,
      supplierId: (_selectedCategory == CategoryType.supplierDebt || Category.getByType(_selectedCategory!).requiresMeatDetails) 
          ? (_meatItems.isNotEmpty ? _meatItems.first.supplier : null)
          : null,
      arisanId: _selectedCategory == CategoryType.arisan ? _selectedArisanId : null,
      paymentStatus: (_selectedCategory == CategoryType.pelangganRdff || Category.getByType(_selectedCategory!).requiresMeatDetails) ? _paymentStatus : null,
      remainingAmount: (_selectedCategory == CategoryType.pelangganRdff || Category.getByType(_selectedCategory!).requiresMeatDetails)
        ? (_paymentStatus == 'unpaid' ? _remainingAmount : 0)
        : null,
    );

    await transactionProvider.addTransaction(transaction);

    // If this is an arisan transaction, also record it in ArisanProvider
    if (_selectedCategory == CategoryType.arisan && _selectedArisanId != null) {
      final arisanPayment = ArisanPayment(
        arisanId: _selectedArisanId!,
        payerMemberId: memberProvider.selectedMember!.id,
        amount: _totalAmount,
        paymentDate: _arisanPaymentDate ?? DateTime.now(),
      );
      arisanProvider.addArisanPayment(_selectedArisanId!, arisanPayment);
    }

    // Show success animation
    if (mounted) {
      await _showSuccessDialog();
      Navigator.pop(context);
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SuccessDialog(amount: _totalAmount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();
    final selectedMember = memberProvider.selectedMember;

    if (selectedMember == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final requiresMeatDetails = _selectedCategory != null &&
        Category.getByType(_selectedCategory!).requiresMeatDetails;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // MAIN CONTENT
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // APP BAR
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    HapticHelper.light();
                    Navigator.pop(context);
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(
                    left: 60,
                    bottom: 16,
                  ),
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isHeaderCollapsed ? 1.0 : 0.0,
                    child: Text(
                      'Catat Transaksi',
                      style: AppTypography.headingMedium,
                    ),
                  ),
                  background: Padding(
                    padding: EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      top: 60,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeTransition(
                          opacity: _headerAnimation,
                          child: Text(
                            'Transaksi Keuangan Harian',
                            style: AppTypography.displayMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeTransition(
                          opacity: _headerAnimation,
                          child: Text(
                            DateHelper.formatDateLong(DateTime.now()),
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // CONTENT
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MEMBER SELECTOR
                      _SectionLabel(
                        icon: Icons.person_rounded,
                        label: 'Pilih Anggota',
                      ),
                      SizedBox(height: AppSpacing.md),
                      const MemberSelector(),

                      SizedBox(height: AppSpacing.xxl),

                      // TRANSACTION TYPE
                      _SectionLabel(
                        icon: Icons.swap_horiz_rounded,
                        label: 'Jenis Transaksi',
                      ),
                      SizedBox(height: AppSpacing.md),
                      TransactionTypeToggle(
                        selectedType: _selectedType,
                        onChanged: _onTypeChanged,
                      ),

                      SizedBox(height: AppSpacing.xxl),

                      // CATEGORY
                      _SectionLabel(
                        icon: Icons.category_rounded,
                        label: 'Kategori',
                      ),
                      SizedBox(height: AppSpacing.md),
                      CategoryGrid(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: _onCategorySelected,
                        transactionType: _selectedType,
                      ),

                      SizedBox(height: AppSpacing.xxl),

                      // MEAT DETAILS (if category is meat)
                      if (requiresMeatDetails) ...[
                        // MEAT DETAILS
                        _SectionLabel(
                          icon: Icons.shopping_bag_rounded,
                          label: 'Detail Potongan Daging',
                        ),
                        SizedBox(height: AppSpacing.md),
                        MeatDetailForm(
                          meatItems: _meatItems,
                          onChanged: _onMeatItemsChanged,
                          category: _selectedCategory!,
                          paymentStatus: _paymentStatus,
                          onPaymentStatusChanged: (status) {
                            setState(() {
                              _paymentStatus = status;
                              if (status == 'lunas') {
                                _remainingAmount = 0;
                              }
                            });
                          },
                          remainingAmount: _remainingAmount,
                          onRemainingAmountChanged: (amount) {
                            setState(() => _remainingAmount = amount);
                          },
                        ),
                        SizedBox(height: AppSpacing.xxl),
                      ],

                      // ARISAN SELECTION
                      if (_selectedCategory == CategoryType.arisan) ...[
                        _SectionLabel(
                          icon: Icons.savings_rounded,
                          label: 'Pilih Arisan',
                        ),
                        SizedBox(height: AppSpacing.md),
                        Consumer<ArisanProvider>(
                          builder: (context, arisanProvider, _) {
                            final activeArisans = arisanProvider.getActiveArisans();
                            
                            return Column(
                              children: [
                                if (activeArisans.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(AppConstants.spacingL),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardBackground,
                                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 48,
                                          color: AppColors.textSecondary.withOpacity(0.3),
                                        ),
                                        SizedBox(height: AppSpacing.md),
                                        Text(
                                          'Belum ada arisan aktif',
                                          style: AppTypography.bodyMedium.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFFE8E8E8)),
                                          borderRadius: BorderRadius.circular(AppConstants.radiusL),
                                        ),
                                        child: DropdownButton<String>(
                                          value: _selectedArisanId,
                                          hint: Text(
                                            'Pilih arisan',
                                            style: AppTypography.bodyMedium.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          isExpanded: true,
                                          underline: const SizedBox.shrink(),
                                          items: activeArisans.map((arisan) {
                                            return DropdownMenuItem<String>(
                                              value: arisan.id,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: AppConstants.spacingM,
                                                  vertical: AppConstants.spacingS,
                                                ),
                                                child: Text(
                                                  arisan.name,
                                                  style: AppTypography.bodyMedium,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                _selectedArisanId = value;
                                                _arisanPaymentDate = null;
                                              });
                                            }
                                          },
                                          padding: const EdgeInsets.only(
                                            left: AppConstants.spacingM,
                                            right: AppConstants.spacingM,
                                          ),
                                        ),
                                      ),
                                      // Arisan detail form (if selected)
                                      if (_selectedArisanId != null) ...[
                                        SizedBox(height: AppSpacing.lg),
                                        _SectionLabel(
                                          icon: Icons.calendar_today_rounded,
                                          label: 'Tanggal Pembayaran',
                                        ),
                                        SizedBox(height: AppSpacing.md),
                                        GestureDetector(
                                          onTap: () async {
                                            final pickedDate = await showDatePicker(
                                              context: context,
                                              initialDate: _arisanPaymentDate ?? DateTime.now(),
                                              firstDate: DateTime(2020),
                                              lastDate: DateTime.now().add(const Duration(days: 365)),
                                            );
                                            if (pickedDate != null) {
                                              setState(() => _arisanPaymentDate = pickedDate);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(AppConstants.spacingM),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: const Color(0xFFE8E8E8)),
                                              borderRadius: BorderRadius.circular(AppConstants.radiusL),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  _arisanPaymentDate != null
                                                      ? '${_arisanPaymentDate!.day}/${_arisanPaymentDate!.month}/${_arisanPaymentDate!.year}'
                                                      : 'Pilih tanggal pembayaran',
                                                  style: AppTypography.bodyMedium.copyWith(
                                                    color: _arisanPaymentDate != null
                                                        ? AppColors.textPrimary
                                                        : AppColors.textSecondary,
                                                  ),
                                                ),
                                                const Icon(Icons.calendar_today_outlined),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: AppSpacing.lg),
                                        _SectionLabel(
                                          icon: Icons.repeat_rounded,
                                          label: 'Durasi Siklus',
                                        ),
                                        SizedBox(height: AppSpacing.md),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: const Color(0xFFE8E8E8)),
                                            borderRadius: BorderRadius.circular(AppConstants.radiusL),
                                          ),
                                          child: DropdownButton<int>(
                                            value: _arisanDurationMonths,
                                            isExpanded: true,
                                            underline: const SizedBox.shrink(),
                                            items: List.generate(12, (i) => i + 1).map((month) {
                                              return DropdownMenuItem<int>(
                                                value: month,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: AppConstants.spacingM,
                                                    vertical: AppConstants.spacingS,
                                                  ),
                                                  child: Text(
                                                    month == 1 ? '1 bulan' : '$month bulan',
                                                    style: AppTypography.bodyMedium,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() => _arisanDurationMonths = value);
                                              }
                                            },
                                            padding: const EdgeInsets.only(
                                              left: AppConstants.spacingM,
                                              right: AppConstants.spacingM,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: AppSpacing.lg),
                                        // INFO: Calculated total
                                        Container(
                                          padding: const EdgeInsets.all(AppConstants.spacingL),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                            border: Border.all(
                                              color: AppColors.primary.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Total Siklus',
                                                style: AppTypography.labelSmall.copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: AppConstants.spacingS),
                                              Builder(
                                                builder: (context) {
                                                  final daysInCycle = _arisanDurationMonths * 30;
                                                  final dailyAmount = _amount;
                                                  final totalCycle = dailyAmount * daysInCycle;
                                                  return Text(
                                                    'Rp ${(totalCycle).toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                                                    style: AppTypography.headingSmall.copyWith(
                                                      color: AppColors.primary,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: AppConstants.spacingS),
                                              Text(
                                                '$_arisanDurationMonths bulan × 30 hari = ${_arisanDurationMonths * 30} pembayaran',
                                                style: AppTypography.bodySmall.copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: AppSpacing.xxl),
                      ],

                      // PELANGGAN RDFF PAYMENT STATUS & NAME
                      if (_selectedCategory == CategoryType.pelangganRdff) ...[
                        _SectionLabel(
                          icon: Icons.person_rounded,
                          label: 'Nama Pelanggan',
                        ),
                        SizedBox(height: AppSpacing.md),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE8E8E8)),
                            borderRadius: BorderRadius.circular(AppConstants.radiusL),
                          ),
                          child: DropdownButton<String>(
                            value: _customerName.isEmpty ? null : _customerName,
                            hint: Text(
                              'Pilih nama pelanggan',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            isExpanded: true,
                            underline: const SizedBox.shrink(),
                            items: DefaultCustomers.customerNames.map((name) {
                              return DropdownMenuItem<String>(
                                value: name,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.spacingM,
                                    vertical: AppConstants.spacingS,
                                  ),
                                  child: Text(
                                    name,
                                    style: AppTypography.bodyMedium,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _customerName = value);
                              }
                            },
                            padding: const EdgeInsets.only(
                              left: AppConstants.spacingM,
                              right: AppConstants.spacingM,
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        _SectionLabel(
                          icon: Icons.receipt_rounded,
                          label: 'Status Pembayaran',
                        ),
                        SizedBox(height: AppSpacing.md),
                        Column(
                          children: [
                            _PaymentStatusTile(
                              isSelected: _paymentStatus == 'lunas',
                              title: 'Lunas',
                              subtitle: 'Pembayaran selesai',
                              onTap: () {
                                setState(() {
                                  _paymentStatus = 'lunas';
                                  _remainingAmount = 0;
                                });
                              },
                            ),
                            SizedBox(height: AppSpacing.md),
                            _PaymentStatusTile(
                              isSelected: _paymentStatus == 'unpaid',
                              title: 'Belum Lunas',
                              subtitle: 'Ada sisa pembayaran',
                              onTap: () {
                                setState(() => _paymentStatus = 'unpaid');
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xxl),
                      ],



                      // AMOUNT INPUT
                      if (!requiresMeatDetails && _selectedCategory != null) ...[
                        _SectionLabel(
                          icon: Icons.payments_rounded,
                          label: _selectedCategory == CategoryType.arisan ? 'Nominal Per Hari' : 'Nominal',
                        ),
                        SizedBox(height: AppSpacing.md),
                        AmountInput(
                          amount: _amount,
                          onChanged: _onAmountChanged,
                        ),
                        SizedBox(height: AppSpacing.xxl),
                      ],

                      // REMAINING AMOUNT INPUT (if unpaid)
                      if (_selectedCategory == CategoryType.pelangganRdff && _paymentStatus == 'unpaid') ...[
                        _SectionLabel(
                          icon: Icons.money_off_rounded,
                          label: 'Jumlah Sisa (Rp)',
                        ),
                        SizedBox(height: AppSpacing.md),
                        TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _remainingAmount = double.tryParse(value) ?? 0;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: '0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusL,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxl),
                      ],

                      // NOTE
                      if (_selectedCategory != null) ...[
                        _SectionLabel(
                          icon: Icons.notes_rounded,
                          label: 'Catatan (Opsional)',
                        ),
                        SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _noteController,
                          onChanged: (value) => _note = value,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Tambahkan catatan...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusL,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 120), // Space for footer
                    ],
                  ),
                ),
              ),
            ],
          ),

          // STICKY FOOTER
          if (_selectedCategory != null)
            StickyTotalFooter(
              total: _totalAmount,
              canSave: _canSave,
              onSave: _saveTransaction,
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTypography.headingSmall,
        ),
      ],
    );
  }
}

class _SuccessDialog extends StatefulWidget {
  final double amount;

  const _SuccessDialog({required this.amount});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.all(AppConstants.spacingXL),
          padding: const EdgeInsets.all(AppConstants.spacingXL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SUCCESS ICON
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.incomeGradient,
                  shape: BoxShape.circle,
                ),
                child: ScaleTransition(
                  scale: _checkAnimation,
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.lg),

              Text(
                'Transaksi Berhasil! 🎉',
                style: AppTypography.headingMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.spacingS),

              Text(
                'Data keuangan Anda telah tersimpan',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Payment Status Tile Widget
class _PaymentStatusTile extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentStatusTile({
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
          color:
              isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
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
