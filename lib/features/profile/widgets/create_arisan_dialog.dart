import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '';import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/arisan.dart';
import '../../../data/providers/arisan_provider.dart';
import '../../../data/providers/member_provider.dart';

class CreateArisanDialog extends StatefulWidget {
  const CreateArisanDialog({super.key});

  @override
  State<CreateArisanDialog> createState() => _CreateArisanDialogState();
}

class _CreateArisanDialogState extends State<CreateArisanDialog> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _cycleController;
  DateTime _selectedStartDate = DateTime.now();
  Set<String> _selectedParticipants = {};
  String? _selectedOrganizerError;
  String? _nameError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();
    _cycleController = TextEditingController(text: '3');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _cycleController.dispose();
    super.dispose();
  }

  void _validateAndCreate() {
    setState(() {
      _nameError = null;
      _amountError = null;
      _selectedOrganizerError = null;
    });

    bool isValid = true;

    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Nama arisan tidak boleh kosong');
      isValid = false;
    }

    if (_amountController.text.trim().isEmpty) {
      setState(() => _amountError = 'Jumlah setoran tidak boleh kosong');
      isValid = false;
    } else {
      try {
        int.parse(_amountController.text.replaceAll('.', ''));
      } catch (e) {
        setState(() => _amountError = 'Format angka tidak valid');
        isValid = false;
      }
    }

    if (_selectedParticipants.isEmpty) {
      setState(() => _selectedOrganizerError = 'Pilih minimal 1 peserta');
      isValid = false;
    }

    if (!isValid) return;

    final arisanProvider = context.read<ArisanProvider>();
    final memberProvider = context.read<MemberProvider>();
    final currentMemberId = memberProvider.selectedMember?.id ?? 'unknown';

    final arisan = Arisan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      memberId: currentMemberId,
      startDate: _selectedStartDate,
      cycleLengthMonths: int.parse(_cycleController.text),
      monthlyAmount: double.parse(_amountController.text.replaceAll('.', '')),
      participantMemberIds: _selectedParticipants.toList(),
      userPosition: _selectedParticipants.toList().indexOf(currentMemberId) + 1,
      paymentHistory: [],
      status: 'active',
      createdAt: DateTime.now(),
    );

    arisanProvider.addArisan(arisan);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Arisan berhasil dibuat!'),
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
                'Buat Arisan Baru',
                style: AppTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // NAMA ARISAN
              Text(
                'Nama Arisan',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Arisan Keluarga',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  errorText: _nameError,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // JUMLAH SETORAN
              Text(
                'Jumlah Per Bulan (Rp)',
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
                  // Format with dots
                  if (value.isNotEmpty) {
                    final unformatted = value.replaceAll('.', '');
                    final formatted = CurrencyFormatter.formatInput(unformatted);
                    _amountController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // TANGGAL MULAI
              Text(
                'Tanggal Mulai',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedStartDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    setState(() => _selectedStartDate = pickedDate);
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
                        '${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year}',
                        style: AppTypography.bodyMedium,
                      ),
                      const Icon(Icons.calendar_today_outlined),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // DURASI SIKLUS
              Text(
                'Durasi Siklus (Bulan)',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _cycleController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: 3, 6, 12',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // PESERTA
              Text(
                'Pilih Peserta (${_selectedParticipants.length})',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_selectedOrganizerError != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    _selectedOrganizerError!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              Consumer<MemberProvider>(
                builder: (context, memberProvider, _) {
                  final members = memberProvider.members;
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedOrganizerError != null
                            ? AppColors.error
                            : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final isSelected = _selectedParticipants.contains(member.id);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedParticipants.add(member.id);
                                    } else {
                                      _selectedParticipants.remove(member.id);
                                    }
                                  });
                                },
                              ),
                              Text(member.name),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
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
                      onPressed: _validateAndCreate,
                      child: const Text('Buat Arisan'),
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



