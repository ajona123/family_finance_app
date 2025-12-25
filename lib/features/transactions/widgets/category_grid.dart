import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/models/category.dart';
import '../../../data/models/transaction.dart';
import '../../../data/providers/member_provider.dart';

class CategoryGrid extends StatelessWidget {
  final CategoryType? selectedCategory;
  final ValueChanged<CategoryType> onCategorySelected;
  final TransactionType transactionType;

  const CategoryGrid({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
    required this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    // Get selected member from provider
    final memberProvider = context.read<MemberProvider>();
    final selectedMember = memberProvider.selectedMember;
    final isRDFF = selectedMember?.name == 'PD RDFF';

    // Filter categories based on selected member and transaction type
    final availableCategories = Category.all.where((category) {
      // If RDFF
      if (isRDFF) {
        // For income: Pelanggan, Savings, Arisan, Other (NO meat)
        if (transactionType == TransactionType.income) {
          return category.type == CategoryType.pelangganRdff ||
              category.type == CategoryType.savings ||
              category.type == CategoryType.arisan ||
              category.type == CategoryType.other;
        }
        // For expense: All RDFF categories including meat
        return selectedMember!.allowedCategories.contains(category.type);
      }
      
      // For other members: exclude meat categories and pelanggan RDFF
      if (category.type == CategoryType.meatLocal ||
          category.type == CategoryType.meatImport ||
          category.type == CategoryType.pelangganRdff) {
        return false;
      }
      return true;
    }).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: availableCategories.length,
      itemBuilder: (context, index) {
        final category = availableCategories[index];
        final isSelected = selectedCategory == category.type;

        return _CategoryItem(
          key: ValueKey('category_${category.type.name}'),
          category: category,
          isSelected: isSelected,
          onTap: () {
            HapticHelper.selection();
            onCategorySelected(category.type);
          },
        );
      },
    );
  }
}

class _CategoryItem extends StatefulWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isSelected ? AppColors.primary : AppColors.border,
            width: widget.isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.primary.withOpacity(0.15)
                      : widget.category.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.category.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.category.name,
                style: AppTypography.labelMedium.copyWith(
                  color: widget.isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: widget.isSelected 
                      ? FontWeight.bold 
                      : FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

