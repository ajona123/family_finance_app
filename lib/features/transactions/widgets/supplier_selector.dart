import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '';import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/models/category.dart';

class SupplierSelector extends StatefulWidget {
  final CategoryType category;
  final String? selectedSupplier;
  final ValueChanged<String> onSupplierSelected;

  const SupplierSelector({
    super.key,
    required this.category,
    this.selectedSupplier,
    required this.onSupplierSelected,
  });

  @override
  State<SupplierSelector> createState() => _SupplierSelectorState();
}

class _SupplierSelectorState extends State<SupplierSelector> {
  late List<String> suppliers;

  @override
  void initState() {
    super.initState();
    suppliers = _getSuppliers();
  }

  List<String> _getSuppliers() {
    if (widget.category == CategoryType.meatLocal) {
      return ['Ucup', 'Bewok', 'Miki'];
    } else if (widget.category == CategoryType.meatImport) {
      return ['Nasruloh', 'Alan'];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Supplier',
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 2.5,
          ),
          itemCount: suppliers.length,
          itemBuilder: (context, index) {
            final supplier = suppliers[index];
            final isSelected = widget.selectedSupplier == supplier;

            return GestureDetector(
              onTap: () {
                HapticHelper.selection();
                widget.onSupplierSelected(supplier);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2.5 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    supplier,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}



