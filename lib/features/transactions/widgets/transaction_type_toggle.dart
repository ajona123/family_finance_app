import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/transaction.dart';

class TransactionTypeToggle extends StatefulWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onChanged;

  const TransactionTypeToggle({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  State<TransactionTypeToggle> createState() => _TransactionTypeToggleState();
}

class _TransactionTypeToggleState extends State<TransactionTypeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: widget.selectedType == TransactionType.income ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(TransactionTypeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedType != oldWidget.selectedType) {
      if (widget.selectedType == TransactionType.income) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // ANIMATED INDICATOR
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_controller.value * (MediaQuery.of(context).size.width * 0.5 - 12), 0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5 - 12,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: widget.selectedType == TransactionType.expense
                        ? AppColors.expenseGradient
                        : AppColors.incomeGradient,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusM,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.selectedType == TransactionType.expense
                            ? AppColors.expense.withOpacity(0.3)
                            : AppColors.income.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // BUTTONS
          Row(
            children: [
              Expanded(
                child: _ToggleButton(
                  label: 'Pengeluaran',
                  icon: Icons.arrow_upward_rounded,
                  isSelected: widget.selectedType == TransactionType.expense,
                  onTap: () => widget.onChanged(TransactionType.expense),
                ),
              ),
              Expanded(
                child: _ToggleButton(
                  label: 'Pemasukan',
                  icon: Icons.arrow_downward_rounded,
                  isSelected: widget.selectedType == TransactionType.income,
                  onTap: () => widget.onChanged(TransactionType.income),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

