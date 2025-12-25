import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/member_provider.dart';

class PaySupplierDebtScreen extends StatefulWidget {
  final String? initialSupplierName;

  const PaySupplierDebtScreen({
    super.key,
    this.initialSupplierName,
  });

  @override
  State<PaySupplierDebtScreen> createState() => _PaySupplierDebtScreenState();
}

class _PaySupplierDebtScreenState extends State<PaySupplierDebtScreen> {
  String? _selectedSupplier;
  double _paymentAmount = 0;
  final _paymentController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Set initial supplier jika ada
    if (widget.initialSupplierName != null) {
      _selectedSupplier = widget.initialSupplierName;
    }
  }

  @override
  void dispose() {
    _paymentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_selectedSupplier == null || _paymentAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih supplier dan masukkan nominal pembayaran'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    HapticHelper.medium();

    try {
      final memberProvider = context.read<MemberProvider>();
      final transactionProvider = context.read<TransactionProvider>();

      if (memberProvider.selectedMember == null) {
        throw Exception('Pilih anggota terlebih dahulu');
      }

      final result = await transactionProvider.processSupplierPayment(
        memberId: memberProvider.selectedMember!.id,
        supplierId: _selectedSupplier!,
        paymentAmount: _paymentAmount,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      if (mounted) {
        if (result.success) {
          HapticHelper.success();

          // Show success dialog
          _showSuccessDialog(result);

          // Reset form
          _paymentController.clear();
          _noteController.clear();
          setState(() {
            _selectedSupplier = null;
            _paymentAmount = 0;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      HapticHelper.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSuccessDialog(SupplierPaymentResult result) {
    final displayAmount = result.paymentAmount ?? 0;
    final displaySupplier = _selectedSupplier ?? 'Supplier';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.incomeGradient,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),
              Text(
                'Pembayaran Berhasil!',
                style: AppTypography.headingSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'Rp ${displayAmount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                style: AppTypography.displaySmall.copyWith(
                  color: AppColors.income,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                'ke $displaySupplier',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (result.fullyPaidSuppliers.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacingL),
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: BoxDecoration(
                    color: AppColors.income.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.celebration_rounded,
                        color: Color(0xFF10B981),
                        size: 24,
                      ),
                      const SizedBox(width: AppConstants.spacingM),
                      Expanded(
                        child: Text(
                          'Hutang ke $displaySupplier sudah LUNAS!',
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppConstants.spacingXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Auto balik ke home
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.income,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingM,
                    ),
                  ),
                  child: Text(
                    'Selesai',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pembayaran Hutang Supplier',
          style: AppTypography.headingMedium,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFO BOX
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              decoration: BoxDecoration(
                color: AppColors.income.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                border: Border.all(
                  color: AppColors.income.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_rounded,
                    color: AppColors.income,
                    size: 24,
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: Text(
                      'Catat pembayaran hutang ke supplier',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.income,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // SUPPLIER SELECTION
            Text(
              'Nama Supplier',
              style: AppTypography.labelMedium,
            ),
            const SizedBox(height: AppConstants.spacingM),
            TextField(
              controller: TextEditingController(text: _selectedSupplier ?? ''),
              decoration: InputDecoration(
                hintText: 'Masukkan nama supplier',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
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
                setState(() => _selectedSupplier = value);
              },
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // PAYMENT AMOUNT
            Text(
              'Nominal Pembayaran (Rp)',
              style: AppTypography.labelMedium,
            ),
            const SizedBox(height: AppConstants.spacingM),
            TextField(
              controller: _paymentController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _paymentAmount = double.tryParse(value) ?? 0;
                });
              },
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
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
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // NOTE
            Text(
              'Catatan (Opsional)',
              style: AppTypography.labelMedium,
            ),
            const SizedBox(height: AppConstants.spacingM),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
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
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // SUMMARY
            if (_paymentAmount > 0) ...[
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingS),
                        Text(
                          'Rp ${_paymentAmount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                          style: AppTypography.headingSmall.copyWith(
                            color: AppColors.income,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      decoration: BoxDecoration(
                        color: AppColors.income.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.income,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),
            ],

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.income,
                  disabledBackgroundColor: AppColors.income.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Catat Pembayaran',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

