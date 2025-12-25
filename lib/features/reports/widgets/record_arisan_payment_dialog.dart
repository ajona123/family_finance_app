import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart'
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../data/models/arisan.dart';
import '../../../data/providers/arisan_provider.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/member_provider.dart';

class RecordArisanPaymentDialog extends StatefulWidget {
  final Arisan arisan;

  const RecordArisanPaymentDialog({
    super.key,
    required this.arisan,
  });

  @override
  State<RecordArisanPaymentDialog> createState() =>
      _RecordArisanPaymentDialogState();
}

class _RecordArisanPaymentDialogState extends State<RecordArisanPaymentDialog> {
  late TextEditingController _amountController;
  DateTime _paymentDate = DateTime.now();
  String? _selectedPayerId;
  String? _amountError;
  String? _payerError;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: CurrencyFormatter.formatInput(
        widget.arisan.monthlyAmount.toStringAsFixed(0),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _validateAndSave() {
    setState(() {
      _amountError = null;
      _payerError = null;
    });

    bool isValid = true;

    if (_amountController.text.trim().isEmpty) {
      setState(() => _amountError = 'Jumlah pembayaran tidak boleh kosong');
      isValid = false;
    } else {
      try {
        int.parse(_amountController.text.replaceAll('.', ''));
      } catch (e) {
        setState(() => _amountError = 'Format angka tidak valid');
        isValid = false;
      }
    }

    if (_selectedPayerId == null) {
      setState(() => _payerError = 'Pilih pembayar');
      isValid = false;
    }

    if (!isValid) return;

    final transactionProvider = context.read<TransactionProvider>();
    final arisanProvider = context.read<ArisanProvider>();
    final amount = int.parse(_amountController.text.replaceAll('.', ''));

    // Create transaction
    final transaction = Transaction(
      memberId: _selectedPayerId!,
      type: TransactionType.expense,
      category: CategoryType.arisan,
      amount: amount.toDouble(),
      arisanId: widget.arisan.id,
      note: 'Pembayaran Arisan ${widget.arisan.name}',
      createdAt: _paymentDate,
    );

    // Add transaction
    transactionProvider.addTransaction(transaction);

    // Add payment to arisan
    final payment = ArisanPayment(
      arisanId: widget.arisan.id,
      payerMemberId: _selectedPayerId!,
      amount: amount.toDouble(),
      paymentDate: _paymentDate,
    );
    arisanProvider.addArisanPayment(widget.arisan.id, payment);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembayaran arisan berhasil dicatat!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Text(
                'Catat Pembayaran Arisan',
                style: AppTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.arisan.name,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // PAYER SELECTION
              Text(
                'Pembayar',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_payerError != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    _payerError!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              Consumer<MemberProvider>(
                builder: (context, memberProvider, _) {
                  final participants = memberProvider.members
                      .where((m) => widget.arisan.participantMemberIds.contains(m.id))
                      .toList();

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _payerError != null
                            ? AppColors.error
                            : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedPayerId,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          'Pilih pembayar',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      items: participants
                          .map((member) => DropdownMenuItem(
                            value: member.id,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Text(member.name),
                            ),
                          ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedPayerId = value);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // JUMLAH PEMBAYARAN
              Text(
                'Jumlah Pembayaran (Rp)',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: 300000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  errorText: _amountError,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final unformatted = value.replaceAll('.', '');
                    final formatted =
                        CurrencyFormatter.formatInput(unformatted);
                    _amountController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // TANGGAL PEMBAYARAN
              Text(
                'Tanggal Pembayaran',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _paymentDate,
                    firstDate: widget.arisan.startDate,
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() => _paymentDate = pickedDate);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}',
                        style: AppTypography.bodyMedium,
                      ),
                      const Icon(Icons.calendar_today_outlined),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _validateAndSave,
                      child: const Text('Catat Pembayaran'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


