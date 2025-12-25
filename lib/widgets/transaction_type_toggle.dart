import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class TransactionTypeToggle extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const TransactionTypeToggle({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Transaksi',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildToggleButton(
                  context,
                  'Pengeluaran',
                  'pengeluaran',
                  AppTheme.expenseColor,
                ),
              ),
              Expanded(
                child: _buildToggleButton(
                  context,
                  'Pemasukan',
                  'pemasukan',
                  AppTheme.incomeColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(
      BuildContext context,
      String label,
      String value,
      Color color,
      ) {
    final isSelected = selectedType == value;
    return GestureDetector(
      onTap: () => onTypeChanged(value),
      child: AnimatedContainer(
        duration: AppConstants.animationDuration,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}