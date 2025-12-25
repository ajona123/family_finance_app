import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/meat_item.dart';
import '../models/transaction.dart';
import '../widgets/member_selector.dart';
import '../widgets/transaction_type_toggle.dart';
import '../widgets/category_grid.dart';
import '../widgets/meat_detail_form.dart';
import '../widgets/sticky_total_footer.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/currency_formatter.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String? _selectedMember;
  String _transactionType = 'pengeluaran';
  String? _selectedCategory;
  List<MeatItem> _meatItems = [MeatItem(type: 'Daging')];
  final TextEditingController _manualAmountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _showSuccess = false;

  bool get _isMeatCategory =>
      _selectedCategory == 'daging-lokal' ||
          _selectedCategory == 'daging-import';

  double get _totalAmount {
    if (_isMeatCategory) {
      return _meatItems.fold(0.0, (sum, item) => sum + item.total);
    }
    return CurrencyFormatter.parse(_manualAmountController.text);
  }

  bool get _isValid {
    if (_selectedMember == null || _selectedCategory == null) return false;

    if (_isMeatCategory) {
      return _meatItems.any((item) => item.isValid);
    }
    return _totalAmount > 0;
  }

  String get _categoryLabel {
    final category = AppConstants.categories.firstWhere(
          (cat) => cat['id'] == _selectedCategory,
      orElse: () => {'label': ''},
    );
    return category['label']!;
  }

  void _saveTransaction() {
    if (!_isValid) return;

    HapticFeedback.mediumImpact();

    // Create transaction object
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      member: _selectedMember!,
      type: _transactionType,
      category: _selectedCategory!,
      amount: _totalAmount,
      meatItems: _isMeatCategory ? _meatItems : null,
      notes: _notesController.text,
      date: DateTime.now(),
    );

    // Show success animation
    setState(() => _showSuccess = true);

    // Simulate saving and navigate back
    Future.delayed(AppConstants.successDuration, () {
      if (mounted) {
        Navigator.pop(context, transaction);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaksi Keuangan Harian',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            SizedBox(height: 4),
            Text(
              dateFormat.format(now),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Member Selector
                MemberSelector(
                  selectedMember: _selectedMember,
                  onMemberSelected: (member) {
                    setState(() => _selectedMember = member);
                  },
                ),
                SizedBox(height: 24),

                // Transaction Type
                TransactionTypeToggle(
                  selectedType: _transactionType,
                  onTypeChanged: (type) {
                    setState(() => _transactionType = type);
                  },
                ),
                SizedBox(height: 24),

                // Category Grid
                CategoryGrid(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                      // Reset inputs when category changes
                      if (category == 'daging-lokal' || category == 'daging-import') {
                        _meatItems = [MeatItem(type: 'Daging')];
                      } else {
                        _manualAmountController.clear();
                      }
                    });
                  },
                ),
                SizedBox(height: 24),

                // Dynamic Input Area
                if (_selectedCategory != null) ...[
                  if (_isMeatCategory)
                    MeatDetailForm(
                      items: _meatItems,
                      onItemsChanged: (items) {
                        setState(() => _meatItems = items);
                      },
                      categoryLabel: _categoryLabel,
                    )
                  else
                    _buildManualAmountInput(),

                  SizedBox(height: 24),

                  // Notes
                  _buildNotesInput(),
                ],

                SizedBox(height: 120), // Space for sticky footer
              ],
            ),
          ),

          // Sticky Footer
          if (_selectedCategory != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: StickyTotalFooter(
                totalAmount: _totalAmount,
                onSave: _saveTransaction,
                isValid: _isValid,
              ),
            ),

          // Success Overlay
          if (_showSuccess)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: AppTheme.successColor,
                            size: 64,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Transaksi Berhasil Disimpan',
                          style: Theme.of(context).textTheme.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.format(_totalAmount),
                          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildManualAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nominal',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: 12),

        // Quick amount buttons
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppConstants.quickAmounts.map((amount) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _manualAmountController.text = amount.toString();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  border: Border.all(color: AppTheme.borderColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  CurrencyFormatter.formatCompact(amount.toDouble()),
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        SizedBox(height: 12),

        TextField(
          controller: _manualAmountController,
          decoration: InputDecoration(
            hintText: 'Masukkan nominal',
            prefixText: 'Rp ',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catatan (Opsional)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: 12),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: 'Tambahkan catatan...',
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _manualAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}