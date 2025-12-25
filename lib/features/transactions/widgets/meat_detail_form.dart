import 'package:flutter/material.dart';
import '../../../data/models/category.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/models/meat_item.dart';

class MeatDetailForm extends StatefulWidget {
  final List<MeatItem> meatItems;
  final ValueChanged<List<MeatItem>> onChanged;
  final CategoryType category; // Kategori untuk determine suppliers
  final String paymentStatus;
  final ValueChanged<String> onPaymentStatusChanged;
  final double remainingAmount;
  final ValueChanged<double> onRemainingAmountChanged;

  const MeatDetailForm({
    super.key,
    required this.meatItems,
    required this.onChanged,
    required this.category,
    required this.paymentStatus,
    required this.onPaymentStatusChanged,
    required this.remainingAmount,
    required this.onRemainingAmountChanged,
  });

  @override
  State<MeatDetailForm> createState() => _MeatDetailFormState();
}

class _MeatDetailFormState extends State<MeatDetailForm> {
  void _addMeatItem() {
    if (widget.meatItems.length >= AppConstants.maxMeatItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maksimal ${AppConstants.maxMeatItems} item'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticHelper.medium();
    
    // Show supplier selector dialog
    _showSupplierDialog();
  }

  void _removeMeatItem(int index) {
    HapticHelper.heavy();
    final items = List<MeatItem>.from(widget.meatItems);
    items.removeAt(index);
    widget.onChanged(items);
  }

  void _updateMeatItem(int index, MeatItem item) {
    final items = List<MeatItem>.from(widget.meatItems);
    items[index] = item;
    widget.onChanged(items);
  }

  void _showSupplierDialog() {
    final suppliers = widget.category == CategoryType.meatLocal
        ? ['Ucup', 'Bewok', 'Miki']
        : ['Nasruloh', 'Alan'];

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
              // HEADER
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
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Pilih Supplier',
                      style: AppTypography.headingSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // SUPPLIER BUTTONS
              ...suppliers.map((supplier) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _createAndAddMeatItem(supplier);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingL,
                        vertical: AppConstants.spacingM,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingM),
                          Expanded(
                            child: Text(
                              supplier,
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: AppConstants.spacingL),

              // CANCEL BUTTON
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFFE8E8E8),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingXL,
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
            ],
          ),
        ),
      ),
    );
  }

  void _createAndAddMeatItem(String supplier) {
    final newItem = MeatItem(
      cutName: AppConstants.meatCuts.first,
      weight: 1.0,
      pricePerKg: 0,
      supplier: supplier,
    );

    widget.onChanged([...widget.meatItems, newItem]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // MEAT ITEMS LIST
        ...widget.meatItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Padding(
            key: ValueKey('meat_${item.id}'),
            padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
            child: _MeatItemCard(
              key: ValueKey(item.id),
              item: item,
              index: index,
              onUpdate: (updatedItem) => _updateMeatItem(index, updatedItem),
              onRemove: () => _removeMeatItem(index),
            ),
          );
        }),

        // ADD BUTTON
        OutlinedButton.icon(
          onPressed: _addMeatItem,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            widget.meatItems.isEmpty
                ? 'Tambah Potongan Daging'
                : 'Tambah Potongan Lagi',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(
              color: AppColors.primary.withOpacity(0.5),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
        ),

        // PAYMENT STATUS (for meat items)
        if (widget.meatItems.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacingXL),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Pembayaran',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingM),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onPaymentStatusChanged('lunas'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingM,
                            vertical: AppConstants.spacingM,
                          ),
                          decoration: BoxDecoration(
                            color: widget.paymentStatus == 'lunas'
                                ? AppColors.success.withOpacity(0.2)
                                : Colors.transparent,
                            border: Border.all(
                              color: widget.paymentStatus == 'lunas'
                                  ? AppColors.success
                                  : const Color(0xFFE8E8E8),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                          child: Text(
                            'Lunas',
                            textAlign: TextAlign.center,
                            style: AppTypography.labelMedium.copyWith(
                              color: widget.paymentStatus == 'lunas'
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onPaymentStatusChanged('unpaid'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingM,
                            vertical: AppConstants.spacingM,
                          ),
                          decoration: BoxDecoration(
                            color: widget.paymentStatus == 'unpaid'
                                ? AppColors.warning.withOpacity(0.2)
                                : Colors.transparent,
                            border: Border.all(
                              color: widget.paymentStatus == 'unpaid'
                                  ? AppColors.warning
                                  : const Color(0xFFE8E8E8),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                          child: Text(
                            'Belum Lunas',
                            textAlign: TextAlign.center,
                            style: AppTypography.labelMedium.copyWith(
                              color: widget.paymentStatus == 'unpaid'
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // REMAINING AMOUNT (if unpaid)
                if (widget.paymentStatus == 'unpaid') ...[
                  const SizedBox(height: AppConstants.spacingL),
                  Text(
                    'Sisa Pembayaran (Rp)',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
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
                    onChanged: (value) {
                      widget.onRemainingAmountChanged(double.tryParse(value) ?? 0);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient.scale(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Keseluruhan',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.meatItems.length} potongan',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: widget.meatItems.fold(
                      0,
                          (sum, item) => (sum ?? 0) + item.totalPrice,
                    ),
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Text(
                      CurrencyFormatter.format(value),
                      style: AppTypography.headingMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MeatItemCard extends StatefulWidget {
  final MeatItem item;
  final int index;
  final ValueChanged<MeatItem> onUpdate;
  final VoidCallback onRemove;

  const _MeatItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<_MeatItemCard> createState() => _MeatItemCardState();
}

class _MeatItemCardState extends State<_MeatItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late TextEditingController _weightController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _weightController = TextEditingController(
      text: widget.item.weight.toStringAsFixed(2),
    );
    _priceController = TextEditingController(
      text: widget.item.pricePerKg > 0
          ? widget.item.pricePerKg.toStringAsFixed(0)
          : '',
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _weightController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _updateCutName(String? value) {
    if (value != null) {
      widget.onUpdate(widget.item.copyWith(cutName: value));
    }
  }

  void _updateWeight(String value) {
    final weight = double.tryParse(value) ?? 0;
    widget.onUpdate(widget.item.copyWith(weight: weight));
  }

  void _updatePrice(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    final price = double.tryParse(cleanValue) ?? 0;
    widget.onUpdate(widget.item.copyWith(pricePerKg: price));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primaryDark.withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusL),
                  topRight: Radius.circular(AppConstants.radiusL),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${widget.index + 1}',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // SUPPLIER BADGE
                  if (widget.item.supplier != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        widget.item.supplier!,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: AppColors.error,
                    iconSize: 20,
                  ),
                ],
              ),
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CUT NAME DROPDOWN
                  Text(
                    'Jenis Potongan',
                    style: AppTypography.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: widget.item.cutName,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        items: AppConstants.meatCuts.map((cut) {
                          return DropdownMenuItem(
                            value: cut,
                            child: Text(
                              cut,
                              style: AppTypography.bodyMedium,
                            ),
                          );
                        }).toList(),
                        onChanged: _updateCutName,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingM),

                  // WEIGHT & PRICE
                  Row(
                    children: [
                      // WEIGHT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Berat (kg)',
                              style: AppTypography.labelSmall,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _weightController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              decoration: InputDecoration(
                                hintText: '0.00',
                                prefixIcon: const Icon(Icons.scale_rounded),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radiusM,
                                  ),
                                ),
                              ),
                              onChanged: _updateWeight,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: AppConstants.spacingM),

                      // PRICE PER KG
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Harga/kg',
                              style: AppTypography.labelSmall,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                hintText: '0',
                                prefixText: 'Rp ',
                                prefixIcon: const Icon(
                                  Icons.payments_rounded,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radiusM,
                                  ),
                                ),
                              ),
                              onChanged: _updatePrice,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacingM),

                  // TOTAL
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.income.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.income,
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: widget.item.totalPrice),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Text(
                              CurrencyFormatter.format(value),
                              style: AppTypography.headingSmall.copyWith(
                                color: AppColors.income,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
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